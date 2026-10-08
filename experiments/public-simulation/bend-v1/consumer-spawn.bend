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
import ./runtime-spawn.bend as Runtime
import ./runtime-register-spawn.bend as Register

type Context<-S: Data> is Type:
  Context{a: R.Owner<S,Storage.Store<S>,Array<U32>,Events.SimulationEvent>,b: R.Owner<S,Storage.Store<S>,Array<U32>,Events.SimulationEvent>,journalA: List<&2,ER.Reading<Events.SimulationEvent>>,journalB: List<&2,ER.Reading<Events.SimulationEvent>>,movement: Maybe<&1,Systems.MovementRegistry(~S)>,damage: Maybe<&1,Systems.DamageRegistry(~S)>}
def assembled(~S: Data,runtime: Game.Runtime(~S),spawn: Maybe<&1,Spawn.Registry(~S)>,context: Context<S>) -> App.Application<S>:
  match context:
    case Context{a,b,journalA,journalB,movement,damage}: App.Application{Readers.ReaderPair{runtime,a,b,journalA,journalB},App.Registries{spawn,movement,damage}}
def returned(~S: Data,context: Context<S>,result: Game.Runtime(~S) & Runtime.Output<S>) -> App.Application<S> & Runtime.Completion<S>:
  match result:
    case (runtime,Runtime.Output{registry,completion}): (assembled(~S,runtime,Some{registry},context),completion)
def registered(~S: Data,context: Context<S>,result: Game.Runtime(~S) & Register.Registered<S>) -> App.Application<S> & Runtime.Completion<S>:
  match result:
    case (runtime,Register.Registered{registry}): returned(~S,context,Runtime.run(~S,runtime,registry))
    case (runtime,Register.RegistrationRefused{}): (assembled(~S,runtime,None{},context),Runtime.SpawnRegistrationRejected{})
def selected(~S: Data,runtime: Game.Runtime(~S),context: Context<S>,spawn: Maybe<&1,Spawn.Registry(~S)>) -> App.Application<S> & Runtime.Completion<S>:
  match spawn:
    case None{}: registered(~S,context,Register.register(~S,runtime))
    case Some{registry}: returned(~S,context,Runtime.run(~S,runtime,registry))
def registries(~S: Data,runtime: Game.Runtime(~S),a: R.Owner<S,Storage.Store<S>,Array<U32>,Events.SimulationEvent>,b: R.Owner<S,Storage.Store<S>,Array<U32>,Events.SimulationEvent>,journalA: List<&2,ER.Reading<Events.SimulationEvent>>,journalB: List<&2,ER.Reading<Events.SimulationEvent>>,owners: App.Registries<S>) -> App.Application<S> & Runtime.Completion<S>:
  match owners:
    case App.Registries{spawn,movement,damage}: selected(~S,runtime,Context{a,b,journalA,journalB,movement,damage},spawn)
def paired(~S: Data,owners: App.Registries<S>,pair: App.ReaderState(~S)) -> App.Application<S> & Runtime.Completion<S>:
  match pair:
    case Readers.ReaderPair{runtime,a,b,journalA,journalB}: registries(~S,runtime,a,b,journalA,journalB,owners)
def run(~S: Data,app: App.Application<S>) -> App.Application<S> & Runtime.Completion<S>:
  match app:
    case App.Application{pair,owners}: paired(~S,owners,pair)
