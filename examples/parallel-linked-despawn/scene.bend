import Base
import ../../src/ecs/execution-lifetime-scope-description.bend as LinkedText
import ./actor.bend as Actor
import ./remover.bend as Remover
import ../../src/ecs/execution-schema-provisioning.bend as Provision
import ./setup.bend as Setup
import ../parallel-relations/failure-message-text.bend as Text
import ../../src/ecs/execution-relation-operation.bend as O
import ../../src/ecs/execution-relation-failure-message.bend as Message
import ../../src/ecs/execution-stream-channel.bend as Channel
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/machine-stream-queue.bend as Queue
import ./initialize.bend as Initialize
import ./scheduled.bend as Scheduled
import ../../src/ecs/world.bend as W
import ../../src/ecs/entity-key.bend as Key
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/dependency-application.bend as App
import ../../src/ecs/execution-parallel-root-application.bend as Root
import ../../src/ecs/execution-command-system.bend as Cmd
import ../../src/ecs/execution-command-local.bend as Local
import ../../src/ecs/execution-command-buffer.bend as Buffer
import ../../src/ecs/execution-command-removed.bend as Removed
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-relation-context.bend as Context
import ../../src/ecs/execution-relation-operation.bend as Operation
import ../../src/ecs/execution-relation-store.bend as Store
import ../../src/ecs/relation-types.bend as T
import ../../src/ecs/execution-lifetime-scope-description.bend as ScopeText
import ../../src/ecs/execution-lifetime-scope-store.bend as ScopeStore
import ../../src/ecs/lifetime-scope.bend as Scope
import ../../src/ecs/chunk-column.bend as Column

type Schema is Data:
  Scene{}
def key(value:Key.Key) -> String:
  match value:
    case Key.EntityKey{index,generation}:U32.show(index) ++ ":" ++ U32.show(generation)
def handle(value:W.Handle<Schema>) -> String:
  match value:
    case W.Handle{namespace,value}:U32.show(namespace) ++ "/" ++ key(value)
def operation(value:Operation.Operation<Schema>) -> String:
  match value:
    case Operation.Relate{source,target}:"relate(" ++ handle(source) ++ "," ++ handle(target) ++ ")"
    case Operation.Unrelate{source}:"unrelate(" ++ handle(source) ++ ")"
    case Operation.Reorder{parent,children}:"reorder(" ++ handle(parent) ++ "," ++ List.show(&2,W.Handle<Schema>,handle,children) ++ ")"
def maybe_session(value:Maybe<&1,Actor.Session>) -> String:
  match value:
    case None{}:"none"
    case Some{Actor.Session{value}}:U32.show(value)
def removed(value:Removed.Removed(Actor.components())) -> String:
  match value:
    case Product.Owner{owner,_}:maybe_session(owner)
def route(value:Layout.Route) -> String:
  match value:
    case Layout.AtLeaf{}:"@"
    case Layout.InLeft{rest}:"L" ++ route(rest)
    case Layout.InRight{rest}:"R" ++ route(rest)
def reason(value:Store.Reason) -> String:
  match value:
    case Store.NamespaceMismatch{}:"namespace-mismatch"
    case Store.OperationRefused{O.HierarchyRequired{}}:"hierarchy-required"
    case Store.OperationRefused{O.RelationError{error}}:Text.error(error)
