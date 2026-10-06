import Base
import ../../../examples/user-simulation/schema.bend as S
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/component.bend as C
import ../../../src/ecs/lifecycle.bend as L
import stamps.bend as A

def force_exhaustion(world: W.World<S.Schema,S.Store,F32,S.SimEvent>) -> W.World<S.Schema,S.Store,F32,S.SimEvent>:
  match world:
    case W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,_}: W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,4294967295}
def force_last_clock(world: W.World<S.Schema,S.Store,F32,S.SimEvent>) -> W.World<S.Schema,S.Store,F32,S.SimEvent>:
  match world:
    case W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,_}: W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,4294967294}
def verify_stamp(observed: W.World<S.Schema,S.Store,F32,S.SimEvent> & L.Stamp) -> String:
  (world,stamp) = observed
  String.append("exhaustion-preserves-stamp:",String.append(A.bool_string(A.check(stamp,1,2)),";"))
def verify_clock(+handle: W.Handle<S.Schema>,observed: W.World<S.Schema,S.Store,F32,S.SimEvent> & U32) -> String:
  (world,tick) = observed
  String.append(String.append("exhaustion-clock:",String.append(A.bool_string(U32.is_eq(tick,4294967295)),";")),verify_stamp(A.stamp(world,handle)))
def rejected(+handle: W.Handle<S.Schema>,result: C.Replacement<W.World<S.Schema,S.Store,F32,S.SimEvent>,S.Position>) -> String:
  match result:
    case C.ReplaceRejected{world,Some{S.Position{x,ALeaf{v}}},W.CapacityExceeded{}}: String.append(String.append("exhaustion-recovers-incoming:",String.append(A.bool_string(F32.is_eq(x,9.0) && U32.is_eq(v,91)),";")),verify_clock(handle,W.clock(~S.Schema,~S.Store,~F32,~S.SimEvent,world)))
    case _: "exhaustion:false;"
def exhaustion(world: W.World<S.Schema,S.Store,F32,S.SimEvent>,+handle: W.Handle<S.Schema>) -> String:
  world = A.write(world,handle)
  world = A.failure(force_last_clock(world),handle)
  rejected(handle,C.replace(~S.Schema,~S.Store,~F32,~S.SimEvent,~S.PositionRest,~S.Position,~S.PositionView,~S.PositionToken,~S.take_positions,~S.put_positions,~S.project_position,A.position(),force_exhaustion(world),handle,Some{S.Position{9.0,ALeaf{91}}}))
def after_barrier(+handle: W.Handle<S.Schema>,+prior: String,observed: W.World<S.Schema,S.Store,F32,S.SimEvent> & String) -> String:
  (world,result) = observed
  String.append(String.append(prior,result),exhaustion(world,handle))
def before_barrier(+handle: W.Handle<S.Schema>,observed: W.World<S.Schema,S.Store,F32,S.SimEvent> & String) -> String:
  (world,prior) = observed
  after_barrier(handle,prior,A.checked("deferred-after-barrier",1,1,A.stamp(W.barrier(~S.Schema,~S.Store,~F32,~S.SimEvent,world),handle)))
def activated(+handle: W.Handle<S.Schema>,observed: W.World<S.Schema,S.Store,F32,S.SimEvent> & W.Status) -> String:
  (world,_) = observed
  world = W.enqueue(~S.Schema,~S.Store,~F32,~S.SimEvent,world,(world => A.write(world,handle)))
  before_barrier(handle,A.checked("deferred-before-barrier",0,0,A.stamp(world,handle)))
def reserved(result: W.World<S.Schema,S.Store,F32,S.SimEvent> & W.Reservation<S.Schema>) -> String:
  match result:
    case (world,W.ReservationRejected{_}): "reservation:false;"
    case (world,W.Reserved{+handle}): activated(handle,W.activate(~S.Schema,~S.Store,~F32,~S.SimEvent,world,handle))
def created(result: W.Creation<S.Schema,S.Store,F32,S.SimEvent>) -> String:
  match result:
    case W.CreateRejected{_,_}: "creation:false;"
    case W.Created{_,world}: reserved(W.reserve_id(~S.Schema,~S.Store,~F32,~S.SimEvent,world))
def main() -> IO(Unit): IO.print(created(S.create(W.factory(),1.0)))
