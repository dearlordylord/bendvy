import Base
import schema.bend as S
import simulation.bend as Sim
import json.bend as J
import ../../src/ecs/world.bend as W
import ../../src/ecs/transaction.bend as T
import ../../src/ecs/component.bend as C
import ../../src/ecs/commands.bend as Cmd
import ../../src/ecs/structural.bend as St
import ../../src/ecs/events.bend as E
import ../../src/ecs/system.bend as Sys
import ../../src/ecs/provider.bend as Pv
import ../../src/ecs/query.bend as Q

def World() -> Type:
  W.World<S.Schema,S.Store,F32,S.SimEvent>
def Tx() -> Type:
  T.Tx<World(),S.SimEvent>
def error_text(error: Pv.Error<Sim.UserError>) -> String:
  match error:
    case Pv.UserError{Sim.Rejected{}}: "Rejected"
    case _: "UnexpectedFailure"
def runner_result(result: T.Returned<World(),Pv.Error<Sim.UserError>>) -> Sys.Outcome<World(),String,Unit>:
  match result:
    case T.Returned{world,T.Success{}}: Sys.Succeeded{world,Unit{}}
    case T.Returned{world,T.Failure{error}}: Sys.Failed{world,error_text(error)}
def run_movement(world: World(),args: Unit) -> Sys.Outcome<World(),String,Unit>:
  runner_result(Sim.movement(world))
def run_damage(world: World(),args: Unit) -> Sys.Outcome<World(),String,Unit>:
  runner_result(Sim.damage(world))
def run_retry(world: World(),args: Bool) -> Sys.Outcome<World(),String,Unit>:
  runner_result(Sim.retry(world,args))
type Checkpoint is Data:
  Observed{label: String,snapshot: Sim.Snapshot,filtered: List<&2,U32>}
  FailedResult{label: String,error: String}
  ForeignResult{foreignId: U32,localId: U32,missing: Bool,queueUnchanged: Bool,postBarrierUnchanged: Bool}
type State is Type:
  State{factory: W.Factory,world: World(),reader: E.Reader<S.Schema>,movement: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,Unit,String,Unit,run_movement>,damage: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,Unit,String,Unit,run_damage>,retry: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,Bool,String,Unit,run_retry>,checkpoints: List<&2,Checkpoint>}
def filter_body(~H: Type,~get: H -> H & C.Access<S.Tag>,~aux: H -> H & C.Access<S.VelocityView>,~resource_get: H -> H & F32,args: Unit,handle: W.Handle<S.Schema>,ctx: H) -> H & U32:
  (ctx,Sim.handle_id(handle))
def filtered(world: World()) -> World() & List<&2,U32>:
  Q.each_read(~S.Schema,~S.Store,~F32,~S.SimEvent,~S.TagRest,~S.Tag,~S.Tag,~S.TagToken,~S.take_tags,~S.put_tags,~S.project_tag,~S.VelocityRest,~S.Velocity,~S.VelocityView,~S.VelocityToken,~S.take_velocities,~S.put_velocities,~S.project_velocity,~F32,~Sim.resource_view,~S.Bundle,~S.populate,~S.clear,~Unit,~U32,~filter_body,S.tag(),S.velocity(),Q.Absent{},world,Unit{})
def record_filter(+label: String,+snapshot: Sim.Snapshot,factory: W.Factory,reader: E.Reader<S.Schema>,movement: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,Unit,String,Unit,run_movement>,damage: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,Unit,String,Unit,run_damage>,retry: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,Bool,String,Unit,run_retry>,+checkpoints: List<&2,Checkpoint>,result: World() & List<&2,U32>) -> State:
  (world,+ids) = result
  State{factory,world,reader,movement,damage,retry,Observed{label,snapshot,ids} <> checkpoints}
def record_observed(+label: String,factory: W.Factory,movement: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,Unit,String,Unit,run_movement>,damage: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,Unit,String,Unit,run_damage>,retry: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,Bool,String,Unit,run_retry>,+checkpoints: List<&2,Checkpoint>,result: Sim.Observation) -> State:
  match result:
    case Sim.Observation{world,reader,+snapshot}: record_filter(label,snapshot,factory,reader,movement,damage,retry,checkpoints,filtered(world))
    case Sim.ObservationRejected{world,reader}: State{factory,world,reader,movement,damage,retry,FailedResult{label,"ForeignReader"} <> checkpoints}
