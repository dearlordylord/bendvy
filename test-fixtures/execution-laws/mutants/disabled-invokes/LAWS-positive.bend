import Base
import ../../../../src/ecs/dependency-plan.bend as Plan
import ../../../../src/ecs/dependency-executor.bend as Exec
import ../../spec.bend as Spec

law disabled_condition_state:
  for State:Data
  for Requirement:Data
  for Error:Data
  for Out:Data
  for dispatch:State -> U32 -> State & Exec.Invocation<Error,Out>
  for handler:State -> Error -> State & Exec.Handling
  for next:State -> List<&2,Exec.Observation<Error,Out>> -> Exec.ExecutionResult<State,Requirement,Error,Out>
  for +state:State
  for +id:U32
  for +events:List<&2,Exec.Observation<Error,Out>>
  {Exec.conditioned(~State,~Requirement,~Error,~Out,~dispatch,~handler,next,(state,Exec.Disabled{}),id,events) == next(state,List.append(&2,Exec.Observation<Error,Out>,events,[Exec.Skipped{id}])) : Exec.ExecutionResult<State,Requirement,Error,Out>}
