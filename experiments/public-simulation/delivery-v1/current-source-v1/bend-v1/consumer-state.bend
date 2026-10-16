import Base
import ./owner-metadata.bend as Metadata
import ../readers-v1/pair.bend as Readers
import ../readers-v1/readers.bend as R
import ./storage.bend as Storage
import ./events.bend as Events
import ./spawn-system.bend as Spawn
import ./systems.bend as Systems
import ./runtime-gameplay.bend as Game
import ./runtime-checkpoint.bend as Checkpoint
import ../../../../../src/ecs/event-runtime.bend as ER

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
  Observation{runtime: Checkpoint.Snapshot,journalA: List<&2,ER.Reading<Events.SimulationEvent>>,journalB: List<&2,ER.Reading<Events.SimulationEvent>>,owners:Metadata.OwnerMetadata}
def metadata_b(~S:Data,runtime:Game.Runtime(~S),snapshot:Checkpoint.Snapshot,registries:Registries<S>,a:R.Owner<S,Storage.Store<S>,Array<U32>,Events.SimulationEvent>,+journalA:List<&2,ER.Reading<Events.SimulationEvent>>,+journalB:List<&2,ER.Reading<Events.SimulationEvent>>,sv:Maybe<&2,Metadata.RegistryMetadata>,mv:Maybe<&2,Metadata.RegistryMetadata>,dv:Maybe<&2,Metadata.RegistryMetadata>,av:Metadata.ReaderMetadata,observed:R.Owner<S,Storage.Store<S>,Array<U32>,Events.SimulationEvent> & Metadata.ReaderMetadata) -> Application<S> & Observation:
  (b,bv)=observed
  (Application{Readers.ReaderPair{runtime,a,b,journalA,journalB},registries},Observation{snapshot,journalA,journalB,Metadata.OwnerMetadata{sv,mv,dv,av,bv}})
def metadata_a(~S:Data,runtime:Game.Runtime(~S),snapshot:Checkpoint.Snapshot,registries:Registries<S>,b:R.Owner<S,Storage.Store<S>,Array<U32>,Events.SimulationEvent>,journalA:List<&2,ER.Reading<Events.SimulationEvent>>,journalB:List<&2,ER.Reading<Events.SimulationEvent>>,sv:Maybe<&2,Metadata.RegistryMetadata>,mv:Maybe<&2,Metadata.RegistryMetadata>,dv:Maybe<&2,Metadata.RegistryMetadata>,observed:R.Owner<S,Storage.Store<S>,Array<U32>,Events.SimulationEvent> & Metadata.ReaderMetadata) -> Application<S> & Observation:
  (a,av)=observed
  metadata_b(~S,runtime,snapshot,registries,a,journalA,journalB,sv,mv,dv,av,Metadata.reader(~S,b))
def metadata_registries(~S:Data,runtime:Game.Runtime(~S),snapshot:Checkpoint.Snapshot,a:R.Owner<S,Storage.Store<S>,Array<U32>,Events.SimulationEvent>,b:R.Owner<S,Storage.Store<S>,Array<U32>,Events.SimulationEvent>,journalA:List<&2,ER.Reading<Events.SimulationEvent>>,journalB:List<&2,ER.Reading<Events.SimulationEvent>>,observed:Metadata.RegistryRead<S>) -> Application<S> & Observation:
  match observed:
    case Metadata.RegistryRead{spawn,movement,damage,Metadata.RegistryViews{sv,mv,dv}}:metadata_a(~S,runtime,snapshot,Registries{spawn,movement,damage},b,journalA,journalB,sv,mv,dv,Metadata.reader(~S,a))
def observed(~S: Data,registries: Registries<S>,a: R.Owner<S,Storage.Store<S>,Array<U32>,Events.SimulationEvent>,b: R.Owner<S,Storage.Store<S>,Array<U32>,Events.SimulationEvent>,+journalA: List<&2,ER.Reading<Events.SimulationEvent>>,+journalB: List<&2,ER.Reading<Events.SimulationEvent>>,result: Game.Runtime(~S) & Checkpoint.Snapshot) -> Application<S> & Observation:
  match registries result:
    case Registries{spawn,movement,damage},(runtime,snapshot): metadata_registries(~S,runtime,snapshot,a,b,journalA,journalB,Metadata.registries(~S,spawn,movement,damage))
def observe_pair(~S: Data,label: String,registries: Registries<S>,pair: ReaderState(~S)) -> Application<S> & Observation:
  match pair:
    case Readers.ReaderPair{runtime,a,b,+journalA,+journalB}: observed(~S,registries,a,b,journalA,journalB,Checkpoint.observe(~S,label,runtime))
def observe(~S: Data,label: String,app: Application<S>) -> Application<S> & Observation:
  match app:
    case Application{pair,registries}: observe_pair(~S,label,registries,pair)
