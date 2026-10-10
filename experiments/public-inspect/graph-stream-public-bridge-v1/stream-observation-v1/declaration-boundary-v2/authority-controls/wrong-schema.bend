import Base
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import ../transitions.bend as T
import ../failures.bend as Fail
import /workspace/formal-proofs/bendvy-worktrees/graph-stream-public-bridge-v1/experiments/public-inspect/graph-stream-public-bridge-v1/state.bend as State
def body(~H:Type,~cap:Cap.ValueRead<H,T.TransitionLog<State.Workshop,State.FlowToken,U32>>,owner:H) -> H & T.TransitionLog<State.Garden,State.FlowToken,U32>:
  Cap.value_read(~H,~T.TransitionLog<State.Garden,State.FlowToken,U32>,~cap,owner)
