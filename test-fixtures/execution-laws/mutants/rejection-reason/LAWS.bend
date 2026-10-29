import Base
import ../../../../src/ecs/dependency-plan.bend as Plan
import ./dependency-executor.bend as Exec
import ./spec.bend as Spec

law rejected_plan_state:
  for State:Data
  for Requirement:Data
  for Error:Data
  for Out:Data
  for condition:State -> U32 -> State & Exec.Condition<Error>
  for dispatch:State -> U32 -> State & Exec.Invocation<Error,Out>
  for handler:State -> Error -> State & Exec.Handling
  for +state:State
  for +reason:Plan.Invalid<Requirement>
  {Exec.run(~State,~Requirement,~Error,~Out,~condition,~dispatch,~handler,Plan.Rejected{reason},state) == Exec.Invalid{state,reason} : Exec.ExecutionResult<State,Requirement,Error,Out>}
