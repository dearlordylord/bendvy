import Base
import ../parallel-captures/scheduled.bend as Existing
import ../parallel-captures/declarations.bend as D
import ../parallel-captures/bodies.bend as Body
import ../parallel-captures/contexts.bend as Context
import ../parallel-captures/payloads.bend as P
import ../parallel-captures/reports.bend as Common
import ../parallel-persistence/observation.bend as Basic
import ../parallel-persistence/extended-observation-data.bend as Data
import ../../src/ecs/inspector.bend as I
import ../../src/ecs/execution-capture.bend as Capture
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/world.bend as W
import ../../src/ecs/entity-allocator.bend as Allocator
import ../../src/ecs/clock-state.bend as Clock
import ../../src/ecs/execution-lifecycle-notices.bend as Notice
import ../../src/ecs/lifecycle.bend as Life
import ../../src/ecs/deferred-command.bend as Deferred
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/dependency-application.bend as State
import ../../src/ecs/dependency-plan.bend as Plan
import ../../src/ecs/execution-parallel-root-application.bend as App
import ../../src/ecs/execution-parallel-registration.bend as Part
import ../../src/ecs/execution-trace.bend as Trace

def instance(~S:Data,value:I.Instance<S>) -> I.Instance<S> & String:
  match value:
    case I.Fresh{}:(I.Fresh{},"fresh")
    case I.Active{+cursor,+registeredAt}:(I.Active{cursor,registeredAt},"active(cursor=" ++ Basic.maybe_tick(cursor) ++ ",registeredAt=" ++ Tick.show(registeredAt) ++ ")")
def result(value:Result<&2,&2,String,String>) -> String:
  match value:
    case Done{value}:"done(" ++ value ++ ")"
    case Fail{error}:"fail(" ++ error ++ ")"
def report(value:State.Report<String,String>) -> String:Basic.report(value)
def status(value:Trace.Status<String>) -> String:
  match value:
    case Trace.SystemOk{}:"ok"
    case Trace.SystemError{error}:"error(" ++ error ++ ")"
def completion(value:Trace.Completion<String>) -> String:
  match value:
    case Trace.EndOk{}:"ok"
    case Trace.EndFailed{error}:"failed(" ++ error ++ ")"
    case Trace.EndRejected{}:"rejected"
    case Trace.EndMissing{}:"missing"
def trace_event(value:Trace.TraceEvent<String>) -> String:
  match value:
    case Trace.SystemOutcome{id,value}:"system(" ++ U32.show(id) ++ "," ++ status(value) ++ ")"
    case Trace.ConditionOutcome{id,value}:"condition(" ++ U32.show(id) ++ "," ++ status(value) ++ ")"
    case Trace.InvocationRefused{id}:"invocation-refused(" ++ U32.show(id) ++ ")"
    case Trace.ConditionRefused{id}:"condition-refused(" ++ U32.show(id) ++ ")"
    case Trace.SystemSkipped{id}:"skipped(" ++ U32.show(id) ++ ")"
    case Trace.DependencyObserved{before,after}:"dependency(" ++ U32.show(before) ++ "," ++ U32.show(after) ++ ")"
    case Trace.ScheduleEnded{value}:"end(" ++ completion(value) ++ ")"
    case _:"unobserved-trace-variant"
def batch(value:Trace.Batch<String>) -> String:
  match value:
    case Trace.Disabled{}:"disabled"
    case Trace.BendvyReady{events}:"ready" ++ List.show(&2,Trace.TraceEvent<String>,trace_event,events)

def count_capture(result:Array<U32> & String) -> Context.Count() & String:
  match result:
    case (context,text):(Capture.Captured{context},"context=" ++ text ++ ":step=opaque")
def count(value:Context.Count()) -> Context.Count() & String:
  match value:
    case Capture.Captured{context}:count_capture(Data.u32_array(context))
def text_words(token:Array<U32>,text:String,result:Array<String> & String) -> Context.TextContext & String:
  match result:
    case (words,other):(Context.TextContext{token,words},"token=" ++ text ++ ":words=" ++ other)
def text_token(words:Array<String>,result:Array<U32> & String) -> Context.TextContext & String:
  match result:
    case (token,text):text_words(token,text,Data.array_retained(~String,~(value => Data.data_retained(String,(x => x),value)),words))
