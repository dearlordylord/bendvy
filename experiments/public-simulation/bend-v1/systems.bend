import Base
import ./events.bend as Events
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import ./geometry.bend as Geometry
import ./storage.bend as Storage
import ./step.bend as Step
import ./movement.bend as Movement
import ./damage.bend as Damage
import ./damage-body.bend as DamageBody

def returned(~World: Type,~Error: Data,~Out: Data,result: Q.Executed<World,Error,Out>) -> Sys.Outcome<World,Error,List<&2,Out>>:
  match result:
    case Q.Executed{world,T.Success{},values}: Sys.Succeeded{world,values}
    case Q.Executed{world,T.Failure{error},_}: Sys.Failed{world,error}
def movement_runner(~S: Data,world: Step.World(~S),args: U32) -> Sys.Outcome<Step.World(~S),Q.Error<Movement.MovementError>,List<&2,Geometry.Cell>>:
  returned(~Step.World(~S),~Q.Error<Movement.MovementError>,~Geometry.Cell,Movement.execute(~S,args,world))
def MovementRegistry(~S: Data) -> Type:
  Sys.Registry<S,Storage.Store<S>,Array<U32>,Events.SimulationEvent,U32,Q.Error<Movement.MovementError>,List<&2,Geometry.Cell>,movement_runner(~S)>
def register_movement(~S: Data,world: Step.World(~S)) -> Sys.RegistrationResult<S,Storage.Store<S>,Array<U32>,Events.SimulationEvent,U32,Q.Error<Movement.MovementError>,List<&2,Geometry.Cell>,movement_runner(~S)>:
  Sys.register(~S,~Storage.Store<S>,~Array<U32>,~Events.SimulationEvent,~U32,~Q.Error<Movement.MovementError>,~List<&2,Geometry.Cell>,~movement_runner(~S),world,"Simulation/Move",["write:Simulation/Position","read:Simulation/Velocity","write:Simulation/Step"])
def run_movement(~S: Data,registry: MovementRegistry(~S),world: Step.World(~S),args: U32) -> Sys.RunResult<S,Storage.Store<S>,Array<U32>,Events.SimulationEvent,U32,Q.Error<Movement.MovementError>,List<&2,Geometry.Cell>,movement_runner(~S)>:
  Sys.run_tracked(~S,~Storage.Store<S>,~Array<U32>,~Events.SimulationEvent,~U32,~Q.Error<Movement.MovementError>,~List<&2,Geometry.Cell>,~movement_runner(~S),registry,world,args)
def damage_runner(~S: Data,world: Step.World(~S),args: DamageBody.DamageArgs) -> Sys.Outcome<Step.World(~S),Q.Error<DamageBody.DamageError>,List<&2,Geometry.Cell>>:
  returned(~Step.World(~S),~Q.Error<DamageBody.DamageError>,~Geometry.Cell,Damage.execute(~S,args,world))
def DamageRegistry(~S: Data) -> Type:
  Sys.Registry<S,Storage.Store<S>,Array<U32>,Events.SimulationEvent,DamageBody.DamageArgs,Q.Error<DamageBody.DamageError>,List<&2,Geometry.Cell>,damage_runner(~S)>
def register_damage(~S: Data,world: Step.World(~S)) -> Sys.RegistrationResult<S,Storage.Store<S>,Array<U32>,Events.SimulationEvent,DamageBody.DamageArgs,Q.Error<DamageBody.DamageError>,List<&2,Geometry.Cell>,damage_runner(~S)>:
  Sys.register(~S,~Storage.Store<S>,~Array<U32>,~Events.SimulationEvent,~DamageBody.DamageArgs,~Q.Error<DamageBody.DamageError>,~List<&2,Geometry.Cell>,~damage_runner(~S),world,"Simulation/Damage",["read:Simulation/Position","write:Simulation/Health","write:Simulation/Hit","write:Simulation/Death","command:despawn"])
def run_damage(~S: Data,registry: DamageRegistry(~S),world: Step.World(~S),args: DamageBody.DamageArgs) -> Sys.RunResult<S,Storage.Store<S>,Array<U32>,Events.SimulationEvent,DamageBody.DamageArgs,Q.Error<DamageBody.DamageError>,List<&2,Geometry.Cell>,damage_runner(~S)>:
  Sys.run_tracked(~S,~Storage.Store<S>,~Array<U32>,~Events.SimulationEvent,~DamageBody.DamageArgs,~Q.Error<DamageBody.DamageError>,~List<&2,Geometry.Cell>,~damage_runner(~S),registry,world,args)
