import Base
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy-worktrees/graph-stream-public-bridge-v1/experiments/public-inspect/graph-stream-public-bridge-v1/state.bend as State
import ../failures.bend as Fail
def body(~S:Data,~H:Type,~cap:Cap.ValueRead<H,Fail.FailureView<S,U32>>,owner:H,value:Fail.FailureView<S,U32>) -> H:
  Cap.value_set(~H,~Fail.FailureView<S,U32>,~Fail.FailureView<S,U32>,~cap,owner,value)
