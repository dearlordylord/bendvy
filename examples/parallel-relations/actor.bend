import Base
import ./setup.bend as Scene
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-command-local.bend as Local
import ../../src/ecs/execution-command-permission.bend as Permission
import ../../src/ecs/execution-command-system.bend as Cmd
import ../../src/ecs/execution-relation-command.bend as Relation
import ../../src/ecs/execution-resource-policy.bend as Policy
import ../../src/ecs/execution-reservation-task.bend as Task
import ../../src/ecs/execution-system.bend as Sys

type Session is Type:
  Session{value:U32}
def project(value:Session) -> Session & U32:
  match value:
    case Session{+value}:(Session{value},value)
def unit(value:Unit) -> Unit & Unit:(value,Unit{})
def components() -> Layout.Layout:
  Layout.LayoutPair{Layout.LayoutLeaf{Unit,Unit,unit,"scene-node",Policy.Ordinary{}},Layout.EmptyLayout{}}
def resources(~S:Data) -> Layout.Layout:Scene.resources(~S,~Session,~U32,~project)
def route() -> Layout.Route:Layout.InLeft{Layout.AtLeaf{}}
def C(~S:Data) -> Type:Layout.columns(~S,Layout.LayoutLeaf{Unit,Unit,unit,"scene-node",Policy.Ordinary{}})
def R(~S:Data) -> Type:Layout.resources(~S,Scene.graph_layout(~S))
def Ops(~S:Data,Permit:Data,H:Type,Q:Type) -> Type:Relation.HierarchyCommands<Q,S>
type User<-S:Data> is Type:
  User{child:W.Handle<S>,parent:W.Handle<S>,replacement:W.Handle<S>,session:Session}
def declaration(~S:Data,~Permit:Data,~H:Type,~Q:Type,~commands:Local.Commands<Q,S,Unit>,~B:Type,~builder:Build.Builder(~S,~Layout.columns(~S,components()),~C(~S),~R(~S),~Permit,~H,~B),~K:Type,~entity:Permission.Grant(~S,~components(),~Permit,~Q,~K),~relations:Permission.RelationGrant(~S,~resources(~S),~Q,~K),book:B,permissions:K) -> B & (K & Ops(~S,Permit,H,Q)):
  (book,relations(route(),{==},Scene.hierarchy(~S),{==},{==},{==},permissions))
def authored(~S:Data,~Permit:Data,~H:Type,~Q:Type,~relate:Q -> W.Handle<S> -> W.Handle<S> -> Q,~unrelate:Q -> W.Handle<S> -> Q,~reorder:Q -> W.Handle<S> -> List<&2,W.Handle<S>> -> Q,scope:H,queue:Q,user:User<S>) -> Task.Task<S,Permit,H & (Q & (User<S> & Sys.Completion<String,String>))>:
  match user:
    case User{+child,+parent,+replacement,session}:Task.TDone{(scope,(relate(reorder(relate(unrelate(relate(queue,child,parent),child),child,replacement),replacement,[child]),child,child),(User{child,parent,replacement,session},Sys.BodyError{"scene body finished with an error","scene hierarchy queued"})))}
def body(~S:Data,~Permit:Data,~H:Type,~Q:Type,~caps:Ops(~S,Permit,H,Q),~commands:Local.Commands<Q,S,Unit>,scope:H,queue:Q,user:User<S>) -> Task.Task<S,Permit,H & (Q & (User<S> & Sys.Completion<String,String>))>:
  authored(~S,~Permit,~H,~Q,~Relation.relate_field(~S,~Q,Relation.relations_field(~S,~Q,caps)),~Relation.unrelate_field(~S,~Q,Relation.relations_field(~S,~Q,caps)),~Relation.reorder_field(~S,~Q,caps),scope,queue,user)
def Owner(~S:Data) -> Type:
  Cmd.Owner<S,C(~S),R(~S),Unit,components(),resources(~S),route(),Ops(~S),User<S>,String,String,declaration(~S),body(~S)>
