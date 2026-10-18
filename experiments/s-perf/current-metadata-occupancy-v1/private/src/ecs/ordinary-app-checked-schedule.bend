import Base
import ./execution-context.bend as Ctx
import ./execution-trace.bend as Trace
import ./ordinary-app-execution.bend as Execution
import ./ordinary-checked-bindings.bend as B
import ./checked-condition-schedule.bend as Checked
import ./world.bend as W
import ./system.bend as Sys
import ./schedule.bend as Sch
import ./schedule-provision.bend as SP
import ./ordinary-schema.bend as Schema
import ./ordinary-app-schema.bend as App
import ./ordinary-app-composer.bend as Build
import ./ordinary-app-schedule.bend as Schedule
import ./ordinary-app-recipe.bend as Tree
import ./ordinary-app-observation-data.bend as DTO
import ./ordinary-app-registration-fields.bend as Records
# Check descriptions derive from operational declarations and explicit bindings.
# The existing App, recipe, ordinary registration owners and real plan are retained.
type Application<S:Data,C:Type,R:Type,E:Data,H:Type,Rows:Data,-observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,-fold:H -> H & List<&2,Records.Fields<S>>,B:Type,-select:B -> W.World<S,C,R,E> -> U32 -> B.Selection<W.World<S,C,R,E>,B>> is Type:
  Application{app:Schedule.Application<S,C,R,E,H,Rows,observe,fold>,bindings:B.Bindings<W.World<S,C,R,E>,B,select>}
type Attachment<-Original:Type,-Guards:Type,-Scheduled:Type> is Type:
  Attached{app:Scheduled}
  Invalid{app:Original,bindings:Guards}
type Description<S:Data,Rows:Data> is Data:
  Description{original:Schedule.Description<S,Rows>,bindings:List<&2,B.Description>}
def attached(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> B.Selection<W.World<S,C,R,E>,B>,schema:Schema.Schema<S,C,R>,world:W.World<S,C,R,E>,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,debug:Bool,plan:SP.Plan<S>,needs:List<&2,SP.Requirement<S>>,result:Checked.Attachment<S,C,R,E,H,B,select>) -> Attachment<Schedule.Application<S,C,R,E,H,Rows,observe,fold>,B.Bindings<W.World<S,C,R,E>,B,select>,Application<S,C,R,E,H,Rows,observe,fold,B,select>>:
  match result:
    case Checked.Attached{Sch.Schedule{namespace,name,steps,(owners,bindings)}}:Attached{Application{Schedule.Application{App.Application{schema,Build.Registered{world,owners,recipe,debug}},plan,namespace,name,steps,needs},bindings}}
    case Checked.AttachmentRejected{Sch.Schedule{namespace,name,steps,owners},bindings}:Invalid{Schedule.Application{App.Application{schema,Build.Registered{world,owners,recipe,debug}},plan,namespace,name,steps,needs},bindings}
def attach(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> B.Selection<W.World<S,C,R,E>,B>,value:Schedule.Application<S,C,R,E,H,Rows,observe,fold>,bindings:B.Bindings<W.World<S,C,R,E>,B,select>) -> Attachment<Schedule.Application<S,C,R,E,H,Rows,observe,fold>,B.Bindings<W.World<S,C,R,E>,B,select>,Application<S,C,R,E,H,Rows,observe,fold,B,select>>:
  match value:
    case Schedule.Application{App.Application{schema,Build.Registered{world,owners,recipe,debug}},plan,namespace,name,steps,needs}:attached(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~B,~select,schema,world,recipe,debug,plan,needs,Checked.attach(~S,~C,~R,~E,~H,~B,~select,Sch.Schedule{namespace,name,steps,owners},bindings))
def enabled(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> B.Selection<W.World<S,C,R,E>,B>,value:Application<S,C,R,E,H,Rows,observe,fold,B,select>,flag:Bool) -> Application<S,C,R,E,H,Rows,observe,fold,B,select>:
  match value:
    case Application{app,bindings}:Application{Schedule.enabled(~S,~C,~R,~E,~H,~Rows,~observe,~fold,app,flag),bindings}
