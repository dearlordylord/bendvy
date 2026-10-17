import Base
import ../../../../src/ecs/ordinary-app-event-family-runtime.bend as FamilyApp
import ./fixture.bend as F
import ../../../../src/ecs/transaction.bend as T
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/execution-trace.bend as Trace
import ../../../../src/ecs/trace-facts.bend as Facts
import ../../../../src/ecs/system.bend as Sys
import ../../../../src/ecs/entity-key.bend as Key
import ../../../../src/ecs/entity-allocator.bend as Alloc
import ../../../../src/ecs/event-runtime.bend as Ev
import ../../../../src/ecs/deferred-command.bend as Command
import ../../../../src/ecs/schedule.bend as Sch
import ../../../../src/ecs/checked-condition-schedule.bend as Engine
import ../../../../src/ecs/check.bend as K
import ../../../../src/ecs/owned-event-log.bend as Log
import ../../../../src/ecs/event-stream.bend as Stream
import ../../../../src/ecs/event-family-runtime.bend as FR
import ../../../../src/ecs/event-family-routing.bend as Route
import ../../../../src/ecs/ordinary-event-declaration.bend as Event
import ../../../../src/ecs/ordinary-app-event-family-reader.bend as Reader
import ../../../../src/ecs/owned-event-family-reader-query.bend as Core
import ../../../../src/ecs/ordinary-checked-bindings.bend as B
import ../../../../src/ecs/ordinary-checked-condition.bend as Cond
import ../../../../src/ecs/ordinary-condition-composition.bend as OldCond
import ../../../../src/ecs/ordinary-check-declaration.bend as CD
import ../../../../src/ecs/ordinary-app-recipe.bend as Tree
import ../../../../src/ecs/ordinary-app-observation-data.bend as DTO
import ../../../../src/ecs/ordinary-app-checked-family-schedule.bend as Checked
import ../../../../src/ecs/ordinary-app-checked-schedule.bend as Check
import ../../../../src/ecs/ordinary-app-schedule.bend as Single
import ../../../../src/ecs/ordinary-app-schema.bend as SchemaApp
import ../../../../src/ecs/ordinary-app-composer.bend as Build
import ../../../../src/ecs/ordinary-schema.bend as Schema
import ../../../../src/ecs/schema-fragments.bend as Fragment
import ../../../../src/ecs/schedule-provision.bend as SP
import ../../../../src/ecs/ordinary-query-declaration.bend as Query
import ../../../../src/ecs/column.bend as Col
import ../../../../src/ecs/indexed-lifecycle.bend as Meta
import ../../../../src/ecs/lifecycle.bend as Life
import ../../../../src/ecs/compose.bend as Q

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
def check_error(value:K.Error) -> String:
  match value:
    case K.MissingRuntimeRequirements{resources}:"MissingRuntimeRequirements{" ++ strings(resources) ++ "}"
def engine_error(value:Engine.Error<String>) -> String:
  match value:
    case Engine.SystemError{error}:"SystemError{" ++ error ++ "}"
    case Engine.CheckError{error}:"CheckError{" ++ check_error(error) ++ "}"
    case Engine.ConditionUnavailable{}:"ConditionUnavailable"
    case Engine.ConditionRegistrationRejected{}:"ConditionRegistrationRejected"
def trace_status(value:Trace.Status<Engine.Error<String>>) -> String:
  match value:
    case Trace.SystemOk{}:"SystemOk"
    case Trace.SystemError{error}:"SystemError{error=" ++ engine_error(error) ++ "}"
def completion(value:Trace.Completion<Engine.Error<String>>) -> String:
  match value:
    case Trace.EndOk{}:"EndOk"
    case Trace.EndFailed{error}:"EndFailed{error=" ++ engine_error(error) ++ "}"
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
def event(value:Trace.TraceEvent<Engine.Error<String>>) -> String:
  match value:
    case Trace.ScheduleStarted{ns,name}:"ScheduleStarted{namespace=" ++ U32.show(ns) ++ ";name=" ++ name ++ "}"
    case Trace.PhaseEntered{name}:"PhaseEntered{name=" ++ name ++ "}"
    case Trace.SystemCompleted{who,before,after,result}:"SystemCompleted{" ++ identity(who) ++ ";before=" ++ U32.show(before) ++ ";after=" ++ U32.show(after) ++ ";status=" ++ trace_status(result) ++ "}"
    case Trace.OperationObserved{who,value}:"OperationObserved{" ++ identity(who) ++ ";fact=" ++ fact(value) ++ "}"
    case Trace.BarrierOperationObserved{value}:"BarrierOperationObserved{fact=" ++ fact(value) ++ "}"
    case Trace.ExecutionOperationObserved{value}:"ExecutionOperationObserved{fact=" ++ fact(value) ++ "}"
    case Trace.SystemSkipped{id}:"SystemSkipped{id=" ++ U32.show(id) ++ "}"
    case Trace.DeferredApplied{}:"DeferredApplied"
    case Trace.ScheduleEnded{result}:"ScheduleEnded{outcome=" ++ completion(result) ++ "}"
    case Trace.ScheduleAdmissionRefused{ns,name,result}:"ScheduleAdmissionRefused{namespace=" ++ U32.show(ns) ++ ";name=" ++ name ++ ";outcome=" ++ completion(result) ++ "}"
