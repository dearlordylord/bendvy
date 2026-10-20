import Base
import ./change-tick.bend as Tick
import ./machine-world.bend as MachineWorld
import ./ordinary-app-execution-run.bend as ExecuteRun
import ./machine-handler-engine.bend as HandlerEngine
import ./machine-handlers.bend as Handlers
import ./machine.bend as Machine
import ./ordinary-machine-declaration.bend as MachineDecl
import ./ordinary-app-resource-field-declaration.bend as FieldDecl
import ./ordinary-resource-field-system.bend as FieldSystem
import ./transaction.bend as Transaction
import ./execution-context.bend as Ctx
import ./trace-facts.bend as Facts
import ./execution-trace.bend as Trace
import ./ordinary-app-schedule.bend as Single
import ./ordinary-app-schema.bend as App
import ./ordinary-app-composer.bend as Build
import ./ordinary-app-recipe.bend as Tree
import ./ordinary-app-registration-fields.bend as Records
import ./ordinary-app-observation-data.bend as DTO
import ./ordinary-schema.bend as Schema
import ./world.bend as W
import ./system.bend as Sys
import ./schedule.bend as Sch
import ./schedule-provision.bend as SP

# A detached batch is returned only after its actual ECS run has completed.
# Execution returns a retained application result and a detached trace batch.
# Inspect result for Finished/Failed/Rejected/Missing; tracing is Disabled or
# Ready according to the actual run. Subscribers process the copied batch
# afterward; external printing/file IO is outside ECS rollback.
# Example: examples/scheduled-health/application.bend, ran().
type Run<A:Type,S:Data,Error:Data> is Type:
  Run{result:Single.RunResult<A,S,Error>,batch:Trace.Batch<Error>}
type Journal<Error:Data> is Data:
  Journal{catalog:List<&2,Trace.Identity>,events:List<&2,Trace.TraceEvent<Error>>}
def catalog(~S:Data,fields:List<&2,Records.Fields<S>>) -> List<&2,Trace.Identity>:
  match fields:
    case []:[]
    case Records.Fields{namespace,id,name,_,_,_,_,_} <> rest:Trace.Identity{namespace,id,Some{name}} <> catalog(~S,rest)
def named(found:Bool,name:Maybe<&2,String>,next:Unit -> Maybe<&2,String>) -> Maybe<&2,String>:
  match found:
    case True{}:name
    case False{}:next(Unit{})
def registration_name(items:List<&2,Trace.Identity>,+id:U32) -> Maybe<&2,String>:
  match items:
    case []:None{}
    case Trace.Identity{_,candidate,name} <> rest:named(U32.is_eq(candidate,id),name,_ => registration_name(rest,id))
def identity_clock(~S:Data,~C:Type,~R:Type,~E:Data,namespace:U32,id:U32,name:Maybe<&2,String>,observed:W.World<S,C,R,E> & Tick.Tick) -> W.World<S,C,R,E> & (Trace.Identity & Tick.Tick):
  match observed:
    case (world,clock):(world,(Trace.Identity{namespace,id,name},clock))
def identity_namespace(~S:Data,~C:Type,~R:Type,~E:Data,id:U32,name:Maybe<&2,String>,observed:W.World<S,C,R,E> & U32) -> W.World<S,C,R,E> & (Trace.Identity & Tick.Tick):
  match observed:
    case (world,namespace):identity_clock(~S,~C,~R,~E,namespace,id,name,W.clock(~S,~C,~R,~E,world))
def identity(~S:Data,~C:Type,~R:Type,~E:Data,~Error:Data,journal:Journal<Error>,world:W.World<S,C,R,E>,+id:U32) -> W.World<S,C,R,E> & (Trace.Identity & Tick.Tick):
  match journal:
    case Journal{catalog,_}:identity_namespace(~S,~C,~R,~E,id,registration_name(catalog,id),W.namespace(~S,~C,~R,~E,world))
def record(~Error:Data,event:Trace.TraceEvent<Error>,journal:Journal<Error>) -> Journal<Error>:
  match journal:
    case Journal{catalog,events}:Journal{catalog,event <> events}
