import Base
import ../../../src/ecs/trace-facts.bend as Trace
import ../../../examples/scheduled-health/components.bend as D
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/column.bend as Col
import ../../../src/ecs/component.bend as C
import ../../../src/ecs/commands.bend as Cmd
import ../../../src/ecs/transaction.bend as T

import ../../../src/ecs/ordinary-service-declaration.bend as Service
type Resources is Type: Resources{counter:Service.Slot<Array<U32>>}
def take_counter(value:Resources) -> Unit & Service.Slot<Array<U32>>:
  match value:
    case Resources{slot}:(Unit{},slot)
def put_counter(rest:Unit,slot:Service.Slot<Array<U32>>) -> Resources:
  Resources{slot}
def increment_read(result:Array<U32> & U32) -> Array<U32>:
  match result:
    case (owner,value):Array.set(U32,owner,0,(value + 1:U32))
def increment(owner:Array<U32>) -> Array<U32>:
  increment_read(Array.get(U32,owner,0))
def counter() -> Service.Declaration<Schema,Resources,Array<U32>,Unit,take_counter,put_counter,increment>:
  Service.Declaration{1,"counter"}
type Schema is Data: Schema{}
type Store is Type: Store{healths: Col.Column<Schema,D.Health>,decays: Col.Column<Schema,D.HealthDecay>}
def World() -> Type: W.World<Schema,Store,Resources,Unit>

type HealthToken is Data: HealthToken{}
def take_health(store: Store) -> Col.Column<Schema,D.HealthDecay> & Col.Column<Schema,D.Health>:
  match store:
    case Store{column,rest}: (rest,column)
def put_health(rest: Col.Column<Schema,D.HealthDecay>,column: Col.Column<Schema,D.Health>) -> Store: Store{column,rest}
def project_health(component: D.Health) -> D.Health & D.Health:
  match component:
    case D.Health{+value}: (D.Health{value},D.Health{value})
def health_family() -> C.Family<Schema,Store,Col.Column<Schema,D.HealthDecay>,D.Health,D.Health,HealthToken,take_health,put_health,project_health>: C.Family{"health"}
def health_installed(result: C.Replacement<World(),D.Health>) -> World():
  match result:
    case C.Replaced{world,_}: world
    case C.ReplaceRejected{world,_,_}: world
def install_health(world: World(),handle: W.Handle<Schema>,value: D.Health) -> World():
  health_installed(C.structural_replace(~Schema,~Store,~Resources,~Unit,~Col.Column<Schema,D.HealthDecay>,~D.Health,~D.Health,~HealthToken,~take_health,~put_health,~project_health,health_family(),world,handle,Some{value}))

type HealthDecayToken is Data: HealthDecayToken{}
def take_decay(store: Store) -> Col.Column<Schema,D.Health> & Col.Column<Schema,D.HealthDecay>:
  match store:
    case Store{rest,column}: (rest,column)
def put_decay(rest: Col.Column<Schema,D.Health>,column: Col.Column<Schema,D.HealthDecay>) -> Store: Store{rest,column}
def project_decay(component: D.HealthDecay) -> D.HealthDecay & D.HealthDecay:
  match component:
    case D.HealthDecay{+factor}: (D.HealthDecay{factor},D.HealthDecay{factor})
def decay_family() -> C.Family<Schema,Store,Col.Column<Schema,D.Health>,D.HealthDecay,D.HealthDecay,HealthDecayToken,take_decay,put_decay,project_decay>: C.Family{"decay"}
def decay_installed(result: C.Replacement<World(),D.HealthDecay>) -> World():
  match result:
    case C.Replaced{world,_}: world
    case C.ReplaceRejected{world,_,_}: world
def install_decay(world: World(),handle: W.Handle<Schema>,value: D.HealthDecay) -> World():
  decay_installed(C.structural_replace(~Schema,~Store,~Resources,~Unit,~Col.Column<Schema,D.Health>,~D.HealthDecay,~D.HealthDecay,~HealthDecayToken,~take_decay,~put_decay,~project_decay,decay_family(),world,handle,Some{value}))

def empty(_: Unit) -> Store: Store{Col.empty_indexed(~Schema,~D.Health),Col.empty_indexed(~Schema,~D.HealthDecay)}
def optional_decay(world: World(),handle: W.Handle<Schema>,decay: Maybe<&2,D.HealthDecay>) -> World():
  match decay:
    case None{}: world
    case Some{value}: install_decay(world,handle,value)
def populate(world: World(),handle: W.Handle<Schema>,seed: D.EntitySeed) -> World():
  match handle seed:
    case W.Handle{+namespace,+id} D.EntitySeed{health,decay}: optional_decay(install_health(world,W.Handle{namespace,id},health),W.Handle{namespace,id},decay)
type Spawned is Type:
  Spawned{world: World(),handle: W.Handle<Schema>}
  SpawnRejected{world: World(),error: W.WorldError}
def spawn_finished(result: T.Tx<World(),Unit> & W.Reservation<Schema>) -> Spawned:
  match result:
    case (T.Tx{world,_,commands,_,_},W.Reserved{handle}): Spawned{Cmd.enqueue(~Schema,~Store,~Resources,~Unit,world,commands),handle}
    case (T.Tx{world,_,_,_,_},W.ReservationRejected{error}): SpawnRejected{world,error}
# Reservation returns a handle immediately; components appear at the barrier.
def spawn(world: World(),seed: D.EntitySeed) -> Spawned:
  spawn_finished(Cmd.tx_spawn(~Schema,~Store,~Resources,~Unit,~D.EntitySeed,~populate,T.Tx{world,[],[],[],Trace.Off{}},seed))
def barrier(world: World()) -> World(): W.barrier(~Schema,~Store,~Resources,~Unit,world)