def text_context(value:Context.TextContext) -> Context.TextContext & String:
  match value:
    case Context.TextContext{token,words}:text_token(words,Data.u32_array(token))
def text_capture(result:Context.TextContext & String) -> Context.Text() & String:
  match result:
    case (context,text):(Capture.Captured{context},"context={" ++ text ++ "}:step=opaque")
def text_retained(value:Context.Text()) -> Context.Text() & String:
  match value:
    case Capture.Captured{context}:text_capture(text_context(context))
def left_capture(state:Array<U32>,text:String,result:Context.Count() & String) -> Body.LeftLocal() & String:
  match result:
    case (capture,other):(Capture.Local{state,capture},"state=" ++ text ++ ":capture={" ++ other ++ "}")
def left_state(capture:Context.Count(),result:Array<U32> & String) -> Body.LeftLocal() & String:
  match result:
    case (state,text):left_capture(state,text,count(capture))
def left_local(value:Body.LeftLocal()) -> Body.LeftLocal() & String:
  match value:
    case Capture.Local{state,capture}:left_state(capture,Data.u32_array(state))
def right_capture(state:Array<U32>,text:String,result:Context.Text() & String) -> Body.RightLocal() & String:
  match result:
    case (capture,other):(Capture.Local{state,capture},"state=" ++ text ++ ":capture={" ++ other ++ "}")
def right_state(capture:Context.Text(),result:Array<U32> & String) -> Body.RightLocal() & String:
  match result:
    case (state,text):right_capture(state,text,text_retained(capture))
def right_local(value:Body.RightLocal()) -> Body.RightLocal() & String:
  match value:
    case Capture.Local{state,capture}:right_state(capture,Data.u32_array(state))
def left_values(~S:Data,+namespace:U32,+id:U32,+name:String,+access:List<&2,String>,+cursor:Maybe<&2,Tick.Tick>,result:Body.LeftLocal() & String) -> Existing.LeftOwner(~S) & String:
  match result:
    case (local,text):(Sys.Owner{namespace,id,name,access,cursor,local},Basic.system_header(namespace,id,name,access,cursor) ++ ":local={" ++ text ++ "}")
def left(~S:Data,value:Existing.LeftOwner(~S)) -> Existing.LeftOwner(~S) & String:
  match value:
    case Sys.Owner{namespace,id,name,access,cursor,local}:left_values(~S,namespace,id,name,access,cursor,left_local(local))
def right_values(~S:Data,+namespace:U32,+id:U32,+name:String,+access:List<&2,String>,+cursor:Maybe<&2,Tick.Tick>,result:Body.RightLocal() & String) -> Existing.RightOwner(~S) & String:
  match result:
    case (local,text):(Sys.Owner{namespace,id,name,access,cursor,local},Basic.system_header(namespace,id,name,access,cursor) ++ ":local={" ++ text ++ "}")
def right(~S:Data,value:Existing.RightOwner(~S)) -> Existing.RightOwner(~S) & String:
  match value:
    case Sys.Owner{namespace,id,name,access,cursor,local}:right_values(~S,namespace,id,name,access,cursor,right_local(local))
def handler_values(+errors:U32,result:Array<U32> & String) -> Common.Handler & String:
  match result:
    case (token,text):(Common.Handler{token,errors},"token=" ++ text ++ ":errors=" ++ U32.show(errors))
def handler(value:Common.Handler) -> Common.Handler & String:
  match value:
    case Common.Handler{token,errors}:handler_values(errors,Data.u32_array(token))

def counter_values(+value:U32,result:Array<U32> & String) -> P.Counter & String:
  match result:
    case (token,text):(P.Counter{token,value},"token=" ++ text ++ ":value=" ++ U32.show(value))
def counter(value:P.Counter) -> P.Counter & String:
  match value:
    case P.Counter{token,value}:counter_values(value,Data.u32_array(token))
def score_values(+value:U32,result:Array<U32> & String) -> P.Score & String:
  match result:
    case (token,text):(P.Score{token,value},"token=" ++ text ++ ":value=" ++ U32.show(value))