def succeeded(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Error:Data,owners:H,fact:Trace.Identity,before:Tick.Tick,journal:Journal<Error>,observed:W.World<S,C,R,E> & Tick.Tick) -> (H & Journal<Error>) & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>:
  match observed:
    case (world,after):((owners,record(~Error,Trace.SystemCompleted{fact,before,after,Trace.SystemOk{}},journal)),Sys.Succeeded{world,Unit{}})
def failed(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Error:Data,owners:H,fact:Trace.Identity,before:Tick.Tick,journal:Journal<Error>,+error:Error,observed:W.World<S,C,R,E> & Tick.Tick) -> (H & Journal<Error>) & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>:
  match observed:
    case (world,after):((owners,record(~Error,Trace.SystemCompleted{fact,before,after,Trace.SystemError{error}},journal)),Sys.Failed{world,error})
def record_operations(~Error:Data,facts:List<&2,Facts.Fact>,+identity:Trace.Identity,journal:Journal<Error>) -> Journal<Error>:
  match facts:
    case []:journal
    case fact <> rest:record_operations(~Error,rest,identity,record(~Error,Trace.OperationObserved{identity,fact},journal))
def record_barrier_operations(~Error:Data,facts:List<&2,Facts.Fact>,journal:Journal<Error>) -> Journal<Error>:
  match facts:
    case []:journal
    case fact <> rest:record_barrier_operations(~Error,rest,record(~Error,Trace.BarrierOperationObserved{fact},journal))
def barrier_returned(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Error:Data,owners:H,journal:Journal<Error>,result:W.World<S,C,R,E> & Facts.State) -> (H & Journal<Error>) & W.World<S,C,R,E>:
  match result:
    case (world,trace):((owners,record_barrier_operations(~Error,Facts.facts(trace),journal)),world)
def barrier_recorded(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Error:Data,owners:H & Journal<Error>,world:W.World<S,C,R,E>) -> (H & Journal<Error>) & W.World<S,C,R,E>:
  match owners:
    case (owners,journal):barrier_returned(~S,~C,~R,~E,~H,~Error,owners,journal,W.barrier_traced(~S,~C,~R,~E,world,Facts.On{[]}))
def dispatched(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Error:Data,+fact:Trace.Identity,before:Tick.Tick,journal:Journal<Error>,result:H & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,Error,Unit>) -> (H & Journal<Error>) & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>:
  match result:
    case (owners,Sys.Succeeded{Ctx.Context{world,trace},_}):succeeded(~S,~C,~R,~E,~H,~Error,owners,fact,before,record_operations(~Error,Facts.facts(trace),fact,journal),W.clock(~S,~C,~R,~E,world))
    case (owners,Sys.Failed{Ctx.Context{world,trace},error}):failed(~S,~C,~R,~E,~H,~Error,owners,fact,before,record_operations(~Error,Facts.facts(trace),fact,journal),error,W.clock(~S,~C,~R,~E,world))
def identified(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Error:Data,~dispatch:H -> Ctx.Context<W.World<S,C,R,E>> -> U32 -> H & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,Error,Unit>,owners:H,journal:Journal<Error>,+id:U32,result:W.World<S,C,R,E> & (Trace.Identity & Tick.Tick)) -> (H & Journal<Error>) & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>:
  match result:
    case (world,(fact,before)):dispatched(~S,~C,~R,~E,~H,~Error,fact,before,journal,dispatch(owners,Ctx.Context{world,Facts.On{[]}},id))
def dispatch_id(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Error:Data,~dispatch:H -> Ctx.Context<W.World<S,C,R,E>> -> U32 -> H & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,Error,Unit>,owners:H & Journal<Error>,world:W.World<S,C,R,E>,+id:U32) -> (H & Journal<Error>) & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>:
  match owners:
    case (owners,+journal):identified(~S,~C,~R,~E,~H,~Error,~dispatch,owners,journal,id,identity(~S,~C,~R,~E,~Error,journal,world,id))
def dispatch_recorded(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Error:Data,~dispatch:H -> Ctx.Context<W.World<S,C,R,E>> -> U32 -> H & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,Error,Unit>,owners:H & Journal<Error>,world:W.World<S,C,R,E>,id:U32) -> (H & Journal<Error>) & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>:
  dispatch_id(~S,~C,~R,~E,~H,~Error,~dispatch,owners,world,id)
