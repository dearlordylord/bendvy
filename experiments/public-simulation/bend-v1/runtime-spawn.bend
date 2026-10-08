import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as ER
import ./step.bend as Step
import ./storage.bend as Storage
import ./events.bend as Events
import ./spawn-system.bend as Spawn
import ./runtime-gameplay.bend as Game

type Completion<-S: Data> is Data:
  SpawnSucceeded{reservations: List<&2,W.Reservation<S>>}
  SpawnFailed{error: Spawn.SpawnError}
  SpawnRegistrationRejected{}
type Output<-S: Data> is Type:
  Output{registry: Spawn.Registry(~S),completion: Completion<S>}
def returned(~S: Data,result: Sys.RunResult<S,Storage.Store<S>,Array<U32>,Events.SimulationEvent,Unit,Spawn.SpawnError,List<&2,W.Reservation<S>>,Spawn.runner(~S)>) -> Step.World(~S) & Output<S>:
  match result:
    case Sys.Completed{registry,Sys.Succeeded{world,reservations}}: (world,Output{registry,SpawnSucceeded{reservations}})
    case Sys.Completed{registry,Sys.Failed{world,error}}: (world,Output{registry,SpawnFailed{error}})
    case Sys.RegistrationRejected{registry,world,_}: (world,Output{registry,SpawnRegistrationRejected{}})
def run(~S: Data,runtime: Game.Runtime(~S),registry: Spawn.Registry(~S)) -> Game.Runtime(~S) & Output<S>:
  ER.with_world(~S,~Storage.Store<S>,~Array<U32>,~Events.SimulationEvent,~Output<S>,(world => returned(~S,Spawn.run(~S,registry,world))),runtime)
def barrier_world(~S: Data,world: Step.World(~S)) -> Step.World(~S) & Unit:
  (W.barrier(~S,~Storage.Store<S>,~Array<U32>,~Events.SimulationEvent,world),Unit{})
def barrier(~S: Data,runtime: Game.Runtime(~S)) -> Game.Runtime(~S) & Unit:
  ER.with_world(~S,~Storage.Store<S>,~Array<U32>,~Events.SimulationEvent,~Unit,barrier_world(~S),runtime)
def frame(~S: Data,runtime: Game.Runtime(~S)) -> Game.Runtime(~S):
  ER.frame(~S,~Storage.Store<S>,~Array<U32>,~Events.SimulationEvent,runtime)
