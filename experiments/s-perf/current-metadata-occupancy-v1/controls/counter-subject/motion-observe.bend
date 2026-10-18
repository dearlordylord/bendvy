import Base
import events.bend as E
import ../../private/src/ecs/relation-commands.bend as Notice
import ../../private/src/ecs/relation-types.bend as G
import motion-logical.bend as Logical
import render.bend as JSON
import ../../private/src/ecs/inspector-query-projection.bend as Projection
import ../../private/src/ecs/inspector-query.bend as IQ
import ../../private/src/ecs/component.bend as Cmp
import motion.bend as F
import types.bend as T
import ../../private/observers/owner-observer.bend as Dump
import ../../private/observers/allocator-observer.bend as Gen
import ../../private/src/ecs/world.bend as W
import ../../private/src/ecs/owner-product.bend as Product
import ../../private/src/ecs/ordinary-system.bend as Ordinary
import ../../private/src/ecs/system.bend as Sys
import ../../private/src/ecs/ordinary-query-declaration.bend as Decl
import ../../private/src/ecs/compose.bend as Q
import ../../private/src/ecs/transaction.bend as Tx
import ../../private/src/ecs/column.bend as Col
import ../../private/src/ecs/deferred-command.bend as Deferred
import ../../private/src/ecs/entity-allocator.bend as Alloc
import ../../private/src/ecs/entity-key.bend as Key
def main_joined(+frame:U32,observed:Array<U32> & String) -> T.Position & String:
  match observed:
    case (values,text):(T.Position{values,frame},"Position{" ++ text ++ ";" ++ U32.show(frame) ++ "}")
def main(owner:T.Position) -> T.Position & String:
  match owner:
    case T.Position{values,frame}:main_joined(frame,Dump.u32_array(values))
def aux_joined(+moving:Bool,observed:Array<U32> & String) -> T.Velocity & String:
  match observed:
    case (values,text):(T.Velocity{values,moving},"Velocity{" ++ text ++ ";" ++ Bool.show(moving) ++ "}")
def aux(owner:T.Velocity) -> T.Velocity & String:
  match owner:
    case T.Velocity{values,moving}:aux_joined(moving,Dump.u32_array(values))
def ledger_joined(+epoch:U32,observed:Array<U32> & String) -> T.MotionLedger & String:
  match observed:
    case (values,text):(T.MotionLedger{values,epoch},"MotionLedger{" ++ text ++ ";" ++ U32.show(epoch) ++ "}")
def ledger(owner:T.MotionLedger) -> T.MotionLedger & String:
  match owner:
    case T.MotionLedger{values,epoch}:ledger_joined(epoch,Dump.u32_array(values))
def flag_copy(+value:T.Selected) -> T.Selected & String:
  match value:
    case T.Selected{+group}:(T.Selected{group},"Selected{" ++ U32.show(group) ++ "}")
def flag(value:T.Selected) -> T.Selected & String:flag_copy(value)
def store_join(left:Col.Column<T.MotionSchema,T.Position> & String,middle:Col.Column<T.MotionSchema,T.Velocity> & String,right:Col.Column<T.MotionSchema,T.Selected> & String) -> F.Store() & String:
  (main,sm)=left
  (aux,sa)=middle
  (flag,sf)=right
  (Product.Owner{main,Product.Owner{aux,flag}},"main={" ++ sm ++ "};aux={" ++ sa ++ "};flag={" ++ sf ++ "}")
def store(owner:F.Store()) -> F.Store() & String:
  match owner:
    case Product.Owner{mc,Product.Owner{ac,fc}}:store_join(Dump.column(~T.MotionSchema,~T.Position,~main,mc),Dump.column(~T.MotionSchema,~T.Velocity,~aux,ac),Dump.column(~T.MotionSchema,~T.Selected,~flag,fc))
def resources_join(unit:Unit,observed:T.MotionLedger & String) -> F.Resources() & String:
  match observed:
    case (value,text):(Product.Owner{value,unit},text ++ ";sibling=Unit")
def resources(owner:F.Resources()) -> F.Resources() & String:
  match owner:
    case Product.Owner{value,unit}:resources_join(unit,ledger(value))
def key(value:Key.Key) -> String:
  match value:
    case Key.EntityKey{index,generation}:U32.show(index) ++ ":" ++ U32.show(generation)
def handle(value:W.Handle<T.MotionSchema>) -> String:
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
def publication(value:E.Publication) -> String:
  match value:
    case E.Ping{code}:"Ping{" ++ U32.show(code) ++ "}"
    case E.Removed{value}:"Removed{" ++ handle(value) ++ "}"
    case E.Despawned{value}:"Despawned{" ++ handle(value) ++ "}"
def event(value:E.event_type()) -> String:
  match value:
    case Notice.Original{value}:"Original{" ++ publication(value) ++ "}"
    case Notice.RelationFailed{value}:"RelationFailed{" ++ failure(~T.MotionSchema,value) ++ "}"
    case Notice.ComponentRemoved{value}:"ComponentRemoved{" ++ key(value) ++ "}"
    case Notice.CleanupPaused{values}:"CleanupPaused{" ++ List.show(&2,G.CleanupFrame<T.MotionSchema>,frame(~T.MotionSchema),values) ++ "}"
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
def reservation(value:W.Reservation<T.MotionSchema>) -> String:
  match value:
    case W.Reserved{id}:"Reserved(" ++ handle(id) ++ ")"
    case W.ReservationRejected{reason}:"ReservationRejected(" ++ error(reason) ++ ")"
def outcome(value:Tx.Outcome<Unit>) -> String:
  match value:
    case Tx.Success{}:"Success"
    case Tx.Failure{_}:"Failure(Unit)"

def access(~V:Data,~show:V -> String,value:Cmp.Access<V>) -> String:
  match value:
    case Cmp.Found{value}:"Found(" ++ show(value) ++ ")"
    case Cmp.ComponentAbsent{}:"ComponentAbsent"
    case Cmp.MissingEntity{}:"MissingEntity"
def row(value:IQ.ProjectedRow<T.MotionSchema,Logical.Value()>) -> String:
  match value:
    case IQ.ProjectedRow{entity,Projection.Product{main,Projection.Product{aux,flag}}}:"handle=" ++ handle(entity) ++ ";main=" ++ access(~T.PositionView,~JSON.render_position,main) ++ ";aux=" ++ access(~T.VelocityView,~JSON.render_velocity,aux) ++ ";flag=" ++ access(~T.Selected,~JSON.render_selected,flag)
def rows_observed(observed:F.World() & Logical.Rows()) -> F.World() & String:
  match observed:
    case (world,rows):(world,List.show(&2,IQ.ProjectedRow<T.MotionSchema,Logical.Value()>,row,rows))
def rows(world:F.World()) -> F.World() & String:rows_observed(Logical.rows(world))