# Sch.Ran supplies position only. The completion/error comes from the actual
# dispatch result above, never from a guessed interpretation of Ran.
def ran_chunk_more(~Error:Data,event:Trace.TraceEvent<Error>,chunk:List<&2,Trace.TraceEvent<Error>> & List<&2,Trace.TraceEvent<Error>>) -> List<&2,Trace.TraceEvent<Error>> & List<&2,Trace.TraceEvent<Error>>:
  match chunk:
    case (prefix,remaining):(event <> prefix,remaining)
def ran_chunk(~Error:Data,journal:List<&2,Trace.TraceEvent<Error>>) -> List<&2,Trace.TraceEvent<Error>> & List<&2,Trace.TraceEvent<Error>>:
  match journal:
    case []:([],[])
    case Trace.OperationObserved{identity,fact} <> rest:ran_chunk_more(~Error,Trace.OperationObserved{identity,fact},ran_chunk(~Error,rest))
    case event <> rest:([event],rest)
def barrier_chunk(~Error:Data,journal:List<&2,Trace.TraceEvent<Error>>) -> List<&2,Trace.TraceEvent<Error>> & List<&2,Trace.TraceEvent<Error>>:
  match journal:
    case []:([],[])
    case Trace.BarrierOperationObserved{fact} <> rest:ran_chunk_more(~Error,Trace.BarrierOperationObserved{fact},barrier_chunk(~Error,rest))
    case event <> rest:([],event <> rest)
def merged_chunk(~Error:Data,next:List<&2,Trace.TraceEvent<Error>> -> List<&2,Trace.TraceEvent<Error>>,chunk:List<&2,Trace.TraceEvent<Error>> & List<&2,Trace.TraceEvent<Error>>) -> List<&2,Trace.TraceEvent<Error>>:
  match chunk:
    case (prefix,remaining):List.append(&2,Trace.TraceEvent<Error>,prefix,next(remaining))
def merge(~Error:Data,observations:List<&2,Sch.Observation>,journal:List<&2,Trace.TraceEvent<Error>>) -> List<&2,Trace.TraceEvent<Error>>:
  match observations journal:
    case [], journal:journal
    case Sch.Entered{name} <> rest, journal:Trace.PhaseEntered{name} <> merge(~Error,rest,journal)
    case Sch.Skipped{id} <> rest, journal:Trace.SystemSkipped{id} <> merge(~Error,rest,journal)
    case Sch.Applied{} <> rest, journal:merged_chunk(~Error,(remaining=>Trace.DeferredApplied{} <> merge(~Error,rest,remaining)),barrier_chunk(~Error,journal))
    case Sch.Ran{_} <> rest, journal:merged_chunk(~Error,(remaining=>merge(~Error,rest,remaining)),ran_chunk(~Error,journal))
def batch(~Error:Data,namespace:U32,name:String,observations:List<&2,Sch.Observation>,journal:Journal<Error>,outcome:Trace.Completion<Error>) -> Trace.Batch<Error>:
  match journal:
    case Journal{_,events}:Trace.Ready{Trace.ScheduleStarted{namespace,name} <> List.append(&2,Trace.TraceEvent<Error>,merge(~Error,observations,List.reverse(&2,Trace.TraceEvent<Error>,events)),[Trace.ScheduleEnded{outcome}])}
def restored(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~Error:Data,schema:Schema.Schema<S,C,R>,world:W.World<S,C,R,E>,owners:H,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,debug:Bool,plan:SP.Plan<S>,namespace:U32,name:String,steps:List<&2,Sch.Step>,needs:List<&2,SP.Requirement<S>>) -> Single.Application<S,C,R,E,H,Rows,observe,fold>:
  Single.Application{App.Application{schema,Build.Registered{world,owners,recipe,debug}},plan,namespace,name,steps,needs}
def disabled_outcome(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Error:Data,result:H & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,Error,Unit>) -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>:
  match result:
    case (owners,Sys.Succeeded{Ctx.Context{world,_},output}):(owners,Sys.Succeeded{world,output})
    case (owners,Sys.Failed{Ctx.Context{world,_},error}):(owners,Sys.Failed{world,error})
def dispatch_disabled(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Error:Data,~dispatch:H -> Ctx.Context<W.World<S,C,R,E>> -> U32 -> H & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,Error,Unit>,owners:H,world:W.World<S,C,R,E>,id:U32) -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>:
  disabled_outcome(~S,~C,~R,~E,~H,~Error,dispatch(owners,Ctx.Context{world,Facts.Off{}},id))
