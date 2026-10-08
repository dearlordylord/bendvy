import Base
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as ER
import ../readers-v1/readers.bend as R
import ../readers-v1/pair.bend as Readers
import ./storage.bend as Storage
import ./events.bend as Events
import ./systems.bend as Systems
import ./spawn-system.bend as Spawn
import ./consumer-state.bend as App
import ./runtime-gameplay.bend as Game
import ./runtime-install.bend as Install
import ./damage-body.bend as Damage

type Completion is Data:
  GameplayRan{output: Game.FrameOutput}
  MovementRegistrationFailed{}
  DamageRegistrationFailed{}
  GameplayIncompleteRegistration{}
type Context<-S: Data> is Type:
  Context{a: R.Owner<S,Storage.Store<S>,Array<U32>,Events.SimulationEvent>,b: R.Owner<S,Storage.Store<S>,Array<U32>,Events.SimulationEvent>,journalA: List<&2,ER.Reading<Events.SimulationEvent>>,journalB: List<&2,ER.Reading<Events.SimulationEvent>>,spawn: Maybe<&1,Spawn.Registry(~S)>}
def assembled(~S: Data,runtime: Game.Runtime(~S),movement: Maybe<&1,Systems.MovementRegistry(~S)>,damage: Maybe<&1,Systems.DamageRegistry(~S)>,context: Context<S>) -> App.Application<S>:
  match context:
    case Context{a,b,journalA,journalB,spawn}: App.Application{Readers.ReaderPair{runtime,a,b,journalA,journalB},App.Registries{spawn,movement,damage}}
def returned_state(~S: Data,context: Context<S>,output: Game.FrameOutput,state: Game.State<S>) -> App.Application<S> & Completion:
  match state:
    case Game.State{runtime,movement,damage}: (assembled(~S,runtime,Some{movement},Some{damage},context),GameplayRan{output})
def returned(~S: Data,context: Context<S>,result: Game.State<S> & Game.FrameOutput) -> App.Application<S> & Completion:
  match result:
    case (state,output): returned_state(~S,context,output,state)
def installed(~S: Data,context: Context<S>,fixed_step: U32,args: Damage.DamageArgs,result: Game.Runtime(~S) & Install.Owners<S>) -> App.Application<S> & Completion:
  match result:
    case (runtime,Install.Installed{movement,damage}): returned(~S,context,Game.run(~S,Game.State{runtime,movement,damage},fixed_step,args))
    case (runtime,Install.MovementRefused{}): (assembled(~S,runtime,None{},None{},context),MovementRegistrationFailed{})
    case (runtime,Install.DamageRefused{movement}): (assembled(~S,runtime,Some{movement},None{},context),DamageRegistrationFailed{})
def selected(~S: Data,runtime: Game.Runtime(~S),context: Context<S>,fixed_step: U32,args: Damage.DamageArgs,movement: Maybe<&1,Systems.MovementRegistry(~S)>,damage: Maybe<&1,Systems.DamageRegistry(~S)>) -> App.Application<S> & Completion:
  match movement damage:
    case None{} None{}: installed(~S,context,fixed_step,args,Install.install(~S,runtime))
    case Some{movement} Some{damage}: returned(~S,context,Game.run(~S,Game.State{runtime,movement,damage},fixed_step,args))
    case movement damage: (assembled(~S,runtime,movement,damage,context),GameplayIncompleteRegistration{})
def registries(~S: Data,runtime: Game.Runtime(~S),a: R.Owner<S,Storage.Store<S>,Array<U32>,Events.SimulationEvent>,b: R.Owner<S,Storage.Store<S>,Array<U32>,Events.SimulationEvent>,journalA: List<&2,ER.Reading<Events.SimulationEvent>>,journalB: List<&2,ER.Reading<Events.SimulationEvent>>,fixed_step: U32,args: Damage.DamageArgs,owners: App.Registries<S>) -> App.Application<S> & Completion:
  match owners:
    case App.Registries{spawn,movement,damage}: selected(~S,runtime,Context{a,b,journalA,journalB,spawn},fixed_step,args,movement,damage)
def paired(~S: Data,owners: App.Registries<S>,fixed_step: U32,args: Damage.DamageArgs,pair: App.ReaderState(~S)) -> App.Application<S> & Completion:
  match pair:
    case Readers.ReaderPair{runtime,a,b,journalA,journalB}: registries(~S,runtime,a,b,journalA,journalB,fixed_step,args,owners)
def run(~S: Data,app: App.Application<S>,fixed_step: U32,args: Damage.DamageArgs) -> App.Application<S> & Completion:
  match app:
    case App.Application{pair,owners}: paired(~S,owners,fixed_step,args,pair)
