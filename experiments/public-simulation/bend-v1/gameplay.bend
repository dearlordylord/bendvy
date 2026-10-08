import Base
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import ./movement.bend as Movement
import ./events.bend as Events
import ./geometry.bend as Geometry
import ./storage.bend as Storage
import ./step.bend as Step
import ./systems.bend as Systems
import ./damage-body.bend as Damage

type Gameplay<-S: Data> is Type:
  Gameplay{world: Step.World(~S),movement: Systems.MovementRegistry(~S),damage: Systems.DamageRegistry(~S)}
type Installed<-S: Data> is Type:
  GameplayInstalled{game: Gameplay<S>}
  GameplayMovementRefused{world: Step.World(~S)}
  GameplayDamageRefused{world: Step.World(~S),movement: Systems.MovementRegistry(~S)}
def damage_registered(~S: Data,movement: Systems.MovementRegistry(~S),result: Sys.RegistrationResult<S,Storage.Store<S>,Array<U32>,Events.SimulationEvent,Damage.DamageArgs,Q.Error<Damage.DamageError>,List<&2,Geometry.Cell>,Systems.damage_runner(~S)>) -> Installed<S>:
  match result:
    case Sys.Registered{world,damage}: GameplayInstalled{Gameplay{world,movement,damage}}
    case Sys.RegistrationFailed{world}: GameplayDamageRefused{world,movement}
def movement_registered(~S: Data,result: Sys.RegistrationResult<S,Storage.Store<S>,Array<U32>,Events.SimulationEvent,U32,Q.Error<Movement.MovementError>,List<&2,Geometry.Cell>,Systems.movement_runner(~S)>) -> Installed<S>:
  match result:
    case Sys.Registered{world,movement}: damage_registered(~S,movement,Systems.register_damage(~S,world))
    case Sys.RegistrationFailed{world}: GameplayMovementRefused{world}
def install(~S: Data,world: Step.World(~S)) -> Installed<S>:
  movement_registered(~S,Systems.register_movement(~S,world))
