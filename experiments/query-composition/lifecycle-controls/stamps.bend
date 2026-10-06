import Base
import ../../../examples/user-simulation/schema.bend as S
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/component.bend as C
import ../../../src/ecs/lifecycle.bend as L
import ../../../src/ecs/transaction.bend as T
import ../../../src/ecs/commands.bend as Cmd
import ../../../src/ecs/system.bend as Sys

def position() -> C.Family<S.Schema,S.Store,S.PositionRest,S.Position,S.PositionView,S.PositionToken,S.take_positions,S.put_positions,S.project_position>: C.Family{"collision"}
def velocity() -> C.Family<S.Schema,S.Store,S.VelocityRest,S.Velocity,S.VelocityView,S.VelocityToken,S.take_velocities,S.put_velocities,S.project_velocity>: C.Family{"collision"}
def owner() -> S.Position: S.Position{7.0,ANode{ALeaf{71},ALeaf{72}}}
def write(world: W.World<S.Schema,S.Store,F32,S.SimEvent>,handle: W.Handle<S.Schema>) -> W.World<S.Schema,S.Store,F32,S.SimEvent>:
  S.consume_replaced(~S.Position,C.replace(~S.Schema,~S.Store,~F32,~S.SimEvent,~S.PositionRest,~S.Position,~S.PositionView,~S.PositionToken,~S.take_positions,~S.put_positions,~S.project_position,position(),world,handle,Some{owner()}))
def remove(world: W.World<S.Schema,S.Store,F32,S.SimEvent>,handle: W.Handle<S.Schema>) -> W.World<S.Schema,S.Store,F32,S.SimEvent>:
  S.consume_replaced(~S.Position,C.replace(~S.Schema,~S.Store,~F32,~S.SimEvent,~S.PositionRest,~S.Position,~S.PositionView,~S.PositionToken,~S.take_positions,~S.put_positions,~S.project_position,position(),world,handle,None{}))
def stamp(world: W.World<S.Schema,S.Store,F32,S.SimEvent>,handle: W.Handle<S.Schema>) -> W.World<S.Schema,S.Store,F32,S.SimEvent> & L.Stamp:
  C.lifecycle(~S.Schema,~S.Store,~F32,~S.SimEvent,~S.PositionRest,~S.Position,~S.PositionView,~S.PositionToken,~S.take_positions,~S.put_positions,~S.project_position,position(),world,handle)
def check(actual: L.Stamp,added: U32,changed: U32) -> Bool:
  match actual:
    case L.Stamp{a,c}: U32.is_eq(a,added) && U32.is_eq(c,changed)
def bool_string(value: Bool) -> String:
  match value:
    case True{}: "true"
    case False{}: "false"
def checked(label: String,+expectedAdded: U32,+expectedChanged: U32,observed: W.World<S.Schema,S.Store,F32,S.SimEvent> & L.Stamp) -> W.World<S.Schema,S.Store,F32,S.SimEvent> & String:
  (world,actual) = observed
  (world,String.append(label,String.append(":",String.append(bool_string(check(actual,expectedAdded,expectedChanged)),";"))))
def outcome_world(result: T.Returned<W.World<S.Schema,S.Store,F32,S.SimEvent>,U32>) -> W.World<S.Schema,S.Store,F32,S.SimEvent>:
  match result:
    case T.Returned{world,_}: world
def written(result: C.SetResult<T.Tx<W.World<S.Schema,S.Store,F32,S.SimEvent>,S.SimEvent>,S.Position>) -> T.Tx<W.World<S.Schema,S.Store,F32,S.SimEvent>,S.SimEvent>:
  match result:
    case C.Written{tx}: tx
    case C.WriteRejected{tx,_,_}: tx
    case C.WriteFailure{tx,_}: tx
def removed(result: C.RemoveResult<T.Tx<W.World<S.Schema,S.Store,F32,S.SimEvent>,S.SimEvent>>) -> T.Tx<W.World<S.Schema,S.Store,F32,S.SimEvent>,S.SimEvent>:
  match result:
    case C.Removed{tx}: tx
    case C.RemoveRejected{tx,_}: tx

