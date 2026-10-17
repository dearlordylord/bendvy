import Base
import ../../../../src/ecs/deferred-command.bend as Command
import ../../../../src/ecs/system.bend as Sys
import ../../../../src/ecs/transaction.bend as T
import ../../../../src/ecs/machine-handlers.bend as Handlers
import ../../../../src/ecs/ordinary-app-execution.bend as Execution
import ../../../../src/ecs/ordinary-app-relation.bend as AppRelation
import ../../../../src/ecs/relation-query.bend as RQ
import ../../../../src/ecs/inspector-query-projection.bend as Select
import ./fixture.bend as F
import ../../../../src/ecs/execution-trace.bend as Trace
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/owner-product.bend as Product
import ../../../../src/ecs/ordinary-schema.bend as Schema
import ../../../../src/ecs/schema-fragments.bend as Fragment
import ../../../../src/ecs/ordinary-app-schema.bend as App
import ../../../../src/ecs/ordinary-app-composer.bend as Build
import ../../../../src/ecs/ordinary-app-recipe.bend as Tree
import ../../../../src/ecs/ordinary-app-records.bend as Leaf
import ../../../../src/ecs/ordinary-app-registration-fields.bend as Records
import ../../../../src/ecs/ordinary-app-observation-data.bend as DTO
import ../../../../src/ecs/ordinary-query-declaration.bend as Query
import ../../../../src/ecs/ordinary-app-schedule.bend as Single
import ../../../../src/ecs/schedule.bend as Sch
import ../../../../src/ecs/schedule-provision.bend as SP

import ../../../../src/ecs/entity-key.bend as Key
import ../../../../src/ecs/entity-allocator.bend as Alloc
import ../../../../src/ecs/column.bend as Col
import ../../../../src/ecs/lifecycle.bend as L
import ../../../../src/ecs/indexed-lifecycle.bend as M
import ../../../../src/ecs/trace-facts.bend as Facts
import ../../../../src/ecs/component.bend as Cmp
import ../../../../src/ecs/inspector-query.bend as IQ

import ../../../../src/ecs/ordinary-machine-initialization.bend as Init
import ../../../../src/ecs/machine.bend as Machine
import ../../../../src/ecs/owned-event-log.bend as Log
import ../../../../src/ecs/relation-types.bend as Graph
import ../../../../src/ecs/relation-commands.bend as Relations
import ../../../../src/ecs/machine-stream.bend as Stream
import ../../../../src/ecs/machine-stream-queue.bend as MQ
import ../../../../src/ecs/event-runtime.bend as Ev
def leaf(~T:Type,observed:T & String) -> Array<T> & String:
  (value,text)=observed
  (ALeaf{value},"leaf:" ++ text)
def node_join(~T:Type,leftObserved:Array<T> & String,rightObserved:Array<T> & String) -> Array<T> & String:
  (left,text)=leftObserved
  (right,other)=rightObserved
  (ANode{left,right},"node(" ++ text ++ "," ++ other ++ ")")
def array(~T:Type,~project:T -> T & String,value:Array<T>) -> Array<T> & String:
  match value:
    case ALeaf{value}:leaf(~T,project(value))
    case ANode{left,right}:node_join(~T,array(~T,~project,left),array(~T,~project,right))
def u32_data(+value:U32) -> U32 & String:
  (value,U32.show(value))
def u32_value(value:U32) -> U32 & String:
  u32_data(value)
def u32_array(value:Array<U32>) -> Array<U32> & String:
  array(~U32,~u32_value,value)
def bool_data(+value:Bool) -> Bool & String:
  (value,Bool.show(value))
def bool_value(value:Bool) -> Bool & String:
  bool_data(value)
def bool_array(value:Array<Bool>) -> Array<Bool> & String:
  array(~Bool,~bool_value,value)
def optional_done(~Payload:Type,observed:Payload & String) -> Maybe<&1,Payload> & String:
  (owner,text)=observed
  (Some{owner},"some(" ++ text ++ ")")
def optional(~Payload:Type,~project:Payload -> Payload & String,value:Maybe<&1,Payload>) -> Maybe<&1,Payload> & String:
  match value:
    case None{}:(None{},"none")
    case Some{owner}:optional_done(~Payload,project(owner))
def stamp(value:L.Stamp) -> String:
  match value:
    case L.Stamp{added,changed}:U32.show(added) ++ ":" ++ U32.show(changed)
def entry(value:L.Entry) -> String:
  match value:
    case L.Entry{id,value}:U32.show(id) ++ ":" ++ stamp(value)
def metadata_join(+capacity:U32,+depth:Nat,+exceptional:List<&2,L.Entry>,observedAdded:Array<U32> & String,observedChanged:Array<U32> & String) -> M.Metadata & String:
  (added,sa)=observedAdded
  (changed,sc)=observedChanged
  (M.Metadata{added,changed,capacity,depth,exceptional},"added=" ++ sa ++ ";changed=" ++ sc ++ ";capacity=" ++ U32.show(capacity) ++ ";depth=" ++ Nat.show(depth) ++ ";exceptional=" ++ List.show(&2,L.Entry,entry,exceptional))
def metadata(value:M.Metadata) -> M.Metadata & String:
  match value:
    case M.Metadata{added,changed,capacity,depth,exceptional}:metadata_join(capacity,depth,exceptional,u32_array(added),u32_array(changed))
def indexed_join(~S:Data,~P:Type,observedValues:Array<Maybe<&1,P>> & String,observedMeta:M.Metadata & String) -> Col.IndexedOrdinaryCarrier<S,P> & String:
  (values,sv)=observedValues
  (metadata,sm)=observedMeta
  (Col.IndexedOrdinaryOwned{Col.IndexedOrdinaryState{values,metadata}},"owned(values=" ++ sv ++ ";metadata={" ++ sm ++ "})")
def indexed_wrap(~S:Data,~P:Type,observed:Col.IndexedOrdinaryCarrier<S,P> & String) -> Col.IndexedOrdinaryCarrier<S,P> & String:
  (inner,text)=observed
  (Col.IndexedOrdinaryWrapped{inner},"wrapped(" ++ text ++ ")")
def indexed_state(~S:Data,~P:Type,~project:P -> P & String,value:Col.IndexedOrdinaryState<S,P>) -> Col.IndexedOrdinaryCarrier<S,P> & String:
  match value:
    case Col.IndexedOrdinaryState{values,meta}:indexed_join(~S,~P,array(~Maybe<&1,P>,~optional(~P,~project),values),metadata(meta))
def indexed(~S:Data,~P:Type,~project:P -> P & String,value:Col.IndexedOrdinaryCarrier<S,P>) -> Col.IndexedOrdinaryCarrier<S,P> & String:
  match value:
    case Col.IndexedOrdinaryOwned{state}:indexed_state(~S,~P,~project,state)
    case Col.IndexedOrdinaryWrapped{inner}:indexed_wrap(~S,~P,indexed(~S,~P,~project,inner))