# Disabled runs use the old ordinary run directly: no identity/clock scan,
# completion journal, trace-event construction or subscriber delivery occurs.
# Transition-handler failure identifying its exit/transition/enter phase
# and error text. Enter failure follows an already committed transition;
# inspect the phase instead of assuming whole-transition rollback.
type HandlerFailure is Data:
  HandlerFailure{phase:Handlers.Phase,error:String}
# Transition-handler execution retains the App, all handler owners, the
# captured machine snapshot, optional phase failure and detached trace batch.
# The captured snapshot is not a rollback command or a copy of affine owners.
type HandlerRun<App:Type,Owners:Type,Snapshot:Data> is Type:
  HandlerRun{app:App,owners:Owners,captured:Snapshot,failure:Maybe<&2,HandlerFailure>,batch:Trace.Batch<String>}
def operation_events(facts:List<&2,Facts.Fact>) -> List<&2,Trace.TraceEvent<String>>:
  match facts:
    case []:[]
    case fact <> rest:Trace.ExecutionOperationObserved{fact} <> operation_events(rest)
def operation_batch(state:Facts.State) -> Trace.Batch<String>:
  match state:
    case Facts.Off{}:Trace.Disabled{}
    case Facts.On{facts}:Trace.Ready{operation_events(List.reverse(&2,Facts.Fact,facts))}
def trace_state(debug:Bool) -> Facts.State:
  match debug:
    case False{}:Facts.Off{}
    case True{}:Facts.On{[]}
def handlers_returned(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Value:Data,~declaration:FieldDecl.Declaration<S,C,R,E,Ops,Value>,~K:Data,~MachineV:Data,~take:R -> R & Machine.Slot<S,K,MachineV>,~put:R -> Machine.Slot<S,K,MachineV> -> R,~machine:MachineDecl.Declaration<S,K,MachineV,R,take>,~same:MachineV -> MachineV -> Bool,~publish:W.World<S,C,R,E> -> Machine.Transition<MachineV> -> W.World<S,C,R,E>,~body:@-H:Type -> @-caps:Ops(H) -> Handlers.Invocation<MachineV> -> H -> H & (Transaction.Outcome<String> & Unit),~Owners:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>,schema:Schema.Schema<S,C,R>,previous:Owners,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,debug:Bool,plan:SP.Plan<S>,namespace:U32,name:String,steps:List<&2,Sch.Step>,needs:List<&2,SP.Requirement<S>>,captured:Machine.Snapshot<MachineV>,result:HandlerEngine.HandlerResult<Ctx.Context<W.World<S,C,R,E>>,Handlers.Entry<S,C,R,E,MachineV,FieldSystem.runner(~S,~C,~R,~E,~Ops,~Handlers.Invocation<MachineV>,~String,~Unit,~FieldDecl.ordinary(~S,~C,~R,~E,~Ops,~Value,declaration),~body)>,Handlers.Phase>) -> HandlerRun<Single.Application<S,C,R,E,Owners,Rows,observe,fold>,Handlers.Owners<S,C,R,E,MachineV,FieldSystem.runner(~S,~C,~R,~E,~Ops,~Handlers.Invocation<MachineV>,~String,~Unit,~FieldDecl.ordinary(~S,~C,~R,~E,~Ops,~Value,declaration),~body)>,Machine.Snapshot<MachineV>>:
  match result:
    case HandlerEngine.Completed{HandlerEngine.Owners{exit,transition,enter},Ctx.Context{world,trace}}:HandlerRun{restored(~S,~C,~R,~E,~Owners,~Rows,~observe,~fold,~String,schema,world,previous,recipe,debug,plan,namespace,name,steps,needs),Handlers.Owners{exit,transition,enter},captured,None{},operation_batch(trace)}
    case HandlerEngine.Stopped{HandlerEngine.Owners{exit,transition,enter},Ctx.Context{world,trace},phase,error}:HandlerRun{restored(~S,~C,~R,~E,~Owners,~Rows,~observe,~fold,~String,schema,world,previous,recipe,debug,plan,namespace,name,steps,needs),Handlers.Owners{exit,transition,enter},captured,Some{HandlerFailure{phase,error}},operation_batch(trace)}