def batch(value:Trace.Batch<Engine.Error<String>>) -> String:
  match value:
    case Trace.Disabled{}:"Disabled"
    case Trace.Ready{events}:"Ready{events=" ++ List.show(&2,Trace.TraceEvent<Engine.Error<String>>,event,events) ++ "}"
def collector_join(+calls:Nat,+events:List<&2,Trace.TraceEvent<Engine.Error<String>>>,value:Array<U32> & String) -> F.Collector & String:
  (owned,text)=value
  (F.Collector{calls,events,owned},"collector{calls=" ++ Nat.show(calls) ++ ";events=" ++ List.show(&2,Trace.TraceEvent<Engine.Error<String>>,event,events) ++ ";owned=" ++ text ++ "}")
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
def allocator_join(+next:U32,+high:U32,+capacity:U32,+depth:Nat,+free:List<&2,U32>,+order:List<&2,Key.Key>,value:Array<Alloc.Slot> & String) -> Alloc.Allocator & String:
  match value:
    case (slots,text):(Alloc.Allocator{next,high,slots,capacity,depth,free,order},"allocator{next=" ++ U32.show(next) ++ ";high=" ++ U32.show(high) ++ ";capacity=" ++ U32.show(capacity) ++ ";depth=" ++ Nat.show(depth) ++ ";slots=" ++ text ++ ";free=" ++ List.show(&2,U32,U32.show,free) ++ ";order=" ++ List.show(&2,Key.Key,key_text,order) ++ "}")
def allocator(value:Alloc.Allocator) -> Alloc.Allocator & String:
  match value:
    case Alloc.Allocator{next,high,slots,capacity,depth,free,order}:allocator_join(next,high,capacity,depth,free,order,array(~Alloc.Slot,~allocator_slot,slots))
def step(value:Sch.Step) -> String:
  match value:
    case Sch.Phase{name}:"Phase{" ++ name ++ "}"
    case Sch.System{id,condition}:"System{" ++ U32.show(id) ++ ";condition=" ++ U32.show(condition) ++ "}"
    case Sch.Barrier{}:"Barrier"
def observation(value:Sch.Observation) -> String:
  match value:
    case Sch.Entered{name}:"Entered{" ++ name ++ "}"
    case Sch.Ran{id}:"Ran{" ++ U32.show(id) ++ "}"
    case Sch.Skipped{id}:"Skipped{" ++ U32.show(id) ++ "}"
    case Sch.Applied{}:"Applied"
def observations(value:List<&2,Sch.Observation>) -> String:List.show(&2,Sch.Observation,observation,value)
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
def registry_kind(value:Fragment.RegistryKind) -> String:
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
    case Fragment.Entry{cat,key,name}:"Entry{" ++ registry_kind(cat) ++ ":" ++ key ++ ":" ++ name ++ "}"
    case Fragment.Classified{cat,key,name,p}:"Classified{" ++ registry_kind(cat) ++ ":" ++ key ++ ":" ++ name ++ ":" ++ persistence(p) ++ "}"
def requirement(~S:Data,value:SP.Requirement<S>) -> String:
  match value:
    case SP.Component{id}:"Component{" ++ U32.show(id) ++ "}"
    case SP.Resource{id}:"Resource{" ++ U32.show(id) ++ "}"
    case SP.Service{id}:"Service{" ++ U32.show(id) ++ "}"
def plan(~S:Data,value:SP.Plan<S>) -> String:
  match value:
    case SP.Empty{}:"Empty"
    case SP.Entry{s,needs}:"Entry{" ++ step(s) ++ ";needs=" ++ List.show(&2,SP.Requirement<S>,requirement(~S),needs) ++ "}"
    case SP.Sequence{left,right}:"Sequence{" ++ plan(~S,left) ++ "," ++ plan(~S,right) ++ "}"
