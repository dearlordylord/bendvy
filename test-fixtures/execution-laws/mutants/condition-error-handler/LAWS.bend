import Base
import ../../../../src/ecs/dependency-plan.bend as Plan
import ./dependency-executor.bend as Exec
import ./spec.bend as Spec

law condition_error_continuation:
  for State:Data
  for Requirement:Data
  for Error:Data
  for Out:Data
  for dispatch:State -> U32 -> State & Exec.Invocation<Error,Out>
  for handler:State -> Error -> State & Exec.Handling
  for next:State -> List<&2,Exec.Observation<Error,Out>> -> Exec.ExecutionResult<State,Requirement,Error,Out>
  for +state:State
  for +error:Error
  for +id:U32
  for +events:List<&2,Exec.Observation<Error,Out>>
  {Exec.conditioned(~State,~Requirement,~Error,~Out,~dispatch,~handler,next,(state,Exec.ConditionError{error}),id,events) == Spec.after_handler(~State,~Requirement,~Error,~Out,next,handler(state,error),error,List.append(&2,Exec.Observation<Error,Out>,events,[Exec.ConditionFailed{id,error}])) : Exec.ExecutionResult<State,Requirement,Error,Out>}