def record(state: State,+label: String) -> State:
  match state:
    case State{factory,world,reader,movement,damage,retry,+checkpoints}: record_observed(label,factory,movement,damage,retry,checkpoints,Sim.observe(world,reader))
def barrier(state: State) -> State:
  match state:
    case State{factory,world,reader,movement,damage,retry,+checkpoints}: State{factory,W.barrier(~S.Schema,~S.Store,~F32,~S.SimEvent,world),reader,movement,damage,retry,checkpoints}
def ran_movement(factory: W.Factory,reader: E.Reader<S.Schema>,damage: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,Unit,String,Unit,run_damage>,retry: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,Bool,String,Unit,run_retry>,+checkpoints: List<&2,Checkpoint>,result: Sys.RunResult<S.Schema,S.Store,F32,S.SimEvent,Unit,String,Unit,run_movement>) -> State:
  match result:
    case Sys.Completed{movement,Sys.Succeeded{world,_}}: State{factory,world,reader,movement,damage,retry,checkpoints}
    case Sys.Completed{movement,Sys.Failed{world,+error}}: State{factory,world,reader,movement,damage,retry,FailedResult{"failed-result",error} <> checkpoints}
    case Sys.RegistrationRejected{movement,world,_}: State{factory,world,reader,movement,damage,retry,FailedResult{"failed-result","RegistrationRejected"} <> checkpoints}
def step_movement(state: State) -> State:
  match state:
    case State{factory,world,reader,movement,damage,retry,+checkpoints}: ran_movement(factory,reader,damage,retry,checkpoints,Sys.run(~S.Schema,~S.Store,~F32,~S.SimEvent,~Unit,~String,~Unit,~run_movement,movement,world,Unit{}))
def ran_damage(factory: W.Factory,reader: E.Reader<S.Schema>,movement: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,Unit,String,Unit,run_movement>,retry: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,Bool,String,Unit,run_retry>,+checkpoints: List<&2,Checkpoint>,result: Sys.RunResult<S.Schema,S.Store,F32,S.SimEvent,Unit,String,Unit,run_damage>) -> State:
  match result:
    case Sys.Completed{damage,Sys.Succeeded{world,_}}: State{factory,world,reader,movement,damage,retry,checkpoints}
    case Sys.Completed{damage,Sys.Failed{world,+error}}: State{factory,world,reader,movement,damage,retry,FailedResult{"failed-result",error} <> checkpoints}
    case Sys.RegistrationRejected{damage,world,_}: State{factory,world,reader,movement,damage,retry,FailedResult{"failed-result","RegistrationRejected"} <> checkpoints}
def step_damage(state: State) -> State:
  match state:
    case State{factory,world,reader,movement,damage,retry,+checkpoints}: ran_damage(factory,reader,movement,retry,checkpoints,Sys.run(~S.Schema,~S.Store,~F32,~S.SimEvent,~Unit,~String,~Unit,~run_damage,damage,world,Unit{}))
def ran_retry(factory: W.Factory,reader: E.Reader<S.Schema>,movement: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,Unit,String,Unit,run_movement>,damage: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,Unit,String,Unit,run_damage>,+checkpoints: List<&2,Checkpoint>,result: Sys.RunResult<S.Schema,S.Store,F32,S.SimEvent,Bool,String,Unit,run_retry>) -> State:
  match result:
    case Sys.Completed{retry,Sys.Succeeded{world,_}}: State{factory,world,reader,movement,damage,retry,checkpoints}
    case Sys.Completed{retry,Sys.Failed{world,+error}}: State{factory,world,reader,movement,damage,retry,FailedResult{"failed-result",error} <> checkpoints}
    case Sys.RegistrationRejected{retry,world,_}: State{factory,world,reader,movement,damage,retry,FailedResult{"failed-result","RegistrationRejected"} <> checkpoints}
def step_retry(state: State,args: Bool) -> State:
  match state:
    case State{factory,world,reader,movement,damage,retry,+checkpoints}: ran_retry(factory,reader,movement,damage,checkpoints,Sys.run(~S.Schema,~S.Store,~F32,~S.SimEvent,~Bool,~String,~Unit,~run_retry,retry,world,args))
def committed(result: T.Returned<World(),String>) -> World():
  match result:
    case T.Returned{world,_}: world