def receipts(values:List<Buffer.Receipt<Schema,Actor.Session,Removed.Removed(Actor.components())>>) -> String:
  match values:
    case []:""
    case Buffer.RelationPublished{path,Store.Applied{value}} <> rest:"applied:" ++ route(path) ++ ":" ++ operation(value) ++ ";" ++ receipts(rest)
    case Buffer.RelationPublished{path,Store.Refused{value,why}} <> rest:"refused:" ++ route(path) ++ ":" ++ operation(value) ++ "/" ++ reason(why) ++ ";" ++ receipts(rest)
    case Buffer.RelationUndeclared{_,value} <> rest:"undeclared:" ++ operation(value) ++ ";" ++ receipts(rest)
    case Buffer.Applied{entity,previous} <> rest:"component-applied:" ++ handle(entity) ++ "/previous=" ++ maybe_session(previous) ++ ";" ++ receipts(rest)
    case Buffer.Refused{entity,incoming} <> rest:"component-refused:" ++ handle(entity) ++ "/incoming=" ++ maybe_session(incoming) ++ ";" ++ receipts(rest)
    case Buffer.Despawned{entity,owners} <> rest:"despawned:" ++ handle(entity) ++ "/owner=" ++ removed(owners) ++ ";" ++ receipts(rest)
    case Buffer.DespawnRefused{entity} <> rest:"despawn-refused:" ++ handle(entity) ++ ";" ++ receipts(rest)
    case Buffer.LinkedDespawn{entity,status,nested,frames} <> rest:"linked-despawn:" ++ handle(entity) ++ ":" ++ LinkedText.linked_status(status) ++ "{" ++ receipts(nested) ++ "}/frames=" ++ Nat.show(List.length(&2,T.CleanupFrame<Schema>,frames)) ++ ";" ++ receipts(rest)
    case Buffer.Spawned{entity,previous} <> rest:"spawned:" ++ handle(entity) ++ "/previous=" ++ removed(previous) ++ ";" ++ receipts(rest)
    case Buffer.SpawnRefused{entity,bundle,_} <> rest:"spawn-refused:" ++ handle(entity) ++ "/bundle=" ++ removed(bundle) ++ ";" ++ receipts(rest)
    case Buffer.ScopePublished{_,value,status,nested,frames} <> rest:"scope:" ++ ScopeText.operation(~Schema,value) ++ ":" ++ ScopeText.status(status) ++ "{" ++ receipts(nested) ++ "}/frames=" ++ Nat.show(List.length(&2,T.CleanupFrame<Schema>,frames)) ++ ";" ++ receipts(rest)
    case Buffer.ScopeStoreApplied{_,request,result} <> rest:"scope-store:" ++ ScopeText.request(~Schema,request) ++ ":" ++ ScopeText.outcome(~Schema,result) ++ ";" ++ receipts(rest)
def edge(value:T.Edge<Schema>) -> String:
  match value:
    case T.Edge{_,source,target}:key(source) ++ "->" ++ key(target)
def inverse(value:T.Inverse<Schema>) -> String:
  match value:
    case T.Inverse{_,target,sources}:key(target) ++ "<-" ++ List.show(&2,Key.Key,key,sources)
def member(value:Scope.Member) -> String:
  match value:
    case Scope.Member{name,value}:name ++ "/" ++ key(value)
def failure_values(~family:T.Descriptor<Schema>,value:Channel.Store<Message.Message<Schema,family>>) -> List<&2,Message.Message<Schema,family>>:
  match value:
    case Channel.Store{queue,_,_}:Queue.read_generic(Message.Message<Schema,family>,queue,0n)
def maintenance(value:Maybe<&2,Tick.Tick>) -> String:
  match value:
    case None{}:"none"
    case Some{Tick.Tick{epoch,low}}:Nat.show(epoch) ++ ":" ++ U32.show(low)
def channel(~family:T.Descriptor<Schema>,value:Channel.Store<Message.Message<Schema,family>>) -> String:
  match value:
    case Channel.Store{Queue.Queue{_,_,size,dropped,_},older,at}:"retained=" ++ Nat.show(size) ++ ",dropped=" ++ Nat.show(dropped) ++ ",older-through=" ++ Nat.show(older) ++ ",maintained=" ++ maintenance(at)
def graph_value(~family:T.Descriptor<Schema>,owner:Store.Store<Schema,family>,cache:Store.View<Schema,family>) -> String:
  match owner cache:
    case Store.Store{namespace,T.Graph{edges,inverses},+failures,sequence,nextReader} Store.View{cachedNamespace,T.Graph{cachedEdges,cachedInverses},_,_,_}:"namespace=" ++ U32.show(namespace) ++ ",edges=" ++ List.show(&2,T.Edge<Schema>,edge,edges) ++ ",inverse=" ++ List.show(&2,T.Inverse<Schema>,inverse,inverses) ++ ",cache=" ++ U32.show(cachedNamespace) ++ "/" ++ List.show(&2,T.Edge<Schema>,edge,cachedEdges) ++ "/" ++ List.show(&2,T.Inverse<Schema>,inverse,cachedInverses) ++ ",failure-sequence=" ++ Nat.show(sequence) ++ "," ++ channel(~family,failures) ++ ",failure-messages=" ++ List.show(&2,Message.Message<Schema,family>,value => Text.message(Schema,family,value),failure_values(~family,failures)) ++ ",nextReader=" ++ U32.show(nextReader)
