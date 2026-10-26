import Base
import ../../../src/ecs/execution-lifecycle-notices.bend as Notice
import ../../../src/ecs/execution-state.bend as State
import ../../../src/ecs/execution-declaration.bend as D
import ../../../src/ecs/execution-system.bend as Sys
import ../../../src/ecs/execution-app.bend as Execute
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/change-tick.bend as Tick

type Schema is Data:
  Schema{}
type Get<-H:Type> is Type:
  Get{run:H -> H & U32}
def Ops(H:Type) -> Type:Get<H>
def revealed(store:Unit,handles:List<&2,W.Handle<Schema>>,tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,result:Array<U32> & U32,lifecycleView:Notice.View<Schema>) -> State.Scope<Schema,Unit,Array<U32>> & U32:
  match result:
    case (resource,value):(State.Scope{store,resource,handles,tick,prior,lifecycleView},value)
def reveal(scope:State.Scope<Schema,Unit,Array<U32>>) -> State.Scope<Schema,Unit,Array<U32>> & U32:
  match scope:
    case State.Scope{store,resource,handles,tick,prior,lifecycleView}:revealed(store,handles,tick,prior,Array.get(U32,resource,0),lifecycleView)
def declaration() -> D.Declaration<Schema,Unit,Array<U32>,Ops>:
  D.Declaration{Get{reveal},[]}
def returned(~H:Type,result:H & U32) -> H & (Unit & Sys.Completion<Unit,U32>):
  match result:
    case (scope,value):(scope,(Unit{},Sys.Success{value}))
def field(~H:Type,caps:Get<H>) -> H -> H & U32:
  match caps:
    case Get{run}:run
def body(~H:Type,~caps:Ops(H),scope:H,local:Unit) -> H & (Unit & Sys.Completion<Unit,U32>):
  returned(~H,field(~H,caps)(scope))
def World() -> Type:W.World<Schema,Unit,Array<U32>,Unit>
def Application() -> Type:Execute.Application<Schema,Unit,Array<U32>,Unit,Ops,Unit,Unit,U32,declaration(),body>
def printed(result:Application() & Execute.Status<Unit,U32>) -> IO(Unit):
  match result:
    case (_,Execute.Ran{Sys.Success{value}}):IO.print(U32.show(value))
    case _:IO.print("refused")
def built(result:Execute.Built<Application(),World(),Unit>) -> IO(Unit):
  match result:
    case Execute.Built{application}:printed(Execute.run(~Schema,~Unit,~Array<U32>,~Unit,~Ops,~Unit,~Unit,~U32,~declaration(),~body,application))
    case _:IO.print("build refused")
def empty(_:Unit) -> Unit:Unit{}
def created(result:W.Creation<Schema,Unit,Array<U32>,Unit>) -> IO(Unit):
  match result:
    case W.Created{_,world}:built(Execute.define(~Schema,~Unit,~Array<U32>,~Unit,~Ops,~Unit,~Unit,~U32,~declaration(),~body,world,"undeclared secret getter",Unit{}))
    case _:IO.print("create refused")
def main() -> IO(Unit):
  created(W.create(~Schema,~Unit,~Array<U32>,~Unit,~empty,W.factory(),ALeaf{777}))