def commit(tx: Tx()) -> World():
  committed(T.finish(~World(),~S.SimEvent,~String,~Cmd.enqueue(~S.Schema,~S.Store,~F32,~S.SimEvent),~Cmd.publish(~S.Schema,~S.Store,~F32,~S.SimEvent),tx,T.Success{}))
def spawn_next(result: Tx() & W.Reservation<S.Schema>) -> Tx():
  (tx,_) = result
  tx
def spawn(world: World()) -> World():
  commit(spawn_next(Cmd.tx_spawn(~S.Schema,~S.Store,~F32,~S.SimEvent,~S.Bundle,~S.populate,spawn_next(Cmd.tx_spawn(~S.Schema,~S.Store,~F32,~S.SimEvent,~S.Bundle,~S.populate,spawn_next(Cmd.tx_spawn(~S.Schema,~S.Store,~F32,~S.SimEvent,~S.Bundle,~S.populate,T.begin(~World(),~S.SimEvent,world),S.actor_a())),S.actor_b())),S.actor_c())))
def replace_world(state: State,effect: World() -> World()) -> State:
  match state:
    case State{factory,world,reader,movement,damage,retry,+checkpoints}: State{factory,effect(world),reader,movement,damage,retry,checkpoints}
def queued(~Owner: Type,result: St.Queued<Tx(),Owner>) -> Tx():
  match result:
    case St.Queued{tx}: tx
    case St.QueueRejected{tx,_,_}: tx
def insert_velocity(tx: Tx()) -> Tx():
  queued(~S.Velocity,St.tx_insert(~S.Schema,~S.Store,~F32,~S.SimEvent,~S.VelocityRest,~S.Velocity,~S.VelocityView,~S.VelocityToken,~S.take_velocities,~S.put_velocities,~S.project_velocity,S.velocity(),tx,W.Handle{1,3},S.Velocity{3.0,ALeaf{23}}))
def insert_armor(tx: Tx()) -> Tx():
  queued(~S.Armor,St.tx_insert(~S.Schema,~S.Store,~F32,~S.SimEvent,~S.ArmorRest,~S.Armor,~S.Armor,~S.ArmorToken,~S.take_armors,~S.put_armors,~S.project_armor,S.armor(),tx,W.Handle{1,3},S.Armor{2.0}))
def remove_velocity(tx: Tx()) -> Tx():
  queued(~S.Velocity,St.tx_remove(~S.Schema,~S.Store,~F32,~S.SimEvent,~S.VelocityRest,~S.Velocity,~S.VelocityView,~S.VelocityToken,~S.take_velocities,~S.put_velocities,~S.project_velocity,S.velocity(),tx,W.Handle{1,1}))
def insert(world: World()) -> World():
  commit(insert_armor(insert_velocity(T.begin(~World(),~S.SimEvent,world))))
def remove(world: World()) -> World():
  commit(remove_velocity(T.begin(~World(),~S.SimEvent,world)))
def despawn_result(result: Tx() & W.Status) -> World():
  (tx,_) = result
  commit(tx)
def despawn(world: World()) -> World():
  despawn_result(Cmd.tx_despawn_with(~S.Schema,~S.Store,~F32,~S.SimEvent,~S.clear,T.begin(~World(),~S.SimEvent,world),W.Handle{1,3}))
def init_retry(factory: W.Factory,reader: E.Reader<S.Schema>,movement: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,Unit,String,Unit,run_movement>,damage: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,Unit,String,Unit,run_damage>,result: Sys.RegistrationResult<S.Schema,S.Store,F32,S.SimEvent,Bool,String,Unit,run_retry>) -> Maybe<&1,State>:
  match result:
    case Sys.Registered{world,retry}: Some{State{factory,world,reader,movement,damage,retry,[]}}
    case _: None{}
def init_damage(factory: W.Factory,reader: E.Reader<S.Schema>,movement: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,Unit,String,Unit,run_movement>,result: Sys.RegistrationResult<S.Schema,S.Store,F32,S.SimEvent,Unit,String,Unit,run_damage>) -> Maybe<&1,State>:
  match result:
    case Sys.Registered{world,damage}: init_retry(factory,reader,movement,damage,Sys.register(~S.Schema,~S.Store,~F32,~S.SimEvent,~Bool,~String,~Unit,~run_retry,world,"retry",["Position.write","Velocity.read","Dt.write","Hit.emit","spawn"]))
    case _: None{}
