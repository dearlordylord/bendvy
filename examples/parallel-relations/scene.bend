import Base
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
def receipt(value:Buffer.Receipt<Schema,Unit,Removed.Removed(Actor.components())>) -> String:
  match value:
    case Buffer.RelationPublished{_,Store.Applied{value}}:"applied:" ++ operation(value)
    case Buffer.RelationPublished{_,Store.Refused{value,_}}:"refused:" ++ operation(value)
    case Buffer.RelationUndeclared{_,value}:"undeclared:" ++ operation(value)
    case Buffer.Applied{_,_}:"component-applied"
    case Buffer.Refused{_,_}:"component-refused"
    case Buffer.Despawned{_,_}:"despawned"
    case Buffer.DespawnRefused{_}:"despawn-refused"
    case Buffer.Spawned{_,_}:"spawned"
    case Buffer.SpawnRefused{_,_,_}:"spawn-refused"
    case Buffer.ScopePublished{_,value,status,receipts,frames}:"scope:" ++ ScopeText.operation(~Schema,value) ++ ":" ++ ScopeText.status(status) ++ ":" ++ Nat.show(List.length(&1,Buffer.Receipt<Schema,Unit,Removed.Removed(Actor.components())>,receipts)) ++ ":frames=" ++ Nat.show(List.length(&2,T.CleanupFrame<Schema>,frames))
    case Buffer.ScopeStoreApplied{_,request,result}:"scope-store:" ++ ScopeText.request(~Schema,request) ++ ":" ++ ScopeText.outcome(~Schema,result)
def edge(value:T.Edge<Schema>) -> String:
  match value:
    case T.Edge{_,source,target}:key(source) ++ "->" ++ key(target)
def inverse(value:T.Inverse<Schema>) -> String:
  match value:
    case T.Inverse{_,target,sources}:key(target) ++ "<-" ++ List.show(&2,Key.Key,key,sources)
def resources(value:Scheduled.Resources(~Schema)) -> String:
  match value:
    case Product.Owner{Layout.ResourceSlot{Layout.Viewed{Store.Store{namespace,T.Graph{edges,inverses},_,sequence,nextReader},Store.View{cachedNamespace,T.Graph{cachedEdges,cachedInverses}}},_},Layout.ResourceSlot{Layout.Viewed{Actor.Session{resourceSession},cachedSession},_}}:"namespace=" ++ U32.show(namespace) ++ ",edges=" ++ List.show(&2,T.Edge<Schema>,edge,edges) ++ ",inverse=" ++ List.show(&2,T.Inverse<Schema>,inverse,inverses) ++ ",cache=" ++ U32.show(cachedNamespace) ++ "/" ++ List.show(&2,T.Edge<Schema>,edge,cachedEdges) ++ "/" ++ List.show(&2,T.Inverse<Schema>,inverse,cachedInverses) ++ ",failures=" ++ Nat.show(sequence) ++ ",nextReader=" ++ U32.show(nextReader) ++ ",resource=" ++ U32.show(resourceSession) ++ "/" ++ U32.show(cachedSession)
def actor(value:Actor.Owner(~Schema)) -> String:
  match value:
    case Cmd.Owner{Sys.Owner{_,_,_,_,_,Local.Local{Actor.User{_,_,_,Actor.Session{session}},Buffer.Buffer{pending,receipts},_}}}:"local=" ++ U32.show(session) ++ ",pending=" ++ Nat.show(List.length(&1,Buffer.Entry<Schema,Unit,Removed.Removed(Actor.components())>,pending)) ++ ",receipts=" ++ List.show(&1,Buffer.Receipt<Schema,Unit,Removed.Removed(Actor.components())>,receipt,List.reverse(&1,Buffer.Receipt<Schema,Unit,Removed.Removed(Actor.components())>,receipts))
def application(value:Scheduled.Bound(~Schema)) -> String:
  match value:
    case Context.Bound{_,Root.Scheduled{App.State{W.World{_,_,_,owners,_,_,_,_,_,_},Product.Owner{author,_},_,_,_},_,_,_,_}}:resources(owners) ++ "|" ++ actor(author)
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
