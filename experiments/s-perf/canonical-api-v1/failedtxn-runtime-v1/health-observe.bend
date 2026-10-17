import Base
import health-logical.bend as Logical
import ../dense-runtime-v1/render.bend as JSON
import ../../../../src/ecs/inspector-query-projection.bend as Projection
import ../../../../src/ecs/inspector-query.bend as IQ
import health-events.bend as E
import ../../../../src/ecs/relation-commands.bend as Notice
import ../../../../src/ecs/relation-types.bend as G
import ../../../../src/ecs/component.bend as Cmp
import health.bend as F
import ../dense-runtime-v1/types.bend as T
import health-resources.bend as R
import ../../../../src/ecs/ordinary-service-declaration.bend as Service
import ../../../public-audit61/app-a-current-carrier-v1/owner-observer.bend as Dump
import ../../../public-audit61/app-a-current-carrier-v1/allocator-observer.bend as Gen
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/owner-product.bend as Product
import ../../../../src/ecs/ordinary-system.bend as Ordinary
import ../../../../src/ecs/system.bend as Sys
import ../../../../src/ecs/ordinary-query-declaration.bend as Decl
import ../../../../src/ecs/compose.bend as Q
import ../../../../src/ecs/transaction.bend as Tx
import ../../../../src/ecs/column.bend as Col
import ../../../../src/ecs/deferred-command.bend as Deferred
import ../../../../src/ecs/entity-allocator.bend as Alloc
import ../../../../src/ecs/entity-key.bend as Key
def main_joined(+reserve:U32,+class:U32,observed:Array<U32> & String) -> T.Vitals & String:
  match observed:
    case (values,text):(T.Vitals{values,reserve,class},"Vitals{" ++ text ++ ";" ++ U32.show(reserve) ++ ";" ++ U32.show(class) ++ "}")
def main(owner:T.Vitals) -> T.Vitals & String:
  match owner:
    case T.Vitals{values,reserve,class}:main_joined(reserve,class,Dump.u32_array(values))
def aux_joined(+grade:U32,observed:Array<U32> & String) -> T.Armor & String:
  match observed:
    case (values,text):(T.Armor{values,grade},"Armor{" ++ text ++ ";" ++ U32.show(grade) ++ "}")
def aux(owner:T.Armor) -> T.Armor & String:
  match owner:
    case T.Armor{values,grade}:aux_joined(grade,Dump.u32_array(values))
def ledger_joined(+epoch:U32,observed:Array<U32> & String) -> T.HealthLedger & String:
  match observed:
    case (values,text):(T.HealthLedger{values,epoch},"HealthLedger{" ++ text ++ ";" ++ U32.show(epoch) ++ "}")
def ledger(owner:T.HealthLedger) -> T.HealthLedger & String:
  match owner:
    case T.HealthLedger{values,epoch}:ledger_joined(epoch,Dump.u32_array(values))
def flag_copy(+value:T.Tracked) -> T.Tracked & String:
  match value:
    case T.Tracked{+group}:(T.Tracked{group},"Tracked{" ++ U32.show(group) ++ "}")
def flag(value:T.Tracked) -> T.Tracked & String:flag_copy(value)
def store_join(left:Col.Column<T.HealthSchema,T.Vitals> & String,middle:Col.Column<T.HealthSchema,T.Armor> & String,right:Col.Column<T.HealthSchema,T.Tracked> & String) -> F.Store() & String:
  (main,sm)=left
  (aux,sa)=middle
  (flag,sf)=right
  (Product.Owner{main,Product.Owner{aux,flag}},"main={" ++ sm ++ "};aux={" ++ sa ++ "};flag={" ++ sf ++ "}")
def store(owner:F.Store()) -> F.Store() & String:
  match owner:
    case Product.Owner{mc,Product.Owner{ac,fc}}:store_join(Dump.column(~T.HealthSchema,~T.Vitals,~main,mc),Dump.column(~T.HealthSchema,~T.Armor,~aux,ac),Dump.column(~T.HealthSchema,~T.Tracked,~flag,fc))
def audit_effect_copy(+text:String) -> String:Nat.show(String.length(text)) ++ ":" ++ text
def audit_effect(text:String) -> String:audit_effect_copy(text)
def audit(owner:Service.Slot<R.Audit>) -> Service.Slot<R.Audit> & String:
  match owner:
    case Service.Missing{}:(Service.Missing{},"Missing")
    case Service.Ready{R.Recorded{+effects}}:(Service.Ready{R.Recorded{effects}},"Recorded" ++ List.show(&2,String,audit_effect,effects))
