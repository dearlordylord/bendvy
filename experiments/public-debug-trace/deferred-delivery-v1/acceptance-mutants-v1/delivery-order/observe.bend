import Base
import ./fixture.bend as F
import ../../../../../src/ecs/transaction.bend as T
import ../../../../../src/ecs/machine-handlers.bend as H
import ../../../../../src/ecs/ordinary-app-machine-handler.bend as App
import ../../../../../src/ecs/machine-handler-bundle.bend as B
import ../../../../../src/ecs/ordinary-machine-handler-bundle.bend as Operation
import ../../../../../src/ecs/ordinary-machine-schedule.bend as Ordinary
import ../../../../../src/ecs/world.bend as W
import ../../../../../src/ecs/owner-product.bend as Product
import ../../../../../src/ecs/execution-trace.bend as Trace
import ../../../../../src/ecs/trace-facts.bend as Facts
import ../../../../../src/ecs/system.bend as Sys
import ../../../../../src/ecs/entity-key.bend as Key
import ../../../../../src/ecs/entity-allocator.bend as Alloc
import ../../../../../src/ecs/ordinary-machine-initialization.bend as Init
import ../../../../../src/ecs/machine.bend as Machine
import ../../../../../src/ecs/machine-stream.bend as Stream
import ../../../../../src/ecs/machine-stream-queue.bend as MQ
import ../../../../../src/ecs/event-runtime.bend as Ev
import ../../../../../src/ecs/deferred-command.bend as Command
import ../../../../../src/ecs/schedule.bend as Sch

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
def trace_status(value:Trace.Status<String>) -> String:
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
    case Trace.SystemCompleted{who,before,after,result}:"SystemCompleted{" ++ identity(who) ++ ";before=" ++ U32.show(before) ++ ";after=" ++ U32.show(after) ++ ";status=" ++ trace_status(result) ++ "}"
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
def machine_state_text(~S:Data,value:Init.State<S,F.Mode,U32>) -> String:
  match value:
    case Init.State{slot,stream,revision}:"State{slot=" ++ machine_slot(~S,slot) ++ ";stream=" ++ machine_stream(stream) ++ ";revision=" ++ Nat.show(revision) ++ "}"
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
def resources_join(~S:Data,+state:Init.State<S,F.Mode,U32>,observed:Array<U32> & String) -> F.Resources(~S) & String:
  (counter,text)=observed
  (Product.Owner{counter,state},"resources{Counter=" ++ text ++ ";Mode=" ++ machine_state_text(~S,state) ++ "}")
def resources(~S:Data,value:F.Resources(~S)) -> F.Resources(~S) & String:
  match value:
    case Product.Owner{counter,state}:resources_join(~S,state,u32_array(counter))
def world_join(~S:Data,+ns:U32,+events:List<&2,Unit>,+registrations:List<&2,W.RegistrationMeta>,+sid:U32,+clock:U32,slots:Alloc.Allocator & String,owned:F.Resources(~S) & String,pending:List<Command.Command<F.World(~S)>> & String) -> F.World(~S) & String:
  (allocator,at)=slots
  (resource,rt)=owned
  (pending,pt)=pending
  (W.World{ns,allocator,Unit{},resource,events,pending,registrations,sid,clock},"world{namespace=" ++ U32.show(ns) ++ ";" ++ at ++ ";store=Unit;" ++ rt ++ ";events=" ++ List.show(&2,Unit,unit,events) ++ ";pending=" ++ pt ++ ";registrations=" ++ List.show(&2,W.RegistrationMeta,registration,registrations) ++ ";nextSystemId=" ++ U32.show(sid) ++ ";clock=" ++ U32.show(clock) ++ "}")
def world(~S:Data,value:F.World(~S)) -> F.World(~S) & String:
  match value:
    case W.World{ns,slots,Unit{},owned,events,pending,registrations,sid,clock}:world_join(~S,ns,events,registrations,sid,clock,allocator(slots),resources(~S,owned),commands(~S,pending))
def need(value:F.Need) -> String:
  match value:
    case F.ModeRequired{}:"ModeRequired"