def indexed_column(~S:Data,~P:Type,observed:Col.IndexedOrdinaryCarrier<S,P> & String) -> Col.Column<S,P> & String:
  (state,text)=observed
  (Col.Indexed{state},"Indexed{" ++ text ++ "}")
def plain_column(~S:Data,~P:Type,+stamps:List<&2,L.Entry>,observed:Array<Maybe<&1,P>> & String) -> Col.Column<S,P> & String:
  (values,text)=observed
  (Col.Column{values,stamps},"Column{values=" ++ text ++ ";stamps=" ++ List.show(&2,L.Entry,entry,stamps) ++ "}")
def column(~S:Data,~P:Type,~project:P -> P & String,value:Col.Column<S,P>) -> Col.Column<S,P> & String:
  match value:
    case Col.Column{values,stamps}:plain_column(~S,~P,stamps,array(~Maybe<&1,P>,~optional(~P,~project),values))
    case Col.Indexed{state}:indexed_column(~S,~P,indexed(~S,~P,~project,state))
    case value:(value,"UNSUPPORTED_PREPARED_COLUMN")
# Opaque callbacks are returned unchanged; this observer never executes them.
def callbacks_join(~A:Type,~B:Type,head:A -> B,observed:List<(A -> B)> & Nat) -> List<(A -> B)> & Nat:
  (rest,count)=observed
  (head <> rest,1n+count)
def callbacks(~A:Type,~B:Type,values:List<(A -> B)>) -> List<(A -> B)> & Nat:
  match values:
    case []:([],0n)
    case head <> rest:callbacks_join(~A,~B,head,callbacks(~A,~B,rest))
def registration(value:W.RegistrationMeta) -> String:
  match value:
    case W.RegistrationMeta{id,name,access}:U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,x => x,access)

def strings(value:List<&2,String>) -> String:List.show(&2,String,x=>x,value)
def unit(_:Unit) -> String:"Unit"
def optional_name(value:Maybe<&2,String>) -> String:
  match value:
    case None{}:"None"
    case Some{name}:"Some{" ++ name ++ "}"
def identity(value:Trace.Identity) -> String:
  match value:
    case Trace.Identity{ns,id,name}:"identity{namespace=" ++ U32.show(ns) ++ ";id=" ++ U32.show(id) ++ ";name=" ++ optional_name(name) ++ "}"
def status(value:Trace.Status<String>) -> String:
  match value:
    case Trace.SystemOk{}:"SystemOk"
    case Trace.SystemError{error}:"SystemError{error=" ++ error ++ "}"
def completion(value:Trace.Completion<String>) -> String:
  match value:
    case Trace.EndOk{}:"EndOk"
    case Trace.EndFailed{error}:"EndFailed{error=" ++ error ++ "}"
    case Trace.EndRejected{}:"EndRejected"
    case Trace.EndMissing{}:"EndMissing"
def fact_category(value:Facts.Category) -> String:
  match value:
    case Facts.ComponentValue{}:"ComponentValue"
    case Facts.ResourceValue{}:"ResourceValue"
    case Facts.EventValue{}:"EventValue"
    case Facts.NextStateValue{}:"NextStateValue"
    case Facts.DeferredCommand{}:"DeferredCommand"
    case Facts.RelationOperation{}:"RelationOperation"
    case Facts.TransitionHandler{}:"TransitionHandler"
    case Facts.MissedValue{}:"MissedValue"
def fact_operation(value:Facts.Operation) -> String:
  match value:
    case Facts.ReadOperation{}:"ReadOperation"
    case Facts.WriteOperation{}:"WriteOperation"
    case Facts.RemoveOperation{}:"RemoveOperation"
    case Facts.SendOperation{}:"SendOperation"
    case Facts.StageOperation{}:"StageOperation"
    case Facts.ApplyOperation{}:"ApplyOperation"
    case Facts.HandlerOperation{}:"HandlerOperation"
def fact_result(value:Facts.FactResult) -> String:
  match value:
    case Facts.Attempted{}:"Attempted"
    case Facts.Applied{}:"Applied"
    case Facts.Refused{reason}:"Refused{" ++ reason ++ "}"
    case Facts.RolledBack{}:"RolledBack"
def fact_value(value:Facts.Value) -> String:
  match value:
    case Facts.OpaqueValue{}:"OpaqueValue"
    case Facts.UnavailableValue{}:"UnavailableValue"
    case Facts.DisplayedValue{text}:"DisplayedValue{" ++ text ++ "}"
def fact_handle(value:Facts.HandleValue) -> String:
  match value:
    case Facts.HandleValue{ns,index,generation}:"handle{" ++ U32.show(ns) ++ ":" ++ U32.show(index) ++ ":" ++ U32.show(generation) ++ "}"
def fact_relation_kind(value:Facts.RelationKind) -> String:
  match value:
    case Facts.OrdinaryRelation{}:"OrdinaryRelation"
    case Facts.HierarchyRelation{}:"HierarchyRelation"
def fact_relation(value:Facts.RelationIdentity) -> String:
  match value:
    case Facts.RelationIdentity{id,name,inverse,kind}:"relation{id=" ++ U32.show(id) ++ ";name=" ++ name ++ ";inverse=" ++ inverse ++ ";kind=" ++ fact_relation_kind(kind) ++ "}"
def fact_action(value:Facts.RelationAction) -> String:
  match value:
    case Facts.RelateAction{target}:"RelateAction{" ++ fact_handle(target) ++ "}"
    case Facts.UnrelateAction{}:"UnrelateAction"
    case Facts.ReorderAction{children}:"ReorderAction{" ++ List.show(&2,Facts.HandleValue,fact_handle,children) ++ "}"
def fact_phase(value:Facts.HandlerPhase) -> String:
  match value:
    case Facts.ExitPhase{}:"ExitPhase"
    case Facts.TransitionPhase{}:"TransitionPhase"
    case Facts.EnterPhase{}:"EnterPhase"
    case Facts.InitialEnterPhase{}:"InitialEnterPhase"
def boundary(value:Facts.Boundary) -> String:
  match value:
    case Facts.PhaseBoundary{name}:"PhaseBoundary{" ++ name ++ "}"
    case Facts.BarrierEntered{}:"BarrierEntered"
    case Facts.BarrierFinished{}:"BarrierFinished"