def resources_join(left:T.HealthLedger & String,right:Service.Slot<R.Audit> & String) -> F.Resources() & String:
  (ledger,sl)=left
  (slot,sa)=right
  (Product.Owner{ledger,slot},"ledger={" ++ sl ++ "};audit={" ++ sa ++ "}")
def resources(owner:F.Resources()) -> F.Resources() & String:
  match owner:
    case Product.Owner{value,slot}:resources_join(ledger(value),audit(slot))
def key(value:Key.Key) -> String:
  match value:
    case Key.EntityKey{index,generation}:U32.show(index) ++ ":" ++ U32.show(generation)
def handle(value:W.Handle<T.HealthSchema>) -> String:
  match value:
    case W.Handle{ns,Key.EntityKey{index,generation}}:U32.show(ns) ++ ":" ++ U32.show(index) ++ ":" ++ U32.show(generation)
def kind(value:G.RelationKind) -> String:
  match value:
    case G.Ordinary{}:"Ordinary"
    case G.Hierarchy{}:"Hierarchy"
def descriptor(~S:Data,value:G.Descriptor<S>) -> String:
  match value:
    case G.Descriptor{key,name,inverse,k}:"Descriptor{" ++ U32.show(key) ++ ";" ++ name ++ ";inverse=" ++ inverse ++ ";kind=" ++ kind(k) ++ "}"
def edge(~S:Data,value:G.Edge<S>) -> String:
  match value:
    case G.Edge{relation,source,target}:"Edge{" ++ descriptor(~S,relation) ++ ";source=" ++ key(source) ++ ";target=" ++ key(target) ++ "}"
def inverse(~S:Data,value:G.Inverse<S>) -> String:
  match value:
    case G.Inverse{relation,target,sources}:"Inverse{" ++ descriptor(~S,relation) ++ ";target=" ++ key(target) ++ ";sources=" ++ List.show(&2,Key.Key,key,sources) ++ "}"
def graph(~S:Data,value:G.Graph<S>) -> String:
  match value:
    case G.Graph{edges,inverses}:"Graph{edges=" ++ List.show(&2,G.Edge<S>,edge(~S),edges) ++ ";inverses=" ++ List.show(&2,G.Inverse<S>,inverse(~S),inverses) ++ "}"
def relation_error(value:G.Error) -> String:
  match value:
    case G.MissingEntity{source}:"MissingEntity{" ++ key(source) ++ "}"
    case G.MissingTargetEntity{source,target,relation}:"MissingTargetEntity{" ++ key(source) ++ ";" ++ key(target) ++ ";" ++ relation ++ "}"
    case G.SelfRelationNotAllowed{source,relation}:"SelfRelationNotAllowed{" ++ key(source) ++ ";" ++ relation ++ "}"
    case G.HierarchyCycle{source,target,relation}:"HierarchyCycle{" ++ key(source) ++ ";" ++ key(target) ++ ";" ++ relation ++ "}"
    case G.MissingChildEntity{source,child,relation}:"MissingChildEntity{" ++ key(source) ++ ";" ++ key(child) ++ ";" ++ relation ++ "}"
    case G.DuplicateChild{source,child,relation}:"DuplicateChild{" ++ key(source) ++ ";" ++ key(child) ++ ";" ++ relation ++ "}"
    case G.ChildNotRelatedToParent{source,child,relation}:"ChildNotRelatedToParent{" ++ key(source) ++ ";" ++ key(child) ++ ";" ++ relation ++ "}"
    case G.ChildSetMismatch{source,relation}:"ChildSetMismatch{" ++ key(source) ++ ";" ++ relation ++ "}"
def operation(value:G.Operation) -> String:
  match value:
    case G.Relate{}:"Relate"
    case G.ReorderChildren{}:"ReorderChildren"
def failure(~S:Data,value:G.Failure<S>) -> String:
  match value:
    case G.Failure{relation,op,source,target,error}:"Failure{" ++ descriptor(~S,relation) ++ ";operation=" ++ operation(op) ++ ";source=" ++ key(source) ++ ";target=" ++ key(target) ++ ";error=" ++ relation_error(error) ++ "}"