def planned(~S:Data,value:Single.PlannedStep<S>) -> String:
  match value:
    case Single.PlannedStep{s,needs}:"planned{" ++ step(s) ++ ";needs=" ++ List.show(&2,SP.Requirement<S>,requirement(~S),needs) ++ "}"
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
    case Query.Clause{key,value}:key ++ ":" ++ mode(value)
def dto_binding(~S:Data,value:DTO.Binding<S>) -> String:
  match value:
    case DTO.Binding{ns,id,name,access,cursor,slot,clauses}:"Binding{namespace=" ++ U32.show(ns) ++ ";id=" ++ U32.show(id) ++ ";name=" ++ name ++ ";access=" ++ strings(access) ++ ";cursor=" ++ U32.show(cursor) ++ ";slot=" ++ slot ++ ";clauses=" ++ List.show(&2,Query.Clause<S>,clause(~S),clauses) ++ "}"
def old_leaf(value:OldCond.LeafDescription) -> String:
  match value:
    case OldCond.StateChanged{ns,id,name,access}:"StateChanged{namespace=" ++ U32.show(ns) ++ ";id=" ++ U32.show(id) ++ ";name=" ++ name ++ ";access=" ++ strings(access) ++ "}"
    case OldCond.InState{name}:"InState{" ++ name ++ "}"
    case OldCond.Constant{value}:"Constant{" ++ Bool.show(value) ++ "}"
def old_description(value:OldCond.Description) -> String:
  match value:
    case OldCond.Description{name,access,leaves}:"Description{name=" ++ name ++ ";access=" ++ strings(access) ++ ";leaves=" ++ List.show(&2,OldCond.LeafDescription,old_leaf,leaves) ++ "}"
def metadata_kind(value:CD.RelationKind) -> String:
  match value:
    case CD.Ordinary{}:"Ordinary"
    case CD.Hierarchy{}:"Hierarchy"
def relation_identity(value:CD.RelationIdentity) -> String:
  match value:
    case CD.RelationIdentity{id,name,inverseName,kind}:"identity{id=" ++ U32.show(id) ++ ";name=" ++ name ++ ";inverseName=" ++ inverseName ++ ";kind=" ++ metadata_kind(kind) ++ "}"
def direction_view(value:CD.RelationDirection) -> String:
  match value:
    case CD.Outgoing{}:"Outgoing"
    case CD.Incoming{}:"Incoming"
def selection_view(value:CD.RelationSelection) -> String:
  match value:
    case CD.RelationRequired{}:"Required"
    case CD.RelationOptional{}:"Optional"
    case CD.RelationPresent{}:"Present"
    case CD.RelationAbsent{}:"Absent"
def component_selection(value:CD.ComponentSelection) -> String:
  match value:
    case CD.Required{}:"Required"
    case CD.Optional{}:"Optional"
    case CD.With{}:"With"
    case CD.Without{}:"Without"
def use(value:CD.Use) -> String:
  match value:
    case CD.Use{CD.Machine{},key,CD.Read{},required}:"Machine{" ++ key ++ ";mode=Read;required=" ++ Bool.show(required) ++ "}"
    case CD.Use{CD.Relation{identity,direction,selection,cellKey},key,CD.Read{},required}:"Relation{" ++ relation_identity(identity) ++ ";direction=" ++ direction_view(direction) ++ ";selection=" ++ selection_view(selection) ++ ";cellKey=" ++ optional_name(cellKey) ++ ";key=" ++ key ++ ";mode=Read;required=" ++ Bool.show(required) ++ "}"
    case CD.Use{CD.Resource{},key,CD.Read{},required}:"Resource{" ++ key ++ ";mode=Read;required=" ++ Bool.show(required) ++ "}"
    case CD.Use{CD.Component{selection},key,CD.Read{},required}:"Component{" ++ component_selection(selection) ++ ";key=" ++ key ++ ";mode=Read;required=" ++ Bool.show(required) ++ "}"
def shape(value:Cond.Shape) -> String:
  match value:
    case Cond.Existing{facts}:"Existing{" ++ old_description(facts) ++ "}"
    case Cond.Check{name}:"Check{" ++ name ++ "}"
    case Cond.Constant{value}:"Constant{" ++ Bool.show(value) ++ "}"
    case Cond.Not{inner}:"Not{" ++ shape(inner) ++ "}"
    case Cond.And{left,right}:"And{" ++ shape(left) ++ "," ++ shape(right) ++ "}"
    case Cond.Or{left,right}:"Or{" ++ shape(left) ++ "," ++ shape(right) ++ "}"