def needs(values:List<&2,F.Need>) -> String:List.show(&2,F.Need,need,values)
def selector(~S:Data,value:B.Selector<S,F.Mode,U32>) -> String:
  match value:
    case B.ExitFrom{value}:"ExitFrom{" ++ U32.show(value) ++ "}"
    case B.TransitionPair{from,to}:"TransitionPair{from=" ++ U32.show(from) ++ ";to=" ++ U32.show(to) ++ "}"
    case B.EnterTo{value}:"EnterTo{" ++ U32.show(value) ++ "}"
def phase(value:H.Phase) -> String:
  match value:
    case H.Exit{}:"Exit"
    case H.Transition{}:"Transition"
    case H.Enter{}:"Enter"
def status(value:B.Status<F.Need>) -> String:
  match value:
    case B.Completed{}:"Completed"
    case B.HandlerFailed{value,error}:"HandlerFailed{phase=" ++ phase(value) ++ ";error=" ++ error ++ "}"
    case B.MissingRequirements{values}:"MissingRequirements{" ++ needs(values) ++ "}"
    case B.ForeignBundle{}:"ForeignBundle"
    case B.MachineUnavailable{}:"MachineUnavailable"
def tx_outcome(value:T.Outcome<String>) -> String:
  match value:
    case T.Success{}:"Success"
    case T.Failure{error}:"Failure{" ++ error ++ "}"
def HandlerEntry(~S:Data) -> Type:H.Entry<S,Unit,F.Resources(~S),Unit,U32,F.runner(~S)>
def handler_entry(~S:Data,value:HandlerEntry(~S)) -> HandlerEntry(~S) & String:
  match value:
    case H.Entry{+ordinal,Sys.Registry{+ns,+id,+name,+access,+cursor}}:(H.Entry{ordinal,Sys.Registry{ns,id,name,access,cursor}},"handler{ordinal=" ++ U32.show(ordinal) ++ ";registry{namespace=" ++ U32.show(ns) ++ ";id=" ++ U32.show(id) ++ ";name=" ++ name ++ ";access=" ++ strings(access) ++ ";cursor=" ++ U32.show(cursor) ++ "}}")
def handler_entries_join(~S:Data,head:HandlerEntry(~S) & String,tail:List<HandlerEntry(~S)> & String) -> List<HandlerEntry(~S)> & String:
  (head,ht)=head
  (tail,tt)=tail
  (head <> tail,ht ++ ";" ++ tt)
def handler_entries(~S:Data,values:List<HandlerEntry(~S)>) -> List<HandlerEntry(~S)> & String:
  match values:
    case []:([],"[]")
    case head <> tail:handler_entries_join(~S,handler_entry(~S,head),handler_entries(~S,tail))
def scheduled_join(~S:Data,+selected:B.Selector<S,F.Mode,U32>,+required:List<&2,F.Need>,observed:HandlerEntry(~S) & String) -> F.Entry(~S) & String:
  (entry,text)=observed
  (B.Scheduled{selected,required,entry},"scheduled{selector=" ++ selector(~S,selected) ++ ";requirements=" ++ needs(required) ++ ";" ++ text ++ "}")
def scheduled(~S:Data,value:F.Entry(~S)) -> F.Entry(~S) & String:
  match value:
    case B.Scheduled{selected,required,entry}:scheduled_join(~S,selected,required,handler_entry(~S,entry))
def entries_join(~S:Data,head:F.Entry(~S) & String,tail:List<F.Entry(~S)> & String) -> List<F.Entry(~S)> & String:
  (head,ht)=head
  (tail,tt)=tail
  (head <> tail,ht ++ ";" ++ tt)
def entries(~S:Data,values:List<F.Entry(~S)>) -> List<F.Entry(~S)> & String:
  match values:
    case []:([],"[]")
    case head <> tail:entries_join(~S,scheduled(~S,head),entries(~S,tail))
def bundle_join(~S:Data,+ns:U32,observed:List<F.Entry(~S)> & String) -> F.Bundle(~S) & String:
  (items,text)=observed
  (B.Bundle{ns,items},"bundle{namespace=" ++ U32.show(ns) ++ ";entries=" ++ text ++ "}")
def bundle(~S:Data,value:F.Bundle(~S)) -> F.Bundle(~S) & String:
  match value:
    case B.Bundle{ns,items}:bundle_join(~S,ns,entries(~S,items))