def handlers_read(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Value:Data,~declaration:FieldDecl.Declaration<S,C,R,E,Ops,Value>,~K:Data,~MachineV:Data,~take:R -> R & Machine.Slot<S,K,MachineV>,~put:R -> Machine.Slot<S,K,MachineV> -> R,~machine:MachineDecl.Declaration<S,K,MachineV,R,take>,~same:MachineV -> MachineV -> Bool,~publish:W.World<S,C,R,E> -> Machine.Transition<MachineV> -> W.World<S,C,R,E>,~body:@-H:Type -> @-caps:Ops(H) -> Handlers.Invocation<MachineV> -> H -> H & (Transaction.Outcome<String> & Unit),~Owners:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>,schema:Schema.Schema<S,C,R>,previous:Owners,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,+debug:Bool,plan:SP.Plan<S>,namespace:U32,name:String,steps:List<&2,Sch.Step>,needs:List<&2,SP.Requirement<S>>,owners:Handlers.Owners<S,C,R,E,MachineV,FieldSystem.runner(~S,~C,~R,~E,~Ops,~Handlers.Invocation<MachineV>,~String,~Unit,~FieldDecl.ordinary(~S,~C,~R,~E,~Ops,~Value,declaration),~body)>,read:W.World<S,C,R,E> & Machine.Slot<S,K,MachineV>) -> HandlerRun<Single.Application<S,C,R,E,Owners,Rows,observe,fold>,Handlers.Owners<S,C,R,E,MachineV,FieldSystem.runner(~S,~C,~R,~E,~Ops,~Handlers.Invocation<MachineV>,~String,~Unit,~FieldDecl.ordinary(~S,~C,~R,~E,~Ops,~Value,declaration),~body)>,Machine.Snapshot<MachineV>>:
  match read:
    case (world,+slot):handlers_returned(~S,~C,~R,~E,~Ops,~Value,~declaration,~K,~MachineV,~take,~put,~machine,~same,~publish,~body,~Owners,~Rows,~observe,~fold,schema,previous,recipe,debug,plan,namespace,name,steps,needs,Machine.snapshot(~S,~K,~MachineV,slot),ExecuteRun.handlers_resource_field(~S,~C,~R,~E,~Ops,~Value,~declaration,~K,~MachineV,~take,~put,~machine,~same,~publish,~body,owners,Ctx.Context{world,trace_state(debug)},Machine.snapshot(~S,~K,~MachineV,slot)))
def run_handlers_resource_field(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Value:Data,~declaration:FieldDecl.Declaration<S,C,R,E,Ops,Value>,~K:Data,~MachineV:Data,~take:R -> R & Machine.Slot<S,K,MachineV>,~put:R -> Machine.Slot<S,K,MachineV> -> R,~machine:MachineDecl.Declaration<S,K,MachineV,R,take>,~same:MachineV -> MachineV -> Bool,~publish:W.World<S,C,R,E> -> Machine.Transition<MachineV> -> W.World<S,C,R,E>,~body:@-H:Type -> @-caps:Ops(H) -> Handlers.Invocation<MachineV> -> H -> H & (Transaction.Outcome<String> & Unit),~Owners:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>,app:Single.Application<S,C,R,E,Owners,Rows,observe,fold>,owners:Handlers.Owners<S,C,R,E,MachineV,FieldSystem.runner(~S,~C,~R,~E,~Ops,~Handlers.Invocation<MachineV>,~String,~Unit,~FieldDecl.ordinary(~S,~C,~R,~E,~Ops,~Value,declaration),~body)>) -> HandlerRun<Single.Application<S,C,R,E,Owners,Rows,observe,fold>,Handlers.Owners<S,C,R,E,MachineV,FieldSystem.runner(~S,~C,~R,~E,~Ops,~Handlers.Invocation<MachineV>,~String,~Unit,~FieldDecl.ordinary(~S,~C,~R,~E,~Ops,~Value,declaration),~body)>,Machine.Snapshot<MachineV>>:
  match app:
    case Single.Application{App.Application{schema,Build.Registered{world,previous,recipe,debug}},plan,namespace,name,steps,needs}:handlers_read(~S,~C,~R,~E,~Ops,~Value,~declaration,~K,~MachineV,~take,~put,~machine,~same,~publish,~body,~Owners,~Rows,~observe,~fold,schema,previous,recipe,debug,plan,namespace,name,steps,needs,owners,MachineWorld.take(~S,~K,~MachineV,~C,~R,~E,~take,world))