def description(value:Cond.Description) -> String:
  match value:
    case Cond.Description{value,uses}:"description{shape=" ++ shape(value) ++ ";uses=" ++ List.show(&2,CD.Use,use,uses) ++ "}"
def binding(value:B.Description) -> String:
  match value:
    case B.Description{id,facts}:"binding{systemId=" ++ U32.show(id) ++ ";" ++ description(facts) ++ "}"
def guards(~S:Data,value:B.Bindings<F.World(~S),F.Guard(~S),F.select(~S)>) -> B.Bindings<F.World(~S),F.Guard(~S),F.select(~S)> & String:
  match value:
    case B.Bindings{B.BoundOwner{+id,+flag},+facts}:(B.Bindings{B.BoundOwner{id,flag},facts},"guards{systemId=" ++ U32.show(id) ++ ";owner=" ++ Bool.show(flag) ++ ";descriptions=" ++ List.show(&2,B.Description,binding,facts) ++ "}")
def log_rows_join(+id:Nat,head:Array<U32> & String,tail:List<Log.Row<Array<U32>>> & String) -> List<Log.Row<Array<U32>>> & String:
  (payload,pt)=head
  (rows,rt)=tail
  (Log.Row{id,payload} <> rows,"Row{id=" ++ Nat.show(id) ++ ";payload=" ++ pt ++ "}," ++ rt)
def log_rows(rows:List<Log.Row<Array<U32>>>) -> List<Log.Row<Array<U32>>> & String:
  match rows:
    case []:([],"end")
    case Log.Row{id,payload} <> rest:log_rows_join(id,u32_array(payload),log_rows(rest))
def log_join(+next:Nat,value:List<Log.Row<Array<U32>>> & String) -> Log.Log<Array<U32>> & String:
  (rows,text)=value
  (Log.Log{next,rows},"Log{next=" ++ Nat.show(next) ++ ";rows=" ++ text ++ "}")
def log(value:Log.Log<Array<U32>>) -> Log.Log<Array<U32>> & String:
  match value:
    case Log.Log{next,rows}:log_join(next,log_rows(rows))
def optional_array_join(value:Array<U32> & String) -> Maybe<Array<U32>> & String:
  (value,text)=value
  (Some{value},"Some{" ++ text ++ "}")
def optional_array(value:Maybe<Array<U32>>) -> Maybe<Array<U32>> & String:
  match value:
    case None{}:(None{},"None")
    case Some{value}:optional_array_join(u32_array(value))
def life(value:Life.Entry) -> String:
  match value:
    case Life.Entry{id,Life.Stamp{added,changed}}:U32.show(id) ++ ":" ++ U32.show(added) ++ ":" ++ U32.show(changed)
def metadata_join(+capacity:U32,+depth:Nat,+exceptional:List<&2,Life.Entry>,a:Array<U32> & String,b:Array<U32> & String) -> Meta.Metadata & String:
  (added,at)=a
  (changed,bt)=b
  (Meta.Metadata{added,changed,capacity,depth,exceptional},"Metadata{added=" ++ at ++ ";changed=" ++ bt ++ ";capacity=" ++ U32.show(capacity) ++ ";depth=" ++ Nat.show(depth) ++ ";exceptional=" ++ List.show(&2,Life.Entry,life,exceptional) ++ "}")
def metadata(value:Meta.Metadata) -> Meta.Metadata & String:
  match value:
    case Meta.Metadata{added,changed,+capacity,+depth,+exceptional}:metadata_join(capacity,depth,exceptional,u32_array(added),u32_array(changed))
def indexed_join(~S:Data,a:Array<Maybe<Array<U32>>> & String,b:Meta.Metadata & String) -> Col.IndexedOrdinaryState<S,Array<U32>> & String:
  (values,vt)=a
  (metadata,mt)=b
  (Col.IndexedOrdinaryState{values,metadata},"IndexedState{values=" ++ vt ++ ";" ++ mt ++ "}")
def indexed_owned(~S:Data,value:Col.IndexedOrdinaryState<S,Array<U32>> & String) -> Col.IndexedOrdinaryCarrier<S,Array<U32>> & String:
  (state,text)=value
  (Col.IndexedOrdinaryOwned{state},"Owned{" ++ text ++ "}")
