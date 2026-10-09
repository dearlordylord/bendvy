import Base
import ../../../src/ecs/transaction.bend as Tx
import ../../../src/ecs/world.bend as W
import ./ordinary-binding.bend as B
import ./mutant-drop-read-clause.bend as D
import ../../../src/ecs/ordinary-declaration.bend as Identity
import ../../../src/ecs/ordinary-query-declaration.bend as Normal
import ../../../src/ecs/inspector.bend as I
import ../../../src/ecs/inspector-query.bend as Q
import ../../../src/ecs/inspector-query-projection.bend as Projection
import ../../../src/ecs/compose.bend as Compose
import ../../../src/ecs/component.bend as C
import ../../../src/ecs/column.bend as Col

type A is Data:
  A{}
type Other is Data:
  Other{}
type Token is Data:
  Token{}
# Affine payload, deliberately not a persistence/Data requirement.
type Payload is Type:
  Payload{values:Array<U32>}
def viewed(result:Array<U32> & U32) -> Payload & U32:
  match result:
    case (values,value):(Payload{values},value)
def view(payload:Payload) -> Payload & U32:
  match payload:
    case Payload{values}:
      viewed(Array.get(U32,values,0))
def take(~S:Data,column:Col.Column<S,Payload>) -> Unit & Col.Column<S,Payload>:
  (Unit{},column)
def put(~S:Data,rest:Unit,column:Col.Column<S,Payload>) -> Col.Column<S,Payload>:
  column
def binding(~S:Data) -> B.Binding<S,Col.Column<S,Payload>,Unit,Payload,U32,Token,take(~S),put(~S),view>:
  B.bind(~S,~Col.Column<S,Payload>,~Unit,~Payload,~U32,~Token,~take(~S),~put(~S),~view,Identity.component(~S,~Payload,"Position"))
def system_read(~S:Data,owner:Compose.Frame<S,Col.Column<S,Payload>,Array<U32>,U32>) -> Compose.Frame<S,Col.Column<S,Payload>,Array<U32>,U32> & C.Access<U32>:
  Normal.execute_read(~S,~Compose.Frame<S,Col.Column<S,Payload>,Array<U32>,U32>,~U32,~Normal.read(~S,~Payload,~Col.Column<S,Payload>,~Array<U32>,~U32,~Unit,~U32,~Token,~B.identity(~S,~Col.Column<S,Payload>,~Unit,~Payload,~U32,~Token,~take(~S),~put(~S),~view,binding(~S)),~view,~take(~S),~put(~S)),owner)
def inspector_read(~S:Data,owner:I.Frame<S,Col.Column<S,Payload>,Array<U32>,U32>) -> I.Frame<S,Col.Column<S,Payload>,Array<U32>,U32> & (List<&2,Projection.Row<S,U32>> & List<&2,Normal.Clause<S>>):
  D.each(~S,~I.Frame<S,Col.Column<S,Payload>,Array<U32>,U32>,~U32,~D.read(~S,~Col.Column<S,Payload>,~Unit,~Payload,~U32,~Token,~take(~S),~put(~S),~view,~Array<U32>,~U32,~binding(~S)),owner)
type Delivery<-S:Data> is Type:
  Delivered{factory:W.Factory,owner:I.Frame<S,Col.Column<S,Payload>,Array<U32>,U32>,rows:List<&2,Projection.Row<S,U32>>,clauses:List<&2,Normal.Clause<S>>,access:C.Access<U32>,previous:Maybe<&1,Payload>,undo:List<&1,(W.World<S,Col.Column<S,Payload>,Array<U32>,U32> -> W.World<S,Col.Column<S,Payload>,Array<U32>,U32>)>,commands:List<&1,(W.World<S,Col.Column<S,Payload>,Array<U32>,U32> -> W.World<S,Col.Column<S,Payload>,Array<U32>,U32>)>,events:List<&2,U32>}
  SetupRefused{factory:W.Factory,world:W.World<S,Col.Column<S,Payload>,Array<U32>,U32>,incoming:Maybe<&1,Payload>,error:W.WorldError}
  Refused{factory:W.Factory,resource:Array<U32>}
def empty(~S:Data,unit:Unit) -> Col.Column<S,Payload>:
  Col.empty(~S,~Payload)
