import Base
import ../../../../src/ecs/dependency-plan.bend as Plan
import ./dependency-executor.bend as Exec
import ./spec.bend as Spec

law body_error_continuation:
  for State:Data
  for Requirement:Data
  for Error:Data
  for Out:Data
  for handler:State -> Error -> State & Exec.Handling
  for next:State -> List<&2,Exec.Observation<Error,Out>> -> Exec.ExecutionResult<State,Requirement,Error,Out>
  for +state:State
  for +error:Error
  for +output:Out
  for +id:U32
  for +events:List<&2,Exec.Observation<Error,Out>>
  {Exec.invoked(~State,~Requirement,~Error,~Out,~handler,next,(state,Exec.BodyError{error,output}),id,events) == Spec.after_handler(~State,~Requirement,~Error,~Out,next,handler(state,error),error,List.append(&2,Exec.Observation<Error,Out>,events,[Exec.BodyFailed{id,error,output}])) : Exec.ExecutionResult<State,Requirement,Error,Out>}
