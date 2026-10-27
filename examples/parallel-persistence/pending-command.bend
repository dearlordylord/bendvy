import Base
import ./declarations.bend as O
import ./receiver.bend as R
import ./execution.bend as E
import ./scheduled.bend as P
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-command-system.bend as Cmd
import ../../src/ecs/execution-command-local.bend as Local
import ../../src/ecs/execution-command-permission.bend as Permission
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-reservation-task.bend as Task
import ../../src/ecs/execution-parallel-scope-registry.bend as Tree
import ../../src/ecs/world.bend as W

type Capture<-S:Data> is Type:Capture{handle:W.Handle<S>,retained:E.Left(~S),capture:Array<U32>,runs:U32}
# Bevy ad678262ce53b5d142fe49ee5e08caff6f00ab60:
# crates/bevy_ecs/src/schedule/executor/single_threaded.rs keeps authored
# commands when deferred application is disabled. Returning the same affine
# captures through persistence refusal is a Bend-specific ownership requirement.
def route() -> Layout.Route:Layout.InLeft{Layout.AtLeaf{}}
def Ops(Permit:Data,H:Type,Q:Type) -> Type:Unit
def declaration(~S:Data,~Permit:Data,~H:Type,~Q:Type,~commands:Local.Commands<Q,S,O.Actor<S>>,~B:Type,~builder:Build.Builder(~S,~Layout.columns(~S,R.Components(~S)),~P.LeftColumn(~S),~P.LeftResource(~S),~Permit,~H,~B),~K:Type,~entity:Permission.Grant(~S,~R.Components(~S),~Permit,~Q,~K),book:B,permission:K) -> B & (K & Unit):(book,(permission,Unit{}))
def body(~S:Data,~Permit:Data,~H:Type,~Q:Type,~caps:Unit,~commands:Local.Commands<Q,S,O.Actor<S>>,scope:H,queue:Q,local:Capture<S>) -> Task.Task<S,Permit,H & (Q & (Capture<S> & Sys.Completion<String,String>))>:
  match local:
    case Capture{+handle,retained,capture,runs}:Task.TDone{(scope,(Local.insert_field(~Q,~S,~O.Actor<S>,commands)(queue,handle,O.Actor{"queued",ALeaf{515}}),(Capture{handle,retained,capture,U32.add(runs,1)},Sys.Success{"authored"}))) }
def Owner(~S:Data) -> Type:Cmd.Owner<S,P.LeftColumn(~S),P.LeftResource(~S),Unit,R.Components(~S),route(),Ops,Capture<S>,String,String,declaration(~S),body(~S)>
def selection(~S:Data,~F:Tree.Family(),~leaf:Tree.Leaf(~S,~Layout.columns(~S,R.Components(~S)),~P.LeftColumn(~S),~P.LeftResource(~S),~Unit,~String,~String,~F),~command:Tree.CommandLeaf(~S,~Layout.columns(~S,R.Components(~S)),~P.LeftColumn(~S),~P.LeftResource(~S),~Unit,~String,~String,~F),~join:Tree.Join(~F),owner:Owner(~S)) -> F(Owner(~S)):
  command(R.Components(~S),route(),{==},{==},Ops,Capture<S>,declaration(~S),body(~S),owner)
def define(~S:Data,world:R.World(~S),handle:W.Handle<S>,retained:E.Left(~S)) -> Sys.Defined<R.World(~S),Owner(~S),Cmd.Captures(~S,~R.Components(~S),~route(),~Capture<S>)>:
  Cmd.define(~S,~P.LeftColumn(~S),~P.LeftResource(~S),~Unit,~R.Components(~S),~route(),~{==},~Ops,~Capture<S>,~String,~String,~declaration(~S),~body(~S),~R.Resources(~S),world,"pending-actor",Capture{handle,retained,ALeaf{404},0})
