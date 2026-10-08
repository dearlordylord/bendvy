import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as ER
import ../readers-v1/readers.bend as R
import ../readers-v1/pair.bend as Readers
import ./storage.bend as Storage
import ./events.bend as Events
import ./runtime-gameplay.bend as Game
import ./runtime-start.bend as Start
import ./consumer-state.bend as App

type Initialized<-S: Data> is Type:
  Initialized{factory: W.Factory,app: App.Application<S>,readers: App.ReaderResults}
  WorldCreateRefused{factory: W.Factory,resource: Array<U32>}
  ReaderARegisterRefused{factory: W.Factory,runtime: Game.Runtime(~S)}
  ReaderARunStopped{factory: W.Factory,runtime: Game.Runtime(~S),a: R.Owner<S,Storage.Store<S>,Array<U32>,Events.SimulationEvent>,journalA: List<&2,ER.Reading<Events.SimulationEvent>>,statusA: Readers.Status<Events.SimulationEvent>}
  ReaderBRegisterRefused{factory: W.Factory,runtime: Game.Runtime(~S),a: R.Owner<S,Storage.Store<S>,Array<U32>,Events.SimulationEvent>,journalA: List<&2,ER.Reading<Events.SimulationEvent>>,statusA: Readers.Status<Events.SimulationEvent>}
def registered(~S: Data,factory: W.Factory,result: Readers.Registration<S,Storage.Store<S>,Array<U32>,Events.SimulationEvent>) -> Initialized<S>:
  match result:
    case Readers.Ready{Readers.Returned{pair,a,b}}: Initialized{factory,App.Application{pair,App.Registries{None{},None{},None{}}},App.ReaderResults{a,b}}
    case Readers.ARegistrationFailed{runtime}: ReaderARegisterRefused{factory,runtime}
    case Readers.ARunStopped{runtime,a,journalA,statusA}: ReaderARunStopped{factory,runtime,a,journalA,statusA}
    case Readers.BRegistrationFailed{runtime,a,journalA,statusA}: ReaderBRegisterRefused{factory,runtime,a,journalA,statusA}
def created(~S: Data,result: Start.Started<S>) -> Initialized<S>:
  match result:
    case Start.Started{factory,runtime}: registered(~S,factory,Readers.register(~S,~Storage.Store<S>,~Array<U32>,~Events.SimulationEvent,runtime))
    case Start.StartRefused{factory,resource}: WorldCreateRefused{factory,resource}
def initialize(~S: Data,factory: W.Factory,capacity: Nat) -> Initialized<S>:
  created(~S,Start.start(~S,factory,capacity))
