import ../../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/meter.bend as Meter
import Base
import health-observe.bend as Observe
import ../../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/deferred-command.bend as Deferred
import ../../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/trace-facts.bend as Trace
import health.bend as F
import types.bend as T
import health-events.bend as E
import payload.bend as P
import ../../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/local.bend as Local
import ../../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/world.bend as W
import ../../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/transaction.bend as Tx
import ../../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/commands.bend as Cmd
import ../../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/component.bend as Cmp
import ../../../../src/ecs/structural.bend as St
import ../../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/column.bend as Col
import ../../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/relation-commands.bend as Notice

type TxFacts is Data:
  TxFacts{operation:U32,undo:Nat,commands:Nat,events:List<&2,E.event_type()>,trace:Bool,world:String}
type MeasuredFacts is Data:
  MeasuredFacts{original:TxFacts,committed:Bool,report:Meter.Report}
type Frame is Data:
  Frame{count:U32,iteration:U32,transient:Maybe<&2,W.Handle<T.HealthSchema>>,reservations:List<&2,W.Reservation<T.HealthSchema>>,facts:List<&2,MeasuredFacts>}
def bump_read(observed:Array<U32> & U32) -> Array<U32>:
  match observed:
    case (owner,count):Array.set(U32,owner,0,U32.add(count,1))
def bump(owner:Array<U32>) -> Array<U32>:bump_read(Array.get(U32,owner,0))
def populate(world:F.World(),handle:W.Handle<T.HealthSchema>,main:T.Vitals) -> F.World():F.populate(world,handle,F.Payload{main,None{},None{}})
def count_join(~A:Type,head:A,observed:List<A> & Nat) -> List<A> & Nat:
  match observed:
    case (rest,count):(head <> rest,1n+count)
def count_owned(~A:Type,values:List<A>) -> List<A> & Nat:
  match values:
    case []:([],0n)
    case head <> rest:count_join(~A,head,count_owned(~A,rest))
def finished_fact(count:U32,iteration:U32,transient:Maybe<&2,W.Handle<T.HealthSchema>>,reservations:List<&2,W.Reservation<T.HealthSchema>>,facts:List<&2,MeasuredFacts>,fact:TxFacts,result:Tx.Returned<F.World(),Unit>) -> Frame & Tx.Returned<F.World(),Unit>:
  match result:
    case Tx.Returned{world,+outcome,+report}:(Frame{count,iteration,transient,reservations,List.append(&2,MeasuredFacts,facts,[MeasuredFacts{fact,Tx.committed(~Unit,outcome),report}])},Tx.Returned{world,outcome,report})
def finish_parts(operation:U32,count:U32,iteration:U32,transient:Maybe<&2,W.Handle<T.HealthSchema>>,reservations:List<&2,W.Reservation<T.HealthSchema>>,facts:List<&2,MeasuredFacts>,outcome:Tx.Outcome<Unit>,undo:List<(F.World()->F.World())> & Nat,commands:List<Deferred.Command<F.World()>> & Nat,+events:List<&2,E.event_type()>,+trace:Trace.State,meter:Meter.State,observed:F.World() & String) -> Frame & Tx.Returned<F.World(),Unit>:
  (undo,nu)=undo
  (commands,nc)=commands
  (world,text)=observed
  finished_fact(count,iteration,transient,reservations,facts,TxFacts{operation,nu,nc,events,Trace.enabled(trace),text},Cmd.tx_finish(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),~Unit,Tx.Tx{world,undo,commands,events,trace,meter},outcome))
def finish_observed(operation:U32,frame:Frame,outcome:Tx.Outcome<Unit>,undo:List<(F.World()->F.World())> & Nat,commands:List<Deferred.Command<F.World()>> & Nat,+events:List<&2,E.event_type()>,+trace:Trace.State,meter:Meter.State,observed:F.World() & String) -> Frame & Tx.Returned<F.World(),Unit>:
  match frame:
    case Frame{count,iteration,transient,reservations,facts}:finish_parts(operation,count,iteration,transient,reservations,facts,outcome,undo,commands,events,trace,meter,observed)
def finish(operation:U32,frame:Frame,outcome:Tx.Outcome<Unit>,tx:Tx.Tx<F.World(),E.event_type()>) -> Frame & Tx.Returned<F.World(),Unit>:
  match tx:
    case Tx.Tx{world,undo,commands,events,trace,meter}:finish_observed(operation,frame,outcome,count_owned(~(F.World()->F.World()),undo),count_owned(~Deferred.Command<F.World()>,commands),events,trace,meter,Observe.world(world))
