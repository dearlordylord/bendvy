import Base
import ../../../examples/user-simulation/schema.bend as S
import ../../../examples/user-simulation/simulation.bend as Sim
import ../../../src/ecs/component.bend as C
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/transaction.bend as T

type Counters is Data:
  Counters{sets: U32,resources: U32,events: U32,spawns: U32}
def get(ctx: Counters) -> Counters & C.Access<S.PositionView>:
  (ctx,C.Found{S.PositionView{2.0,[10,11]}})
def set(ctx: Counters,incoming: S.Position) -> Counters:
  match ctx:
    case Counters{sets,resources,events,spawns}: Counters{(sets+1 : U32),resources,events,spawns}
def aux(ctx: Counters) -> Counters & C.Access<S.VelocityView>:
  (ctx,C.Found{S.VelocityView{2.0,[20]}})
def resource_get(ctx: Counters) -> Counters & F32:
  (ctx,1.0)
def resource_set(ctx: Counters,incoming: F32) -> Counters:
  match ctx:
    case Counters{sets,resources,events,spawns}: Counters{sets,(resources+1 : U32),events,spawns}
def emit(ctx: Counters,event: S.SimEvent) -> Counters:
  match ctx:
    case Counters{sets,resources,events,spawns}: Counters{sets,resources,(events+1 : U32),spawns}
def despawn(ctx: Counters) -> Counters:
  ctx
def spawn(ctx: Counters,incoming: S.Bundle) -> Counters & W.Reservation<S.Schema>:
  match ctx:
    case Counters{sets,resources,events,spawns}: (Counters{sets,resources,events,(spawns+1 : U32)},W.Reserved{W.Handle{13,20}})
def body(+fail: Bool,+id: U32,ctx: Counters) -> Counters & T.Outcome<Sim.UserError>:
  Sim.retry_body(~Counters,~get,~set,~aux,~resource_get,~resource_set,~emit,~despawn,~spawn,Sim.RetryArgs{fail,W.Handle{13,19}},W.Handle{13,id},ctx)
def counts(ctx: Counters) -> List<&2,U32>:
  match ctx:
    case Counters{sets,resources,events,spawns}: [sets,resources,events,spawns]
def failed_second(result: Counters & T.Outcome<Sim.UserError>) -> List<&2,U32>:
  match result:
    case (ctx,T.Failure{Sim.Rejected{}}): counts(ctx)
    case _: [99]
def failed_first(result: Counters & T.Outcome<Sim.UserError>) -> List<&2,U32>:
  match result:
    case (ctx,T.Success{}): failed_second(body(True{},19,ctx))
    case _: [98]
def successful_second(result: Counters & T.Outcome<Sim.UserError>) -> List<&2,U32>:
  match result:
    case (ctx,T.Success{}): counts(ctx)
    case _: [97]
def successful_first(result: Counters & T.Outcome<Sim.UserError>) -> List<&2,U32>:
  match result:
    case (ctx,T.Success{}): successful_second(body(False{},19,ctx))
    case _: [96]
def main() -> List<&2,List<&2,U32>>:
  [failed_first(body(True{},17,Counters{0,0,0,0})),successful_first(body(False{},17,Counters{0,0,0,0}))]
