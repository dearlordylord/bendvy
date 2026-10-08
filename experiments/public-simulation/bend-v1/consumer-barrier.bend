import Base
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as ER
import ../readers-v1/readers.bend as R
import ../readers-v1/pair.bend as Readers
import ./storage.bend as Storage
import ./events.bend as Events
import ./consumer-state.bend as App
import ./runtime-gameplay.bend as Game
import ./runtime-spawn.bend as Runtime

def returned(~S: Data,registries: App.Registries<S>,a: R.Owner<S,Storage.Store<S>,Array<U32>,Events.SimulationEvent>,b: R.Owner<S,Storage.Store<S>,Array<U32>,Events.SimulationEvent>,journalA: List<&2,ER.Reading<Events.SimulationEvent>>,journalB: List<&2,ER.Reading<Events.SimulationEvent>>,observed: Game.Runtime(~S) & Unit) -> App.Application<S>:
  match observed:
    case (runtime,_): App.Application{Readers.ReaderPair{runtime,a,b,journalA,journalB},registries}
def barrier_pair(~S: Data,registries: App.Registries<S>,pair: App.ReaderState(~S)) -> App.Application<S>:
  match pair:
    case Readers.ReaderPair{runtime,a,b,journalA,journalB}: returned(~S,registries,a,b,journalA,journalB,Runtime.barrier(~S,runtime))
def barrier(~S: Data,app: App.Application<S>) -> App.Application<S>:
  match app:
    case App.Application{pair,registries}: barrier_pair(~S,registries,pair)
def frame_pair(~S: Data,registries: App.Registries<S>,pair: App.ReaderState(~S)) -> App.Application<S>:
  match pair:
    case Readers.ReaderPair{runtime,a,b,journalA,journalB}: App.Application{Readers.ReaderPair{Runtime.frame(~S,runtime),a,b,journalA,journalB},registries}
def frame(~S: Data,app: App.Application<S>) -> App.Application<S>:
  match app:
    case App.Application{pair,registries}: frame_pair(~S,registries,pair)
