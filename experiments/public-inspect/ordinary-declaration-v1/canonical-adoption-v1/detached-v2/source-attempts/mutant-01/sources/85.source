import Base
import world.bend as W
import event-runtime.bend as Ev

# Affine transport owner for two independently retained Data streams. Gameplay
# does not receive this owner. The closed classifier belongs to schema setup.
type Events<S: Data,E: Data> is Type:
  Events{namespace: U32,batches: List<&2,Ev.Batch<E>>,positions: List<&2,Ev.Position>,nextReader: U32,tick: Nat,frameStart: Nat,boundary: Nat,capacity: Nat,dropped: Nat,values: List<&2,E>}
type Detached<S: Data,C: Type,R: Type,E: Data> is Type:
  Detached{world: W.World<S,C,R,E>,events: Events<S,E>}
def choose(~E: Data,selected: Bool,+value: E,+events: List<&2,E>,+removals: List<&2,E>) -> List<&2,E> & List<&2,E>:
  match selected:
    case True{}: (value <> events,removals)
    case False{}: (events,value <> removals)
def split_reverse(~E: Data,pair: List<&2,E> & List<&2,E>) -> List<&2,E> & List<&2,E>:
  (events,removals) = pair
  (List.reverse(&2,E,events),List.reverse(&2,E,removals))
def split_loop(~E: Data,~is_event: E -> Bool,values: List<&2,E>,acc: List<&2,E> & List<&2,E>) -> List<&2,E> & List<&2,E>:
  match values:
    case []: split_reverse(~E,acc)
    case +value <> rest:
      (events,removals) = acc
      split_loop(~E,~is_event,rest,choose(~E,is_event(value),value,events,removals))
def split(~E: Data,~is_event: E -> Bool,values: List<&2,E>) -> List<&2,E> & List<&2,E>:
  split_loop(~E,~is_event,values,([],[]))
def detached_values(~S: Data,~C: Type,~R: Type,~E: Data,+namespace: U32,+batches: List<&2,Ev.Batch<E>>,+positions: List<&2,Ev.Position>,+nextReader: U32,+tick: Nat,+frameStart: Nat,+boundary: Nat,+capacity: Nat,+dropped: Nat,+removals: List<&2,E>,observed: W.World<S,C,R,E> & List<&2,E>) -> Detached<S,C,R,E>:
  (world,+values) = observed
  Detached{W.events_replace(~S,~C,~R,~E,world,removals),Events{namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped,values}}
def detach(~S: Data,~C: Type,~R: Type,~E: Data,runtime: Ev.Runtime<S,C,R,E>,+removals: List<&2,E>) -> Detached<S,C,R,E>:
  match runtime:
    case Ev.Runtime{world,+ns,+batches,+positions,+next,+tick,+start,+boundary,+capacity,+dropped}: detached_values(~S,~C,~R,~E,ns,batches,positions,next,tick,start,boundary,capacity,dropped,removals,W.events_view(~S,~C,~R,~E,world))
def attach(~S: Data,~C: Type,~R: Type,~E: Data,events: Events<S,E>,world: W.World<S,C,R,E>) -> Ev.Runtime<S,C,R,E>:
  match events:
    case Events{ns,batches,positions,next,tick,start,boundary,capacity,dropped,+values}: Ev.Runtime{W.events_replace(~S,~C,~R,~E,world,values),ns,batches,positions,next,tick,start,boundary,capacity,dropped}
# Absorb newly committed ordinary events from a removal-domain World through
# the real Event runtime publication synchronization. Deferred barriers use
# this same operation; rollback leaves no publication delta to transport.
def collected(~S: Data,~C: Type,~R: Type,~E: Data,world: W.World<S,C,R,E>,events: Events<S,E>,partition: List<&2,E> & List<&2,E>) -> Detached<S,C,R,E>:
  match events partition:
    case Events{+ns,+batches,+positions,+next,+tick,+start,+boundary,+capacity,+dropped,+old}, (+fresh,+removals):
      +all = Ev.append(~E,old,fresh)
      detach(~S,~C,~R,~E,Ev.sync_values(~S,~C,~R,~E,(W.events_replace(~S,~C,~R,~E,world,all),all),ns,batches,positions,next,1n+tick,start,boundary,capacity,dropped),removals)
def collect_view(~S: Data,~C: Type,~R: Type,~E: Data,~is_event: E -> Bool,events: Events<S,E>,observed: W.World<S,C,R,E> & List<&2,E>) -> Detached<S,C,R,E>:
  (world,+values) = observed
  collected(~S,~C,~R,~E,world,events,split(~E,~is_event,values))