def snapshot_present(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> B.Selection<W.World<S,C,R,E>,B>,app:Schedule.Application<S,C,R,E,H,Rows,observe,fold>,view:Schedule.Description<S,Rows>,bindings:B.Bindings<W.World<S,C,R,E>,B,select>) -> Application<S,C,R,E,H,Rows,observe,fold,B,select> & Maybe<&2,Description<S,Rows>>:
  match bindings:
    case B.Bindings{owner,+facts}:(Application{app,B.Bindings{owner,facts}},Some{Description{view,facts}})
def snapshot_returned(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> B.Selection<W.World<S,C,R,E>,B>,bindings:B.Bindings<W.World<S,C,R,E>,B,select>,observed:Schedule.Application<S,C,R,E,H,Rows,observe,fold> & Maybe<&2,Schedule.Description<S,Rows>>) -> Application<S,C,R,E,H,Rows,observe,fold,B,select> & Maybe<&2,Description<S,Rows>>:
  match observed:
    case (app,None{}):(Application{app,bindings},None{})
    case (app,Some{view}):snapshot_present(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~B,~select,app,view,bindings)
def snapshot(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> B.Selection<W.World<S,C,R,E>,B>,value:Application<S,C,R,E,H,Rows,observe,fold,B,select>) -> Application<S,C,R,E,H,Rows,observe,fold,B,select> & Maybe<&2,Description<S,Rows>>:
  match value:
    case Application{app,bindings}:snapshot_returned(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~B,~select,bindings,Schedule.snapshot(~S,~C,~R,~E,~H,~Rows,~observe,~fold,app))
def executed(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> B.Selection<W.World<S,C,R,E>,B>,~BodyError:Data,schema:Schema.Schema<S,C,R>,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,debug:Bool,plan:SP.Plan<S>,needs:List<&2,SP.Requirement<S>>,result:Sch.RunResult<S,C,R,E,H & B.Bindings<W.World<S,C,R,E>,B,select>,Checked.Error<BodyError>>) -> Schedule.RunResult<Application<S,C,R,E,H,Rows,observe,fold,B,select>,S,Checked.Error<BodyError>>:
  match result:
    case Sch.Finished{Sch.Schedule{namespace,name,steps,(owners,bindings)},world,observations}:Schedule.Finished{Application{Schedule.Application{App.Application{schema,Build.Registered{world,owners,recipe,debug}},plan,namespace,name,steps,needs},bindings},observations}
    case Sch.Failed{Sch.Schedule{namespace,name,steps,(owners,bindings)},world,error,observations}:Schedule.Failed{Application{Schedule.Application{App.Application{schema,Build.Registered{world,owners,recipe,debug}},plan,namespace,name,steps,needs},bindings},error,observations}
    case Sch.Rejected{Sch.Schedule{namespace,name,steps,(owners,bindings)},world}:Schedule.Rejected{Application{Schedule.Application{App.Application{schema,Build.Registered{world,owners,recipe,debug}},plan,namespace,name,steps,needs},bindings}}
def provisioned(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> B.Selection<W.World<S,C,R,E>,B>,~BodyError:Data,schema:Schema.Schema<S,C,R>,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,debug:Bool,plan:SP.Plan<S>,result:SP.ProvisionResult<S,C,R,E,H & B.Bindings<W.World<S,C,R,E>,B,select>,Checked.Error<BodyError>>) -> Schedule.RunResult<Application<S,C,R,E,H,Rows,observe,fold,B,select>,S,Checked.Error<BodyError>>:
  match result:
    case SP.Missing{SP.Provisioned{Sch.Schedule{namespace,name,steps,(owners,bindings)},needs},world,missing}:Schedule.Missing{Application{Schedule.Application{App.Application{schema,Build.Registered{world,owners,recipe,debug}},plan,namespace,name,steps,needs},bindings},missing}
    case SP.Executed{result,needs}:executed(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~B,~select,~BodyError,schema,recipe,debug,plan,needs,result)
