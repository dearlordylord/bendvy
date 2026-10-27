import Base
import ./execution-trace.bend as Trace
import ./dependency-plan.bend as Plan
import ./dependency-executor.bend as Executor
import ./dependency-application.bend as Application
import ./execution-deferred-schedule.bend as Deferred
import ./trace-facts.bend as Facts

# Report observations carry actual outcomes, but no entry/exit timestamps or
# barrier receipts. This adapter deliberately emits only those reached facts.
def events(~Error:Data,~Out:Data,observations:List<&2,Executor.Observation<Error,Out>>) -> List<&2,Trace.TraceEvent<Error>>:
  match observations:
    case []:[]
    case Executor.Ran{id,_} <> rest:Trace.SystemOutcome{id,Trace.SystemOk{}} <> events(~Error,~Out,rest)
    case Executor.BodyFailed{id,error,_} <> rest:Trace.SystemOutcome{id,Trace.SystemError{error}} <> events(~Error,~Out,rest)
    case Executor.Skipped{id} <> rest:Trace.SystemSkipped{id} <> events(~Error,~Out,rest)
    case Executor.ConditionFailed{id,error} <> rest:Trace.ConditionOutcome{id,Trace.SystemError{error}} <> events(~Error,~Out,rest)
    case Executor.ConditionRejected{id} <> rest:Trace.ConditionRefused{id} <> events(~Error,~Out,rest)
    case Executor.AdmissionRejected{id} <> rest:Trace.InvocationRefused{id} <> events(~Error,~Out,rest)
def dependencies(~Error:Data,edges:List<&2,Plan.Edge>) -> List<&2,Trace.TraceEvent<Error>>:
  match edges:
    case []:[]
    case Plan.Edge{before,after} <> rest:Trace.DependencyObserved{before,after} <> dependencies(~Error,rest)
def constraints(~Error:Data,plan:Plan.Build<String>) -> List<&2,Trace.TraceEvent<Error>>:
  match plan:
    case Plan.Rejected{_}:[]
    case Plan.Planned{_,edges}:dependencies(~Error,edges)
def enabled(~Error:Data,~Out:Data,plan:Plan.Build<String>,report:Application.Report<Error,Out>) -> Trace.Batch<Error>:
  match report:
    case Application.Finished{observations}:Trace.BendvyReady{List.append(&2,Trace.TraceEvent<Error>,constraints(~Error,plan),List.append(&2,Trace.TraceEvent<Error>,events(~Error,~Out,observations),[Trace.ScheduleEnded{Trace.EndOk{}}]))}
    case Application.Stopped{error,observations}:Trace.BendvyReady{List.append(&2,Trace.TraceEvent<Error>,constraints(~Error,plan),List.append(&2,Trace.TraceEvent<Error>,events(~Error,~Out,observations),[Trace.ScheduleEnded{Trace.EndFailed{error}}]))}
    case Application.Invalid{_}:Trace.BendvyReady{[Trace.ScheduleEnded{Trace.EndRejected{}}]}
# The complete original Report remains available alongside the detached Batch.
# Disabled tracing does not inspect the plan or discard simulation outcomes.
def read(~Error:Data,~Out:Data,on:Bool,plan:Plan.Build<String>,+report:Application.Report<Error,Out>) -> Application.Report<Error,Out> & Trace.Batch<Error>:
  match on:
    case False{}:(report,Trace.Disabled{})
    case True{}:(report,enabled(~Error,~Out,plan,report))

# Boundary and system-outcome batches are separate ordered projections. Their
# inputs do not establish an interleaving between workers and barrier callbacks.
def boundary_events(~Error:Data,values:List<&2,Deferred.Boundary>) -> List<&2,Trace.TraceEvent<Error>>:
  match values:
    case []:[]
    case Deferred.ApplyEntered{_,_} <> rest:Trace.ExecutionOperationObserved{Facts.BoundaryFact{Facts.BarrierEntered{}}} <> boundary_events(~Error,rest)
    case Deferred.ApplyReturned{_,_} <> rest:Trace.ExecutionOperationObserved{Facts.BoundaryFact{Facts.BarrierFinished{}}} <> boundary_events(~Error,rest)
def boundary_batch(~Error:Data,on:Bool,values:List<&2,Deferred.Boundary>) -> Trace.Batch<Error>:
  match on:
    case False{}:Trace.Disabled{}
    case True{}:Trace.BendvyReady{boundary_events(~Error,values)}
