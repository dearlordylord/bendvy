import Base
import ../../../consumer/motion.bend as F
import ../../../consumer/types.bend as T
import ../../../consumer/events.bend as E
import ../../../consumer/payload.bend as P
import ../../../../../../src/ecs/local.bend as Local
import ../../../../../../src/ecs/world.bend as W
import ../../../../../../src/ecs/transaction.bend as Tx
import ../../../../../../src/ecs/commands.bend as Cmd
import ../../../../../../src/ecs/component.bend as Cmp
import ../../../../../../src/ecs/structural.bend as St
import ../../../../../../src/ecs/column.bend as Col
import ../../../../../../src/ecs/relation-commands.bend as Notice

type Frame is Data:
  Frame{count:U32,iteration:U32,transient:Maybe<&2,W.Handle<T.MotionSchema>>,reservations:List<&2,W.Reservation<T.MotionSchema>>}
def bump_read(observed:Array<U32> & U32) -> Array<U32>:
  match observed:
    case (owner,count):Array.set(U32,owner,0,U32.add(count,1))
def bump(owner:Array<U32>) -> Array<U32>:bump_read(Array.get(U32,owner,0))
def populate(world:F.World(),handle:W.Handle<T.MotionSchema>,main:T.Position) -> F.World():F.populate(world,handle,F.Payload{main,None{},None{}})
def finish(operation:U32,frame:Frame,outcome:Tx.Outcome<Unit>,tx:Tx.Tx<F.World(),E.event_type()>) -> Frame & Tx.Returned<F.World(),Unit>:
  (frame,Cmd.tx_finish(~T.MotionSchema,~F.Store(),~F.Resources(),~E.event_type(),~Unit,tx,outcome))
def spawn_frame(owner:Array<U32>,world:F.World(),+handle:W.Handle<T.MotionSchema>,frame:Frame) -> Local.Outcome<F.World(),Array<U32>,Unit,Frame>:
  match frame:
    case Frame{count,iteration,_,reservations}:Local.Succeeded{world,owner,Frame{count,iteration,Some{handle},List.append(&2,W.Reservation<T.MotionSchema>,reservations,[W.Reserved{handle}])}}
def spawn_returned(owner:Array<U32>,frame:Frame,reservation:W.Reservation<T.MotionSchema>,result:Tx.Returned<F.World(),Unit>) -> Local.Outcome<F.World(),Array<U32>,Unit,Frame>:
  match reservation result:
    case W.Reserved{handle} Tx.Returned{world,Tx.Success{}}:spawn_frame(owner,world,handle,frame)
    case _ Tx.Returned{world,_}:Local.Failed{world,owner,Unit{}}
def spawn_finished(owner:Array<U32>,reservation:W.Reservation<T.MotionSchema>,result:Frame & Tx.Returned<F.World(),Unit>) -> Local.Outcome<F.World(),Array<U32>,Unit,Frame>:
  match result:
    case (frame,returned):spawn_returned(owner,frame,reservation,returned)
def spawn_reserved(owner:Array<U32>,frame:Frame,result:Tx.Tx<F.World(),E.event_type()> & W.Reservation<T.MotionSchema>) -> Local.Outcome<F.World(),Array<U32>,Unit,Frame>:
  match result:
    case (tx,reservation):spawn_finished(owner,reservation,finish(0,frame,Tx.Success{},tx))
def spawn(world:F.World(),owner:Array<U32>,frame:Frame) -> Local.Outcome<F.World(),Array<U32>,Unit,Frame>:
  match frame:
    case Frame{count,+iteration,transient,reservations}:spawn_reserved(bump(owner),Frame{count,iteration,transient,reservations},Cmd.tx_spawn(~T.MotionSchema,~F.Store(),~F.Resources(),~E.event_type(),~T.Position,~populate,Tx.begin(~F.World(),~E.event_type(),world),T.Position{F.quad(iteration,U32.add(iteration,1),U32.add(iteration,2),U32.add(iteration,3)),7}))
