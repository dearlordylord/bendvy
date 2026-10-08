import Base
import ../components.bend as D
import ../schema.bend as S
import ../../../src/ecs/column.bend as Col
import ../../../src/ecs/component.bend as C
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/compose.bend as Q
import ../../../src/ecs/transaction.bend as T
import ../system.bend as Sys

type State is Type: State{world: S.World(),handles: List<&2,W.Handle<S.Schema>>,tick: U32}
type Packet is Type:
  Packet{state: State,frame: String}
  Failed{error: String}

def row(id: U32,health: D.Health,decay: C.Access<D.HealthDecay>) -> String:
  match health decay:
    case D.Health{value} C.Found{D.HealthDecay{factor}}: "{\"id\":" ++ U32.show(id) ++ ",\"health\":" ++ F32.show(value) ++ ",\"decay\":" ++ F32.show(factor) ++ "}"
    case D.Health{value} C.ComponentAbsent{}: "{\"id\":" ++ U32.show(id) ++ ",\"health\":" ++ F32.show(value) ++ ",\"decay\":null}"
    case _ _: "{\"error\":\"Invalid entity\"}"
def entity_id(handle: W.Handle<S.Schema>) -> U32:
  match handle:
    case W.Handle{_,id}: id
def observed_decay(handle: W.Handle<S.Schema>,health: D.Health,result: S.World() & C.Access<D.HealthDecay>) -> S.World() & String:
  match result:
    case (world,decay): (world,row(entity_id(handle),health,decay))
def observed_health(+handle: W.Handle<S.Schema>,result: S.World() & C.Access<D.Health>) -> S.World() & String:
  match result:
    case (world,C.Found{health}): observed_decay(handle,health,C.get(~S.Schema,~S.Store,~Unit,~Unit,~Col.Column<S.Schema,D.Health>,~D.HealthDecay,~D.HealthDecay,~S.HealthDecayToken,~S.take_decay,~S.put_decay,~S.project_decay,S.decay_family(),world,handle))
    case (world,_): (world,"{\"error\":\"Missing health\"}")
def observe(world: S.World(),+handle: W.Handle<S.Schema>) -> S.World() & String:
  observed_health(handle,C.get(~S.Schema,~S.Store,~Unit,~Unit,~Col.Column<S.Schema,D.HealthDecay>,~D.Health,~D.Health,~S.HealthToken,~S.take_health,~S.put_health,~S.project_health,S.health_family(),world,handle))
def snapshot_next(prefix: String,observed: S.World() & String,k: String -> S.World() -> S.World() & String) -> S.World() & String:
  match observed:
    case (world,text): k(prefix ++ text,world)
def separator(prefix: String) -> String:
  match prefix:
    case "": ""
    case prefix: prefix ++ ","
def snapshot(handles: List<&2,W.Handle<S.Schema>>,prefix: String,world: S.World()) -> S.World() & String:
  match handles:
    case []: (world,prefix)
    case handle <> rest: snapshot_next(separator(prefix),observe(world,handle),prefix => world => snapshot(rest,prefix,world))
def packet(+handles: List<&2,W.Handle<S.Schema>>,+tick: U32,result: S.World() & String) -> Packet:
  match result:
    case (world,rows): Packet{State{world,handles,tick},"{\"tick\":" ++ U32.show(tick) ++ ",\"entities\":[" ++ rows ++ "]}"}
def render(world: S.World(),+handles: List<&2,W.Handle<S.Schema>>,tick: U32) -> Packet:
  packet(handles,tick,snapshot(handles,"",world))
def third(result: S.Spawned,+handles: List<&2,W.Handle<S.Schema>>) -> Packet:
  match result:
    case S.Spawned{world,handle}: render(S.barrier(world),List.append(&2,W.Handle<S.Schema>,handles,[handle]),0)
    case S.SpawnRejected{_,_}: Failed{"Spawn refused"}
def second(result: S.Spawned,+handles: List<&2,W.Handle<S.Schema>>) -> Packet:
  match result:
    case S.Spawned{world,handle}: third(S.spawn(world,D.EntitySeed{D.Health{30.0},None{}}),List.append(&2,W.Handle<S.Schema>,handles,[handle]))
    case S.SpawnRejected{_,_}: Failed{"Spawn refused"}
def first(result: S.Spawned) -> Packet:
  match result:
    case S.Spawned{world,handle}: second(S.spawn(world,D.EntitySeed{D.Health{20.0},Some{D.HealthDecay{0.25}}}),[handle])
    case S.SpawnRejected{_,_}: Failed{"Spawn refused"}
def created(result: W.Creation<S.Schema,S.Store,Unit,Unit>) -> Packet:
  match result:
    case W.Created{_,world}: first(S.spawn(world,D.EntitySeed{D.Health{10.0},Some{D.HealthDecay{0.5}}}))
    case W.CreateRejected{_,_}: Failed{"World creation refused"}
def start() -> Packet: created(W.create(~S.Schema,~S.Store,~Unit,~Unit,~S.empty,W.factory(),Unit{}))
def advanced(handles: List<&2,W.Handle<S.Schema>>,tick: U32,result: Q.Executed<S.World(),Q.Error<Sys.Error>,D.Health>) -> Packet:
  match result:
    case Q.Executed{world,T.Success{},_}: render(world,handles,(tick + 1 : U32))
    case Q.Executed{_,T.Failure{_},_}: Failed{"System failed"}
def step(state: State) -> Packet:
  match state:
    case State{world,handles,tick}: advanced(handles,tick,Sys.tick(world))
