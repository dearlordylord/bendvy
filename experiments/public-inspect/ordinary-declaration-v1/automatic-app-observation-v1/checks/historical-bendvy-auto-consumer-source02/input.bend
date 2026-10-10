import Base
import ./app.bend as App
import /workspace/formal-proofs/bendvy/experiments/public-inspect/ordinary-declaration-v1/caller.bend as Caller
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-query-observable.bend as O
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I

def read_ops(H:Type) -> Type:
  Cap.Read<H,U32>
def no_ops(H:Type) -> Type:
  Unit
def read_query(~S:Data) -> O.Declaration<S,Q.Frame<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,read_ops(Q.Frame<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>),I.Frame<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,C.Access<U32>>:
  O.read(~S,~Col.Column<S,Caller.Payload>,~Unit,~Caller.Payload,~U32,~Caller.Token,~Caller.take(~S),~Caller.put(~S),~Caller.view,~Array<U32>,~U32,~Caller.binding(~S))
def absent_query(~S:Data) -> O.Declaration<S,Q.Frame<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,Unit,I.Frame<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,Unit>:
  O.without_component(~S,~Col.Column<S,Caller.Payload>,~Unit,~Caller.Payload,~U32,~Caller.Token,~Caller.take(~S),~Caller.put(~S),~Caller.view,~Array<U32>,~U32,~Caller.binding(~S))
def read_done(~H:Type,result:H & C.Access<U32>) -> H & (T.Outcome<Unit> & Unit):
  match result:
    case (owner,_):(owner,(T.Success{},Unit{}))
def read_body(~H:Type,~caps:read_ops(H),args:Unit,owner:H) -> H & (T.Outcome<Unit> & Unit):
  read_done(~H,Cap.read(~H,~U32,~caps,owner))
def absent_body(~H:Type,~caps:Unit,args:Unit,owner:H) -> H & (T.Outcome<Unit> & Unit):
  (owner,(T.Success{},Unit{}))
def failed(~S:Data,~H:Type,~Rows:Data,~fold:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & Rows,app:App.ApplicationType<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,H,Rows,fold>) -> Bool:
  False{}
def snapshot_done(~S:Data,~H:Type,~Rows:Data,~fold:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & Rows,result:App.ApplicationType<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,H,Rows,fold> & Maybe<&2,App.Product<List<&2,App.Binding<S>>,Rows>>) -> Bool:
  match result:
    case (_,Some{App.Product{bindings,_}}):Nat.is_eq(List.length(&2,App.Binding<S>,bindings),2n)
    case (_,None{}):False{}
def enabled(~S:Data,~H:Type,~Rows:Data,~fold:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & Rows,app:App.ApplicationType<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,H,Rows,fold>) -> Bool:
  snapshot_done(~S,~H,~Rows,~fold,App.snapshot(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~H,~Rows,~fold,App.enable_debug(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~H,~Rows,~fold,app,True{})))
def second(~S:Data,~H:Type,~Rows:Data,~fold:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & Rows,app:App.ApplicationType<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,H,Rows,fold>) -> Bool:
  App.register_with(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~no_ops,~Unit,~Unit,~Unit,~Unit,~absent_query(~S),~absent_body,~H,~Rows,~fold,~Bool,~enabled(~S),~failed(~S,~H,~Rows,~fold),app,"PositionAbsent","Update")
def first(~S:Data,~H:Type,~Rows:Data,~fold:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & Rows,app:App.ApplicationType<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,H,Rows,fold>) -> Bool:
  App.register_with(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~read_ops,~Unit,~Unit,~Unit,~C.Access<U32>,~read_query(~S),~read_body,~H,~Rows,~fold,~Bool,~second(~S),~failed(~S,~H,~Rows,~fold),app,"PositionRead","Update")
def activated(~S:Data,result:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & W.Status) -> Bool:
  match result:
    case (world,W.Accepted{}):App.start(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Bool,~first(~S),world)
    case (_,W.Rejected{_}):False{}
def reserved(~S:Data,result:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & W.Reservation<S>) -> Bool:
  match result:
    case (world,W.Reserved{handle}):activated(~S,W.activate(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,world,handle))
    case (_,W.ReservationRejected{_}):False{}
def setup(~S:Data,value:Caller.Delivery<S>) -> Bool:
  match value:
    case Caller.Delivered{_,I.Frame{world,_},_,_,_,_,_,_,_}:reserved(~S,W.reserve_id(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,world))
    case Caller.SetupRefused{_,_,_,_}:False{}
    case Caller.Refused{_,_}:False{}
def main() -> Bool & Bool:
  (setup(~Caller.A,Caller.run(~Caller.A)),setup(~Caller.Other,Caller.run(~Caller.Other)))