def indexed_wrapped(~S:Data,value:Col.IndexedOrdinaryCarrier<S,Array<U32>> & String) -> Col.IndexedOrdinaryCarrier<S,Array<U32>> & String:
  (inner,text)=value
  (Col.IndexedOrdinaryWrapped{inner},"Wrapped{" ++ text ++ "}")
def indexed(~S:Data,value:Col.IndexedOrdinaryCarrier<S,Array<U32>>) -> Col.IndexedOrdinaryCarrier<S,Array<U32>> & String:
  match value:
    case Col.IndexedOrdinaryOwned{Col.IndexedOrdinaryState{values,meta}}:indexed_owned(~S,indexed_join(~S,array(~Maybe<Array<U32>>,~optional_array,values),metadata(meta)))
    case Col.IndexedOrdinaryWrapped{inner}:indexed_wrapped(~S,indexed(~S,inner))
def column_indexed(~S:Data,value:Col.IndexedOrdinaryCarrier<S,Array<U32>> & String) -> Col.Column<S,Array<U32>> & String:
  (state,text)=value
  (Col.Indexed{state},"Indexed{" ++ text ++ "}")
def column_ordinary(~S:Data,+stamps:List<&2,Life.Entry>,value:Array<Maybe<Array<U32>>> & String) -> Col.Column<S,Array<U32>> & String:
  (values,text)=value
  (Col.Column{values,stamps},"Column{values=" ++ text ++ ";stamps=" ++ List.show(&2,Life.Entry,life,stamps) ++ "}")
def column(~S:Data,value:Col.Column<S,Array<U32>>) -> Col.Column<S,Array<U32>> & String:
  match value:
    case Col.Indexed{state}:column_indexed(~S,indexed(~S,state))
    case Col.Column{values,+stamps}:column_ordinary(~S,stamps,array(~Maybe<Array<U32>>,~optional_array,values))
    case other:(other,"UNSUPPORTED_PREPARED_COLUMN")
def world_join(~S:Data,+ns:U32,+events:List<&2,Nat>,+regs:List<&2,W.RegistrationMeta>,+sid:U32,+clock:U32,a:Alloc.Allocator & String,b:Log.Log<Array<U32>> & String,c:List<Command.Command<F.World(~S)>> & String,d:Col.Column<S,Array<U32>> & String) -> F.World(~S) & String:
  (slots,at)=a
  (resources,bt)=b
  (pending,ct)=c
  (store,dt)=d
  (W.World{ns,slots,store,resources,events,pending,regs,sid,clock},"World{namespace=" ++ U32.show(ns) ++ ";" ++ at ++ ";store=" ++ dt ++ ";resources=" ++ bt ++ ";events=" ++ List.show(&2,Nat,Nat.show,events) ++ ";pending=" ++ ct ++ ";registrations=" ++ List.show(&2,W.RegistrationMeta,registration,regs) ++ ";nextSystemId=" ++ U32.show(sid) ++ ";clock=" ++ U32.show(clock) ++ "}")
def world(~S:Data,value:F.World(~S)) -> F.World(~S) & String:
  match value:
    case W.World{ns,slots,store,resources,events,pending,regs,sid,clock}:world_join(~S,ns,events,regs,sid,clock,allocator(slots),log(resources),commands(~S,pending),column(~S,store))
def event_mode(value:Event.Mode) -> String:
  match value:
    case Event.Read{}:"Read"
    case Event.Write{}:"Write"
def owner(~S:Data,value:F.Owner(~S)) -> F.Owner(~S) & String:
  match value:
    case Reader.Owner{Event.Declaration{Event.Domain{+key},+mode},Route.Reader{+ns,+id,+rid},Sys.Registry{+rns,+sid,+name,+access,+cursor}}:(Reader.Owner{Event.Declaration{Event.Domain{key},mode},Route.Reader{ns,id,rid},Sys.Registry{rns,sid,name,access,cursor}},"ReaderOwner{domain=" ++ key ++ ";mode=" ++ event_mode(mode) ++ ";readerNamespace=" ++ U32.show(ns) ++ ";readerId=" ++ U32.show(id) ++ ";registryId=" ++ U32.show(rid) ++ ";registryNamespace=" ++ U32.show(rns) ++ ";systemId=" ++ U32.show(sid) ++ ";name=" ++ name ++ ";access=" ++ strings(access) ++ ";cursor=" ++ U32.show(cursor) ++ "}")
