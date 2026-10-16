import Base
import bundle.bend as B
import resources.bend as R
import owner-observer.bend as Dump
import systems.bend as Systems
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-system.bend as Ordinary
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-resource-field-system.bend as Field
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/owner-product.bend as Product
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-query-declaration.bend as Query
def store_join(left:Col.Column<B.AuditWorkshop,Array<U32>> & String,right:Col.Column<B.AuditWorkshop,U32> & String) -> B.Store & String:
  (arrays,sa)=left
  (scalars,ss)=right
  (B.Store{arrays,scalars},"arrays={" ++ sa ++ "};scalars={" ++ ss ++ "}")
def store_snapshot(value:B.Store) -> B.Store & String:
  match value:
    case B.Store{arrays,scalars}:store_join(Dump.column(~B.AuditWorkshop,~Array<U32>,~Dump.u32_array,arrays),Dump.column(~B.AuditWorkshop,~U32,~Dump.u32_value,scalars))
def world_join(+namespace:U32,+nextId:U32,+high:U32,+capacity:U32,+depth:Nat,+events:List<&2,U32>,+registrations:List<&2,W.RegistrationMeta>,+nextSystem:U32,+clock:U32,observedLive:Array<Bool> & String,observedStore:B.Store & String,observedResources:R.Resources() & String,observedPending:List<(B.World(R.Resources()) -> B.World(R.Resources()))> & Nat) -> B.World(R.Resources()) & String:
  (live,sl)=observedLive
  (store,ss)=observedStore
  (resources,sr)=observedResources
  (pending,count)=observedPending
  (W.World{namespace,nextId,high,live,capacity,depth,store,resources,events,pending,registrations,nextSystem,clock},"namespace=" ++ U32.show(namespace) ++ "|next=" ++ U32.show(nextId) ++ "|high=" ++ U32.show(high) ++ "|live=" ++ sl ++ "|capacity=" ++ U32.show(capacity) ++ "|depth=" ++ Nat.show(depth) ++ "|store=" ++ ss ++ "|resources=" ++ sr ++ "|events=" ++ List.show(&2,U32,U32.show,events) ++ "|pending=" ++ Nat.show(count) ++ "|registrations=" ++ List.show(&2,W.RegistrationMeta,Dump.registration,registrations) ++ "|nextSystem=" ++ U32.show(nextSystem) ++ "|clock=" ++ U32.show(clock))
def world(value:B.World(R.Resources())) -> B.World(R.Resources()) & String:
  match value:
    case W.World{namespace,nextId,high,live,capacity,depth,store,resources,events,pending,registrations,nextSystem,clock}:world_join(namespace,nextId,high,capacity,depth,events,registrations,nextSystem,clock,Dump.bool_array(live),store_snapshot(store),R.resource_view(resources),Dump.callbacks(~B.World(R.Resources()),~B.World(R.Resources()),pending))
type RegistryView is Data:
  RegistryView{namespace:U32,id:U32,name:String,access:List<&2,String>,cursor:U32}
type OwnerViews is Data:
  OwnerViews{component:RegistryView,slot:String,clauses:List<&2,Query.Clause<B.AuditWorkshop>>,resource:RegistryView}
def owners(value:Systems.Owners) -> Systems.Owners & OwnerViews:
  match value:
    case Systems.Owners{Ordinary.Owner{Sys.Registry{+cn,+ci,+cname,+ca,+cc},+slot,+clauses},Field.Owner{Sys.Registry{+rn,+ri,+rname,+ra,+rc}}}:(Systems.Owners{Ordinary.Owner{Sys.Registry{cn,ci,cname,ca,cc},slot,clauses},Field.Owner{Sys.Registry{rn,ri,rname,ra,rc}}},OwnerViews{RegistryView{cn,ci,cname,ca,cc},slot,clauses,RegistryView{rn,ri,rname,ra,rc}})
