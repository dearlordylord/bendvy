import Base
import ../../../src/ecs/execution-state.bend as State
import ../../../src/ecs/execution-builder.bend as Build
import ../../../src/ecs/change-tick.bend as Tick
import ../../../src/ecs/world.bend as W

type Schema is Data:
  Schema{}
type Get<-H:Type> is Type:
  Get{run:H -> H & U32}
def Ops(H:Type) -> Type:Get<H>
def revealed(store:Unit,handles:List<&2,W.Handle<Schema>>,tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,result:Array<U32> & U32) -> State.Scope<Schema,Unit,Array<U32>> & U32:
  match result:
    case (resource,value):(State.Scope{store,resource,handles,tick,prior},value)
def reveal(scope:State.Scope<Schema,Unit,Array<U32>>) -> State.Scope<Schema,Unit,Array<U32>> & U32:
  match scope:
    case State.Scope{store,resource,handles,tick,prior}:revealed(store,handles,tick,prior,Array.get(U32,resource,0))
def declaration(~H:Type,~B:Type,~builder:Build.Builder(~Schema,~Unit,~Array<U32>,~H,~B),book:B) -> B & Ops(H):
  (book,Get{reveal})
