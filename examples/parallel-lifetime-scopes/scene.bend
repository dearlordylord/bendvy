import Base
import ../../src/ecs/execution-lifetime-scope-description.bend as LinkedText
import ./actor.bend as Actor
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
def receipts(values:List<Buffer.Receipt<Schema,Actor.Session,Removed.Removed(Actor.components())>>) -> String:
  match values:
    case []:""
    case Buffer.RelationPublished{_,Store.Applied{value}} <> rest:"applied:" ++ operation(value) ++ ";" ++ receipts(rest)
    case Buffer.RelationPublished{_,Store.Refused{value,_}} <> rest:"refused:" ++ operation(value) ++ ";" ++ receipts(rest)
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
def resources(value:Scheduled.Resources(~Schema)) -> String:
  match value:
    case Product.Owner{Layout.ResourceSlot{Layout.Viewed{Store.Store{namespace,T.Graph{edges,inverses},_,sequence,nextReader},Store.View{cachedNamespace,T.Graph{cachedEdges,cachedInverses}}},_},Product.Owner{Layout.ResourceSlot{Layout.Viewed{ScopeStore.Store{scopeNamespace,members},ScopeStore.View{cachedScopeNamespace,cachedMembers}},_},Layout.ResourceSlot{Layout.Viewed{Actor.Session{resourceSession},cachedSession},_}}}:"namespace=" ++ U32.show(namespace) ++ ",edges=" ++ List.show(&2,T.Edge<Schema>,edge,edges) ++ ",inverse=" ++ List.show(&2,T.Inverse<Schema>,inverse,inverses) ++ ",cache=" ++ U32.show(cachedNamespace) ++ "/" ++ List.show(&2,T.Edge<Schema>,edge,cachedEdges) ++ "/" ++ List.show(&2,T.Inverse<Schema>,inverse,cachedInverses) ++ ",failures=" ++ Nat.show(sequence) ++ ",nextReader=" ++ U32.show(nextReader) ++ ",scope=" ++ U32.show(scopeNamespace) ++ "/" ++ List.show(&2,Scope.Member,member,members) ++ ",scope-cache=" ++ U32.show(cachedScopeNamespace) ++ "/" ++ List.show(&2,Scope.Member,member,cachedMembers) ++ ",resource=" ++ U32.show(resourceSession) ++ "/" ++ U32.show(cachedSession)
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
def application(value:Scheduled.Bound(~Schema)) -> String:
  match value:
    case Context.Bound{_,Root.Scheduled{App.State{W.World{_,_,columns,owners,_,_,_,_,_,_},Product.Owner{author,_},_,_,_},_,_,_,_}}:resources(owners) ++ "|components=" ++ components(columns) ++ "|" ++ actor(author)
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