def score(value:P.Score) -> P.Score & String:
  match value:
    case P.Score{token,value}:score_values(value,Data.u32_array(token))
def counter_slot_values(~S:Data,+cache:String,+stamp:Life.Stamp,result:P.Counter & String) -> D.LeftResource(~S) & String:
  match result:
    case (owner,text):(Layout.ResourceSlot{Layout.Viewed{owner,cache},stamp},"counter={" ++ text ++ ":cache=" ++ cache ++ ":stamp=" ++ Basic.stamp(stamp) ++ "}")
def counter_slot(~S:Data,value:D.LeftResource(~S)) -> D.LeftResource(~S) & String:
  match value:
    case Layout.ResourceSlot{Layout.Viewed{owner,cache},stamp}:counter_slot_values(~S,cache,stamp,counter(owner))
def score_slot_values(~S:Data,+cache:String,+stamp:Life.Stamp,result:P.Score & String) -> D.RightResource(~S) & String:
  match result:
    case (owner,text):(Layout.ResourceSlot{Layout.Viewed{owner,cache},stamp},"score={" ++ text ++ ":cache=" ++ cache ++ ":stamp=" ++ Basic.stamp(stamp) ++ "}")
def score_slot(~S:Data,value:D.RightResource(~S)) -> D.RightResource(~S) & String:
  match value:
    case Layout.ResourceSlot{Layout.Viewed{owner,cache},stamp}:score_slot_values(~S,cache,stamp,score(owner))
def resources(~S:Data,value:D.Resources(~S)) -> D.Resources(~S) & String:
  Data.pair(D.LeftResource(~S),D.RightResource(~S),counter_slot(~S),score_slot(~S),value)
def deferred(~S:Data,value:Deferred.Command<Existing.World(~S)>) -> Deferred.Command<Existing.World(~S)> & String:
  match value:
    case Deferred.Raw{callback}:(Deferred.Raw{callback},"raw(callback=opaque)")
    case Deferred.Observed{callback}:(Deferred.Observed{callback},"observed(callback=opaque)")
type AllocatorRest<-S:Data> is Type:AllocatorRest{namespace:U32,store:D.Store(~S),resources:D.Resources(~S),events:List<&2,Unit>,pending:List<Deferred.Command<Existing.World(~S)>>,registrations:List<&2,W.RegistrationMeta>,next:U32,clock:Clock.State,lifecycle:Notice.Journal<S>}
def world_allocator_values(~S:Data,rest:AllocatorRest<S>,text:String,result:Allocator.Allocator & String) -> Existing.World(~S) & String:
  match rest result:
    case AllocatorRest{namespace,store,resources,events,pending,registrations,next,clock,lifecycle}, (allocator,other):(W.World{namespace,allocator,store,resources,events,pending,registrations,next,clock,lifecycle},text ++ "/allocator=" ++ other)
def world_allocator(~S:Data,result:Existing.World(~S) & String) -> Existing.World(~S) & String:
  match result:
    case (W.World{namespace,allocator,store,resources,events,pending,registrations,next,clock,lifecycle},text):world_allocator_values(~S,AllocatorRest{namespace,store,resources,events,pending,registrations,next,clock,lifecycle},text,Data.allocator(allocator))
type PendingRest<-S:Data> is Type:PendingRest{namespace:U32,allocator:Allocator.Allocator,store:D.Store(~S),resources:D.Resources(~S),events:List<&2,Unit>,registrations:List<&2,W.RegistrationMeta>,next:U32,clock:Clock.State,lifecycle:Notice.Journal<S>}
type JournalRest<-S:Data> is Type:JournalRest{namespace:U32,allocator:Allocator.Allocator,store:D.Store(~S),resources:D.Resources(~S),events:List<&2,Unit>,pending:List<Deferred.Command<Existing.World(~S)>>,registrations:List<&2,W.RegistrationMeta>,next:U32,clock:Clock.State}
def world_journal_values(~S:Data,rest:JournalRest<S>,text:String,pendingText:String,result:Notice.Journal<S> & String) -> Existing.World(~S) & String:
  match rest result:
    case JournalRest{+namespace,allocator,Product.Owner{Unit{},Unit{}},resources,+events,pending,+registrations,+next,+clock}, (lifecycle,other):(W.World{namespace,allocator,Product.Owner{Unit{},Unit{}},resources,events,pending,registrations,next,clock,lifecycle},"namespace=" ++ U32.show(namespace) ++ "/store=pair(unit,unit)/resources=" ++ text ++ "/events=" ++ List.show(&2,Unit,(_ => "unit"),events) ++ "/pending=" ++ pendingText ++ "/registrations=" ++ List.show(&2,W.RegistrationMeta,Basic.registration,registrations) ++ "/nextSystem=" ++ U32.show(next) ++ "/clock=" ++ Basic.clock(clock) ++ "/lifecycle=" ++ other)
