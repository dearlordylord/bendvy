import Base
import ./app.bend as App
import ./presentation.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query-projection.bend as P
import ./component.bend as Caller
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-query-observable.bend as O
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I

def read_ops(H:Type) -> Type:
  Cap.Read<H,U32> & Unit
def no_ops(H:Type) -> Type:
  Unit
def presented_binding(~S:Data) -> D.Binding<S,Col.Column<S,Caller.Payload>,Unit,Caller.Payload,U32,Caller.Token,Caller.take(~S),Caller.put(~S),Caller.view>:
  D.bind(~S,~Col.Column<S,Caller.Payload>,~Unit,~Caller.Payload,~U32,~Caller.Token,~Caller.take(~S),~Caller.put(~S),~Caller.view,Caller.binding(~S),U32.show)
def read_query(~S:Data) -> D.Declaration<S,Q.Frame<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,Cap.Read<Q.Frame<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,U32>,I.Frame<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,C.Access<U32>>:
  D.read(~S,~Col.Column<S,Caller.Payload>,~Unit,~Caller.Payload,~U32,~Caller.Token,~Caller.take(~S),~Caller.put(~S),~Caller.view,~Array<U32>,~U32,~presented_binding(~S))
def absent_query(~S:Data) -> D.Declaration<S,Q.Frame<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,Unit,I.Frame<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,Unit>:
  D.without_component(~S,~Col.Column<S,Caller.Payload>,~Unit,~Caller.Payload,~U32,~Caller.Token,~Caller.take(~S),~Caller.put(~S),~Caller.view,~Array<U32>,~U32,~presented_binding(~S))
def added_query(~S:Data) -> D.Declaration<S,Q.Frame<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,Unit,I.Frame<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,Unit>:
  D.added(~S,~Col.Column<S,Caller.Payload>,~Unit,~Caller.Payload,~U32,~Caller.Token,~Caller.take(~S),~Caller.put(~S),~Caller.view,~Array<U32>,~U32,~presented_binding(~S))
def composite_query(~S:Data) -> D.Declaration<S,Q.Frame<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,read_ops(Q.Frame<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>),I.Frame<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,P.Product<C.Access<U32>,Unit>>:
  D.pair(~S,~Q.Frame<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,~Cap.Read<Q.Frame<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,U32>,~Unit,~I.Frame<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,~C.Access<U32>,~Unit,~read_query(~S),~added_query(~S))
def read_cap(~H:Type,caps:read_ops(H)) -> Cap.Read<H,U32>:
  match caps:
    case (read,_):read
def read_done(~H:Type,result:H & C.Access<U32>) -> H & (T.Outcome<Unit> & Unit):
  match result:
    case (owner,_):(owner,(T.Success{},Unit{}))
def read_body(~H:Type,~caps:read_ops(H),args:Unit,owner:H) -> H & (T.Outcome<Unit> & Unit):
  read_done(~H,Cap.read(~H,~U32,~read_cap(~H,caps),owner))
def absent_body(~H:Type,~caps:Unit,args:Unit,owner:H) -> H & (T.Outcome<Unit> & Unit):
  (owner,(T.Success{},Unit{}))
def failed(~S:Data,~H:Type,~Rows:Data,~fold:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & App.Observation<Rows>,app:App.ApplicationType<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,H,Rows,fold>) -> Bool:
  False{}
def snapshot_done(~S:Data,~H:Type,~Rows:Data,~fold:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & App.Observation<Rows>,result:App.ApplicationType<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,H,Rows,fold> & Maybe<&2,App.Product<List<&2,App.Binding<S>>,App.Observation<Rows>>>) -> Bool:
  match result:
    case (_,Some{App.Product{bindings,App.Observation{_,rendered}}}):Bool.and(Nat.is_eq(List.length(&2,App.Binding<S>,bindings),2n),Nat.is_eq(List.length(&2,String,rendered),2n))
    case (_,None{}):False{}
def enabled(~S:Data,~H:Type,~Rows:Data,~fold:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & App.Observation<Rows>,app:App.ApplicationType<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,H,Rows,fold>) -> Bool:
  snapshot_done(~S,~H,~Rows,~fold,App.snapshot(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~H,~Rows,~fold,App.enable_debug(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~H,~Rows,~fold,app,True{})))
def second(~S:Data,~H:Type,~Rows:Data,~fold:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & App.Observation<Rows>,app:App.ApplicationType<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,H,Rows,fold>) -> Bool:
  App.register_presented_with(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~no_ops,~Unit,~Unit,~Unit,~Unit,~absent_query(~S),~absent_body,~H,~Rows,~fold,~Bool,~enabled(~S),~failed(~S,~H,~Rows,~fold),app,"PositionAbsent","Update")
def first(~S:Data,~H:Type,~Rows:Data,~fold:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & App.Observation<Rows>,app:App.ApplicationType<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,H,Rows,fold>) -> Bool:
  App.register_presented_with(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~read_ops,~Unit,~Unit,~Unit,~P.Product<C.Access<U32>,Unit>,~composite_query(~S),~read_body,~H,~Rows,~fold,~Bool,~second(~S),~failed(~S,~H,~Rows,~fold),app,"PositionRead","Update")
def activated(~S:Data,result:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & W.Status) -> Bool:
  match result:
    case (world,W.Accepted{}):App.start(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Bool,~first(~S),world)
    case (_,W.Rejected{_}):False{}
def reserved(~S:Data,result:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & W.Reservation<S>) -> Bool:
  match result:
    case (world,W.Reserved{handle}):activated(~S,W.activate(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,world,handle))
    case (_,W.ReservationRejected{_}):False{}
def replaced(~S:Data,result:C.Replacement<W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,Caller.Payload>) -> Bool:
  match result:
    case C.Replaced{world,_}:reserved(~S,W.reserve_id(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,world))
    case C.ReplaceRejected{_,_,_}:False{}
def first_activated(~S:Data,+handle:W.Handle<S>,result:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & W.Status) -> Bool:
  match result:
    case (world,W.Accepted{}):replaced(~S,C.replace(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Unit,~Caller.Payload,~U32,~Caller.Token,~Caller.take(~S),~Caller.put(~S),~Caller.view,Caller.family(~S),world,handle,Some{Caller.Payload{Array.new(U32,0n,42)}}))
    case (_,W.Rejected{_}):False{}
def first_reserved(~S:Data,result:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & W.Reservation<S>) -> Bool:
  match result:
    case (world,W.Reserved{+handle}):first_activated(~S,handle,W.activate(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,world,handle))
    case (_,W.ReservationRejected{_}):False{}
def empty_store(~S:Data,unit:Unit) -> Col.Column<S,Caller.Payload>:
  Col.empty(~S,~Caller.Payload)
def created(~S:Data,result:W.Creation<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>) -> Bool:
  match result:
    case W.Created{_,world}:first_reserved(~S,W.reserve_id(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,world))
    case W.CreateRejected{_,_}:False{}
def setup(~S:Data) -> Bool:
  created(~S,W.create(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~empty_store(~S),W.factory(),Array.new(U32,0n,17)))
def main() -> Bool & Bool:
  (setup(~Caller.A),setup(~Caller.Other))