def run_classic(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> B.Selection<W.World<S,C,R,E>,B>,~BodyError:Data,~dispatch:H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,BodyError,Unit>,~provision:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,value:Application<S,C,R,E,H,Rows,observe,fold,B,select>) -> Schedule.RunResult<Application<S,C,R,E,H,Rows,observe,fold,B,select>,S,Checked.Error<BodyError>>:
  match value:
    case Application{Schedule.Application{App.Application{schema,Build.Registered{world,owners,recipe,debug}},plan,namespace,name,steps,needs},bindings}:provisioned(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~B,~select,~BodyError,schema,recipe,debug,plan,Checked.run_provisioned(~S,~C,~R,~E,~H,~B,~select,~BodyError,~dispatch,~provision,SP.Provisioned{Sch.Schedule{namespace,name,steps,(owners,bindings)},needs},world))

def trace_status(~Error:Data,value:Trace.Status<Error>) -> Trace.Status<Checked.Error<Error>>:
  match value:
    case Trace.SystemOk{}:Trace.SystemOk{}
    case Trace.SystemError{error}:Trace.SystemError{Checked.SystemError{error}}
def trace_completion(~Error:Data,value:Trace.Completion<Error>) -> Trace.Completion<Checked.Error<Error>>:
  match value:
    case Trace.EndOk{}:Trace.EndOk{}
    case Trace.EndFailed{error}:Trace.EndFailed{Checked.SystemError{error}}
    case Trace.EndRejected{}:Trace.EndRejected{}
    case Trace.EndMissing{}:Trace.EndMissing{}
def trace_events(~Error:Data,events:List<&2,Trace.TraceEvent<Error>>) -> List<&2,Trace.TraceEvent<Checked.Error<Error>>>:
  match events:
    case []:[]
    case Trace.ScheduleStarted{namespace,name} <> rest:Trace.ScheduleStarted{namespace,name} <> trace_events(~Error,rest)
    case Trace.PhaseEntered{name} <> rest:Trace.PhaseEntered{name} <> trace_events(~Error,rest)
    case Trace.SystemCompleted{identity,before,after,status} <> rest:Trace.SystemCompleted{identity,before,after,trace_status(~Error,status)} <> trace_events(~Error,rest)
    case Trace.OperationObserved{identity,fact} <> rest:Trace.OperationObserved{identity,fact} <> trace_events(~Error,rest)
    case Trace.BarrierOperationObserved{fact} <> rest:Trace.BarrierOperationObserved{fact} <> trace_events(~Error,rest)
    case Trace.ExecutionOperationObserved{fact} <> rest:Trace.ExecutionOperationObserved{fact} <> trace_events(~Error,rest)
    case Trace.SystemSkipped{id} <> rest:Trace.SystemSkipped{id} <> trace_events(~Error,rest)
    case Trace.DeferredApplied{} <> rest:Trace.DeferredApplied{} <> trace_events(~Error,rest)
    case Trace.ScheduleEnded{outcome} <> rest:Trace.ScheduleEnded{trace_completion(~Error,outcome)} <> trace_events(~Error,rest)
    case Trace.ScheduleAdmissionRefused{namespace,name,outcome} <> rest:Trace.ScheduleAdmissionRefused{namespace,name,trace_completion(~Error,outcome)} <> trace_events(~Error,rest)
def context_batch(~Error:Data,namespace:U32,name:String,observations:List<&2,Sch.Observation>,state:Execution.ExecutionState<Error>,outcome:Trace.Completion<Checked.Error<Error>>) -> Trace.Batch<Checked.Error<Error>>:
  match state:
    case Execution.Off{}:Trace.Disabled{}
    case Execution.On{Execution.Journal{catalog,events}}:Execution.batch(~Checked.Error<Error>,namespace,name,observations,Execution.Journal{catalog,trace_events(~Error,events)},outcome)
def context_barrier_returned(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> B.Selection<W.World<S,C,R,E>,B>,~BodyError:Data,bindings:B.Bindings<W.World<S,C,R,E>,B,select>,value:(H & Execution.ExecutionState<BodyError>) & W.World<S,C,R,E>) -> ((H & Execution.ExecutionState<BodyError>) & B.Bindings<W.World<S,C,R,E>,B,select>) & W.World<S,C,R,E>:
  match value:
    case (owners,world):((owners,bindings),world)