def choice(value:B.Choice) -> String:
  match value:
    case B.Kept{}:"Kept"
    case B.SelectedExit{}:"SelectedExit"
    case B.SelectedTransition{}:"SelectedTransition"
    case B.SelectedEnter{}:"SelectedEnter"
def recovery_position(~S:Data,value:B.Position<S,F.Mode,U32,F.Need>) -> String:
  match value:
    case B.Position{selected,required,value}:"Position{selector=" ++ selector(~S,selected) ++ ";requirements=" ++ needs(required) ++ ";choice=" ++ choice(value) ++ "}"
def HandlerOwners(~S:Data) -> Type:H.Owners<S,Unit,F.Resources(~S),Unit,U32,F.runner(~S)>
def handler_owners_join(~S:Data,exit:List<HandlerEntry(~S)> & String,transition:List<HandlerEntry(~S)> & String,enter:List<HandlerEntry(~S)> & String) -> HandlerOwners(~S) & String:
  (exit,xt)=exit
  (transition,tt)=transition
  (enter,et)=enter
  (H.Owners{exit,transition,enter},"handlerOwners{exit=" ++ xt ++ ";transition=" ++ tt ++ ";enter=" ++ et ++ "}")
def handler_owners(~S:Data,value:HandlerOwners(~S)) -> HandlerOwners(~S) & String:
  match value:
    case H.Owners{exit,transition,enter}:handler_owners_join(~S,handler_entries(~S,exit),handler_entries(~S,transition),handler_entries(~S,enter))
def Recovery(~S:Data) -> Type:B.Recovery<S,F.Mode,U32,F.Need,Unit,F.Resources(~S),Unit,F.runner(~S)>
def recovery_join(~S:Data,+positions:List<&2,B.Position<S,F.Mode,U32,F.Need>>,items:List<F.Entry(~S)> & String,kept:List<HandlerEntry(~S)> & String,owners:HandlerOwners(~S) & String) -> Recovery(~S) & String:
  (items,it)=items
  (kept,kt)=kept
  (owners,ot)=owners
  (B.Recovery{items,positions,kept,owners},"recovery{entries=" ++ it ++ ";positions=" ++ List.show(&2,B.Position<S,F.Mode,U32,F.Need>,recovery_position(~S),positions) ++ ";kept=" ++ kt ++ ";" ++ ot ++ "}")
def recovery(~S:Data,value:Recovery(~S)) -> Recovery(~S) & String:
  match value:
    case B.Recovery{items,positions,kept,owners}:recovery_join(~S,positions,entries(~S,items),handler_entries(~S,kept),handler_owners(~S,owners))
def BundleResult(~S:Data) -> Type:B.BundleResult<S,F.Mode,U32,F.Need,Unit,F.Resources(~S),Unit,F.runner(~S)>
def result_returned(~S:Data,+value:B.Status<F.Need>,owned:F.Bundle(~S) & String,current:F.World(~S) & String) -> BundleResult(~S) & String:
  (owned,bt)=owned
  (current,wt)=current
  (B.Returned{owned,current,value},"Returned{status=" ++ status(value) ++ ";" ++ bt ++ ";" ++ wt ++ "}")
def result_remainder(~S:Data,+ns:U32,+value:B.Status<F.Need>,owned:Recovery(~S) & String,current:F.World(~S) & String) -> BundleResult(~S) & String:
  (owned,rt)=owned
  (current,wt)=current
  (B.InternalOwnerRemainder{ns,owned,current,value},"InternalOwnerRemainder{namespace=" ++ U32.show(ns) ++ ";status=" ++ status(value) ++ ";" ++ rt ++ ";" ++ wt ++ "}")
def bundle_result(~S:Data,value:BundleResult(~S)) -> BundleResult(~S) & String:
  match value:
    case B.Returned{owned,current,value}:result_returned(~S,value,bundle(~S,owned),world(~S,current))
    case B.InternalOwnerRemainder{ns,owned,current,value}:result_remainder(~S,ns,value,recovery(~S,owned),world(~S,current))
def MarkerResult(~S:Data) -> Type:Operation.MarkerResult<S,F.Mode,U32,F.Need,Unit,F.Resources(~S),Unit,F.runner(~S)>
def marker_join(~S:Data,+steps:List<&2,Sch.Step>,+seen:List<&2,Sch.Observation>,observed:BundleResult(~S) & String) -> MarkerResult(~S) & String:
  (result,text)=observed
  (Operation.MarkerResult{result,steps,seen},"marker{" ++ text ++ ";steps=" ++ List.show(&2,Sch.Step,step,steps) ++ ";observations=" ++ observations(seen) ++ "}")
