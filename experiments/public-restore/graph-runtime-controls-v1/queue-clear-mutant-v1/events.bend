import Base
import ./fixture.bend as F
import ../../basic-world-statefree-v1/model.bend as Model
import ../../basic-world-statefree-v1/events.bend as Old
import ../../basic-world-statefree-v1/schema.bend as Original
import ../../../../src/ecs/ordinary-owned-event-family-reader-binding.bend as Setup
import ../../../../src/ecs/ordinary-owned-event-binding.bend as Binding
import ../../../../src/ecs/ordinary-event-family.bend as Family
import ../../../../src/ecs/event-family-routing.bend as Route
import ../../../../src/ecs/event-notice-runtime.bend as Mixed
import ./core/restore-graph-runtime-state.bend as State
import ../../../../src/ecs/owned-event-family-storage.bend as Storage
import ../../../../src/ecs/owner-product.bend as Product
import ../../../../src/ecs/owned-event-log.bend as Log
import ../../../../src/ecs/world.bend as W

def started(~S:Data,world:F.World(~S),owner:Array<U32>,provision:Family.Provision<S,Model.Events(~S),Old.Domains(~S),Old.FamilyOwner(~S),Old.make(~S),Old.sync(~S),Old.frame(~S),Old.retain(~S),Old.inventory(~S)>) -> F.RuntimeType(~S):
  match provision:
    case Family.Provision{domains}:Mixed.start(~S,~F.Store(~S),~F.Resources(~S),~Model.Events(~S),~Old.FamilyOwner(~S),~Array<U32>,world,Old.make(~S)(domains,8n),owner)
def descriptor(~S:Data,world:F.World(~S),owner:Array<U32>,value:Old.Descriptor(~S)) -> F.RuntimeType(~S):
  match value:
    case Setup.Setup{_,provision,_}:started(~S,world,owner,provision)
def setup(~S:Data,world:F.World(~S),owner:Array<U32>) -> F.RuntimeType(~S):descriptor(~S,world,owner,Old.descriptor(~S))
def Rest(~S:Data) -> Type:F.Machines(~S) & (Original.UserResources(~S) & Old.Rest(~S))
def path(~S:Data) -> Product.Lens<F.Resources(~S),Log.Log<Array<U32>>,Rest(~S)>:Binding.left_path(~Original.FullResources(~S),~F.Machines(~S),~Array<U32>,~(Original.UserResources(~S) & Old.Rest(~S)),~Old.resource_path(~S))
def inject(~S:Data) -> (Nat -> F.Events(~S)):Binding.notice_inject(~S,~Model.Events(~S),~Old.inject(~S))
def publish(~S:Data,runtime:F.RuntimeType(~S),payload:Array<U32>) -> F.RuntimeType(~S):
  match runtime:
    case Route.Runtime{world,state,+tick}:Mixed.ingest(~S,~F.Store(~S),~F.Resources(~S),~Model.Events(~S),~Old.FamilyOwner(~S),~Array<U32>,~Old.sync(~S),~State.classify(~S,~Model.Events(~S)),1n+tick,Route.Runtime{Storage.commit_owned(~S,~F.Store(~S),~F.Resources(~S),~Array<U32>,~Rest(~S),~F.Events(~S),~path(~S),~inject(~S),world,[payload]),state,tick})
def synchronize(~S:Data,runtime:F.RuntimeType(~S)) -> F.RuntimeType(~S):Mixed.after_success(~S,~F.Store(~S),~F.Resources(~S),~Model.Events(~S),~Old.FamilyOwner(~S),~Array<U32>,~Old.sync(~S),~State.classify(~S,~Model.Events(~S)),runtime)
def barrier(~S:Data,runtime:F.RuntimeType(~S)) -> F.RuntimeType(~S):Mixed.barrier(~S,~F.Store(~S),~F.Resources(~S),~Model.Events(~S),~Old.FamilyOwner(~S),~Array<U32>,~State.classify(~S,~Model.Events(~S)),runtime)