def fact(value:Facts.Fact) -> String:
  match value:
    case Facts.ReaderFact{ns,id,name,reader,domain,lagged}:"ReaderFact{namespace=" ++ U32.show(ns) ++ ";id=" ++ U32.show(id) ++ ";name=" ++ name ++ ";readerId=" ++ U32.show(reader) ++ ";domain=" ++ domain ++ ";lagged=" ++ Bool.show(lagged) ++ "}"
    case Facts.BoundaryFact{value}:"BoundaryFact{" ++ boundary(value) ++ "}"
    case Facts.Fact{category,key,operation,subject,before,after,result}:"Fact{category=" ++ fact_category(category) ++ ";key=" ++ key ++ ";operation=" ++ fact_operation(operation) ++ ";subject=" ++ optional_name(subject) ++ ";before=" ++ fact_value(before) ++ ";after=" ++ fact_value(after) ++ ";result=" ++ fact_result(result) ++ "}"
    case Facts.RelationFact{identity,operation,source,action,result}:"RelationFact{" ++ fact_relation(identity) ++ ";operation=" ++ fact_operation(operation) ++ ";source=" ++ fact_handle(source) ++ ";action=" ++ fact_action(action) ++ ";result=" ++ fact_result(result) ++ "}"
    case Facts.HandlerFact{ns,id,name,ordinal,phase,from,to,result}:"HandlerFact{namespace=" ++ U32.show(ns) ++ ";id=" ++ U32.show(id) ++ ";name=" ++ name ++ ";ordinal=" ++ U32.show(ordinal) ++ ";phase=" ++ fact_phase(phase) ++ ";from=" ++ fact_value(from) ++ ";to=" ++ fact_value(to) ++ ";result=" ++ fact_result(result) ++ "}"
    case Facts.TransitionFact{key,from,to,result}:"TransitionFact{key=" ++ key ++ ";from=" ++ fact_value(from) ++ ";to=" ++ fact_value(to) ++ ";result=" ++ fact_result(result) ++ "}"
def fact_state(value:Facts.State) -> String:
  match value:
    case Facts.Off{}:"Off"
    case Facts.On{reverseFacts}:"On{reverseFacts=" ++ List.show(&2,Facts.Fact,fact,reverseFacts) ++ "}"
def event(value:Trace.TraceEvent<String>) -> String:
  match value:
    case Trace.ScheduleStarted{ns,name}:"ScheduleStarted{namespace=" ++ U32.show(ns) ++ ";name=" ++ name ++ "}"
    case Trace.PhaseEntered{name}:"PhaseEntered{name=" ++ name ++ "}"
    case Trace.SystemCompleted{who,before,after,result}:"SystemCompleted{" ++ identity(who) ++ ";before=" ++ U32.show(before) ++ ";after=" ++ U32.show(after) ++ ";status=" ++ status(result) ++ "}"
    case Trace.OperationObserved{who,value}:"OperationObserved{" ++ identity(who) ++ ";fact=" ++ fact(value) ++ "}"
    case Trace.BarrierOperationObserved{value}:"BarrierOperationObserved{fact=" ++ fact(value) ++ "}"
    case Trace.ExecutionOperationObserved{value}:"ExecutionOperationObserved{fact=" ++ fact(value) ++ "}"
    case Trace.SystemSkipped{id}:"SystemSkipped{id=" ++ U32.show(id) ++ "}"
    case Trace.DeferredApplied{}:"DeferredApplied"
    case Trace.ScheduleEnded{result}:"ScheduleEnded{outcome=" ++ completion(result) ++ "}"
    case Trace.ScheduleAdmissionRefused{ns,name,result}:"ScheduleAdmissionRefused{namespace=" ++ U32.show(ns) ++ ";name=" ++ name ++ ";outcome=" ++ completion(result) ++ "}"
def batch(value:Trace.Batch<String>) -> String:
  match value:
    case Trace.Disabled{}:"Disabled"
    case Trace.Ready{events}:"Ready{events=" ++ List.show(&2,Trace.TraceEvent<String>,event,events) ++ "}"
def collector_join(+calls:U32,+events:List<&2,Trace.TraceEvent<String>>,value:Array<U32> & String) -> F.Collector & String:
  (owned,text)=value
  (F.Collector{calls,events,owned},"collector{calls=" ++ U32.show(calls) ++ ";events=" ++ List.show(&2,Trace.TraceEvent<String>,event,events) ++ ";owned=" ++ text ++ "}")
def collector(value:F.Collector) -> F.Collector & String:
  match value:
    case F.Collector{calls,events,owned}:collector_join(calls,events,u32_array(owned))
def subscriber_join(value:F.Collector & String) -> F.Subscriber() & String:
  (state,text)=value
  (Trace.Subscriber{state},"subscriber{" ++ text ++ "}")
def subscriber(value:F.Subscriber()) -> F.Subscriber() & String:
  match value:
    case Trace.Subscriber{state}:subscriber_join(collector(state))
def allocator_phase(value:Alloc.Phase) -> String:
  match value:
    case Alloc.Consumed{}:"Consumed"
    case Alloc.Pending{}:"Pending"
    case Alloc.Live{}:"Live"
    case Alloc.DeadRetained{}:"DeadRetained"
    case Alloc.Free{}:"Free"
def allocator_slot(value:Alloc.Slot) -> Alloc.Slot & String:
  match value:
    case Alloc.Slot{+generation,+state}:(Alloc.Slot{generation,state},U32.show(generation) ++ ":" ++ allocator_phase(state))
def key_text(value:Key.Key) -> String:
  match value:
    case Key.EntityKey{index,generation}:U32.show(index) ++ ":" ++ U32.show(generation)
def handle_text(~S:Data,value:W.Handle<S>) -> String:
  match value:
    case W.Handle{ns,key}:U32.show(ns) ++ "/" ++ key_text(key)
def allocator_join(+next:U32,+high:U32,+capacity:U32,+depth:Nat,+free:List<&2,U32>,+order:List<&2,Key.Key>,value:Array<Alloc.Slot> & String) -> Alloc.Allocator & String:
  match value:
    case (slots,text):(Alloc.Allocator{next,high,slots,capacity,depth,free,order},"allocator{next=" ++ U32.show(next) ++ ";high=" ++ U32.show(high) ++ ";capacity=" ++ U32.show(capacity) ++ ";depth=" ++ Nat.show(depth) ++ ";slots=" ++ text ++ ";free=" ++ List.show(&2,U32,U32.show,free) ++ ";order=" ++ List.show(&2,Key.Key,key_text,order) ++ "}")
def allocator(value:Alloc.Allocator) -> Alloc.Allocator & String:
  match value:
    case Alloc.Allocator{next,high,slots,capacity,depth,free,order}:allocator_join(next,high,capacity,depth,free,order,array(~Alloc.Slot,~allocator_slot,slots))
def mode(value:Query.Mode) -> String:
  match value:
    case Query.Read{}:"Read"
    case Query.Write{}:"Write"
    case Query.Optional{}:"Optional"
    case Query.With{}:"With"
    case Query.Without{}:"Without"
    case Query.Added{}:"Added"
    case Query.Changed{}:"Changed"