def event_batch(value:Ev.Batch<Nat>) -> String:
  match value:
    case Ev.Batch{tick,values}:"Batch{tick=" ++ Nat.show(tick) ++ ";values=" ++ List.show(&2,Nat,Nat.show,values) ++ "}"
def position(value:Ev.Position) -> String:
  match value:
    case Ev.Position{id,cursor,registered}:"Position{id=" ++ U32.show(id) ++ ";cursor=" ++ Nat.show(cursor) ++ ";registeredAt=" ++ Nat.show(registered) ++ "}"
def stream(~S:Data,value:Stream.Stream<S,Nat>) -> String:
  match value:
    case Stream.Stream{Event.Domain{key},batches,positions,next,frameStart,boundary,capacity,dropped}:"Stream{domain=" ++ key ++ ";batches=" ++ List.show(&2,Ev.Batch<Nat>,event_batch,batches) ++ ";positions=" ++ List.show(&2,Ev.Position,position,positions) ++ ";nextReader=" ++ U32.show(next) ++ ";frameStart=" ++ Nat.show(frameStart) ++ ";boundary=" ++ Nat.show(boundary) ++ ";capacity=" ++ Nat.show(capacity) ++ ";dropped=" ++ Nat.show(dropped) ++ "}"
def family(~S:Data,value:F.State(~S)) -> F.State(~S) & String:
  match value:
    case FR.State{+value,Unit{},+journal,+frameStart}:(FR.State{value,Unit{},journal,frameStart},"Family{stream=" ++ stream(~S,value) ++ ";owners=Unit;journal=" ++ List.show(&2,Ev.Batch<Nat>,event_batch,journal) ++ ";frameStart=" ++ Nat.show(frameStart) ++ "}")
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
def query_error(value:Q.Error<String>) -> String:
  match value:
    case Q.UserError{error}:"UserError{" ++ error ++ "}"
    case Q.AccessError{error}:"AccessError{" ++ world_error(error) ++ "}"
def reader_failure(value:Core.Error<String>) -> String:
  match value:
    case Core.MissingPayload{}:"MissingPayload"
    case Core.ProjectError{error}:"ProjectError{" ++ error ++ "}"
    case Core.QueryError{error}:"QueryError{" ++ query_error(error) ++ "}"
def semantic_status(value:T.Outcome<Core.Error<String>>) -> String:
  match value:
    case T.Success{}:"Success"
    case T.Failure{error}:"Failure{" ++ reader_failure(error) ++ "}"
def observation_join(+event:U32,value:Array<U32> & String) -> F.Observation & String:
  (owned,text)=value
  (F.Observation{event,owned},"Observation{event=" ++ U32.show(event) ++ ";owned=" ++ text ++ "}")
def query_observation(value:F.Observation) -> F.Observation & String:
  match value:
    case F.Observation{event,owned}:observation_join(event,u32_array(owned))
def history_join(a:F.Observation & String,b:List<F.Observation> & String) -> List<F.Observation> & String:
  (first,at)=a
  (rest,bt)=b
  (first <> rest,at ++ "," ++ bt)
def history(value:List<F.Observation>) -> List<F.Observation> & String:
  match value:
    case []:([],"end")
    case first <> rest:history_join(query_observation(first),history(rest))
def seed_handle(value:Maybe<&2,Facts.HandleValue>) -> String:
  match value:
    case None{}:"None"
    case Some{handle}:"Some{" ++ fact_handle(handle) ++ "}"
def seed_join(+handle:Maybe<&2,Facts.HandleValue>,+activation:W.Status,a:Maybe<Array<U32>> & String,b:Maybe<Array<U32>> & String) -> F.Seed & String:
  (previous,pt)=a
  (rejected,rt)=b
  (F.Seed{handle,activation,previous,rejected},"Seed{handle=" ++ seed_handle(handle) ++ ";activation=" ++ world_status(activation) ++ ";previous=" ++ pt ++ ";rejected=" ++ rt ++ "}")
def seed(value:F.Seed) -> F.Seed & String:
  match value:
    case F.Seed{handle,activation,previous,rejected}:seed_join(handle,activation,optional_array(previous),optional_array(rejected))