def failure(world: W.World<S.Schema,S.Store,F32,S.SimEvent>,+handle: W.Handle<S.Schema>) -> W.World<S.Schema,S.Store,F32,S.SimEvent>:
  tx = T.begin(~W.World<S.Schema,S.Store,F32,S.SimEvent>,~S.SimEvent,world)
  tx = written(C.tx_set(~S.Schema,~S.Store,~F32,~S.SimEvent,~S.PositionRest,~S.Position,~S.PositionView,~S.PositionToken,~S.take_positions,~S.put_positions,~S.project_position,position(),tx,handle,S.Position{99.0,ALeaf{99}}))
  tx = removed(C.tx_remove(~S.Schema,~S.Store,~F32,~S.SimEvent,~S.PositionRest,~S.Position,~S.PositionView,~S.PositionToken,~S.take_positions,~S.put_positions,~S.project_position,position(),tx,handle))
  tx = written(C.tx_set(~S.Schema,~S.Store,~F32,~S.SimEvent,~S.PositionRest,~S.Position,~S.PositionView,~S.PositionToken,~S.take_positions,~S.put_positions,~S.project_position,position(),tx,handle,S.Position{88.0,ALeaf{88}}))
  outcome_world(Cmd.tx_finish(~S.Schema,~S.Store,~F32,~S.SimEvent,~U32,tx,T.Failure{1}))

def stage5_join(+handle: W.Handle<S.Schema>,+prior: String,observed: W.World<S.Schema,S.Store,F32,S.SimEvent> & String) -> String:
  (world,result) = observed
  +result = String.append(prior,result)
  result

def stage5(world: W.World<S.Schema,S.Store,F32,S.SimEvent>,+handle: W.Handle<S.Schema>,+prior: String) -> String:
  stage5_join(handle,prior,checked("re-add",8,8,stamp(write(world,handle),handle)))

def stage4_join(+handle: W.Handle<S.Schema>,+prior: String,observed: W.World<S.Schema,S.Store,F32,S.SimEvent> & String) -> String:
  (world,result) = observed
  +result = String.append(prior,result)
  stage5(world,handle,result)

def stage4(world: W.World<S.Schema,S.Store,F32,S.SimEvent>,+handle: W.Handle<S.Schema>,+prior: String) -> String:
  stage4_join(handle,prior,checked("remove",0,0,stamp(remove(world,handle),handle)))

def payload_ok(values: List<&2,U32>) -> Bool:
  match values:
    case Con{a,Con{b,Nil{}}}: U32.is_eq(a,71) && U32.is_eq(b,72)
    case _: False{}
def owner_observed(observed: W.World<S.Schema,S.Store,F32,S.SimEvent> & C.Access<S.PositionView>) -> W.World<S.Schema,S.Store,F32,S.SimEvent> & String:
  match observed:
    case (world,C.Found{S.PositionView{x,values}}): (world,String.append("restored-owner:",String.append(bool_string(F32.is_eq(x,7.0) && payload_ok(values)),";")))
    case (world,_): (world,"restored-owner:false;")
def owner_check(world: W.World<S.Schema,S.Store,F32,S.SimEvent>,handle: W.Handle<S.Schema>) -> W.World<S.Schema,S.Store,F32,S.SimEvent> & String:
  owner_observed(C.get(~S.Schema,~S.Store,~F32,~S.SimEvent,~S.PositionRest,~S.Position,~S.PositionView,~S.PositionToken,~S.take_positions,~S.put_positions,~S.project_position,position(),world,handle))
def collision_check(world: W.World<S.Schema,S.Store,F32,S.SimEvent>,+handle: W.Handle<S.Schema>) -> W.World<S.Schema,S.Store,F32,S.SimEvent> & String:
  world = S.consume_replaced(~S.Velocity,C.replace(~S.Schema,~S.Store,~F32,~S.SimEvent,~S.VelocityRest,~S.Velocity,~S.VelocityView,~S.VelocityToken,~S.take_velocities,~S.put_velocities,~S.project_velocity,velocity(),world,handle,Some{S.Velocity{2.0,ALeaf{12}}}))
  checked("same-name-other-family",1,2,stamp(world,handle))