def init_movement(factory: W.Factory,reader: E.Reader<S.Schema>,result: Sys.RegistrationResult<S.Schema,S.Store,F32,S.SimEvent,Unit,String,Unit,run_movement>) -> Maybe<&1,State>:
  match result:
    case Sys.Registered{world,movement}: init_damage(factory,reader,movement,Sys.register(~S.Schema,~S.Store,~F32,~S.SimEvent,~Unit,~String,~Unit,~run_damage,world,"damage",["Health.write","Armor.optional","Hit.emit","Death.emit","despawn"]))
    case _: None{}
def init_reader(factory: W.Factory,result: World() & E.Reader<S.Schema>) -> Maybe<&1,State>:
  (world,reader) = result
  init_movement(factory,reader,Sys.register(~S.Schema,~S.Store,~F32,~S.SimEvent,~Unit,~String,~Unit,~run_movement,world,"movement",["Position.write","Velocity.read","Dt.read"]))
def init_created(result: W.Creation<S.Schema,S.Store,F32,S.SimEvent>) -> Maybe<&1,State>:
  match result:
    case W.Created{factory,world}: init_reader(factory,E.create(~S.Schema,~S.Store,~F32,~S.SimEvent,world))
    case _: None{}
def phase_one(state: State) -> State:
  record(barrier(record(step_damage(record(step_retry(record(barrier(record(step_retry(record(step_movement(record(barrier(record(replace_world(record(state,"empty"),spawn),"spawn-pending")),"spawn-visible")),"tick1-movement"),True{}),"failed-rollback")),"failed-barrier-no-ghost"),False{}),"same-instance-retry")),"tick1-damage-before-barrier")),"tick1-after-barrier")
def phase_two(state: State) -> State:
  record(barrier(record(step_damage(record(step_movement(state),"tick2-movement")),"tick2-damage-before-barrier")),"tick2-after-barrier")
def phase_three(state: State) -> State:
  record(barrier(record(step_damage(record(step_movement(state),"tick3-movement")),"tick3-damage-before-barrier")),"tick3-after-barrier")
def phase_structural(state: State) -> State:
  record(barrier(record(replace_world(record(barrier(record(replace_world(state,insert),"insert-pending")),"insert-visible"),remove),"remove-pending")),"remove-visible")
type Owners is Type:
  Owners{factory: W.Factory,reader: E.Reader<S.Schema>,movement: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,Unit,String,Unit,run_movement>,damage: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,Unit,String,Unit,run_damage>,retry: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,Bool,String,Unit,run_retry>,checkpoints: List<&2,Checkpoint>}
def foreign_finished(owners: Owners,world: World(),+checkpoint: Checkpoint) -> State:
  match owners:
    case Owners{factory,reader,movement,damage,retry,+checkpoints}: State{factory,world,reader,movement,damage,retry,checkpoint <> checkpoints}
def foreign_finish(owners: Owners,+foreignId: U32,+localId: U32,+missing: Bool,+queueUnchanged: Bool,+before: String,observed: World() & Sim.Snapshot) -> State:
  (world,+snapshot) = observed
  foreign_finished(owners,world,ForeignResult{foreignId,localId,missing,queueUnchanged,String.eq(before,J.snapshot("foreign-invariant",snapshot,[]))})
def foreign_after(owners: Owners,+handle: W.Handle<S.Schema>,+missing: Bool,+beforeQueue: U32,+before: String,observed: World() & U32) -> State:
  (world,+afterQueue) = observed
  foreign_finish(owners,Sim.handle_id(handle),1,missing,U32.is_eq(beforeQueue,afterQueue),before,Sim.snapshot(W.barrier(~S.Schema,~S.Store,~F32,~S.SimEvent,world)))
def foreign_command(owners: Owners,+handle: W.Handle<S.Schema>,+lookupMissing: Bool,+beforeQueue: U32,+before: String,observed: Tx() & W.Status) -> State:
  match observed:
    case (tx,W.Rejected{W.MissingEntity{}}): foreign_after(owners,handle,lookupMissing,beforeQueue,before,W.pending_count(~S.Schema,~S.Store,~F32,~S.SimEvent,commit(tx)))
    case (tx,_): foreign_after(owners,handle,False{},beforeQueue,before,W.pending_count(~S.Schema,~S.Store,~F32,~S.SimEvent,commit(tx)))
