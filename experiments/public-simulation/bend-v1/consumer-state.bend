import Base
import ../readers-v1/pair.bend as Readers
import ../readers-v1/readers.bend as R
import ./storage.bend as Storage
import ./events.bend as Events
import ./spawn-system.bend as Spawn
import ./systems.bend as Systems
import ./runtime-gameplay.bend as Game
import ./runtime-checkpoint.bend as Checkpoint
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as ER

def ReaderState(~S: Data) -> Type: Readers.ReaderPair<S,Storage.Store<S>,Array<U32>,Events.SimulationEvent>
type Registries<-S: Data> is Type:
  Registries{spawn: Maybe<&1,Spawn.Registry(~S)>,movement: Maybe<&1,Systems.MovementRegistry(~S)>,damage: Maybe<&1,Systems.DamageRegistry(~S)>}
type Application<-S: Data> is Type:
  Application{readers: ReaderState(~S),registries: Registries<S>}
type ReaderResults is Data:
  ReaderResults{a: Readers.Status<Events.SimulationEvent>,b: Readers.Status<Events.SimulationEvent>}
def readers_returned(~S: Data,registries: Registries<S>,result: Readers.Returned<S,Storage.Store<S>,Array<U32>,Events.SimulationEvent>) -> Application<S> & ReaderResults:
  match result:
    case Readers.Returned{pair,a,b}: (Application{pair,registries},ReaderResults{a,b})
def read(~S: Data,app: Application<S>,fail_b: Bool) -> Application<S> & ReaderResults:
  match app:
    case Application{pair,registries}: readers_returned(~S,registries,Readers.run(~S,~Storage.Store<S>,~Array<U32>,~Events.SimulationEvent,pair,fail_b))
def retry_b(~S: Data,app: Application<S>) -> Application<S> & ReaderResults:
  match app:
    case Application{pair,registries}: readers_returned(~S,registries,Readers.retry_b(~S,~Storage.Store<S>,~Array<U32>,~Events.SimulationEvent,pair))
type Observation is Data:
  Observation{runtime: Checkpoint.Snapshot,journalA: List<&2,ER.Reading<Events.SimulationEvent>>,journalB: List<&2,ER.Reading<Events.SimulationEvent>>}
def observed(~S: Data,registries: Registries<S>,a: R.Owner<S,Storage.Store<S>,Array<U32>,Events.SimulationEvent>,b: R.Owner<S,Storage.Store<S>,Array<U32>,Events.SimulationEvent>,+journalA: List<&2,ER.Reading<Events.SimulationEvent>>,+journalB: List<&2,ER.Reading<Events.SimulationEvent>>,result: Game.Runtime(~S) & Checkpoint.Snapshot) -> Application<S> & Observation:
  match result:
    case (runtime,snapshot): (Application{Readers.ReaderPair{runtime,a,b,journalA,journalB},registries},Observation{snapshot,journalA,journalB})
def observe_pair(~S: Data,label: String,registries: Registries<S>,pair: ReaderState(~S)) -> Application<S> & Observation:
  match pair:
    case Readers.ReaderPair{runtime,a,b,+journalA,+journalB}: observed(~S,registries,a,b,journalA,journalB,Checkpoint.observe(~S,label,runtime))
def observe(~S: Data,label: String,app: Application<S>) -> Application<S> & Observation:
  match app:
    case Application{pair,registries}: observe_pair(~S,label,registries,pair)
