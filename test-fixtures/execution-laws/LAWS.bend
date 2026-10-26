import Base
import ../../src/ecs/dependency-plan.bend as Plan
import ../../src/ecs/dependency-executor.bend as Exec
import ./spec.bend as Spec

# Draft only. State is reusable Data; these are not affine World laws.
# Guarantees: rejecting a plan returns the supplied state and exact reason.
# Why it matters: preflight refusal must not invoke gameplay or lose its state.
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

# Guarantees: a body error passes returned state to its handler and retains output.
# Why it matters: a handler cannot receive a restored predecessor state by default.
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

# Guarantees: a disabled condition continues with its returned state and one skip.
# Why it matters: false conditions do not call the system body or rewind condition state.
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

# Guarantees: condition errors use their returned state and the same handler policy.
# Why it matters: a failed condition must not invoke its body or erase prior events.
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

# Guarantees: ready contains exactly pending nodes whose predecessors are complete.
# Why it matters: completion permits descendants after skipped or failed predecessors.
law ready_exact:
  for Requirement:Data
  for +pending:List<&2,Plan.Node<Requirement>>
  for +edges:List<&2,Plan.Edge>
  {Plan.ready(~Requirement,pending,edges) == Spec.ready(~Requirement,pending,edges) : List<&2,Plan.Node<Requirement>>}
