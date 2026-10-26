import Base
import ../../../../src/ecs/dependency-plan.bend as Plan
import ../../../../src/ecs/dependency-executor.bend as Exec
import ../../spec.bend as Spec
import ./LAWS-positive.bend as Laws

def handled_equal(-State:Data,-Requirement:Data,-Error:Data,-Out:Data,next:State -> List<&2,Exec.Observation<Error,Out>> -> Exec.ExecutionResult<State,Requirement,Error,Out>,returned:State & Exec.Handling,+error:Error,+events:List<&2,Exec.Observation<Error,Out>>) -> {Exec.handled(~State,~Requirement,~Error,~Out,next,returned,error,events) == Spec.after_handler(~State,~Requirement,~Error,~Out,next,returned,error,events) : Exec.ExecutionResult<State,Requirement,Error,Out>}:
  match returned:
    case (state,Exec.Continue{}):{==}
    case (state,Exec.Escalate{}):{==}

# ---- body_error_continuation ----
def Laws.body_error_continuation(State,Requirement,Error,Out,handler,next,state,error,output,id,events):
  handled_equal(State,Requirement,Error,Out,next,handler(state,error),error,List.append(&2,Exec.Observation<Error,Out>,events,[Exec.BodyFailed{id,error,output}]))