def increment(view:T.PositionView) -> T.Position:
  match view:
    case T.PositionView{T.Four{a,b,c,d},frame}:T.Position{F.quad(U32.add(a,1),b,c,d),frame}
def completed(owner:Array<U32>,result:Frame & Tx.Returned<F.World(),Unit>) -> Local.Outcome<F.World(),Array<U32>,Unit,Frame>:
  match result:
    case (frame,Tx.Returned{world,Tx.Success{}}):Local.Succeeded{world,owner,frame}
    case (_,Tx.Returned{world,_}):Local.Failed{world,owner,Unit{}}
def written(owner:Array<U32>,frame:Frame,code:U32,result:Cmp.SetResult<Tx.Tx<F.World(),E.event_type()>,T.Position>) -> Local.Outcome<F.World(),Array<U32>,Unit,Frame>:
  match result:
    case Cmp.Written{tx}:completed(owner,finish(1,frame,Tx.Success{},Tx.emit(~F.World(),~E.event_type(),tx,Notice.Original{E.Ping{code}})))
    case Cmp.WriteRejected{tx,_,_}:completed(owner,finish(1,frame,Tx.Failure{Unit{}},tx))
    case Cmp.WriteFailure{tx,_}:completed(owner,finish(1,frame,Tx.Failure{Unit{}},tx))
def update_read(owner:Array<U32>,frame:Frame,code:U32,handle:W.Handle<T.MotionSchema>,result:Tx.Tx<F.World(),E.event_type()> & Cmp.Access<T.PositionView>) -> Local.Outcome<F.World(),Array<U32>,Unit,Frame>:
  match result:
    case (tx,Cmp.Found{view}):written(owner,frame,code,Cmp.tx_set(~T.MotionSchema,~F.Store(),~F.Resources(),~E.event_type(),~F.Rest(),~T.Position,~T.PositionView,~T.PositionToken,~F.take_main,~F.put_main,~P.position_get,F.main_family(),tx,handle,increment(view)))
    case (tx,_):completed(owner,finish(1,frame,Tx.Failure{Unit{}},tx))
def update(world:F.World(),owner:Array<U32>,frame:Frame) -> Local.Outcome<F.World(),Array<U32>,Unit,Frame>:
  match frame:
    case Frame{count,+iteration,Some{+handle},reservations}:update_read(bump(owner),Frame{count,iteration,Some{handle},reservations},iteration,handle,Cmp.tx_get(~T.MotionSchema,~F.Store(),~F.Resources(),~E.event_type(),~F.Rest(),~T.Position,~T.PositionView,~T.PositionToken,~F.take_main,~F.put_main,~P.position_get,F.main_family(),Tx.begin(~F.World(),~E.event_type(),world),handle))
    case _:Local.Failed{world,bump(owner),Unit{}}
def main_cleared(rest:F.Rest(),result:Col.SwapOutcome<T.MotionSchema,T.Position>) -> F.Store():
  match result:
    case Col.Accepted{column,_}:F.put_main(rest,column)
    case Col.Rejected{column,_}:F.put_main(rest,column)
def main_taken(handle:W.Handle<T.MotionSchema>,observed:F.Rest() & Col.Column<T.MotionSchema,T.Position>) -> F.Store():
  match observed:
    case (rest,column):main_cleared(rest,Col.clear(~T.MotionSchema,~T.Position,column,W.handle_index(~T.MotionSchema,handle)))
def clear_main(store:F.Store(),handle:W.Handle<T.MotionSchema>) -> F.Store():main_taken(handle,F.take_main(store))

def aux_cleared(rest:F.AuxRest(),result:Col.SwapOutcome<T.MotionSchema,T.Velocity>) -> F.Store():
  match result:
    case Col.Accepted{column,_}:F.put_aux(rest,column)
    case Col.Rejected{column,_}:F.put_aux(rest,column)