def clause(~S:Data,value:Query.Clause<S>) -> String:
  match value:
    case Query.Clause{name,access}:"Clause{" ++ name ++ ";mode=" ++ mode(access) ++ "}"
def use_category(value:Records.UseCategory) -> String:
  match value:
    case Records.ComponentUse{}:"Component"
    case Records.ResourceUse{}:"Resource"
    case Records.EventUse{}:"Event"
def source(value:Records.ReaderSource) -> String:
  match value:
    case Records.QuerySource{}:"Query"
    case Records.MessageSource{}:"Message"
    case Records.RemovalSource{}:"Removal"
    case Records.RelationFailureSource{}:"RelationFailure"
def declared_use(value:Records.DeclaredUse) -> String:
  match value:
    case Records.DeclaredUse{category,reader,key,access}:"Use{" ++ use_category(category) ++ ";source=" ++ source(reader) ++ ";key=" ++ key ++ ";mode=" ++ mode(access) ++ "}"
def registration_kind(value:Records.RegistrationKind) -> String:
  match value:
    case Records.ComponentKind{}:"Component"
    case Records.ResourceKind{access}:"Resource{" ++ mode(access) ++ "}"
    case Records.FieldKind{}:"Field"
    case Records.ServiceKind{}:"Service"
    case Records.EventKind{}:"Event"
    case Records.MixedKind{uses}:"Mixed{" ++ List.show(&2,Records.DeclaredUse,declared_use,uses) ++ "}"
def fields(~S:Data,value:Records.Fields<S>) -> String:
  match value:
    case Records.Fields{ns,id,name,access,cursor,slot,clauses,kind}:"fields{namespace=" ++ U32.show(ns) ++ ";id=" ++ U32.show(id) ++ ";name=" ++ name ++ ";access=" ++ strings(access) ++ ";cursor=" ++ U32.show(cursor) ++ ";slot=" ++ slot ++ ";clauses=" ++ List.show(&2,Query.Clause<S>,clause(~S),clauses) ++ ";kind=" ++ registration_kind(kind) ++ "}"
def record(~S:Data,~Registry:Type,value:Leaf.Record<S,Records.Token<Registry>>) -> Leaf.Record<S,Records.Token<Registry>> & String:
  match value:
    case Leaf.Record{Records.Token{},+metadata}:(Leaf.Record{Records.Token{},metadata},"owner{token=Token;" ++ fields(~S,metadata) ++ "}")
def schema_kind(value:Fragment.RegistryKind) -> String:
  match value:
    case Fragment.Component{}:"Component"
    case Fragment.Resource{}:"Resource"
    case Fragment.Event{}:"Event"
    case Fragment.Relation{}:"Relation"
    case Fragment.Service{}:"Service"
def persistence(value:Fragment.PersistenceKind) -> String:
  match value:
    case Fragment.Plain{}:"Plain"
    case Fragment.Transient{}:"Transient"
    case Fragment.Constructed{}:"Constructed"
def schema_entry(~S:Data,value:Fragment.Entry<S>) -> String:
  match value:
    case Fragment.Entry{kind,key,name}:"Entry{" ++ schema_kind(kind) ++ ";key=" ++ key ++ ";name=" ++ name ++ "}"
    case Fragment.Classified{kind,key,name,stored}:"Classified{" ++ schema_kind(kind) ++ ";key=" ++ key ++ ";name=" ++ name ++ ";persistence=" ++ persistence(stored) ++ "}"
def requirement(~S:Data,value:SP.Requirement<S>) -> String:
  match value:
    case SP.Component{id}:"Component{" ++ U32.show(id) ++ "}"
    case SP.Resource{id}:"Resource{" ++ U32.show(id) ++ "}"
    case SP.Service{id}:"Service{" ++ U32.show(id) ++ "}"
def step(value:Sch.Step) -> String:
  match value:
    case Sch.Phase{name}:"Phase{" ++ name ++ "}"
    case Sch.System{id,condition}:"System{" ++ U32.show(id) ++ ";condition=" ++ U32.show(condition) ++ "}"
    case Sch.Barrier{}:"Barrier"
def plan(~S:Data,value:SP.Plan<S>) -> String:
  match value:
    case SP.Empty{}:"Empty"
    case SP.Entry{action,needs}:"Entry{" ++ step(action) ++ ";requirements=" ++ List.show(&2,SP.Requirement<S>,requirement(~S),needs) ++ "}"
    case SP.Sequence{left,right}:"Sequence{" ++ plan(~S,left) ++ ";" ++ plan(~S,right) ++ "}"
def binding(~S:Data,value:DTO.Binding<S>) -> String:
  match value:
    case DTO.Binding{ns,id,name,access,cursor,slot,clauses}:"binding{namespace=" ++ U32.show(ns) ++ ";id=" ++ U32.show(id) ++ ";name=" ++ name ++ ";access=" ++ strings(access) ++ ";cursor=" ++ U32.show(cursor) ++ ";slot=" ++ slot ++ ";clauses=" ++ List.show(&2,Query.Clause<S>,clause(~S),clauses) ++ "}"
def access(value:Cmp.Access<U32>) -> String:
  match value:
    case Cmp.Found{value}:"Found{" ++ U32.show(value) ++ "}"
    case Cmp.ComponentAbsent{}:"ComponentAbsent"
    case Cmp.MissingEntity{}:"MissingEntity"
def projected_row(~S:Data,value:IQ.ProjectedRow<S,Cmp.Access<U32>>) -> String:
  match value:
    case IQ.ProjectedRow{handle,value}:"ProjectedRow{entity=" ++ handle_text(~S,handle) ++ ";data=" ++ access(value) ++ "}"
def planned(~S:Data,value:Single.PlannedStep<S>) -> String:
  match value:
    case Single.PlannedStep{action,needs}:"PlannedStep{" ++ step(action) ++ ";requirements=" ++ List.show(&2,SP.Requirement<S>,requirement(~S),needs) ++ "}"
def observation(value:Sch.Observation) -> String:
  match value:
    case Sch.Entered{name}:"Entered{" ++ name ++ "}"
    case Sch.Ran{id}:"Ran{" ++ U32.show(id) ++ "}"
    case Sch.Skipped{id}:"Skipped{" ++ U32.show(id) ++ "}"
    case Sch.Applied{}:"Applied"
def observations(value:List<&2,Sch.Observation>) -> String:List.show(&2,Sch.Observation,observation,value)
def world_error(value:W.WorldError) -> String:
  match value:
    case W.MissingEntity{}:"MissingEntity"
    case W.CapacityExceeded{}:"CapacityExceeded"
    case W.NamespaceExhausted{}:"NamespaceExhausted"
    case W.SystemIdExhausted{}:"SystemIdExhausted"