def held_join(+values:List<&2,U32>,+fail:Bool,+status:T.Outcome<Core.Error<String>>,+lagged:Bool,+outputs:List<&2,U32>,a:Array<U32> & String,b:List<F.Observation> & String,c:F.Seed & String) -> F.Held & String:
  (scratch,text)=a
  (history,ht)=b
  (seed,st)=c
  (F.Held{F.Args{scratch,values,fail},status,lagged,history,outputs,seed},"Held{args{scratch=" ++ text ++ ";values=" ++ List.show(&2,U32,U32.show,values) ++ ";fail=" ++ Bool.show(fail) ++ "};status=" ++ semantic_status(status) ++ ";lagged=" ++ Bool.show(lagged) ++ ";history=" ++ ht ++ ";outputs=" ++ List.show(&2,U32,U32.show,outputs) ++ ";seed=" ++ st ++ "}")
def noargs_join(+outputs:List<&2,U32>,a:List<F.Observation> & String,b:F.Seed & String) -> F.Held & String:
  (history,ht)=a
  (seed,st)=b
  (F.NoArgs{history,outputs,seed},"NoArgs{history=" ++ ht ++ ";outputs=" ++ List.show(&2,U32,U32.show,outputs) ++ ";seed=" ++ st ++ "}")
def held(value:F.Held) -> F.Held & String:
  match value:
    case F.NoArgs{hist,outputs,seedValue}:noargs_join(outputs,history(hist),seed(seedValue))
    case F.Held{F.Args{scratch,values,fail},status,lagged,hist,outputs,seedValue}:held_join(values,fail,status,lagged,outputs,u32_array(scratch),history(hist),seed(seedValue))
def owners_join(~S:Data,a:F.Held & String,b:F.Owner(~S) & String) -> F.Owners(~S) & String:
  (held,ht)=a
  (reader,rt)=b
  ((held,reader),"Owners{" ++ ht ++ ";" ++ rt ++ "}")
def owners(~S:Data,value:F.Owners(~S)) -> F.Owners(~S) & String:
  match value:
    case (a,b):owners_join(~S,held(a),owner(~S,b))
def snapshot(~S:Data,value:Maybe<&2,Check.Description<S,F.Rows()>>) -> String:
  match value:
    case None{}:"None"
    case Some{Check.Description{Single.Description{SchemaApp.Description{entries,DTO.Product{bindings,DTO.Observation{DTO.Product{Unit{},Unit{}},rendered}}},ns,name,steps},facts}}:"Some{schema=" ++ List.show(&2,Fragment.Entry<S>,schema_entry(~S),entries) ++ ";bindings=" ++ List.show(&2,DTO.Binding<S>,dto_binding(~S),bindings) ++ ";rows=Product{Unit,Unit};rendered=" ++ strings(rendered) ++ ";namespace=" ++ U32.show(ns) ++ ";name=" ++ name ++ ";steps=" ++ List.show(&2,Single.PlannedStep<S>,planned(~S),steps) ++ ";checkedBindings=" ++ List.show(&2,B.Description,binding,facts) ++ "}"
def status(~S:Data,value:F.RunStatus<S>) -> String:
  match value:
    case F.Finished{seen}:"Finished{" ++ observations(seen) ++ "}"
    case F.Failed{error,seen}:"Failed{error=" ++ engine_error(error) ++ ";observations=" ++ observations(seen) ++ "}"
    case F.Rejected{}:"Rejected"
    case F.Missing{requirements}:"Missing{" ++ List.show(&2,SP.Requirement<S>,requirement(~S),requirements) ++ "}"
def app_join(~S:Data,+entries:List<&2,Fragment.Entry<S>>,+tick:Nat,recipe:Tree.Recipe<F.World(~S),F.Rows(),F.observation(~S)>,+debug:Bool,+schedule:SP.Plan<S>,+ns:U32,+name:String,+steps:List<&2,Sch.Step>,+needs:List<&2,SP.Requirement<S>>,a:F.World(~S) & String,b:F.Owners(~S) & String,c:F.State(~S) & String,d:B.Bindings<F.World(~S),F.Guard(~S),F.select(~S)> & String) -> F.Application(~S) & String:
  (current,wt)=a
  (owned,ot)=b
  (state,ft)=c
  (bindings,bt)=d
  (Checked.Application{Check.Application{Single.Application{SchemaApp.Application{Schema.Schema{entries},Build.Registered{current,(owned,(state,tick)),recipe,debug}},schedule,ns,name,steps,needs},bindings}},"App{schema=" ++ List.show(&2,Fragment.Entry<S>,schema_entry(~S),entries) ++ ";recipe=Recipe;debug=" ++ Bool.show(debug) ++ ";plan=" ++ plan(~S,schedule) ++ ";namespace=" ++ U32.show(ns) ++ ";name=" ++ name ++ ";steps=" ++ List.show(&2,Sch.Step,step,steps) ++ ";needs=" ++ List.show(&2,SP.Requirement<S>,requirement(~S),needs) ++ ";" ++ wt ++ ";" ++ ot ++ ";tick=" ++ Nat.show(tick) ++ ";" ++ ft ++ ";" ++ bt ++ "}")
