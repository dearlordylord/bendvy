import Base
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as ER
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import ./step.bend as Step
import ./storage.bend as Storage
import ./events.bend as Events
import ./geometry.bend as Geometry
import ./systems.bend as Systems
import ./gameplay-run.bend as Run
import ./damage-body.bend as Damage

def Runtime(~S: Data) -> Type: ER.Runtime<S,Storage.Store<S>,Array<U32>,Events.SimulationEvent>
type State<-S: Data> is Type:
  State{runtime: Runtime(~S),movement: Systems.MovementRegistry(~S),damage: Systems.DamageRegistry(~S)}
type MovementOutput<-S: Data> is Type:
  MovementOutput{registry: Systems.MovementRegistry(~S),outcome: T.Outcome<Run.GameplayError>,values: List<&2,Geometry.Cell>}
type DamageOutput<-S: Data> is Type:
  DamageOutput{registry: Systems.DamageRegistry(~S),outcome: T.Outcome<Run.GameplayError>,values: List<&2,Geometry.Cell>}
type FrameOutput is Data:
  FrameOutput{outcome: T.Outcome<Run.GameplayError>,moved: List<&2,Geometry.Cell>,damaged: List<&2,Geometry.Cell>}
def movement_returned(~S: Data,result: Run.MovementRun(~S)) -> Step.World(~S) & MovementOutput<S>:
  match result:
    case Sys.Completed{registry,Sys.Succeeded{world,values}}: (world,MovementOutput{registry,T.Success{},values})
    case Sys.Completed{registry,Sys.Failed{world,error}}: (world,MovementOutput{registry,T.Failure{Run.MovementRunFailed{error}},[]})
    case Sys.RegistrationRejected{registry,world,args}: (world,MovementOutput{registry,T.Failure{Run.MovementRunRegistrationRefused{args}},[]})
def damage_returned(~S: Data,result: Run.DamageRun(~S)) -> Step.World(~S) & DamageOutput<S>:
  match result:
    case Sys.Completed{registry,Sys.Succeeded{world,values}}: (world,DamageOutput{registry,T.Success{},values})
    case Sys.Completed{registry,Sys.Failed{world,error}}: (world,DamageOutput{registry,T.Failure{Run.DamageRunFailed{error}},[]})
    case Sys.RegistrationRejected{registry,world,args}: (world,DamageOutput{registry,T.Failure{Run.DamageRunRegistrationRefused{args}},[]})
def damage_synced(~S: Data,movement: Systems.MovementRegistry(~S),moved: List<&2,Geometry.Cell>,observed: Runtime(~S) & DamageOutput<S>) -> State<S> & FrameOutput:
  match observed:
    case (runtime,DamageOutput{damage,outcome,damaged}): (State{runtime,movement,damage},FrameOutput{outcome,moved,damaged})
def movement_synced(~S: Data,damage: Systems.DamageRegistry(~S),args: Damage.DamageArgs,observed: Runtime(~S) & MovementOutput<S>) -> State<S> & FrameOutput:
  match observed:
    case (runtime,MovementOutput{movement,T.Failure{error},moved}): (State{runtime,movement,damage},FrameOutput{T.Failure{error},moved,[]})
    case (runtime,MovementOutput{movement,T.Success{},moved}): damage_synced(~S,movement,moved,ER.with_world(~S,~Storage.Store<S>,~Array<U32>,~Events.SimulationEvent,~DamageOutput<S>,(world => damage_returned(~S,Systems.run_damage(~S,damage,world,args))),runtime))
# Sync each registered system separately, retaining its committed event batch.
# A failed movement stops damage; damage failure preserves the prior movement.
def run(~S: Data,state: State<S>,fixed_step: U32,args: Damage.DamageArgs) -> State<S> & FrameOutput:
  match state:
    case State{runtime,movement,damage}: movement_synced(~S,damage,args,ER.with_world(~S,~Storage.Store<S>,~Array<U32>,~Events.SimulationEvent,~MovementOutput<S>,(world => movement_returned(~S,Systems.run_movement(~S,movement,world,fixed_step))),runtime))