def frame(~S:Data,value:G.CleanupFrame<S>) -> String:
  match value:
    case G.CleanupEnter{id}:"Enter{" ++ key(id) ++ "}"
    case G.CleanupDescriptors{id,remaining}:"Descriptors{" ++ key(id) ++ ";" ++ List.show(&2,G.Descriptor<S>,descriptor(~S),remaining) ++ "}"
    case G.CleanupChildren{id,desc,remaining,children}:"Children{" ++ key(id) ++ ";" ++ descriptor(~S,desc) ++ ";" ++ List.show(&2,G.Descriptor<S>,descriptor(~S),remaining) ++ ";" ++ List.show(&2,Key.Key,key,children) ++ "}"
    case G.CleanupFinish{id}:"Finish{" ++ key(id) ++ "}"
def publication(value:Nat) -> String:Nat.show(value)
def event(value:E.event_type()) -> String:
  match value:
    case Notice.Original{value}:"Original{" ++ publication(value) ++ "}"
    case Notice.RelationFailed{value}:"RelationFailed{" ++ failure(~T.HealthSchema,value) ++ "}"
    case Notice.ComponentRemoved{value}:"ComponentRemoved{" ++ key(value) ++ "}"
    case Notice.CleanupPaused{values}:"CleanupPaused{" ++ List.show(&2,G.CleanupFrame<T.HealthSchema>,frame(~T.HealthSchema),values) ++ "}"
def world_join(+namespace:U32,+events:List<&2,E.event_type()>,+registrations:List<&2,W.RegistrationMeta>,+nextSystem:U32,+clock:U32,observedAllocator:Alloc.Allocator & String,observedStore:F.Store() & String,observedResource:F.Resources() & String,observedPending:List<Deferred.Command<F.World()>> & (Nat & String)) -> F.World() & String:
  (allocator,sa)=observedAllocator
  (store,ss)=observedStore
  (resource,sr)=observedResource
  (pending,(count,kinds))=observedPending
  (W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystem,clock},"namespace=" ++ U32.show(namespace) ++ "|allocator={" ++ sa ++ "}|store={" ++ ss ++ "}|resource={" ++ sr ++ "}|events=" ++ List.show(&2,E.event_type(),event,events) ++ "|pending=" ++ Nat.show(count) ++ ":" ++ kinds ++ "|registrations=" ++ List.show(&2,W.RegistrationMeta,Dump.registration,registrations) ++ "|nextSystem=" ++ U32.show(nextSystem) ++ "|clock=" ++ U32.show(clock))
def world(owner:F.World()) -> F.World() & String:
  match owner:
    case W.World{namespace,allocator,stored,resource,events,pending,registrations,nextSystem,clock}:world_join(namespace,events,registrations,nextSystem,clock,Gen.allocator(allocator),store(stored),resources(resource),Dump.callbacks(~F.World(),~F.World(),pending))
def error(value:W.WorldError) -> String:
  match value:
    case W.MissingEntity{}:"MissingEntity"
    case W.CapacityExceeded{}:"CapacityExceeded"
    case W.NamespaceExhausted{}:"NamespaceExhausted"
    case W.SystemIdExhausted{}:"SystemIdExhausted"
def reservation(value:W.Reservation<T.HealthSchema>) -> String:
  match value:
    case W.Reserved{id}:"Reserved(" ++ handle(id) ++ ")"
    case W.ReservationRejected{reason}:"ReservationRejected(" ++ error(reason) ++ ")"

def access(~V:Data,~show:V -> String,value:Cmp.Access<V>) -> String:
  match value:
    case Cmp.Found{value}:"Found(" ++ show(value) ++ ")"
    case Cmp.ComponentAbsent{}:"ComponentAbsent"
    case Cmp.MissingEntity{}:"MissingEntity"
def row(value:IQ.ProjectedRow<T.HealthSchema,Logical.Value()>) -> String:
  match value:
    case IQ.ProjectedRow{entity,Projection.Product{main,Projection.Product{aux,flag}}}:"handle=" ++ handle(entity) ++ ";main=" ++ access(~T.VitalsView,~JSON.render_vitals,main) ++ ";aux=" ++ access(~T.ArmorView,~JSON.render_armor,aux) ++ ";flag=" ++ access(~T.Tracked,~JSON.render_tracked,flag)
def rows_observed(observed:F.World() & Logical.Rows()) -> F.World() & String:
  match observed:
    case (world,rows):(world,List.show(&2,IQ.ProjectedRow<T.HealthSchema,Logical.Value()>,row,rows))
def rows(world:F.World()) -> F.World() & String:rows_observed(Logical.rows(world))
