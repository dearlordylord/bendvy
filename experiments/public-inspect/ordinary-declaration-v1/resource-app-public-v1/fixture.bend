import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/experiments/public-inspect/ordinary-declaration-v1/canonical-adoption-v1/detached-v2/owner-observer.bend as Dump
type A is Data:
  A{}
type Counter is Type:
  Counter{values:Array<U32>}
type Output is Type:
  Output{values:Array<U32>}
type Error is Data:
  RolledBack{prior:U32}
def viewed(result:Array<U32> & U32) -> Counter & U32:
  match result:
    case (values,value):(Counter{values},value)
def view(value:Counter) -> Counter & U32:
  match value:
    case Counter{values}:viewed(Array.get(U32,values,0))
def ops(H:Type) -> Type:
  Cap.ValueWrite<H,Counter,U32>
def body_done(~H:Type,fail:Bool,+prior:U32,owner:H) -> H & (T.Outcome<Error> & Output):
  match fail:
    case False{}:(owner,(T.Success{},Output{Array.new(U32,0n,prior)}))
    case True{}:(owner,(T.Failure{RolledBack{prior}},Output{Array.new(U32,0n,prior)}))
def body_observed(~H:Type,~caps:ops(H),fail:Bool,result:H & U32) -> H & (T.Outcome<Error> & Output):
  match result:
    case (owner,+prior):body_done(~H,fail,prior,Cap.value_set(~H,~Counter,~U32,~caps,owner,Counter{Array.new(U32,0n,(prior+1:U32))}))
def body(~H:Type,~caps:ops(H),fail:Bool,owner:H) -> H & (T.Outcome<Error> & Output):
  body_observed(~H,~caps,fail,Cap.value_get(~H,~Counter,~U32,~caps,owner))
def unit_view(value:Unit) -> Unit & String:
  (value,"Unit")
def counter_join(result:Array<U32> & String) -> Counter & String:
  match result:
    case (values,text):(Counter{values},"Counter{" ++ text ++ "}")
def counter(value:Counter) -> Counter & String:
  match value:
    case Counter{values}:counter_join(Dump.u32_array(values))
def world(~S:Data,value:W.World<S,Col.Column<S,Unit>,Counter,U32>) -> W.World<S,Col.Column<S,Unit>,Counter,U32> & String:
  Dump.world(~S,~Unit,~Counter,~U32,~unit_view,~counter,~U32.show,value)
def output_value(result:Array<U32> & U32) -> String:
  match result:
    case (_,prior):"Success{prior=" ++ U32.show(prior) ++ "}"
def output(value:Output) -> String:
  match value:
    case Output{values}:output_value(Array.get(U32,values,0))
def activated(~S:Data,result:W.World<S,Col.Column<S,Unit>,Counter,U32> & W.Status) -> W.World<S,Col.Column<S,Unit>,Counter,U32>:
  match result:
    case (world,_):world
def reserved(~S:Data,result:W.World<S,Col.Column<S,Unit>,Counter,U32> & W.Reservation<S>) -> W.World<S,Col.Column<S,Unit>,Counter,U32>:
  match result:
    case (world,W.Reserved{handle}):activated(~S,W.activate(~S,~Col.Column<S,Unit>,~Counter,~U32,world,handle))
    case (world,_):world
def entities(~S:Data,count:Nat,world:W.World<S,Col.Column<S,Unit>,Counter,U32>) -> W.World<S,Col.Column<S,Unit>,Counter,U32>:
  match count:
    case 0n:world
    case 1n+k:entities(~S,k,reserved(~S,W.reserve_id(~S,~Col.Column<S,Unit>,~Counter,~U32,world)))
def empty(~S:Data,unit:Unit) -> Col.Column<S,Unit>:
  Col.empty(~S,~Unit)