def spawn_frame(owner:Array<U32>,world:F.World(),+handle:W.Handle<T.HealthSchema>,frame:Frame) -> Local.Outcome<F.World(),Array<U32>,Unit,Frame>:
  match frame:
    case Frame{count,iteration,_,reservations,facts}:Local.Succeeded{world,owner,Frame{count,iteration,Some{handle},List.append(&2,W.Reservation<T.HealthSchema>,reservations,[W.Reserved{handle}]),facts}}
def spawn_returned(owner:Array<U32>,frame:Frame,reservation:W.Reservation<T.HealthSchema>,result:Tx.Returned<F.World(),Unit>) -> Local.Outcome<F.World(),Array<U32>,Unit,Frame>:
  match reservation result:
    case W.Reserved{handle} Tx.Returned{world,Tx.Success{},_}:spawn_frame(owner,world,handle,frame)
    case _ Tx.Returned{world,_,_}:Local.Failed{world,owner,Unit{}}
def spawn_finished(owner:Array<U32>,reservation:W.Reservation<T.HealthSchema>,result:Frame & Tx.Returned<F.World(),Unit>) -> Local.Outcome<F.World(),Array<U32>,Unit,Frame>:
  match result:
    case (frame,returned):spawn_returned(owner,frame,reservation,returned)
def spawn_reserved(owner:Array<U32>,frame:Frame,result:Tx.Tx<F.World(),E.event_type()> & W.Reservation<T.HealthSchema>) -> Local.Outcome<F.World(),Array<U32>,Unit,Frame>:
  match result:
    case (tx,reservation):spawn_finished(owner,reservation,finish(0,frame,Tx.Success{},tx))
def spawn(world:F.World(),owner:Array<U32>,frame:Frame) -> Local.Outcome<F.World(),Array<U32>,Unit,Frame>:
  match frame:
    case Frame{count,+iteration,transient,reservations,facts}:spawn_reserved(bump(owner),Frame{count,iteration,transient,reservations,facts},Cmd.tx_spawn(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),~T.Vitals,~populate,Cmd.tx_begin(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),world),T.Vitals{F.quad(iteration,U32.add(iteration,1),U32.add(iteration,2),U32.add(iteration,3)),9,2}))
def increment(view:T.VitalsView) -> T.Vitals:
  match view:
    case T.VitalsView{T.Four{a,b,c,d},reserve,class}:T.Vitals{F.quad(U32.add(a,1),b,c,d),reserve,class}
def completed(owner:Array<U32>,result:Frame & Tx.Returned<F.World(),Unit>) -> Local.Outcome<F.World(),Array<U32>,Unit,Frame>:
  match result:
    case (frame,Tx.Returned{world,Tx.Success{},_}):Local.Succeeded{world,owner,frame}
    case (_,Tx.Returned{world,_,_}):Local.Failed{world,owner,Unit{}}
def written(owner:Array<U32>,frame:Frame,code:U32,result:Cmp.SetResult<Tx.Tx<F.World(),E.event_type()>,T.Vitals>) -> Local.Outcome<F.World(),Array<U32>,Unit,Frame>:
  match result:
    case Cmp.Written{tx}:completed(owner,finish(1,frame,Tx.Success{},Tx.emit(~F.World(),~E.event_type(),tx,Notice.Original{E.Ping{code}})))
    case Cmp.WriteRejected{tx,_,_}:completed(owner,finish(1,frame,Tx.Failure{Unit{}},tx))
    case Cmp.WriteFailure{tx,_}:completed(owner,finish(1,frame,Tx.Failure{Unit{}},tx))
def update_read(owner:Array<U32>,frame:Frame,code:U32,handle:W.Handle<T.HealthSchema>,result:Tx.Tx<F.World(),E.event_type()> & Cmp.Access<T.VitalsView>) -> Local.Outcome<F.World(),Array<U32>,Unit,Frame>:
  match result:
    case (tx,Cmp.Found{view}):written(owner,frame,code,Cmp.tx_set(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),~F.Rest(),~T.Vitals,~T.VitalsView,~T.VitalsToken,~F.take_main,~F.put_main,~P.vitals_get,F.main_family(),tx,handle,increment(view)))
    case (tx,_):completed(owner,finish(1,frame,Tx.Failure{Unit{}},tx))
def update(world:F.World(),owner:Array<U32>,frame:Frame) -> Local.Outcome<F.World(),Array<U32>,Unit,Frame>:
  match frame:
    case Frame{count,+iteration,Some{+handle},reservations,facts}:update_read(bump(owner),Frame{count,iteration,Some{handle},reservations,facts},iteration,handle,Cmp.tx_get(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),~F.Rest(),~T.Vitals,~T.VitalsView,~T.VitalsToken,~F.take_main,~F.put_main,~P.vitals_get,F.main_family(),Cmd.tx_begin(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),world),handle))
    case _:Local.Failed{world,bump(owner),Unit{}}
