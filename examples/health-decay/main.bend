import Base
import components.bend as D
import schema.bend as S
import system.bend as Sys
import ../../src/ecs/world.bend as W
import ../../src/ecs/compose.bend as Q
import ../../src/ecs/transaction.bend as T

def values(rows: List<&2,D.Health>) -> String:
  match rows:
    case []: ""
    case D.Health{value} <> []: F32.show(value)
    case D.Health{value} <> rest: F32.show(value) ++ "," ++ values(rest)
def second(result: Q.Executed<S.World(),Q.Error<Sys.Error>,D.Health>,before: String,first: String) -> String:
  match result:
    case Q.Executed{_,T.Success{},rows}: "before-barrier=" ++ before ++ "\ntick-1=" ++ first ++ "\ntick-2=" ++ values(rows)
    case Q.Executed{_,T.Failure{_},_}: "ERROR: second tick"
def first(result: Q.Executed<S.World(),Q.Error<Sys.Error>,D.Health>,before: String) -> String:
  match result:
    case Q.Executed{world,T.Success{},rows}: second(Sys.tick(world),before,values(rows))
    case Q.Executed{_,T.Failure{_},_}: "ERROR: first tick"
def pending(result: Q.Executed<S.World(),Q.Error<Sys.Error>,D.Health>) -> String:
  match result:
    case Q.Executed{world,T.Success{},rows}: first(Sys.tick(S.barrier(world)),values(rows))
    case Q.Executed{_,T.Failure{_},_}: "ERROR: pending query"
def third_spawn(result: S.Spawned) -> String:
  match result:
    case S.Spawned{world,_}: pending(Sys.tick(world))
    case S.SpawnRejected{_,_}: "ERROR: third spawn"
def second_spawn(result: S.Spawned) -> String:
  match result:
    case S.Spawned{world,_}: third_spawn(S.spawn(world,D.EntitySeed{D.Health{30.0},None{}}))
    case S.SpawnRejected{_,_}: "ERROR: second spawn"
def first_spawn(result: S.Spawned) -> String:
  match result:
    case S.Spawned{world,_}: second_spawn(S.spawn(world,D.EntitySeed{D.Health{20.0},Some{D.HealthDecay{0.25}}}))
    case S.SpawnRejected{_,_}: "ERROR: first spawn"
def setup(created: W.Creation<S.Schema,S.Store,Unit,Unit>) -> String:
  match created:
    case W.Created{_,world}: first_spawn(S.spawn(world,D.EntitySeed{D.Health{10.0},Some{D.HealthDecay{0.5}}}))
    case W.CreateRejected{_,_}: "ERROR: world creation"
def main() -> IO(Unit):
  IO.print(setup(W.create(~S.Schema,~S.Store,~Unit,~Unit,~S.empty,W.factory(),Unit{})))