def delivered(~S:Data,factory:W.Factory,access:C.Access<U32>,previous:Maybe<&1,Payload>,undo:List<&1,(W.World<S,Col.Column<S,Payload>,Array<U32>,U32> -> W.World<S,Col.Column<S,Payload>,Array<U32>,U32>)>,commands:List<&1,(W.World<S,Col.Column<S,Payload>,Array<U32>,U32> -> W.World<S,Col.Column<S,Payload>,Array<U32>,U32>)>,events:List<&2,U32>,result:I.Frame<S,Col.Column<S,Payload>,Array<U32>,U32> & (List<&2,Projection.Row<S,U32>> & List<&2,Normal.Clause<S>>)) -> Delivery<S>:
  match result:
    case (owner,(rows,clauses)):Delivered{factory,owner,rows,clauses,access,previous,undo,commands,events}
def observed_tx(~S:Data,factory:W.Factory,previous:Maybe<&1,Payload>,access:C.Access<U32>,tx:Tx.Tx<W.World<S,Col.Column<S,Payload>,Array<U32>,U32>,U32>) -> Delivery<S>:
  match tx:
    case Tx.Tx{world,undo,commands,events}:delivered(~S,factory,access,previous,undo,commands,events,inspector_read(~S,I.Frame{world,0}))
def observed_system(~S:Data,factory:W.Factory,previous:Maybe<&1,Payload>,observed:Compose.Frame<S,Col.Column<S,Payload>,Array<U32>,U32> & C.Access<U32>) -> Delivery<S>:
  match observed:
    case (Compose.Frame{tx,_,_,_},access):observed_tx(~S,factory,previous,access,tx)
def replaced(~S:Data,factory:W.Factory,handle:W.Handle<S>,result:C.Replacement<W.World<S,Col.Column<S,Payload>,Array<U32>,U32>,Payload>) -> Delivery<S>:
  match result:
    case C.Replaced{world,previous}:observed_system(~S,factory,previous,system_read(~S,Compose.Frame{Tx.begin(~W.World<S,Col.Column<S,Payload>,Array<U32>,U32>,~U32,world),handle,None{},0}))
    case C.ReplaceRejected{world,incoming,error}:SetupRefused{factory,world,incoming,error}
def activated(~S:Data,factory:W.Factory,+handle:W.Handle<S>,result:W.World<S,Col.Column<S,Payload>,Array<U32>,U32> & W.Status) -> Delivery<S>:
  match result:
    case (world,W.Accepted{}):replaced(~S,factory,handle,C.replace(~S,~Col.Column<S,Payload>,~Array<U32>,~U32,~Unit,~Payload,~U32,~Token,~take(~S),~put(~S),~view,B.family(~S,~Col.Column<S,Payload>,~Unit,~Payload,~U32,~Token,~take(~S),~put(~S),~view,binding(~S)),world,handle,Some{Payload{Array.new(U32,0n,42)}}))
    case (world,W.Rejected{error}):SetupRefused{factory,world,None{},error}
def reserved(~S:Data,factory:W.Factory,result:W.World<S,Col.Column<S,Payload>,Array<U32>,U32> & W.Reservation<S>) -> Delivery<S>:
  match result:
    case (world,W.Reserved{+handle}):activated(~S,factory,handle,W.activate(~S,~Col.Column<S,Payload>,~Array<U32>,~U32,world,handle))
    case (world,W.ReservationRejected{error}):SetupRefused{factory,world,None{},error}
def created(~S:Data,creation:W.Creation<S,Col.Column<S,Payload>,Array<U32>,U32>) -> Delivery<S>:
  match creation:
    case W.Created{factory,world}:reserved(~S,factory,W.reserve_id(~S,~Col.Column<S,Payload>,~Array<U32>,~U32,world))
    case W.CreateRejected{factory,resource}:Refused{factory,resource}
def run(~S:Data) -> Delivery<S>:
  created(~S,W.create(~S,~Col.Column<S,Payload>,~Array<U32>,~U32,~empty(~S),W.factory(),Array.new(U32,0n,17)))
def main() -> Delivery<A> & Delivery<Other>:
  (run(~A),run(~Other))
