import Base
import ../../src/ecs/dependency-plan.bend as Plan
import ../../src/ecs/dependency-executor.bend as Exec
import ./spec.bend as Spec

# Approved exact statements; State is reusable Data, not an affine World law.
# Comments were extended at the user's request to cite pinned Bevy code and behavior.
# Guarantees: rejecting a plan returns the supplied state and exact reason.
# Why it matters: preflight refusal must not invoke gameplay or lose its state.
# Bevy code: https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/schedule/schedule.rs#L1261-L1279
# Bevy behavior: schedule graph construction checks cycles before execution.
# Bend adaptation: returning the exact supplied Data state and rejection reason
# is this adapter's contract, not a claim that Bevy graph building never changes World.
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
# Bevy code: https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/schedule/executor/single_threaded.rs#L137-L163
# Bevy behavior: a returned system failure reaches the error handler; if it returns,
# the executor continues without a rollback operation in this path.
# Bend adaptation: Continue/Escalate, explicit returned Data state and observation
# history encode this boundary; Rust panics and every fatal exit are not covered.
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
# Bevy code: https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/schedule/executor/single_threaded.rs#L107-L129
# Bevy behavior: false conditions prevent body execution after marking completion.
# Bend adaptation: this local equation forwards the condition's returned Data
# state and records Skipped; it does not prove an entire runner never invokes the body.
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
# Bevy code: https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/schedule/executor/single_threaded.rs#L246-L262
# Bevy behavior: a returned condition failure reaches the error handler and yields false.
# Bend adaptation: returned Data state, Continue/Escalate and ConditionFailed
# observations make that local boundary explicit; other condition branches are separate.
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
# Bevy code: https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/schedule/executor/multi_threaded.rs#L736-L759
# Bevy behavior: both completion and skipping signal dependents; zero remaining
# completion dependencies makes a dependent ready, without requiring predecessor success.
# Bend adaptation: raw pending-list order, duplicate preservation and absent-ID
# membership are this helper's representation contract, not Bevy list theorems.
law ready_exact:
  for Requirement:Data
  for +pending:List<&2,Plan.Node<Requirement>>
  for +edges:List<&2,Plan.Edge>
  {Plan.ready(~Requirement,pending,edges) == Spec.ready(~Requirement,pending,edges) : List<&2,Plan.Node<Requirement>>}
