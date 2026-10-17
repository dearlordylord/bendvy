import Base
import model.bend as F
import locals.bend as Locals
import ../../../src/ecs/restore-data.bend as Change
import ../../../src/ecs/restore-events.bend as RestoreEvents
import ../../../src/ecs/ordinary-owned-event-family-reader-binding.bend as Setup
import ../../../src/ecs/ordinary-owned-event-binding.bend as Binding
import ../../../src/ecs/ordinary-owned-event.bend as Pub
import ../../../src/ecs/owned-event-log.bend as Log
import ../../../src/ecs/owned-event-key-route.bend as KeyRoute
import ../../../src/ecs/ordinary-event-family.bend as Family
import ../../../src/ecs/owner-product.bend as Product
import ../../../src/ecs/event-publication.bend as Publication
import ../../../src/ecs/ordinary-event-declaration.bend as Declaration
import ../../../src/ecs/event-stream.bend as Stream
import ../../../src/ecs/event-family-runtime.bend as FR
import ../../../src/ecs/event-family-routing.bend as Route
import ../../../src/ecs/owned-event-family-reader-runtime.bend as Core
import ../../../src/ecs/ordinary-owned-event-family-reader.bend as Reader
import ../../../src/ecs/capabilities.bend as Cap
import ../../../src/ecs/transaction.bend as T
import ../../../src/ecs/system.bend as Sys
import ../../../src/ecs/event-runtime.bend as Ev
def domain(~S:Data) -> Pub.Domain<S,Array<U32>>:Pub.domain(~S,~Array<U32>,"OwnedCargo")
def lifecycle(~S:Data) -> Declaration.Domain<S,Change.Change<S>>:Declaration.domain(~S,~Change.Change<S>,"Lifecycle")
def Domains(~S:Data) -> Data:Family.Domains<Declaration.Domain<S,Nat>,Declaration.Domain<S,Change.Change<S>>>
def FamilyOwner(~S:Data) -> Type:Product.Owner<Stream.Stream<S,Nat>,Stream.Stream<S,Change.Change<S>>>
def Rest(~S:Data) -> Type:Unit & Unit
def path(~S:Data) -> (Product.Lens<F.Logs(),Log.Log<Array<U32>>,Rest(~S)>):Binding.left_path(~Log.Log<Array<U32>>,~Unit,~Array<U32>,~Unit,~Binding.identity_lens(~Log.Log<Array<U32>>))
def inject(~S:Data) -> (Nat -> F.Events(~S)):KeyRoute.inject_left(~Nat,~Change.Change<S>,~KeyRoute.inject_leaf)
def select(~S:Data) -> (List<&2,F.Events(~S)> -> List<&2,Nat>):KeyRoute.select_left(~Nat,~Change.Change<S>,~KeyRoute.select_leaf)
def make(~S:Data) -> (Domains(~S) -> Nat -> FamilyOwner(~S)):Family.node_make(~Declaration.Domain<S,Nat>,~Declaration.Domain<S,Change.Change<S>>,~Stream.Stream<S,Nat>,~Stream.Stream<S,Change.Change<S>>,~Family.leaf_make(~S,~Nat),~Family.leaf_make(~S,~Change.Change<S>))
def sync(~S:Data) -> (FamilyOwner(~S) -> Nat -> List<&2,F.Events(~S)> -> FamilyOwner(~S)):Family.node_sync(~Nat,~Change.Change<S>,~Stream.Stream<S,Nat>,~Stream.Stream<S,Change.Change<S>>,~Family.leaf_sync(~S,~Nat),~Family.leaf_sync(~S,~Change.Change<S>))
def frame(~S:Data) -> (FamilyOwner(~S) -> Nat -> FamilyOwner(~S)):Family.node_frame(~Stream.Stream<S,Nat>,~Stream.Stream<S,Change.Change<S>>,~Family.leaf_frame(~S,~Nat),~Family.leaf_frame(~S,~Change.Change<S>))
def retain(~S:Data) -> (FamilyOwner(~S) -> Nat -> List<&2,F.Events(~S)> -> FamilyOwner(~S) & List<&2,F.Events(~S)>):Family.pair_retain(~Nat,~Change.Change<S>,~Stream.Stream<S,Nat>,~Stream.Stream<S,Change.Change<S>>,~Family.leaf_retain(~S,~Nat),~Family.leaf_retain(~S,~Change.Change<S>))
def inventory(~S:Data) -> (FamilyOwner(~S) -> FamilyOwner(~S) & List<&2,String>):Family.pair_inventory(~Stream.Stream<S,Nat>,~Stream.Stream<S,Change.Change<S>>,~Family.leaf_inventory(~S,~Nat),~Family.leaf_inventory(~S,~Change.Change<S>))
def take(~S:Data) -> (FamilyOwner(~S) -> FamilyOwner(~S) & Stream.Stream<S,Nat>):Family.left_take(~S,~Nat,~Stream.Stream<S,Nat>,~Stream.Stream<S,Change.Change<S>>,~Family.selected_leaf(~S,~Nat))
def put(~S:Data) -> (FamilyOwner(~S) -> Stream.Stream<S,Nat> -> FamilyOwner(~S)):Family.left_put(~S,~Nat,~Stream.Stream<S,Nat>,~Stream.Stream<S,Change.Change<S>>,~Family.replaced_leaf(~S,~Nat))
def resource_path(~S:Data) -> Product.Lens<F.FullResources(~S),Log.Log<Array<U32>>,F.UserResources(~S) & Rest(~S)>:Binding.right_path(~F.UserResources(~S),~F.Logs(),~Array<U32>,~Rest(~S),~path(~S))
def Descriptor(~S:Data) -> Data:Setup.Setup<S,F.FullResources(~S),Array<U32>,F.UserResources(~S) & Rest(~S),F.Events(~S),Domains(~S),FamilyOwner(~S),resource_path(~S),inject(~S),select(~S),domain(~S),make(~S),sync(~S),frame(~S),retain(~S),inventory(~S),take(~S),put(~S)>
def descriptor(~S:Data) -> Descriptor(~S):Setup.under_resource(~S,~F.UserResources(~S),~F.Logs(),~Array<U32>,~Rest(~S),~F.Events(~S),~Domains(~S),~FamilyOwner(~S),~path(~S),~inject(~S),~select(~S),~domain(~S),~make(~S),~sync(~S),~frame(~S),~retain(~S),~inventory(~S),~take(~S),~put(~S),RestoreEvents.with_data(~S,~Array<U32>,~Change.Change<S>,~domain(~S),lifecycle(~S)))
def State(~S:Data) -> Type:FR.State<F.Events(~S),FamilyOwner(~S),Array<U32>>
def Runtime(~S:Data) -> Type:Route.Runtime<S,F.FullStore(~S),F.FullResources(~S),F.Events(~S),State(~S)>
def state_take(~S:Data) -> (State(~S) -> State(~S) & Stream.Stream<S,Nat>):FR.take(~S,~Nat,~F.Events(~S),~FamilyOwner(~S),~Array<U32>,~take(~S))
def state_put(~S:Data) -> (State(~S) -> Stream.Stream<S,Nat> -> State(~S)):FR.put(~S,~Nat,~F.Events(~S),~FamilyOwner(~S),~Array<U32>,~put(~S))