def main_cleared(rest:F.Rest(),result:Col.SwapOutcome<T.HealthSchema,T.Vitals>) -> F.Store():
  match result:
    case Col.Accepted{column,_}:F.put_main(rest,column)
    case Col.Rejected{column,_}:F.put_main(rest,column)
def main_taken(handle:W.Handle<T.HealthSchema>,observed:F.Rest() & Col.Column<T.HealthSchema,T.Vitals>) -> F.Store():
  match observed:
    case (rest,column):main_cleared(rest,Col.clear(~T.HealthSchema,~T.Vitals,column,W.handle_index(~T.HealthSchema,handle)))
def clear_main(store:F.Store(),handle:W.Handle<T.HealthSchema>) -> F.Store():main_taken(handle,F.take_main(store))

def aux_cleared(rest:F.AuxRest(),result:Col.SwapOutcome<T.HealthSchema,T.Armor>) -> F.Store():
  match result:
    case Col.Accepted{column,_}:F.put_aux(rest,column)
    case Col.Rejected{column,_}:F.put_aux(rest,column)
def aux_taken(handle:W.Handle<T.HealthSchema>,observed:F.AuxRest() & Col.Column<T.HealthSchema,T.Armor>) -> F.Store():
  match observed:
    case (rest,column):aux_cleared(rest,Col.clear(~T.HealthSchema,~T.Armor,column,W.handle_index(~T.HealthSchema,handle)))
def clear_aux(store:F.Store(),handle:W.Handle<T.HealthSchema>) -> F.Store():aux_taken(handle,F.take_aux(store))

def flag_cleared(rest:F.FlagRest(),result:Col.SwapOutcome<T.HealthSchema,T.Tracked>) -> F.Store():
  match result:
    case Col.Accepted{column,_}:F.put_flag(rest,column)
    case Col.Rejected{column,_}:F.put_flag(rest,column)
def flag_taken(handle:W.Handle<T.HealthSchema>,observed:F.FlagRest() & Col.Column<T.HealthSchema,T.Tracked>) -> F.Store():
  match observed:
    case (rest,column):flag_cleared(rest,Col.clear(~T.HealthSchema,~T.Tracked,column,W.handle_index(~T.HealthSchema,handle)))
def clear_flag(store:F.Store(),handle:W.Handle<T.HealthSchema>) -> F.Store():flag_taken(handle,F.take_flag(store))

def clear_all_copy(store:F.Store(),+handle:W.Handle<T.HealthSchema>) -> F.Store() & List<&2,E.event_type()>:(clear_flag(clear_aux(clear_main(store,handle),handle),handle),[])
def clear_all(store:F.Store(),handle:W.Handle<T.HealthSchema>) -> F.Store() & List<&2,E.event_type()>:clear_all_copy(store,handle)
def removed_record(handle:W.Handle<T.HealthSchema>) -> E.event_type():Notice.Original{E.Removed{handle}}
def despawned_record(handle:W.Handle<T.HealthSchema>) -> E.event_type():Notice.Original{E.Despawned{handle}}
def dispose_queued(owner:Array<U32>,frame:Frame,result:Tx.Tx<F.World(),E.event_type()> & W.Status) -> Local.Outcome<F.World(),Array<U32>,Unit,Frame>:
  match result:
    case (tx,W.Accepted{}):completed(owner,finish(2,frame,Tx.Success{},tx))
    case (tx,_):completed(owner,finish(2,frame,Tx.Failure{Unit{}},tx))
def dispose_removed(owner:Array<U32>,frame:Frame,+handle:W.Handle<T.HealthSchema>,result:St.Queued<Tx.Tx<F.World(),E.event_type()>,T.Vitals>) -> Local.Outcome<F.World(),Array<U32>,Unit,Frame>:
  match result:
    case St.Queued{tx}:dispose_queued(owner,frame,Cmd.tx_despawn_observed(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),~clear_all,~despawned_record,tx,handle))
    case St.QueueRejected{tx,_,_}:completed(owner,finish(2,frame,Tx.Failure{Unit{}},tx))
def dispose(world:F.World(),owner:Array<U32>,frame:Frame) -> Local.Outcome<F.World(),Array<U32>,Unit,Frame>:
  match frame:
    case Frame{count,iteration,Some{+handle},reservations,facts}:dispose_removed(bump(owner),Frame{count,iteration,Some{handle},reservations,facts},handle,St.tx_remove_observed(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),~F.Rest(),~T.Vitals,~T.VitalsView,~T.VitalsToken,~F.take_main,~F.put_main,~P.vitals_get,~removed_record,F.main_family(),Cmd.tx_begin(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),world),handle))
    case _:Local.Failed{world,bump(owner),Unit{}}

def fresh_frame(frame:Frame) -> Frame:
  match frame:
    case Frame{count,iteration,transient,reservations,_}:Frame{count,iteration,transient,reservations,[]}