type ExecutionState<Error:Data> is Data:
  Off{}
  On{journal:Journal<Error>}
def disabled_dispatched(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Error:Data,result:H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>) -> (H & ExecutionState<Error>) & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>:
  match result:
    case (owners,outcome):((owners,Off{}),outcome)
def enabled_dispatched(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Error:Data,result:(H & Journal<Error>) & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>) -> (H & ExecutionState<Error>) & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>:
  match result:
    case ((owners,journal),outcome):((owners,On{journal}),outcome)
def dispatch_state(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Error:Data,~dispatch:H -> Ctx.Context<W.World<S,C,R,E>> -> U32 -> H & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,Error,Unit>,owner:H & ExecutionState<Error>,world:W.World<S,C,R,E>,id:U32) -> (H & ExecutionState<Error>) & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>:
  match owner:
    case (owners,Off{}):disabled_dispatched(~S,~C,~R,~E,~H,~Error,dispatch_disabled(~S,~C,~R,~E,~H,~Error,~dispatch,owners,world,id))
    case (owners,On{journal}):enabled_dispatched(~S,~C,~R,~E,~H,~Error,dispatch_recorded(~S,~C,~R,~E,~H,~Error,~dispatch,(owners,journal),world,id))
def enabled_barrier(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Error:Data,result:(H & Journal<Error>) & W.World<S,C,R,E>) -> (H & ExecutionState<Error>) & W.World<S,C,R,E>:
  match result:
    case ((owners,journal),world):((owners,On{journal}),world)
def barrier_state(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Error:Data,owner:H & ExecutionState<Error>,world:W.World<S,C,R,E>) -> (H & ExecutionState<Error>) & W.World<S,C,R,E>:
  match owner:
    case (owners,Off{}):((owners,Off{}),W.barrier(~S,~C,~R,~E,world))
    case (owners,On{journal}):enabled_barrier(~S,~C,~R,~E,~H,~Error,barrier_recorded(~S,~C,~R,~E,~H,~Error,(owners,journal),world))
def executed(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~Error:Data,schema:Schema.Schema<S,C,R>,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,plan:SP.Plan<S>,needs:List<&2,SP.Requirement<S>>,result:Sch.RunResult<S,C,R,E,H & ExecutionState<Error>,Error>) -> Run<Single.Application<S,C,R,E,H,Rows,observe,fold>,S,Error>:
  match result:
    case Sch.Finished{Sch.Schedule{namespace,name,steps,(owners,Off{})},world,observations}:Run{Single.Finished{restored(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Error,schema,world,owners,recipe,False{},plan,namespace,name,steps,needs),observations},Trace.Disabled{}}
    case Sch.Finished{Sch.Schedule{+namespace,+name,steps,(owners,On{journal})},world,+observations}:Run{Single.Finished{restored(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Error,schema,world,owners,recipe,True{},plan,namespace,name,steps,needs),observations},batch(~Error,namespace,name,observations,journal,Trace.EndOk{})}
    case Sch.Failed{Sch.Schedule{namespace,name,steps,(owners,Off{})},world,error,observations}:Run{Single.Failed{restored(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Error,schema,world,owners,recipe,False{},plan,namespace,name,steps,needs),error,observations},Trace.Disabled{}}
    case Sch.Failed{Sch.Schedule{+namespace,+name,steps,(owners,On{journal})},world,+error,+observations}:Run{Single.Failed{restored(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Error,schema,world,owners,recipe,True{},plan,namespace,name,steps,needs),error,observations},batch(~Error,namespace,name,observations,journal,Trace.EndFailed{error})}
    case Sch.Rejected{Sch.Schedule{namespace,name,steps,(owners,Off{})},world}:Run{Single.Rejected{restored(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Error,schema,world,owners,recipe,False{},plan,namespace,name,steps,needs)},Trace.Disabled{}}
    case Sch.Rejected{Sch.Schedule{+namespace,+name,steps,(owners,On{journal})},world}:Run{Single.Rejected{restored(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Error,schema,world,owners,recipe,True{},plan,namespace,name,steps,needs)},Trace.Ready{[Trace.ScheduleAdmissionRefused{namespace,name,Trace.EndRejected{}}]}}