def app(~S:Data,value:F.Application(~S)) -> F.Application(~S) & String:
  match value:
    case Checked.Application{Check.Application{Single.Application{SchemaApp.Application{Schema.Schema{entries},Build.Registered{current,(owned,(state,tick)),recipe,debug}},schedule,ns,name,steps,needs},bindings}}:app_join(~S,entries,tick,recipe,debug,schedule,ns,name,steps,needs,world(~S,current),owners(~S,owned),family(~S,state),guards(~S,bindings))
def before_join(~S:Data,+entries:List<&2,Fragment.Entry<S>>,+tick:Nat,recipe:Tree.Recipe<F.World(~S),Unit,F.observe(~S)>,+debug:Bool,a:F.World(~S) & String,b:F.State(~S) & String,c:F.Held & String) -> F.Before(~S) & String:
  (current,wt)=a
  (state,ft)=b
  (owned,ot)=c
  (FamilyApp.Application{Schema.Schema{entries},Route.Runtime{current,state,tick},owned,recipe,debug},"Before{schema=" ++ List.show(&2,Fragment.Entry<S>,schema_entry(~S),entries) ++ ";recipe=Recipe;debug=" ++ Bool.show(debug) ++ ";" ++ wt ++ ";tick=" ++ Nat.show(tick) ++ ";" ++ ft ++ ";" ++ ot ++ "}")
def before(~S:Data,value:F.Before(~S)) -> F.Before(~S) & String:
  match value:
    case FamilyApp.Application{Schema.Schema{entries},Route.Runtime{current,state,tick},owned,recipe,debug}:before_join(~S,entries,tick,recipe,debug,world(~S,current),family(~S,state),held(owned))
def unscheduled_join(~S:Data,+entries:List<&2,Fragment.Entry<S>>,+tick:Nat,recipe:Tree.Recipe<F.World(~S),F.Rows(),F.observation(~S)>,+debug:Bool,a:F.World(~S) & String,b:F.State(~S) & String,c:F.Owners(~S) & String) -> F.Unscheduled(~S) & String:
  (current,wt)=a
  (state,ft)=b
  (owned,ot)=c
  (FamilyApp.Application{Schema.Schema{entries},Route.Runtime{current,state,tick},owned,recipe,debug},"Unscheduled{schema=" ++ List.show(&2,Fragment.Entry<S>,schema_entry(~S),entries) ++ ";recipe=Recipe;debug=" ++ Bool.show(debug) ++ ";" ++ wt ++ ";tick=" ++ Nat.show(tick) ++ ";" ++ ft ++ ";" ++ ot ++ "}")
def unscheduled(~S:Data,value:F.Unscheduled(~S)) -> F.Unscheduled(~S) & String:
  match value:
    case FamilyApp.Application{Schema.Schema{entries},Route.Runtime{current,state,tick},owned,recipe,debug}:unscheduled_join(~S,entries,tick,recipe,debug,world(~S,current),family(~S,state),owners(~S)(owned))
def ready_join(~S:Data,value:F.Application(~S) & String) -> F.SetupResult<S> & String:
  (value,text)=value
  (F.Ready{value},"Ready{" ++ text ++ "}")
def registration_join(~S:Data,value:F.Before(~S) & String) -> F.SetupResult<S> & String:
  (value,text)=value
  (F.RegistrationRejected{value},"RegistrationRejected{" ++ text ++ "}")
def schedule_join(~S:Data,a:F.Unscheduled(~S) & String,b:B.Bindings<F.World(~S),F.Guard(~S),F.select(~S)> & String) -> F.SetupResult<S> & String:
  (value,text)=a
  (bindings,bt)=b
  (F.ScheduleRejected{value,bindings},"ScheduleRejected{" ++ text ++ ";" ++ bt ++ "}")
def setup(~S:Data,value:F.SetupResult<S>) -> F.SetupResult<S> & String:
  match value:
    case F.Ready{value}:ready_join(~S,app(~S,value))
    case F.RegistrationRejected{value}:registration_join(~S,before(~S,value))
    case F.ScheduleRejected{value,bindings}:schedule_join(~S,unscheduled(~S,value),guards(~S,bindings))