def aux_taken(handle:W.Handle<T.MotionSchema>,observed:F.AuxRest() & Col.Column<T.MotionSchema,T.Velocity>) -> F.Store():
  match observed:
    case (rest,column):aux_cleared(rest,Col.clear(~T.MotionSchema,~T.Velocity,column,W.handle_index(~T.MotionSchema,handle)))
def clear_aux(store:F.Store(),handle:W.Handle<T.MotionSchema>) -> F.Store():aux_taken(handle,F.take_aux(store))

def flag_cleared(rest:F.FlagRest(),result:Col.SwapOutcome<T.MotionSchema,T.Selected>) -> F.Store():
  match result:
    case Col.Accepted{column,_}:F.put_flag(rest,column)
    case Col.Rejected{column,_}:F.put_flag(rest,column)
def flag_taken(handle:W.Handle<T.MotionSchema>,observed:F.FlagRest() & Col.Column<T.MotionSchema,T.Selected>) -> F.Store():
  match observed:
    case (rest,column):flag_cleared(rest,Col.clear(~T.MotionSchema,~T.Selected,column,W.handle_index(~T.MotionSchema,handle)))
def clear_flag(store:F.Store(),handle:W.Handle<T.MotionSchema>) -> F.Store():flag_taken(handle,F.take_flag(store))

def clear_all_copy(store:F.Store(),+handle:W.Handle<T.MotionSchema>) -> F.Store() & List<&2,E.event_type()>:(clear_flag(clear_aux(clear_main(store,handle),handle),handle),[])
def clear_all(store:F.Store(),handle:W.Handle<T.MotionSchema>) -> F.Store() & List<&2,E.event_type()>:clear_all_copy(store,handle)
def removed_record(handle:W.Handle<T.MotionSchema>) -> E.event_type():Notice.Original{E.Removed{handle}}
def despawned_record(handle:W.Handle<T.MotionSchema>) -> E.event_type():Notice.Original{E.Despawned{handle}}
def dispose_queued(owner:Array<U32>,frame:Frame,result:Tx.Tx<F.World(),E.event_type()> & W.Status) -> Local.Outcome<F.World(),Array<U32>,Unit,Frame>:
  match result:
    case (tx,W.Accepted{}):completed(owner,finish(2,frame,Tx.Success{},tx))
    case (tx,_):completed(owner,finish(2,frame,Tx.Failure{Unit{}},tx))
def dispose_removed(owner:Array<U32>,frame:Frame,+handle:W.Handle<T.MotionSchema>,result:St.Queued<Tx.Tx<F.World(),E.event_type()>,T.Position>) -> Local.Outcome<F.World(),Array<U32>,Unit,Frame>:
  match result:
    case St.Queued{tx}:dispose_queued(owner,frame,Cmd.tx_despawn_observed(~T.MotionSchema,~F.Store(),~F.Resources(),~E.event_type(),~clear_all,~despawned_record,tx,handle))
    case St.QueueRejected{tx,_,_}:completed(owner,finish(2,frame,Tx.Failure{Unit{}},tx))
def dispose(world:F.World(),owner:Array<U32>,frame:Frame) -> Local.Outcome<F.World(),Array<U32>,Unit,Frame>:
  match frame:
    case Frame{count,iteration,Some{+handle},reservations}:dispose_removed(bump(owner),Frame{count,iteration,Some{handle},reservations},handle,St.tx_remove_observed(~T.MotionSchema,~F.Store(),~F.Resources(),~E.event_type(),~F.Rest(),~T.Position,~T.PositionView,~T.PositionToken,~F.take_main,~F.put_main,~P.position_get,~removed_record,F.main_family(),Tx.begin(~F.World(),~E.event_type(),world),handle))
    case _:Local.Failed{world,bump(owner),Unit{}}

def fresh_frame(frame:Frame) -> Frame:frame
