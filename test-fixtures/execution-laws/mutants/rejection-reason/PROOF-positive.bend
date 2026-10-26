import Base
import ../../../../src/ecs/dependency-plan.bend as Plan
import ../../../../src/ecs/dependency-executor.bend as Exec
import ../../spec.bend as Spec
import ./LAWS-positive.bend as Laws

def handled_equal(-State:Data,-Requirement:Data,-Error:Data,-Out:Data,next:State -> List<&2,Exec.Observation<Error,Out>> -> Exec.ExecutionResult<State,Requirement,Error,Out>,returned:State & Exec.Handling,+error:Error,+events:List<&2,Exec.Observation<Error,Out>>) -> {Exec.handled(~State,~Requirement,~Error,~Out,next,returned,error,events) == Spec.after_handler(~State,~Requirement,~Error,~Out,next,returned,error,events) : Exec.ExecutionResult<State,Requirement,Error,Out>}:
  match returned:
    case (state,Exec.Continue{}):{==}
    case (state,Exec.Escalate{}):{==}

# ---- rejected_plan_state ----
def Laws.rejected_plan_state(State,Requirement,Error,Out,condition,dispatch,handler,state,reason):
  {==}