def marker(~S:Data,value:MarkerResult(~S)) -> MarkerResult(~S) & String:
  match value:
    case Operation.MarkerResult{result,steps,seen}:marker_join(~S,steps,seen,bundle_result(~S,result))
def app_join(~S:Data,+name:String,+debug:Bool,current:F.World(~S) & String,owned:F.Bundle(~S) & String,extra:Array<U32> & String) -> F.Application(~S) & String:
  (current,wt)=current
  (owned,bt)=owned
  (extra,et)=extra
  (App.Application{current,owned,Ordinary.Declaration{name},extra,debug},"app{declaration=" ++ name ++ ";debug=" ++ Bool.show(debug) ++ ";" ++ wt ++ ";" ++ bt ++ ";extra=" ++ et ++ "}")
def app_recovering(~S:Data,+name:String,+debug:Bool,result:MarkerResult(~S) & String,extra:Array<U32> & String) -> F.Application(~S) & String:
  (result,rt)=result
  (extra,et)=extra
  (App.Recovering{result,Ordinary.Declaration{name},extra,debug},"appRecovering{declaration=" ++ name ++ ";debug=" ++ Bool.show(debug) ++ ";" ++ rt ++ ";extra=" ++ et ++ "}")
def app(~S:Data,value:F.Application(~S)) -> F.Application(~S) & String:
  match value:
    case App.Application{current,owned,Ordinary.Declaration{name},extra,debug}:app_join(~S,name,debug,world(~S,current),bundle(~S,owned),u32_array(extra))
    case App.Recovering{result,Ordinary.Declaration{name},extra,debug}:app_recovering(~S,name,debug,marker(~S,result),u32_array(extra))
def entry_view(~S:Data,value:App.EntryView<S,F.Mode,U32,F.Need>) -> String:
  match value:
    case App.EntryView{selected,required,ns,ordinal,id,name,access,cursor}:"entryView{selector=" ++ selector(~S,selected) ++ ";requirements=" ++ needs(required) ++ ";namespace=" ++ U32.show(ns) ++ ";ordinal=" ++ U32.show(ordinal) ++ ";id=" ++ U32.show(id) ++ ";name=" ++ name ++ ";access=" ++ strings(access) ++ ";cursor=" ++ U32.show(cursor) ++ "}"
def snapshot(~S:Data,value:Maybe<&2,App.Description<S,F.Mode,U32,F.Need>>) -> String:
  match value:
    case None{}:"None"
    case Some{App.Description{ns,name,steps,items}}:"Some{namespace=" ++ U32.show(ns) ++ ";name=" ++ name ++ ";steps=" ++ List.show(&2,Sch.Step,step,steps) ++ ";entries=" ++ List.show(&2,App.EntryView<S,F.Mode,U32,F.Need>,entry_view(~S),items) ++ "}"
def setup_plan(~S:Data,value:F.Plan<S>) -> String:
  match value:
    case F.Plan{selected,ordinal,name}:"Plan{selector=" ++ selector(~S,selected) ++ ";ordinal=" ++ U32.show(ordinal) ++ ";name=" ++ name ++ "}"
def setup_ready(~S:Data,observed:F.Application(~S) & String) -> F.Setup<S> & String:
  (value,text)=observed
  (F.Ready{value},"Ready{" ++ text ++ "}")
def setup_rejected(~S:Data,+plans:List<&2,F.Plan<S>>,current:F.World(~S) & String,owned:List<F.Entry(~S)> & String) -> F.Setup<S> & String:
  (current,wt)=current
  (owned,et)=owned
  (F.Rejected{current,owned,plans},"Rejected{" ++ wt ++ ";entries=" ++ et ++ ";plans=" ++ List.show(&2,F.Plan<S>,setup_plan(~S),plans) ++ "}")
def setup(~S:Data,value:F.Setup<S>) -> F.Setup<S> & String:
  match value:
    case F.Ready{value}:setup_ready(~S,app(~S,value))
    case F.Rejected{current,owned,plans}:setup_rejected(~S,plans,world(~S,current),entries(~S,owned))
