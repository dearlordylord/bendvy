import Base
import ./world.bend as W
import ./dependency-application.bend as App
import ./dependency-executor.bend as Exec

# DeferredSchedule.run has already selected and applied its final-deferred policy.
# Invalid and escalated Stop retain writes without claiming a completed update.
def completed(~S:Data,~C:Type,~R:Type,~E:Data,~Owners:Type,~Guards:Type,~Handler:Type,~Error:Data,~Out:Data,result:Exec.ExecutionResult<App.State<W.World<S,C,R,E>,Owners,Guards,Handler>,String,Error,Out>) -> Exec.ExecutionResult<App.State<W.World<S,C,R,E>,Owners,Guards,Handler>,String,Error,Out>:
  match result:
    case Exec.Finished{App.State{world,owners,guards,handler,bindings},events}:Exec.Finished{App.State{W.maintain_lifecycle(~S,~C,~R,~E,world),owners,guards,handler,bindings},events}
    case Exec.Stopped{state,error,events}:Exec.Stopped{state,error,events}
    case Exec.Invalid{state,reason}:Exec.Invalid{state,reason}