def world_pending_values(~S:Data,rest:PendingRest<S>,text:String,result:List<Deferred.Command<Existing.World(~S)>> & String) -> Existing.World(~S) & String:
  match rest result:
    case PendingRest{namespace,allocator,store,resources,events,registrations,next,clock,lifecycle}, (pending,other):world_journal_values(~S,JournalRest{namespace,allocator,store,resources,events,pending,registrations,next,clock},text,other,Data.journal_retained(~S,lifecycle))
def world_pending(~S:Data,result:Existing.World(~S) & String) -> Existing.World(~S) & String:
  match result:
    case (W.World{namespace,allocator,store,resources,events,pending,registrations,next,clock,lifecycle},text):world_pending_values(~S,PendingRest{namespace,allocator,store,resources,events,registrations,next,clock,lifecycle},text,Data.list_retained(~Deferred.Command<Existing.World(~S)>,~deferred(~S),pending))
def world(~S:Data,value:Existing.World(~S)) -> Existing.World(~S) & String:
  world_pending(~S,world_allocator(~S,W.observe_resource(~S,~D.Store(~S),~D.Resources(~S),~Unit,~String,~resources(~S),value)))

def compatible_row(+rules:Part.Rules,+left:U32,entries:List<&2,Part.Entry>) -> List<&2,String>:
  match entries:
    case []:[]
    case Part.Entry{+right,_} <> rest:(U32.show(left) ++ "/" ++ U32.show(right) ++ "=" ++ Bool.show(Part.compatible(rules,left,right))) <> compatible_row(rules,left,rest)
def compatibility_entries(+rules:Part.Rules,entries:List<&2,Part.Entry>) -> List<&2,String>:
  match entries:
    case []:[]
    case Part.Entry{left,_} <> +rest:List.append(&2,String,compatible_row(rules,left,rest),compatibility_entries(rules,rest))
def compatibility(+rules:Part.Rules) -> String:
  match rules:
    case Part.Rules{entries}:List.show(&2,String,(x => x),compatibility_entries(rules,entries))
def schedule(plan:Plan.Build<String>,stateBindings:List<&2,State.Binding>,appBindings:List<&2,State.Binding>,+rules:Part.Rules,deferred:App.Deferred) -> String:
  "stateBindings=" ++ List.show(&2,State.Binding,Basic.binding_app,stateBindings) ++ "/plan=" ++ Basic.plan(plan) ++ "/appBindings=" ++ List.show(&2,State.Binding,Basic.binding_app,appBindings) ++ "/rules=" ++ Basic.rules(rules) ++ "/compatibility=" ++ compatibility(rules) ++ "/deferred=" ++ Basic.scheduled_deferred(deferred)
def owners(~S:Data,value:Product.Owner<Existing.LeftTree(~S),Existing.RightOwner(~S)>) -> Product.Owner<Existing.LeftTree(~S),Existing.RightOwner(~S)> & String:
  Data.pair(Existing.LeftTree(~S),Existing.RightOwner(~S),Data.pair(Existing.LeftOwner(~S),Existing.LeftOwner(~S),left(~S),left(~S)),right(~S),value)
type StateRest<-S:Data> is Type:StateRest{world:Existing.World(~S),guards:Unit,handler:Common.Handler,bindings:List<&2,State.Binding>}
def state_owners_values(~S:Data,rest:StateRest<S>,result:Product.Owner<Existing.LeftTree(~S),Existing.RightOwner(~S)> & String) -> State.State<Existing.World(~S),Product.Owner<Existing.LeftTree(~S),Existing.RightOwner(~S)>,Unit,Common.Handler> & String:
  match rest result:
    case StateRest{world,guards,handler,bindings}, (owners,text):(State.State{world,owners,guards,handler,bindings},"owners=" ++ text)