def context_barrier(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> B.Selection<W.World<S,C,R,E>,B>,~BodyError:Data,owners:(H & Execution.ExecutionState<BodyError>) & B.Bindings<W.World<S,C,R,E>,B,select>,world:W.World<S,C,R,E>) -> ((H & Execution.ExecutionState<BodyError>) & B.Bindings<W.World<S,C,R,E>,B,select>) & W.World<S,C,R,E>:
  match owners:
    case (owners,bindings):context_barrier_returned(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~B,~select,~BodyError,bindings,Execution.barrier_state(~S,~C,~R,~E,~H,~BodyError,owners,world))
def context_executed(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> B.Selection<W.World<S,C,R,E>,B>,~BodyError:Data,result:Sch.RunResult<S,C,R,E,(H & Execution.ExecutionState<BodyError>) & B.Bindings<W.World<S,C,R,E>,B,select>,Checked.Error<BodyError>>) -> Sch.RunResult<S,C,R,E,H & B.Bindings<W.World<S,C,R,E>,B,select>,Checked.Error<BodyError>> & Trace.Batch<Checked.Error<BodyError>>:
  match result:
    case Sch.Finished{Sch.Schedule{+namespace,+name,steps,((owners,state),bindings)},world,+observations}:(Sch.Finished{Sch.Schedule{namespace,name,steps,(owners,bindings)},world,observations},context_batch(~BodyError,namespace,name,observations,state,Trace.EndOk{}))
    case Sch.Failed{Sch.Schedule{+namespace,+name,steps,((owners,state),bindings)},world,+error,+observations}:(Sch.Failed{Sch.Schedule{namespace,name,steps,(owners,bindings)},world,error,observations},context_batch(~BodyError,namespace,name,observations,state,Trace.EndFailed{error}))
    case Sch.Rejected{Sch.Schedule{+namespace,+name,steps,((owners,state),bindings)},world}:(Sch.Rejected{Sch.Schedule{namespace,name,steps,(owners,bindings)},world},context_batch(~BodyError,namespace,name,[],state,Trace.EndRejected{}))
def context_wrapped(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> B.Selection<W.World<S,C,R,E>,B>,~BodyError:Data,needs:List<&2,SP.Requirement<S>>,result:Sch.RunResult<S,C,R,E,H & B.Bindings<W.World<S,C,R,E>,B,select>,Checked.Error<BodyError>> & Trace.Batch<Checked.Error<BodyError>>) -> SP.ProvisionResult<S,C,R,E,H & B.Bindings<W.World<S,C,R,E>,B,select>,Checked.Error<BodyError>> & Trace.Batch<Checked.Error<BodyError>>:
  match result:
    case (result,batch):(SP.Executed{result,needs},batch)
def context_provisioned(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> B.Selection<W.World<S,C,R,E>,B>,~BodyError:Data,result:SP.ProvisionResult<S,C,R,E,(H & Execution.ExecutionState<BodyError>) & B.Bindings<W.World<S,C,R,E>,B,select>,Checked.Error<BodyError>>) -> SP.ProvisionResult<S,C,R,E,H & B.Bindings<W.World<S,C,R,E>,B,select>,Checked.Error<BodyError>> & Trace.Batch<Checked.Error<BodyError>>:
  match result:
    case SP.Missing{SP.Provisioned{Sch.Schedule{+namespace,+name,steps,((owners,state),bindings)},needs},world,missing}:(SP.Missing{SP.Provisioned{Sch.Schedule{namespace,name,steps,(owners,bindings)},needs},world,missing},context_batch(~BodyError,namespace,name,[],state,Trace.EndMissing{}))
    case SP.Executed{result,needs}:context_wrapped(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~B,~select,~BodyError,needs,context_executed(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~B,~select,~BodyError,result))
