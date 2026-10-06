import Base
import ../../../examples/user-simulation/schema.bend as S
import ../../../examples/user-simulation/simulation.bend as Sim
import ../../../examples/user-simulation/driver.bend as D
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/query.bend as Q
import ../../../src/ecs/component.bend as C

def body(~H: Type,~get: H -> H & C.Access<S.HealthView>,~aux: H -> H & C.Access<S.Armor>,~resource_get: H -> H & F32,args: Unit,handle: W.Handle<S.Schema>,ctx: H) -> H & U32:
  (ctx,Sim.handle_id(handle))
def query(world: D.World(),mode: Q.Selection) -> D.World() & List<&2,U32>:
  Q.each_read(~S.Schema,~S.Store,~F32,~S.SimEvent,~S.HealthRest,~S.Health,~S.HealthView,~S.HealthToken,~S.take_healths,~S.put_healths,~S.project_health,~S.ArmorRest,~S.Armor,~S.Armor,~S.ArmorToken,~S.take_armors,~S.put_armors,~S.project_armor,~F32,~Sim.resource_view,~S.Bundle,~S.populate,~S.clear,~Unit,~U32,~body,S.health(),S.armor(),mode,world,Unit{})
def optional(+a: List<&2,U32>,+b: List<&2,U32>,+c: List<&2,U32>,observed: D.World() & List<&2,U32>) -> List<&2,List<&2,U32>>:
  (world,+d) = observed
  [a,b,c,d]
def absent(+a: List<&2,U32>,+b: List<&2,U32>,observed: D.World() & List<&2,U32>) -> List<&2,List<&2,U32>>:
  (world,+c) = observed
  optional(a,b,c,query(world,Q.Optional{}))
def present(+a: List<&2,U32>,observed: D.World() & List<&2,U32>) -> List<&2,List<&2,U32>>:
  (world,+b) = observed
  absent(a,b,query(world,Q.Absent{}))
def required(observed: D.World() & List<&2,U32>) -> List<&2,List<&2,U32>>:
  (world,+a) = observed
  present(a,query(world,Q.Present{}))
def populated(state: D.State) -> List<&2,List<&2,U32>>:
  match state:
    case D.State{_,world,_,_,_,_,_,_}: required(query(W.barrier(~S.Schema,~S.Store,~F32,~S.SimEvent,world),Q.Required{}))
def initialized(ready: Maybe<&1,D.State>) -> List<&2,List<&2,U32>>:
  match ready:
    case Some{state}: populated(D.spawn_state(state))
    case None{}: [[99]]
def main() -> List<&2,List<&2,U32>>:
  initialized(D.init_created(S.create(W.factory(),1.0)))
