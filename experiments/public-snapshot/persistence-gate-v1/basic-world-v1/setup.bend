import Base
import ./fixture.bend as F
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/experiments/public-decode/typed.bend as D

type Setup<-S:Data> is Type:
  Ready{world:W.World<S,F.Store<S>,F.Resources,Unit>}
  Refused{world:W.World<S,F.Store<S>,F.Resources,Unit>}
# Existing mutation continuation for already ensured live fixture ID1; construction
# below uses Filled and propagates rejection instead of this unwrap helper.
def swapped(~S:Data,outcome:Col.SwapOutcome<S,F.Payload>) -> Col.Column<S,F.Payload>:
  match outcome:
    case Col.Accepted{column,_}:column
    case Col.Rejected{column,_}:column
# Fixture construction refuses rejected inserts while returning the actual World.
type Filled<-S:Data> is Type:
  ColumnReady{column:Col.Column<S,F.Payload>}
  ColumnRefused{column:Col.Column<S,F.Payload>}
def second_inserted(~S:Data,outcome:Col.SwapOutcome<S,F.Payload>) -> Filled<S>:
  match outcome:
    case Col.Accepted{column,_}:ColumnReady{column}
    case Col.Rejected{column,_}:ColumnRefused{column}
def first_inserted(~S:Data,+secondA:U32,+secondB:U32,outcome:Col.SwapOutcome<S,F.Payload>) -> Filled<S>:
  match outcome:
    case Col.Accepted{column,_}:second_inserted(~S,Col.swap(~S,~F.Payload,column,2,Some{F.payload(secondA,secondB)}))
    case Col.Rejected{column,_}:ColumnRefused{column}
# IDs here are actual successful reservations, checked before setup continues.
# swap does not grow: ensure both actual fixture cells before the first insertion.
def filled(~S:Data,firstA:U32,firstB:U32,secondA:U32,secondB:U32) -> Filled<S>:
  first_inserted(~S,secondA,secondB,Col.swap(~S,~F.Payload,Col.ensure(~S,~F.Payload,Col.empty(~S,~F.Payload),2),1,Some{F.payload(firstA,firstB)}))
def columns_ready(~S:Data,codec:D.Codec,saved:Filled<S>,transient:Filled<S>) -> F.Store<S> & Bool:
  match saved transient:
    case ColumnReady{saved} ColumnReady{transient}:(F.Store{saved,transient,codec},True{})
    case ColumnRefused{saved} ColumnReady{transient}:(F.Store{saved,transient,codec},False{})
    case ColumnReady{saved} ColumnRefused{transient}:(F.Store{saved,transient,codec},False{})
    case ColumnRefused{saved} ColumnRefused{transient}:(F.Store{saved,transient,codec},False{})
def populated(~S:Data,store:F.Store<S>) -> F.Store<S> & Bool:
  match store:
    case F.Store{_,_,codec}:columns_ready(~S,codec,filled(~S,7,9,17,19),filled(~S,107,109,117,119))
def done(~S:Data,observed:W.World<S,F.Store<S>,F.Resources,Unit> & Bool) -> Setup<S>:
  match observed:
    case (world,True{}):Ready{world}
    case (world,False{}):Refused{world}
def reserved_inactive(~S:Data,observed:W.World<S,F.Store<S>,F.Resources,Unit> & W.Reservation<S>) -> Setup<S>:
  match observed:
    case (world,W.ReservationRejected{_}):Refused{world}
    case (world,W.Reserved{_}):done(~S,W.with_store(~S,~F.Store<S>,~F.Resources,~Unit,~Bool,populated(~S),world))
def activated_second(~S:Data,observed:W.World<S,F.Store<S>,F.Resources,Unit> & W.Status) -> Setup<S>:
  match observed:
    case (world,W.Rejected{_}):Refused{world}
    case (world,W.Accepted{}):reserved_inactive(~S,W.reserve_id(~S,~F.Store<S>,~F.Resources,~Unit,world))
def reserved_second(~S:Data,observed:W.World<S,F.Store<S>,F.Resources,Unit> & W.Reservation<S>) -> Setup<S>:
  match observed:
    case (world,W.ReservationRejected{_}):Refused{world}
    case (world,W.Reserved{handle}):activated_second(~S,W.activate(~S,~F.Store<S>,~F.Resources,~Unit,world,handle))
def activated_first(~S:Data,observed:W.World<S,F.Store<S>,F.Resources,Unit> & W.Status) -> Setup<S>:
  match observed:
    case (world,W.Rejected{_}):Refused{world}
    case (world,W.Accepted{}):reserved_second(~S,W.reserve_id(~S,~F.Store<S>,~F.Resources,~Unit,world))
def reserved_first(~S:Data,observed:W.World<S,F.Store<S>,F.Resources,Unit> & W.Reservation<S>) -> Setup<S>:
  match observed:
    case (world,W.ReservationRejected{_}):Refused{world}
    case (world,W.Reserved{handle}):activated_first(~S,W.activate(~S,~F.Store<S>,~F.Resources,~Unit,world,handle))
def setup(~S:Data,world:W.World<S,F.Store<S>,F.Resources,Unit>) -> Setup<S>:
  reserved_first(~S,W.reserve_id(~S,~F.Store<S>,~F.Resources,~Unit,world))