def collect(~S: Data,~C: Type,~R: Type,~E: Data,~is_event: E -> Bool,events: Events<S,E>,world: W.World<S,C,R,E>) -> Detached<S,C,R,E>:
  collect_view(~S,~C,~R,~E,~is_event,events,W.events_view(~S,~C,~R,~E,world))

# Reusable pre-dispatch seam. The setup callback receives the actual separated
# event metadata and complete World owners; no affine owner is copied.
def driven(~S: Data,~C: Type,~R: Type,~E: Data,~H: Type,~Out: Type,~body: Events<S,E> -> H -> W.World<S,C,R,E> -> Out,owners: H,result: Detached<S,C,R,E>) -> Out:
  match result:
    case Detached{world,events}: body(events,owners,world)
def drive(~S: Data,~C: Type,~R: Type,~E: Data,~H: Type,~Out: Type,~is_event: E -> Bool,~body: Events<S,E> -> H -> W.World<S,C,R,E> -> Out,events: Events<S,E>,owners: H,world: W.World<S,C,R,E>) -> Out:
  driven(~S,~C,~R,~E,~H,~Out,~body,owners,collect(~S,~C,~R,~E,~is_event,events,world))

# Event cursors are publication ticks, not list offsets. Removing notice-only
# batches therefore retains every real cursor/tick and the original dropped
# boundary. Ev.run does not trim; retention is applied only by Ev.frame.
def event_batch(~E: Data,~is_event: E -> Bool,+tick: Nat,filtered: List<&2,E> & List<&2,E>,rest: List<&2,Ev.Batch<E>>) -> List<&2,Ev.Batch<E>>:
  match filtered:
    case ([],_): rest
    case (items,_): Ev.Batch{tick,items} <> rest
def event_batches_loop(~E: Data,~is_event: E -> Bool,batches: List<&2,Ev.Batch<E>>,acc: List<&2,Ev.Batch<E>>) -> List<&2,Ev.Batch<E>>:
  match batches:
    case []: List.reverse(&2,Ev.Batch<E>,acc)
    case Ev.Batch{tick,items} <> rest: event_batches_loop(~E,~is_event,rest,event_batch(~E,~is_event,tick,split(~E,~is_event,items),acc))
def event_batches(~E: Data,~is_event: E -> Bool,batches: List<&2,Ev.Batch<E>>) -> List<&2,Ev.Batch<E>>:
  event_batches_loop(~E,~is_event,batches,[])
def recovered(~S: Data,~C: Type,~R: Type,~E: Data,~is_event: E -> Bool,world: W.World<S,C,R,E>,+namespace: U32,+batches: List<&2,Ev.Batch<E>>,+positions: List<&2,Ev.Position>,+nextReader: U32,+tick: Nat,+frameStart: Nat,+boundary: Nat,+capacity: Nat,+dropped: Nat,+old_removals: List<&2,E>,partition: List<&2,E> & List<&2,E>) -> Detached<S,C,R,E>:
  match partition:
    case (+values,+fresh_removals): Detached{W.events_replace(~S,~C,~R,~E,world,Ev.append(~E,old_removals,fresh_removals)),Events{namespace,event_batches(~E,~is_event,batches),positions,nextReader,tick,frameStart,boundary,capacity,dropped,values}}
def recovery_view(~S: Data,~C: Type,~R: Type,~E: Data,~is_event: E -> Bool,+namespace: U32,+batches: List<&2,Ev.Batch<E>>,+positions: List<&2,Ev.Position>,+nextReader: U32,+tick: Nat,+frameStart: Nat,+boundary: Nat,+capacity: Nat,+dropped: Nat,+old_removals: List<&2,E>,observed: W.World<S,C,R,E> & List<&2,E>) -> Detached<S,C,R,E>:
  (world,values) = observed
  recovered(~S,~C,~R,~E,~is_event,world,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped,old_removals,split(~E,~is_event,values))
def recover(~S: Data,~C: Type,~R: Type,~E: Data,~is_event: E -> Bool,runtime: Ev.Runtime<S,C,R,E>,+old_removals: List<&2,E>) -> Detached<S,C,R,E>:
  match runtime:
    case Ev.Runtime{world,+namespace,+batches,+positions,+nextReader,+tick,+frameStart,+boundary,+capacity,+dropped}: recovery_view(~S,~C,~R,~E,~is_event,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped,old_removals,W.events_view(~S,~C,~R,~E,world))
