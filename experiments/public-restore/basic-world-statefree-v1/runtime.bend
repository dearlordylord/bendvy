import Base
import model.bend as F
import locals.bend as Locals
import events.bend as Event
import reader.bend as ReaderTypes
import ../../../src/ecs/ordinary-owned-event-family-reader.bend as Reader
import ../../../src/ecs/owned-event-family-storage.bend as Storage
import ../../../src/ecs/event-family-routing.bend as Route
import ../../../src/ecs/event-family-runtime.bend as FR
def setup(~S:Data,world:F.World(~S),owner:Array<U32>) -> Event.Runtime(~S):Reader.setup(~S,~F.FullStore(~S),~F.FullResources(~S),~Array<U32>,~(F.UserResources(~S) & Event.Rest(~S)),~F.Events(~S),~Event.Domains(~S),~Event.FamilyOwner(~S),~Event.resource_path(~S),~Event.inject(~S),~Event.select(~S),~Event.domain(~S),~Event.make(~S),~Event.sync(~S),~Event.frame(~S),~Event.retain(~S),~Event.inventory(~S),~Event.take(~S),~Event.put(~S),~Array<U32>,Event.descriptor(~S),world,owner,8n)
def register(~S:Data,runtime:Event.Runtime(~S)) -> ReaderTypes.Registration(~S):Reader.register(~S,~F.FullStore(~S),~F.FullResources(~S),~Array<U32>,~(F.UserResources(~S) & Event.Rest(~S)),~F.Events(~S),~Event.Domains(~S),~Event.FamilyOwner(~S),~Event.resource_path(~S),~Event.inject(~S),~Event.select(~S),~Event.domain(~S),~Event.make(~S),~Event.sync(~S),~Event.frame(~S),~Event.retain(~S),~Event.inventory(~S),~Event.take(~S),~Event.put(~S),~Event.descriptor(~S),~Array<U32>,~Unit,~U32,~Array<U32>,~Unit,~ReaderTypes.at,~ReaderTypes.read_body,runtime,"SlowReader")
def read(~S:Data,runtime:Event.Runtime(~S),reader:ReaderTypes.ReaderOwner(~S),registry:ReaderTypes.Registry(~S),args:Array<U32>) -> ReaderTypes.ReadResult(~S):Reader.run(~S,~F.FullStore(~S),~F.FullResources(~S),~Array<U32>,~(F.UserResources(~S) & Event.Rest(~S)),~F.Events(~S),~Event.Domains(~S),~Event.FamilyOwner(~S),~Event.resource_path(~S),~Event.inject(~S),~Event.select(~S),~Event.domain(~S),~Event.make(~S),~Event.sync(~S),~Event.frame(~S),~Event.retain(~S),~Event.inventory(~S),~Event.take(~S),~Event.put(~S),~Event.descriptor(~S),~Array<U32>,~Unit,~U32,~Array<U32>,~Unit,~ReaderTypes.at,~ReaderTypes.read_body,runtime,reader,registry,args)
def returned(~S:Data,observed:Event.Runtime(~S) & Unit) -> Event.Runtime(~S):
  match observed:
    case (runtime,unit):runtime

def publish(~S:Data,runtime:Event.Runtime(~S),payload:Array<U32>) -> Event.Runtime(~S):
  match runtime:
    case Route.Runtime{world,state,tick}:returned(~S,Reader.world_returned(~S,~F.FullStore(~S),~F.FullResources(~S),~F.Events(~S),~Event.FamilyOwner(~S),~Array<U32>,~Event.sync(~S),~Unit,state,1n+tick,(Storage.commit_owned(~S,~F.FullStore(~S),~F.FullResources(~S),~Array<U32>,~(F.UserResources(~S) & Event.Rest(~S)),~F.Events(~S),~Event.resource_path(~S),~Event.inject(~S),world,[payload]),Unit{})))