def context_restored(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> B.Selection<W.World<S,C,R,E>,B>,~BodyError:Data,schema:Schema.Schema<S,C,R>,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,debug:Bool,plan:SP.Plan<S>,value:SP.ProvisionResult<S,C,R,E,H & B.Bindings<W.World<S,C,R,E>,B,select>,Checked.Error<BodyError>> & Trace.Batch<Checked.Error<BodyError>>) -> Execution.Run<Application<S,C,R,E,H,Rows,observe,fold,B,select>,S,Checked.Error<BodyError>>:
  match value:
    case (result,batch):Execution.Run{provisioned(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~B,~select,~BodyError,schema,recipe,debug,plan,result),batch}
def context_start(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> B.Selection<W.World<S,C,R,E>,B>,~BodyError:Data,~dispatch:H -> Ctx.Context<W.World<S,C,R,E>> -> U32 -> H & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,BodyError,Unit>,~provision:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,schema:Schema.Schema<S,C,R>,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,debug:Bool,plan:SP.Plan<S>,world:W.World<S,C,R,E>,namespace:U32,name:String,steps:List<&2,Sch.Step>,needs:List<&2,SP.Requirement<S>>,owners:H,bindings:B.Bindings<W.World<S,C,R,E>,B,select>,state:Execution.ExecutionState<BodyError>) -> Execution.Run<Application<S,C,R,E,H,Rows,observe,fold,B,select>,S,Checked.Error<BodyError>>:
  context_restored(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~B,~select,~BodyError,schema,recipe,debug,plan,context_provisioned(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~B,~select,~BodyError,Checked.run_provisioned_with_barrier(~S,~C,~R,~E,~(H & Execution.ExecutionState<BodyError>),~B,~select,~BodyError,~Execution.dispatch_state(~S,~C,~R,~E,~H,~BodyError,~dispatch),~context_barrier(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~B,~select,~BodyError),~provision,SP.Provisioned{Sch.Schedule{namespace,name,steps,((owners,state),bindings)},needs},world)))
def context_prepared(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> B.Selection<W.World<S,C,R,E>,B>,~BodyError:Data,~dispatch:H -> Ctx.Context<W.World<S,C,R,E>> -> U32 -> H & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,BodyError,Unit>,~provision:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,schema:Schema.Schema<S,C,R>,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,debug:Bool,plan:SP.Plan<S>,world:W.World<S,C,R,E>,namespace:U32,name:String,steps:List<&2,Sch.Step>,needs:List<&2,SP.Requirement<S>>,bindings:B.Bindings<W.World<S,C,R,E>,B,select>,value:H & List<&2,Records.Fields<S>>) -> Execution.Run<Application<S,C,R,E,H,Rows,observe,fold,B,select>,S,Checked.Error<BodyError>>:
  match value:
    case (owners,fields):context_start(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~B,~select,~BodyError,~dispatch,~provision,schema,recipe,debug,plan,world,namespace,name,steps,needs,owners,bindings,Execution.On{Execution.Journal{Execution.catalog(~S,fields),[]}})
def run(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> B.Selection<W.World<S,C,R,E>,B>,~BodyError:Data,~dispatch:H -> Ctx.Context<W.World<S,C,R,E>> -> U32 -> H & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,BodyError,Unit>,~provision:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,value:Application<S,C,R,E,H,Rows,observe,fold,B,select>) -> Execution.Run<Application<S,C,R,E,H,Rows,observe,fold,B,select>,S,Checked.Error<BodyError>>:
  match value:
    case Application{Schedule.Application{App.Application{schema,Build.Registered{world,owners,recipe,False{}}},plan,namespace,name,steps,needs},bindings}:context_start(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~B,~select,~BodyError,~dispatch,~provision,schema,recipe,False{},plan,world,namespace,name,steps,needs,owners,bindings,Execution.Off{})
    case Application{Schedule.Application{App.Application{schema,Build.Registered{world,owners,recipe,True{}}},plan,namespace,name,steps,needs},bindings}:context_prepared(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~B,~select,~BodyError,~dispatch,~provision,schema,recipe,True{},plan,world,namespace,name,steps,needs,bindings,fold(owners))