def state_owners(~S:Data,value:State.State<Existing.World(~S),Product.Owner<Existing.LeftTree(~S),Existing.RightOwner(~S)>,Unit,Common.Handler>) -> State.State<Existing.World(~S),Product.Owner<Existing.LeftTree(~S),Existing.RightOwner(~S)>,Unit,Common.Handler> & String:
  match value:
    case State.State{world,values,guards,handler,bindings}:state_owners_values(~S,StateRest{world,guards,handler,bindings},owners(~S,values))
type HandlerRest<-S:Data> is Type:HandlerRest{world:Existing.World(~S),owners:Product.Owner<Existing.LeftTree(~S),Existing.RightOwner(~S)>,guards:Unit,bindings:List<&2,State.Binding>}
def state_handler_values(~S:Data,rest:HandlerRest<S>,text:String,result:Common.Handler & String) -> State.State<Existing.World(~S),Product.Owner<Existing.LeftTree(~S),Existing.RightOwner(~S)>,Unit,Common.Handler> & String:
  match rest result:
    case HandlerRest{world,owners,guards,bindings}, (handler,other):(State.State{world,owners,guards,handler,bindings},text ++ "/handler=" ++ other)
def state_handler(~S:Data,result:State.State<Existing.World(~S),Product.Owner<Existing.LeftTree(~S),Existing.RightOwner(~S)>,Unit,Common.Handler> & String) -> State.State<Existing.World(~S),Product.Owner<Existing.LeftTree(~S),Existing.RightOwner(~S)>,Unit,Common.Handler> & String:
  match result:
    case (State.State{world,owners,guards,value,bindings},text):state_handler_values(~S,HandlerRest{world,owners,guards,bindings},text,handler(value))
type OwnersRest<-S:Data> is Type:OwnersRest{owners:Product.Owner<Existing.LeftTree(~S),Existing.RightOwner(~S)>,guards:Unit,handler:Common.Handler,bindings:List<&2,State.Binding>}
def state_world_values(~S:Data,rest:OwnersRest<S>,text:String,result:Existing.World(~S) & String) -> State.State<Existing.World(~S),Product.Owner<Existing.LeftTree(~S),Existing.RightOwner(~S)>,Unit,Common.Handler> & String:
  match rest result:
    case OwnersRest{owners,Unit{},handler,bindings}, (world,other):(State.State{world,owners,Unit{},handler,bindings},text ++ "/guards=unit/world={" ++ other ++ "}")
def state_world(~S:Data,result:State.State<Existing.World(~S),Product.Owner<Existing.LeftTree(~S),Existing.RightOwner(~S)>,Unit,Common.Handler> & String) -> State.State<Existing.World(~S),Product.Owner<Existing.LeftTree(~S),Existing.RightOwner(~S)>,Unit,Common.Handler> & String:
  match result:
    case (State.State{value,owners,guards,handler,bindings},text):state_world_values(~S,OwnersRest{owners,guards,handler,bindings},text,world(~S,value))
type AppRest is Data:AppRest{plan:Plan.Build<String>,bindings:List<&2,State.Binding>,rules:Part.Rules,deferred:App.Deferred}
def application_values(~S:Data,rest:AppRest,result:State.State<Existing.World(~S),Product.Owner<Existing.LeftTree(~S),Existing.RightOwner(~S)>,Unit,Common.Handler> & String) -> Existing.Application(~S) & String:
  match rest result:
    case AppRest{+plan,+bindings,+rules,+deferred}, (State.State{world,owners,guards,handler,+stateBindings},text):(App.Scheduled{State.State{world,owners,guards,handler,stateBindings},plan,bindings,rules,deferred},text ++ "/" ++ schedule(plan,stateBindings,bindings,rules,deferred))
def application(~S:Data,value:Existing.Application(~S)) -> Existing.Application(~S) & String:
  match value:
    case App.Scheduled{state,plan,bindings,rules,deferred}:application_values(~S,AppRest{plan,bindings,rules,deferred},state_world(~S,state_handler(~S,state_owners(~S,state))))