def world_status(value:W.Status) -> String:
  match value:
    case W.Accepted{}:"Accepted"
    case W.Rejected{error}:"Rejected{" ++ world_error(error) ++ "}"
def reservation(~S:Data,value:W.Reservation<S>) -> String:
  match value:
    case W.Reserved{handle}:"Reserved{" ++ handle_text(~S,handle) ++ "}"
    case W.ReservationRejected{error}:"ReservationRejected{" ++ world_error(error) ++ "}"
def seed_join(~S:Data,+reserved:W.Reservation<S>,+activation:W.Status,+write:W.Status,observed:Maybe<&1,Array<U32>> & String) -> F.SeedEvidence<S> & String:
  match observed:
    case (returned,text):(F.SeedEvidence{reserved,activation,write,returned},"seed{reservation=" ++ reservation(~S,reserved) ++ ";activation=" ++ world_status(activation) ++ ";write=" ++ world_status(write) ++ ";recovered=" ++ text ++ "}")
def seed(~S:Data,value:F.SeedEvidence<S>) -> F.SeedEvidence<S> & String:
  match value:
    case F.SeedEvidence{reserved,activation,write,recovered}:seed_join(~S,reserved,activation,write,optional(~Array<U32>,~u32_array,recovered))
def maybe_u32(value:Maybe<&2,U32>) -> String:
  match value:
    case None{}:"None"
    case Some{value}:"Some{" ++ U32.show(value) ++ "}"
def machine_pending(value:Machine.Pending<U32>) -> String:
  match value:
    case Machine.NoPending{}:"NoPending"
    case Machine.Queued{value,skip}:"Queued{value=" ++ U32.show(value) ++ ";skipSame=" ++ Bool.show(skip) ++ "}"
def machine_slot(~S:Data,value:Machine.Slot<S,F.Mode,U32>) -> String:
  match value:
    case Machine.Missing{}:"Missing"
    case Machine.Present{current,pending,previous,changed}:"Present{current=" ++ U32.show(current) ++ ";pending=" ++ machine_pending(pending) ++ ";previous=" ++ maybe_u32(previous) ++ ";changed=" ++ Bool.show(changed) ++ "}"
def transition(value:Machine.Transition<U32>) -> String:
  match value:
    case Machine.Initial{to}:"Initial{" ++ U32.show(to) ++ "}"
    case Machine.Transition{from,to}:"Transition{from=" ++ U32.show(from) ++ ";to=" ++ U32.show(to) ++ "}"
def machine_batch(value:MQ.Batch<Machine.Transition<U32>>) -> String:
  match value:
    case MQ.Batch{tick,count,values}:"Batch{tick=" ++ Nat.show(tick) ++ ";count=" ++ Nat.show(count) ++ ";values=" ++ List.show(&2,Machine.Transition<U32>,transition,values) ++ "}"
def position(value:Ev.Position) -> String:
  match value:
    case Ev.Position{id,cursor,registered}:"Position{id=" ++ U32.show(id) ++ ";cursor=" ++ Nat.show(cursor) ++ ";registered=" ++ Nat.show(registered) ++ "}"
def machine_queue(value:MQ.Queue<Machine.Transition<U32>>) -> String:
  match value:
    case MQ.Queue{front,back,size,dropped,count}:"Queue{front=" ++ List.show(&2,MQ.Batch<Machine.Transition<U32>>,machine_batch,front) ++ ";back=" ++ List.show(&2,MQ.Batch<Machine.Transition<U32>>,machine_batch,back) ++ ";size=" ++ Nat.show(size) ++ ";dropped=" ++ Nat.show(dropped) ++ ";batchCount=" ++ Nat.show(count) ++ "}"
def machine_stream(value:Stream.Stream<U32>) -> String:
  match value:
    case Stream.Stream{queue,positions,start}:"Stream{" ++ machine_queue(queue) ++ ";positions=" ++ List.show(&2,Ev.Position,position,positions) ++ ";frameStart=" ++ Nat.show(start) ++ "}"
def machine_state_text(~S:Data,value:F.MachineState(~S)) -> String:
  match value:
    case Init.State{slot,stream,revision}:"State{slot=" ++ machine_slot(~S,slot) ++ ";stream=" ++ machine_stream(stream) ++ ";revision=" ++ Nat.show(revision) ++ "}"
def log_row_join(+id:Nat,value:Array<U32> & String) -> Log.Row<Array<U32>> & String:
  match value:
    case (payload,text):(Log.Row{id,payload},"row{id=" ++ Nat.show(id) ++ ";payload=" ++ text ++ "}")
def log_row(value:Log.Row<Array<U32>>) -> Log.Row<Array<U32>> & String:
  match value:
    case Log.Row{id,payload}:log_row_join(id,u32_array(payload))
def log_rows_join(head:Log.Row<Array<U32>> & String,tail:List<Log.Row<Array<U32>>> & String) -> List<Log.Row<Array<U32>>> & String:
  (head,ht)=head
  (tail,tt)=tail
  (head <> tail,ht ++ ";" ++ tt)
def log_rows(value:List<Log.Row<Array<U32>>>) -> List<Log.Row<Array<U32>>> & String:
  match value:
    case []:([],"[]")
    case head <> tail:log_rows_join(log_row(head),log_rows(tail))
def log_join(+next:Nat,value:List<Log.Row<Array<U32>>> & String) -> Log.Log<Array<U32>> & String:
  match value:
    case (rows,text):(Log.Log{next,rows},"Log{next=" ++ Nat.show(next) ++ ";rows=" ++ text ++ "}")
def log(value:Log.Log<Array<U32>>) -> Log.Log<Array<U32>> & String:
  match value:
    case Log.Log{next,rows}:log_join(next,log_rows(rows))
def resources_join(~S:Data,+state:F.MachineState(~S),left:Array<U32> & String,right:Array<U32> & String,events:Log.Log<Array<U32>> & String) -> F.Resources(~S) & String:
  (left,lt)=left
  (right,rt)=right
  (events,et)=events
  (Product.Owner{Product.Owner{Product.Owner{left,right},state},events},"Counter=" ++ lt ++ ";Sibling=" ++ rt ++ ";Mode=" ++ machine_state_text(~S,state) ++ ";Cargo=" ++ et)
def resources(~S:Data,value:F.Resources(~S)) -> F.Resources(~S) & String:
  match value:
    case Product.Owner{Product.Owner{Product.Owner{left,right},state},events}:resources_join(~S,state,u32_array(left),u32_array(right),log(events))
def graph_kind(value:Graph.RelationKind) -> String:
  match value:
    case Graph.Ordinary{}:"Ordinary"
    case Graph.Hierarchy{}:"Hierarchy"
def descriptor(~S:Data,value:Graph.Descriptor<S>) -> String:
  match value:
    case Graph.Descriptor{key,name,inverse,kind}:"Descriptor{key=" ++ U32.show(key) ++ ";name=" ++ name ++ ";inverse=" ++ inverse ++ ";kind=" ++ graph_kind(kind) ++ "}"