def rollback_owner_join(+handle: W.Handle<S.Schema>,+prior: String,observed: W.World<S.Schema,S.Store,F32,S.SimEvent> & String) -> String:
  (world,result) = observed
  stage4(world,handle,String.append(prior,result))
def rollback_extra_join(+handle: W.Handle<S.Schema>,+prior: String,observed: W.World<S.Schema,S.Store,F32,S.SimEvent> & String) -> String:
  (world,result) = observed
  rollback_owner_join(handle,String.append(prior,result),owner_check(world,handle))
def stage3_join(+handle: W.Handle<S.Schema>,+prior: String,observed: W.World<S.Schema,S.Store,F32,S.SimEvent> & String) -> String:
  (world,result) = observed
  +result = String.append(prior,result)
  rollback_extra_join(handle,result,collision_check(world,handle))

def stage3(world: W.World<S.Schema,S.Store,F32,S.SimEvent>,+handle: W.Handle<S.Schema>,+prior: String) -> String:
  stage3_join(handle,prior,checked("rollback",1,2,stamp(failure(world,handle),handle)))

def stage2_join(+handle: W.Handle<S.Schema>,+prior: String,observed: W.World<S.Schema,S.Store,F32,S.SimEvent> & String) -> String:
  (world,result) = observed
  +result = String.append(prior,result)
  stage3(world,handle,result)

def stage2(world: W.World<S.Schema,S.Store,F32,S.SimEvent>,+handle: W.Handle<S.Schema>,+prior: String) -> String:
  stage2_join(handle,prior,checked("equal-write",1,2,stamp(write(world,handle),handle)))

def stage1_join(+handle: W.Handle<S.Schema>,+prior: String,observed: W.World<S.Schema,S.Store,F32,S.SimEvent> & String) -> String:
  (world,result) = observed
  +result = String.append(prior,result)
  stage2(world,handle,result)

def stage1(world: W.World<S.Schema,S.Store,F32,S.SimEvent>,+handle: W.Handle<S.Schema>,+prior: String) -> String:
  stage1_join(handle,prior,checked("add",1,1,stamp(write(world,handle),handle)))

def stage0_join(+handle: W.Handle<S.Schema>,+prior: String,observed: W.World<S.Schema,S.Store,F32,S.SimEvent> & String) -> String:
  (world,result) = observed
  +result = String.append(prior,result)
  stage1(world,handle,result)

def stage0(world: W.World<S.Schema,S.Store,F32,S.SimEvent>,+handle: W.Handle<S.Schema>,+prior: String) -> String:
  stage0_join(handle,prior,checked("empty",0,0,stamp(world,handle)))

def trial_activated(activated: W.World<S.Schema,S.Store,F32,S.SimEvent> & W.Status,+handle: W.Handle<S.Schema>) -> String:
  (world,_) = activated
  stage0(world,handle,"")
def trial_reserved(reserved: W.World<S.Schema,S.Store,F32,S.SimEvent> & W.Reservation<S.Schema>) -> String:
  match reserved:
    case (world,W.ReservationRejected{_}): "reservation:false;"
    case (world,W.Reserved{+handle}): trial_activated(W.activate(~S.Schema,~S.Store,~F32,~S.SimEvent,world,handle),handle)
def trial_created(created: W.Creation<S.Schema,S.Store,F32,S.SimEvent>) -> String:
  match created:
    case W.CreateRejected{_,_}: "creation:false;"
    case W.Created{_,world}: trial_reserved(W.reserve_id(~S.Schema,~S.Store,~F32,~S.SimEvent,world))
def main() -> IO(Unit):
  IO.print(trial_created(S.create(W.factory(),1.0)))