def foreign_lookup(owners: Owners,+handle: W.Handle<S.Schema>,+beforeQueue: U32,+before: String,observed: World() & C.Access<S.PositionView>) -> State:
  match observed:
    case (world,C.MissingEntity{}): foreign_command(owners,handle,True{},beforeQueue,before,Cmd.tx_despawn_with(~S.Schema,~S.Store,~F32,~S.SimEvent,~S.clear,T.begin(~World(),~S.SimEvent,world),handle))
    case (world,_): foreign_command(owners,handle,False{},beforeQueue,before,Cmd.tx_despawn_with(~S.Schema,~S.Store,~F32,~S.SimEvent,~S.clear,T.begin(~World(),~S.SimEvent,world),handle))
def foreign_queue(owners: Owners,+handle: W.Handle<S.Schema>,+before: String,observed: World() & U32) -> State:
  (world,+beforeQueue) = observed
  foreign_lookup(owners,handle,beforeQueue,before,C.get(~S.Schema,~S.Store,~F32,~S.SimEvent,~S.PositionRest,~S.Position,~S.PositionView,~S.PositionToken,~S.take_positions,~S.put_positions,~S.project_position,S.position(),world,handle))
def foreign_before(owners: Owners,+handle: W.Handle<S.Schema>,observed: World() & Sim.Snapshot) -> State:
  (world,+snapshot) = observed
  foreign_queue(owners,handle,J.snapshot("foreign-invariant",snapshot,[]),W.pending_count(~S.Schema,~S.Store,~F32,~S.SimEvent,world))
def foreign_live(owners: Owners,local: World(),+handle: W.Handle<S.Schema>,activated: World() & W.Status) -> State:
  match activated:
    case (_,W.Accepted{}): foreign_before(owners,handle,Sim.snapshot(local))
    case (_,_): foreign_finished(owners,local,FailedResult{"foreign-collision-reference","ActivationRejected"})
def foreign_reserved(owners: Owners,local: World(),reserved: World() & W.Reservation<S.Schema>) -> State:
  match reserved:
    case (foreign,W.Reserved{+handle}): foreign_live(owners,local,handle,W.activate(~S.Schema,~S.Store,~F32,~S.SimEvent,S.populate(foreign,handle,S.Bundle{Some{S.Position{777.0,ALeaf{77}}},None{},None{},None{},None{}}),handle))
    case (_,W.ReservationRejected{_}): foreign_finished(owners,local,FailedResult{"foreign-collision-reference","ReservationRejected"})
def foreign_created(local: World(),reader: E.Reader<S.Schema>,movement: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,Unit,String,Unit,run_movement>,damage: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,Unit,String,Unit,run_damage>,retry: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,Bool,String,Unit,run_retry>,+checkpoints: List<&2,Checkpoint>,created: W.Creation<S.Schema,S.Store,F32,S.SimEvent>) -> State:
  match created:
    case W.Created{factory,foreign}: foreign_reserved(Owners{factory,reader,movement,damage,retry,checkpoints},local,W.reserve_id(~S.Schema,~S.Store,~F32,~S.SimEvent,foreign))
    case W.CreateRejected{factory,_}: State{factory,local,reader,movement,damage,retry,FailedResult{"foreign-collision-reference","NamespaceExhausted"} <> checkpoints}
def phase_foreign(state: State) -> State:
  match state:
    case State{factory,world,reader,movement,damage,retry,+checkpoints}: foreign_created(world,reader,movement,damage,retry,checkpoints,S.create(factory,1.0))
def phase_despawn(state: State) -> State:
  record(barrier(record(replace_world(state,despawn),"despawn-pending")),"despawn-visible")
def finish(state: State) -> List<&2,Checkpoint>:
  match state:
    case State{_,_,_,_,_,_,+checkpoints}: List.reverse(&2,Checkpoint,checkpoints)
def run_ready(ready: Maybe<&1,State>) -> List<&2,Checkpoint>:
  match ready:
    case None{}: [FailedResult{"init","RegistrationFailed"}]
    case Some{state}: finish(phase_despawn(phase_foreign(phase_structural(phase_three(phase_two(phase_one(state)))))))
def main() -> List<&2,Checkpoint>:
  run_ready(init_created(S.create(W.factory(),1.0)))