def edge(~S:Data,value:Graph.Edge<S>) -> String:
  match value:
    case Graph.Edge{relation,source,target}:"Edge{" ++ descriptor(~S,relation) ++ ";source=" ++ key_text(source) ++ ";target=" ++ key_text(target) ++ "}"
def inverse(~S:Data,value:Graph.Inverse<S>) -> String:
  match value:
    case Graph.Inverse{relation,target,sources}:"Inverse{" ++ descriptor(~S,relation) ++ ";target=" ++ key_text(target) ++ ";sources=" ++ List.show(&2,Key.Key,key_text,sources) ++ "}"
def graph_text(~S:Data,value:Graph.Graph<S>) -> String:
  match value:
    case Graph.Graph{edges,inverses}:"Graph{edges=" ++ List.show(&2,Graph.Edge<S>,edge(~S),edges) ++ ";inverses=" ++ List.show(&2,Graph.Inverse<S>,inverse(~S),inverses) ++ "}"
def cleanup_frame(~S:Data,value:Graph.CleanupFrame<S>) -> String:
  match value:
    case Graph.CleanupEnter{id}:"Enter{" ++ key_text(id) ++ "}"
    case Graph.CleanupFinish{id}:"Finish{" ++ key_text(id) ++ "}"
    case Graph.CleanupDescriptors{id,remaining}:"Descriptors{" ++ key_text(id) ++ ";remaining=" ++ List.show(&2,Graph.Descriptor<S>,descriptor(~S),remaining) ++ "}"
    case Graph.CleanupChildren{id,relation,remaining,children}:"Children{" ++ key_text(id) ++ ";" ++ descriptor(~S,relation) ++ ";remaining=" ++ List.show(&2,Graph.Descriptor<S>,descriptor(~S),remaining) ++ ";children=" ++ List.show(&2,Key.Key,key_text,children) ++ "}"
def relation_error(value:Graph.Error) -> String:
  match value:
    case Graph.MissingEntity{source}:"MissingEntity{" ++ key_text(source) ++ "}"
    case Graph.MissingTargetEntity{source,target,name}:"MissingTargetEntity{" ++ key_text(source) ++ ";" ++ key_text(target) ++ ";" ++ name ++ "}"
    case Graph.SelfRelationNotAllowed{source,name}:"SelfRelationNotAllowed{" ++ key_text(source) ++ ";" ++ name ++ "}"
    case Graph.HierarchyCycle{source,target,name}:"HierarchyCycle{" ++ key_text(source) ++ ";" ++ key_text(target) ++ ";" ++ name ++ "}"
    case Graph.MissingChildEntity{source,child,name}:"MissingChildEntity{" ++ key_text(source) ++ ";" ++ key_text(child) ++ ";" ++ name ++ "}"
    case Graph.DuplicateChild{source,child,name}:"DuplicateChild{" ++ key_text(source) ++ ";" ++ key_text(child) ++ ";" ++ name ++ "}"
    case Graph.ChildNotRelatedToParent{source,child,name}:"ChildNotRelatedToParent{" ++ key_text(source) ++ ";" ++ key_text(child) ++ ";" ++ name ++ "}"
    case Graph.ChildSetMismatch{source,name}:"ChildSetMismatch{" ++ key_text(source) ++ ";" ++ name ++ "}"
def relation_operation(value:Graph.Operation) -> String:
  match value:
    case Graph.Relate{}:"Relate"
    case Graph.ReorderChildren{}:"ReorderChildren"
def relation_failure(~S:Data,value:Graph.Failure<S>) -> String:
  match value:
    case Graph.Failure{relation,operation,source,target,error}:"Failure{" ++ descriptor(~S,relation) ++ ";operation=" ++ relation_operation(operation) ++ ";source=" ++ key_text(source) ++ ";target=" ++ key_text(target) ++ ";error=" ++ relation_error(error) ++ "}"
def notice(~S:Data,value:F.Notice(~S)) -> String:
  match value:
    case Relations.Original{value}:"Original{" ++ Nat.show(value) ++ "}"
    case Relations.ComponentRemoved{id}:"ComponentRemoved{" ++ key_text(id) ++ "}"
    case Relations.RelationFailed{failure}:"RelationFailed{" ++ relation_failure(~S,failure) ++ "}"
    case Relations.CleanupPaused{frames}:"CleanupPaused{" ++ List.show(&2,Graph.CleanupFrame<S>,cleanup_frame(~S),frames) ++ "}"
def store_join(~S:Data,+graph:Graph.Graph<S>,value:Col.Column<S,Array<U32>> & String) -> F.Store(~S) & String:
  match value:
    case (column,text):(Relations.Store{column,graph},"store{column=" ++ text ++ ";" ++ graph_text(~S,graph) ++ "}")
def store(~S:Data,value:F.Store(~S)) -> F.Store(~S) & String:
  match value:
    case Relations.Store{cells,graph}:store_join(~S,graph,column(~S,~Array<U32>,~u32_array,cells))
def commands_join(~S:Data,head:Command.Command<F.World(~S)>,label:String,rest:List<Command.Command<F.World(~S)>> & String) -> List<Command.Command<F.World(~S)>> & String:
  (tail,text)=rest
  (head <> tail,label ++ "," ++ text)
def commands(~S:Data,values:List<Command.Command<F.World(~S)>>) -> List<Command.Command<F.World(~S)>> & String:
  match values:
    case []:([],"end")
    case head <> tail:
      match head:
        case Command.Raw{apply}:commands_join(~S,Command.Raw{apply},"Raw(opaque)",commands(~S,tail))
        case Command.Observed{apply}:commands_join(~S,Command.Observed{apply},"Observed(opaque)",commands(~S,tail))
def world_join(~S:Data,+ns:U32,+events:List<&2,F.Notice(~S)>,+registrations:List<&2,W.RegistrationMeta>,+sid:U32,+clock:U32,a:Alloc.Allocator & String,b:F.Store(~S) & String,c:F.Resources(~S) & String,d:List<Command.Command<F.World(~S)>> & String) -> F.World(~S) & String:
  (allocator,at)=a
  (store,st)=b
  (resources,rt)=c
  (pending,count)=d
  (W.World{ns,allocator,store,resources,events,pending,registrations,sid,clock},"world{namespace=" ++ U32.show(ns) ++ ";" ++ at ++ ";store=" ++ st ++ ";resources={" ++ rt ++ "};events=" ++ List.show(&2,F.Notice(~S),notice(~S),events) ++ ";pending=" ++ count ++ ";registrations=" ++ List.show(&2,W.RegistrationMeta,registration,registrations) ++ ";nextSystemId=" ++ U32.show(sid) ++ ";clock=" ++ U32.show(clock) ++ "}")