def resources(value:Scheduled.Resources(~Schema)) -> String:
  match value:
    case Product.Owner{Product.Owner{Layout.ResourceSlot{Layout.Viewed{parent,parentCache},_},Layout.ResourceSlot{Layout.Viewed{link,linkCache},_}},Product.Owner{Layout.ResourceSlot{Layout.Viewed{ScopeStore.Store{scopeNamespace,members},ScopeStore.View{cachedScopeNamespace,cachedMembers}},_},Layout.ResourceSlot{Layout.Viewed{Actor.Session{resourceSession},cachedSession},_}}}:"parent={" ++ graph_value(~Setup.hierarchy(~Schema),parent,parentCache) ++ "},link={" ++ graph_value(~Setup.link(~Schema),link,linkCache) ++ "},scope=" ++ U32.show(scopeNamespace) ++ "/" ++ List.show(&2,Scope.Member,member,members) ++ ",scope-cache=" ++ U32.show(cachedScopeNamespace) ++ "/" ++ List.show(&2,Scope.Member,member,cachedMembers) ++ ",resource=" ++ U32.show(resourceSession) ++ "/" ++ U32.show(cachedSession)
def cell(value:Maybe<&1,Layout.Viewed<Actor.Session,U32>>) -> String:
  match value:
    case None{}:"none"
    case Some{Layout.Viewed{Actor.Session{owner},cache}}:U32.show(owner) ++ "/" ++ U32.show(cache)
def cells(values:Array<Maybe<&1,Layout.Viewed<Actor.Session,U32>>>) -> String:
  match values:
    case ALeaf{value}:cell(value)
    case ANode{left,right}:"[" ++ cells(left) ++ "," ++ cells(right) ++ "]"
def column(value:Column.Column<Schema,Layout.Viewed<Actor.Session,U32>>) -> String:
  match value:
    case Column.Leaf{values,_}:cells(values)
    case Column.Branch{_,left,right}:"[" ++ column(left) ++ "," ++ column(right) ++ "]"
def components(value:Scheduled.Columns(~Schema)) -> String:
  match value:
    case Product.Owner{Layout.ColumnSlot{value},_}:column(value)
def actor(value:Actor.Owner(~Schema)) -> String:
  match value:
    case Cmd.Owner{Sys.Owner{_,_,_,_,_,Local.Local{Actor.User{_,_,_,Actor.Session{session}},Buffer.Buffer{pending,values},_}}}:"local=" ++ U32.show(session) ++ ",pending=" ++ Nat.show(List.length(&1,Buffer.Entry<Schema,Actor.Session,Removed.Removed(Actor.components())>,pending)) ++ ",receipts=[" ++ receipts(List.reverse(&1,Buffer.Receipt<Schema,Actor.Session,Removed.Removed(Actor.components())>,values)) ++ "]"
def remover(value:Remover.Owner(~Schema)) -> String:
  match value:
    case Cmd.Owner{Sys.Owner{_,_,_,_,_,Local.Local{handle,Buffer.Buffer{pending,values},permission}}}:"despawn-only=" ++ Text.handle(Schema,handle) ++ ",pending=" ++ Nat.show(List.length(&1,Buffer.Entry<Schema,Actor.Session,Removed.Removed(Actor.components())>,pending)) ++ ",receipts=[" ++ receipts(List.reverse(&1,Buffer.Receipt<Schema,Actor.Session,Removed.Removed(Actor.components())>,values)) ++ "]"
def application(value:Scheduled.Bound(~Schema)) -> String:
  match value:
    case Provision.Bound{Context.Bound{_,Root.Scheduled{App.State{W.World{_,_,columns,owners,_,_,_,_,_,_},Product.Owner{author,despawner},_,_,_},_,_,_,_}}}:resources(owners) ++ "|components=" ++ components(columns) ++ "|" ++ actor(author) ++ "|" ++ remover(despawner)
def report(value:Context.RunReport<App.Report<String,String>>) -> String:
  match value:
    case Context.ContextRefused{}:"context-refused"
    case Context.RunReported{App.Finished{_}}:"finished"
    case Context.RunReported{App.Stopped{error,_}}:"stopped:" ++ error
    case Context.RunReported{App.Invalid{_}}:"invalid"
def finished(result:Scheduled.Bound(~Schema) & Context.RunReport<App.Report<String,String>>) -> IO(Unit):
  match result:
    case (bound,status):IO.print(report(status) ++ "|" ++ application(bound))
def initialized(value:Initialize.Initialization<Schema>) -> IO(Unit):
  match value:
    case Initialize.SceneInitialized{_,Scheduled.SceneReady{bound}}:IO.bind(Scheduled.Bound(~Schema) & Context.RunReport<App.Report<String,String>>,Unit,Scheduled.run_once(~Schema,bound),finished)
    case Initialize.SceneInitialized{_,_}:IO.print("registration-refused")
    case Initialize.NodeSetupRefused{_,_,_,_,_,_}:IO.print("entity-setup-refused")
    case Initialize.SchemaSetupRefused{_,_,_,_}:IO.print("schema-refused")
def main() -> IO(Unit):
  initialized(Initialize.create(~Schema,W.factory(),Actor.Session{401},Actor.Session{601}))
