import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as ER
import ./storage.bend as Storage
import ./events.bend as Events
import ./application.bend as Application
import ./runtime-gameplay.bend as Game

type Started<-S: Data> is Type:
  Started{factory: W.Factory,runtime: Game.Runtime(~S)}
  StartRefused{factory: W.Factory,resource: Array<U32>}
def created(~S: Data,capacity: Nat,result: W.Creation<S,Storage.Store<S>,Array<U32>,Events.SimulationEvent>) -> Started<S>:
  match result:
    case W.Created{factory,world}: Started{factory,ER.start(~S,~Storage.Store<S>,~Array<U32>,~Events.SimulationEvent,world,capacity)}
    case W.CreateRejected{factory,resource}: StartRefused{factory,resource}
def start(~S: Data,factory: W.Factory,capacity: Nat) -> Started<S>:
  created(~S,capacity,Application.create(~S,factory))