def provisioned(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~Error:Data,schema:Schema.Schema<S,C,R>,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,plan:SP.Plan<S>,result:SP.ProvisionResult<S,C,R,E,H & ExecutionState<Error>,Error>) -> Run<Single.Application<S,C,R,E,H,Rows,observe,fold>,S,Error>:
  match result:
    case SP.Executed{result,needs}:executed(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Error,schema,recipe,plan,needs,result)
    case SP.Missing{SP.Provisioned{Sch.Schedule{namespace,name,steps,(owners,Off{})},needs},world,missing}:Run{Single.Missing{restored(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Error,schema,world,owners,recipe,False{},plan,namespace,name,steps,needs),missing},Trace.Disabled{}}
    case SP.Missing{SP.Provisioned{Sch.Schedule{+namespace,+name,steps,(owners,On{journal})},needs},world,+missing}:Run{Single.Missing{restored(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Error,schema,world,owners,recipe,True{},plan,namespace,name,steps,needs),missing},Trace.Ready{[Trace.ScheduleAdmissionRefused{namespace,name,Trace.EndMissing{}}]}}
def start(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~Error:Data,~dispatch:H -> Ctx.Context<W.World<S,C,R,E>> -> U32 -> H & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,Error,Unit>,~condition:W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,~provision:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,schema:Schema.Schema<S,C,R>,world:W.World<S,C,R,E>,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,plan:SP.Plan<S>,namespace:U32,name:String,steps:List<&2,Sch.Step>,needs:List<&2,SP.Requirement<S>>,owners:H,state:ExecutionState<Error>) -> Run<Single.Application<S,C,R,E,H,Rows,observe,fold>,S,Error>:
  provisioned(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Error,schema,recipe,plan,SP.run_with_barrier(~S,~C,~R,~E,~(H & ExecutionState<Error>),~Error,~dispatch_state(~S,~C,~R,~E,~H,~Error,~dispatch),~condition,~barrier_state(~S,~C,~R,~E,~H,~Error),~provision,SP.Provisioned{Sch.Schedule{namespace,name,steps,(owners,state)},needs},world))
def prepared(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~Error:Data,~dispatch:H -> Ctx.Context<W.World<S,C,R,E>> -> U32 -> H & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,Error,Unit>,~condition:W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,~provision:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,schema:Schema.Schema<S,C,R>,world:W.World<S,C,R,E>,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,plan:SP.Plan<S>,namespace:U32,name:String,steps:List<&2,Sch.Step>,needs:List<&2,SP.Requirement<S>>,value:H & List<&2,Records.Fields<S>>) -> Run<Single.Application<S,C,R,E,H,Rows,observe,fold>,S,Error>:
  match value:
    case (owners,fields):start(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Error,~dispatch,~condition,~provision,schema,world,recipe,plan,namespace,name,steps,needs,owners,On{Journal{catalog(~S,fields),[]}})
# Advanced traced schedule execution with supplied dispatch/condition/provision
# callbacks. Returns Run on admission refusal, missing requirements, success
# or system failure, retaining App ownership throughout. Disabled debug omits
# trace collection; enabled debug derives identities and operations from actual
# execution. Supplied callbacks are trusted world-transforming adapters;
# arbitrary callback mutations/host IO are not automatically transactional.
# Prefer ordinary-app-run.run for registration-derived dispatch.
def run(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~Error:Data,~dispatch:H -> Ctx.Context<W.World<S,C,R,E>> -> U32 -> H & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,Error,Unit>,~condition:W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,~provision:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,value:Single.Application<S,C,R,E,H,Rows,observe,fold>) -> Run<Single.Application<S,C,R,E,H,Rows,observe,fold>,S,Error>:
  match value:
    case Single.Application{App.Application{schema,Build.Registered{world,owners,recipe,False{}}},plan,namespace,name,steps,needs}:start(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Error,~dispatch,~condition,~provision,schema,world,recipe,plan,namespace,name,steps,needs,owners,Off{})
    case Single.Application{App.Application{schema,Build.Registered{world,owners,recipe,True{}}},plan,namespace,name,steps,needs}:prepared(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Error,~dispatch,~condition,~provision,schema,world,recipe,plan,namespace,name,steps,needs,fold(owners))
