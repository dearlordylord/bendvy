import Base
import ../../../src/ecs/deferred-command.bend as Deferred
import ../../../src/ecs/entity-allocator.bend as Alloc
import allocator-observer.bend as Gen
import bundle.bend as B
import resources.bend as R
import owner-observer.bend as Dump
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/ordinary-system.bend as Ordinary
import ../../../src/ecs/ordinary-resource-field-system.bend as Field
import ../../../src/ecs/system.bend as Sys
import ../../../src/ecs/inspector.bend as I
import ../../../src/ecs/column.bend as Col
import ../../../src/ecs/owner-product.bend as Product
import ../../../src/ecs/capabilities.bend as Cap
import ../../../src/ecs/ordinary-query-declaration.bend as Query
def store_join(left:Col.Column<B.AuditWorkshop,Array<U32>> & String,right:Col.Column<B.AuditWorkshop,U32> & String) -> B.Store & String:
  (arrays,sa)=left
  (scalars,ss)=right
  (B.Store{arrays,scalars},"arrays={" ++ sa ++ "};scalars={" ++ ss ++ "}")
def store_snapshot(value:B.Store) -> B.Store & String:
  match value:
    case B.Store{arrays,scalars}:store_join(Dump.column(~B.AuditWorkshop,~Array<U32>,~Dump.u32_array,arrays),Dump.column(~B.AuditWorkshop,~U32,~Dump.u32_value,scalars))
def world_join(+namespace:U32,+events:List<&2,Nat>,+registrations:List<&2,W.RegistrationMeta>,+nextSystem:U32,+clock:U32,observedAllocator:Alloc.Allocator & String,observedStore:B.Store & String,observedResources:R.Resources() & String,observedPending:List<Deferred.Command<B.World(R.Resources())>> & (Nat & String)) -> B.World(R.Resources()) & String:
  (allocator,sa)=observedAllocator
  (store,ss)=observedStore
  (resources,sr)=observedResources
  (pending,(count,kinds))=observedPending
  (W.World{namespace,allocator,store,resources,events,pending,registrations,nextSystem,clock},"namespace=" ++ U32.show(namespace) ++ "|allocator={" ++ sa ++ "}|store=" ++ ss ++ "|resources=" ++ sr ++ "|events=" ++ List.show(&2,Nat,Nat.show,events) ++ "|pending=" ++ Nat.show(count) ++ "|pendingKinds=" ++ kinds ++ "|registrations=" ++ List.show(&2,W.RegistrationMeta,Dump.registration,registrations) ++ "|nextSystem=" ++ U32.show(nextSystem) ++ "|clock=" ++ U32.show(clock))
def world(value:B.World(R.Resources())) -> B.World(R.Resources()) & String:
  match value:
    case W.World{namespace,allocator,store,resources,events,pending,registrations,nextSystem,clock}:world_join(namespace,events,registrations,nextSystem,clock,Gen.allocator(allocator),store_snapshot(store),R.resource_view(resources),Dump.callbacks(~B.World(R.Resources()),~B.World(R.Resources()),pending))
