import Base
import /workspace/formal-proofs/bendvy-worktrees/graph-stream-public-bridge-v1/experiments/public-inspect/graph-stream-public-bridge-v1/state.bend as State
import /workspace/formal-proofs/bendvy/src/ecs/machine-stream.bend as St
import /workspace/formal-proofs/bendvy/src/ecs/inspector-transition-projection.bend as T
def take(~S:Data,resources:State.Resources<S>) -> State.Resources<S> & St.Stream<U32>:
  match resources:
    case State.Resources{owned,flow,level,ran,+flowStream,levelStream}:(State.Resources{owned,flow,level,ran,flowStream,levelStream},flowStream)
def declaration(~S:Data) -> T.Declaration<S,State.FlowToken,U32,State.Resources<S>,take(~S)>:
  T.Declaration{"Flow"}