def world(~S:Data,value:F.World(~S)) -> F.World(~S) & String:
  match value:
    case W.World{ns,slots,cells,owned,events,pending,regs,sid,clock}:world_join(~S,ns,events,regs,sid,clock,allocator(slots),store(~S,cells),resources(~S,owned),commands(~S,pending))
def arrays_join(head:Array<U32> & String,tail:List<Array<U32>> & String) -> List<Array<U32>> & String:
  (head,ht)=head
  (tail,tt)=tail
  (head <> tail,ht ++ ";" ++ tt)
def arrays(value:List<Array<U32>>) -> List<Array<U32>> & String:
  match value:
    case []:([],"[]")
    case head <> tail:arrays_join(u32_array(head),arrays(tail))
def outcome(value:T.Outcome<String>) -> String:
  match value:
    case T.Success{}:"Success"
    case T.Failure{error}:"Failure{" ++ error ++ "}"
def held_join(~S:Data,+source:W.Handle<S>,+target:W.Handle<S>,+publicationCalls:U32,+relationCalls:U32,+outcomes:List<&2,T.Outcome<String>>,incoming:List<Array<U32>> & String,retry:List<Array<U32>> & String) -> F.Held<S> & String:
  (incoming,it)=incoming
  (retry,rt)=retry
  (F.Held{source,target,incoming,retry,publicationCalls,relationCalls,outcomes},"held{source=" ++ handle_text(~S,source) ++ ";target=" ++ handle_text(~S,target) ++ ";incoming=" ++ it ++ ";retry=" ++ rt ++ ";publicationCalls=" ++ U32.show(publicationCalls) ++ ";relationCalls=" ++ U32.show(relationCalls) ++ ";outcomes=" ++ List.show(&2,T.Outcome<String>,outcome,outcomes) ++ "}")
def held(~S:Data,value:F.Held<S>) -> F.Held<S> & String:
  match value:
    case F.Held{source,target,incoming,retry,publicationCalls,relationCalls,outcomes}:held_join(~S,source,target,publicationCalls,relationCalls,outcomes,arrays(incoming),arrays(retry))
def owners3_join(~S:Data,a:F.Owner(~S) & String,b:F.Owner(~S) & String,c:F.Owner(~S) & String) -> F.Owners3(~S) & String:
  (first,ft)=a
  (second,st)=b
  (third,tt)=c
  ((((Unit{},first),second),third),"owners{previous=Unit;first=" ++ ft ++ ";second=" ++ st ++ ";third=" ++ tt ++ "}")
def owners3(~S:Data,value:F.Owners3(~S)) -> F.Owners3(~S) & String:
  match value:
    case (((Unit{},first),second),third):owners3_join(~S,record(~S,~F.Registry(~S),first),record(~S,~F.Registry(~S),second),record(~S,~F.Registry(~S),third))
def owners4_join(~S:Data,left:F.Owners3(~S) & String,right:F.ComponentOwner(~S) & String) -> F.Owners4(~S) & String:
  (left,lt)=left
  (right,rt)=right
  ((left,right),"owners4{resources=" ++ lt ++ ";component=" ++ rt ++ "}")
def owners4(~S:Data,value:F.Owners4(~S)) -> F.Owners4(~S) & String:
  match value:
    case (left,right):owners4_join(~S,owners3(~S,left),record(~S,~F.ComponentRegistry(~S),right))
def owners5_join(~S:Data,left:F.Owners4(~S) & String,right:F.MachineOwner(~S) & String) -> F.Owners5(~S) & String:
  (left,lt)=left
  (right,rt)=right
  ((left,right),"owners5{previous=" ++ lt ++ ";machine=" ++ rt ++ "}")
def owners5(~S:Data,value:F.Owners5(~S)) -> F.Owners5(~S) & String:
  match value:
    case (left,right):owners5_join(~S,owners4(~S,left),record(~S,~F.MachineRegistry(~S),right))
def owners6_join(~S:Data,left:F.Owners5(~S) & String,right:F.RelationOwner(~S) & String) -> F.Owners6(~S) & String:
  (left,lt)=left
  (right,rt)=right
  ((left,right),"owners6{previous=" ++ lt ++ ";relation=" ++ rt ++ "}")
def owners6(~S:Data,value:F.Owners6(~S)) -> F.Owners6(~S) & String:
  match value:
    case (left,right):owners6_join(~S,owners5(~S,left),record(~S,~F.RelationRegistry(~S),right))
def owners7_join(~S:Data,left:F.Owners6(~S) & String,right:F.PublisherOwner(~S) & String) -> F.Owners7(~S) & String:
  (left,lt)=left
  (right,rt)=right
  ((left,right),"owners7{previous=" ++ lt ++ ";publisher=" ++ rt ++ "}")
def owners7(~S:Data,value:F.Owners7(~S)) -> F.Owners7(~S) & String:
  match value:
    case (left,right):owners7_join(~S,owners6(~S,left),record(~S,~F.PublisherRegistry(~S),right))
def owners_join(~S:Data,left:F.Owners7(~S) & String,right:F.Held<S> & String) -> F.Owners(~S) & String:
  (left,lt)=left
  (right,rt)=right
  ((left,right),"owners{registered=" ++ lt ++ ";" ++ rt ++ "}")
def owners(~S:Data,value:F.Owners(~S)) -> F.Owners(~S) & String:
  match value:
    case (left,right):owners_join(~S,owners7(~S,left),held(~S,right))
def app_join(~S:Data,+entries:List<&2,Fragment.Entry<S>>,+debug:Bool,recipe:Tree.Recipe<F.World(~S),F.Rows(~S),F.observe(~S)>,+schedule:SP.Plan<S>,+ns:U32,+name:String,+steps:List<&2,Sch.Step>,+needs:List<&2,SP.Requirement<S>>,a:F.World(~S) & String,b:F.Owners(~S) & String) -> F.Application(~S) & String:
  (world,wt)=a
  (owners,ot)=b
  (Single.Application{App.Application{Schema.Schema{entries},Build.Registered{world,owners,recipe,debug}},schedule,ns,name,steps,needs},"app{schema=" ++ List.show(&2,Fragment.Entry<S>,schema_entry(~S),entries) ++ ";debug=" ++ Bool.show(debug) ++ ";recipe=Recipe;plan=" ++ plan(~S,schedule) ++ ";namespace=" ++ U32.show(ns) ++ ";name=" ++ name ++ ";steps=" ++ List.show(&2,Sch.Step,step,steps) ++ ";needs=" ++ List.show(&2,SP.Requirement<S>,requirement(~S),needs) ++ ";" ++ wt ++ ";" ++ ot ++ "}")
