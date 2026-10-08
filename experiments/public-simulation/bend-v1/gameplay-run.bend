import Base
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import ./events.bend as Events
import ./geometry.bend as Geometry
import ./storage.bend as Storage
import ./step.bend as Step
import ./systems.bend as Systems
import ./movement.bend as Movement
import ./damage-body.bend as Damage
import ./gameplay.bend as Game

type GameplayError is Data:
  MovementRunFailed{error: Q.Error<Movement.MovementError>}
  DamageRunFailed{error: Q.Error<Damage.DamageError>}
  MovementRunRegistrationRefused{args: U32}
  DamageRunRegistrationRefused{args: Damage.DamageArgs}
type FrameReturned<-S: Data> is Type:
  GameplayFrameReturned{game: Game.Gameplay<S>,outcome: T.Outcome<GameplayError>,moved: List<&2,Geometry.Cell>,damaged: List<&2,Geometry.Cell>}
def DamageRun(~S: Data) -> Type:
  Sys.RunResult<S,Storage.Store<S>,Array<U32>,Events.SimulationEvent,Damage.DamageArgs,Q.Error<Damage.DamageError>,List<&2,Geometry.Cell>,Systems.damage_runner(~S)>
def MovementRun(~S: Data) -> Type:
  Sys.RunResult<S,Storage.Store<S>,Array<U32>,Events.SimulationEvent,U32,Q.Error<Movement.MovementError>,List<&2,Geometry.Cell>,Systems.movement_runner(~S)>
# Each registered system is its own transaction. A damage failure preserves
# the movement already committed, while retaining both registration owners.
def damage_returned(~S: Data,movement: Systems.MovementRegistry(~S),moved: List<&2,Geometry.Cell>,result: DamageRun(~S)) -> FrameReturned<S>:
  match result:
    case Sys.Completed{damage,Sys.Succeeded{world,damaged}}: GameplayFrameReturned{Game.Gameplay{world,movement,damage},T.Success{},moved,damaged}
    case Sys.Completed{damage,Sys.Failed{world,error}}: GameplayFrameReturned{Game.Gameplay{world,movement,damage},T.Failure{DamageRunFailed{error}},moved,[]}
    case Sys.RegistrationRejected{damage,world,args}: GameplayFrameReturned{Game.Gameplay{world,movement,damage},T.Failure{DamageRunRegistrationRefused{args}},moved,[]}
def movement_returned(~S: Data,damage: Systems.DamageRegistry(~S),args: Damage.DamageArgs,result: MovementRun(~S)) -> FrameReturned<S>:
  match result:
    case Sys.Completed{movement,Sys.Succeeded{world,moved}}: damage_returned(~S,movement,moved,Systems.run_damage(~S,damage,world,args))
    case Sys.Completed{movement,Sys.Failed{world,error}}: GameplayFrameReturned{Game.Gameplay{world,movement,damage},T.Failure{MovementRunFailed{error}},[],[]}
    case Sys.RegistrationRejected{movement,world,args}: GameplayFrameReturned{Game.Gameplay{world,movement,damage},T.Failure{MovementRunRegistrationRefused{args}},[],[]}
def run(~S: Data,game: Game.Gameplay<S>,fixed_step: U32,args: Damage.DamageArgs) -> FrameReturned<S>:
  match game:
    case Game.Gameplay{world,movement,damage}: movement_returned(~S,damage,args,Systems.run_movement(~S,movement,world,fixed_step))
