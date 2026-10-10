import Base
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy-worktrees/graph-stream-public-bridge-v1/experiments/public-inspect/graph-stream-public-bridge-v1/state.bend as State
import ../failures.bend as Fail
def body(~H:Type,~cap:Cap.ValueRead<H,Fail.FailureView<State.Workshop,U32>>,owner:H) -> H & Fail.FailureView<State.Garden,U32>:
  Cap.value_read(~H,~Fail.FailureView<State.Garden,U32>,~cap,owner)