def app(~S:Data,value:F.Application(~S)) -> F.Application(~S) & String:
  match value:
    case Single.Application{App.Application{Schema.Schema{entries},Build.Registered{current,owned,recipe,debug}},schedule,ns,name,steps,needs}:app_join(~S,entries,debug,recipe,schedule,ns,name,steps,needs,world(~S,current),owners(~S,owned))
def resource_rows(value:F.Rows3()) -> String:
  match value:
    case DTO.Product{DTO.Product{DTO.Product{Unit{},first},second},third}:"Product{Product{Product{Unit," ++ U32.show(first) ++ "}," ++ U32.show(second) ++ "}," ++ U32.show(third) ++ "}"
def component_rows(~S:Data,value:F.Rows4(~S)) -> String:
  match value:
    case DTO.Product{resources,DTO.Product{Unit{},components}}:"Product{" ++ resource_rows(resources) ++ ",Product{Unit," ++ List.show(&2,IQ.ProjectedRow<S,Cmp.Access<U32>>,projected_row(~S),components) ++ "}}"
def current(~S:Data,value:Machine.CurrentView<S,F.Mode,U32>) -> String:
  match value:
    case Machine.Unavailable{}:"Unavailable"
    case Machine.Current{value}:"Current{" ++ U32.show(value) ++ "}"
def relation_end(value:RQ.End) -> String:
  match value:
    case RQ.Outgoing{}:"Outgoing"
    case RQ.Incoming{}:"Incoming"
def relation_value(~S:Data,value:RQ.Value<S>) -> String:
  match value:
    case RQ.Missing{}:"Missing"
    case RQ.Target{target}:"Target{" ++ handle_text(~S,target) ++ "}"
    case RQ.Sources{sources}:"Sources{" ++ List.show(&2,W.Handle<S>,handle_text(~S),sources) ++ "}"
def relation_cell(~S:Data,value:RQ.Cell<S>) -> String:
  match value:
    case RQ.Cell{key,direction,value}:"Cell{key=" ++ key ++ ";direction=" ++ relation_end(direction) ++ ";value=" ++ relation_value(~S,value) ++ "}"
def relation_row(~S:Data,value:AppRelation.Row(~S)) -> String:
  match value:
    case IQ.ProjectedRow{handle,Select.Product{Unit{},cells}}:"ProjectedRow{entity=" ++ handle_text(~S,handle) ++ ";data=Product{Unit," ++ List.show(&2,RQ.Cell<S>,relation_cell(~S),cells) ++ "}}"
def relation_view(~S:Data,value:AppRelation.View<S>) -> String:
  match value:
    case AppRelation.View{declared,rows}:"View{" ++ descriptor(~S,declared) ++ ";rows=" ++ List.show(&2,AppRelation.Row(~S),relation_row(~S),rows) ++ "}"
def rows(~S:Data,value:F.Rows(~S)) -> String:
  match value:
    case DTO.Product{DTO.Product{previous,machine},relation}:"Product{Product{" ++ component_rows(~S,previous) ++ "," ++ current(~S,machine) ++ "}," ++ relation_view(~S,relation) ++ "}"
def snapshot(~S:Data,value:Maybe<&2,Single.Description<S,F.Rows(~S)>>) -> String:
  match value:
    case None{}:"None"
    case Some{Single.Description{App.Description{entries,DTO.Product{bindings,DTO.Observation{values,rendered}}},ns,name,steps}}:"Some{schema=" ++ List.show(&2,Fragment.Entry<S>,schema_entry(~S),entries) ++ ";bindings=" ++ List.show(&2,DTO.Binding<S>,binding(~S),bindings) ++ ";rows=" ++ rows(~S,values) ++ ";rendered=" ++ strings(rendered) ++ ";namespace=" ++ U32.show(ns) ++ ";name=" ++ name ++ ";steps=" ++ List.show(&2,Single.PlannedStep<S>,planned(~S),steps) ++ "}"
def HandlerEntry(~S:Data) -> Type:Handlers.Entry<S,F.Store(~S),F.Resources(~S),F.Notice(~S),U32,F.handler_runner(~S)>
def handler_entry(~S:Data,value:HandlerEntry(~S)) -> HandlerEntry(~S) & String:
  match value:
    case Handlers.Entry{+ordinal,Sys.Registry{+ns,+id,+name,+access,+cursor}}:(Handlers.Entry{ordinal,Sys.Registry{ns,id,name,access,cursor}},"handler{ordinal=" ++ U32.show(ordinal) ++ ";registry{namespace=" ++ U32.show(ns) ++ ";id=" ++ U32.show(id) ++ ";name=" ++ name ++ ";access=" ++ strings(access) ++ ";cursor=" ++ U32.show(cursor) ++ "}}")
def handler_entries_join(~S:Data,head:HandlerEntry(~S) & String,tail:List<HandlerEntry(~S)> & String) -> List<HandlerEntry(~S)> & String:
  (head,ht)=head
  (tail,tt)=tail
  (head <> tail,ht ++ ";" ++ tt)
def handler_entries(~S:Data,value:List<HandlerEntry(~S)>) -> List<HandlerEntry(~S)> & String:
  match value:
    case []:([],"[]")
    case head <> tail:handler_entries_join(~S,handler_entry(~S,head),handler_entries(~S,tail))
def handler_owners_join(~S:Data,exit:List<HandlerEntry(~S)> & String,transition:List<HandlerEntry(~S)> & String,enter:List<HandlerEntry(~S)> & String) -> F.HandlerOwners(~S) & String:
  (exit,xt)=exit
  (transition,tt)=transition
  (enter,et)=enter
  (Handlers.Owners{exit,transition,enter},"handlerOwners{exit=" ++ xt ++ ";transition=" ++ tt ++ ";enter=" ++ et ++ "}")
def handler_owners(~S:Data,value:F.HandlerOwners(~S)) -> F.HandlerOwners(~S) & String:
  match value:
    case Handlers.Owners{exit,transition,enter}:handler_owners_join(~S,handler_entries(~S,exit),handler_entries(~S,transition),handler_entries(~S,enter))
def handler_phase(value:Handlers.Phase) -> String:
  match value:
    case Handlers.Exit{}:"Exit"
    case Handlers.Transition{}:"Transition"
    case Handlers.Enter{}:"Enter"
def handler_failure(value:Maybe<&2,Execution.HandlerFailure>) -> String:
  match value:
    case None{}:"None"
    case Some{Execution.HandlerFailure{phase,error}}:"Some{phase=" ++ handler_phase(phase) ++ ";error=" ++ error ++ "}"
def capturedSnapshot(value:Machine.Snapshot<U32>) -> String:
  match value:
    case Machine.Unscheduled{}:"Unscheduled"
    case Machine.Scheduled{value,skip}:"Scheduled{value=" ++ U32.show(value) ++ ";skipSame=" ++ Bool.show(skip) ++ "}"
