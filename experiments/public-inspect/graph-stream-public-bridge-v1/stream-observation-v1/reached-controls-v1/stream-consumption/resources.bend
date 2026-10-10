import Base
import /workspace/formal-proofs/bendvy-worktrees/graph-stream-public-bridge-v1/experiments/public-inspect/graph-stream-public-bridge-v1/state.bend as State
import /workspace/formal-proofs/bendvy/src/ecs/machine-stream.bend as St
import transitions.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
def consumed(~S:Data,owned:Array<U32>,flow:M.Slot<S,State.FlowToken,U32>,level:M.Slot<S,State.LevelToken,U32>,ran:U32,levelStream:St.Stream<U32>,+stream:St.Stream<U32>) -> State.Resources<S> & St.Stream<U32>:
  (State.Resources{owned,flow,level,ran,stream,levelStream},stream)
def take(~S:Data,resources:State.Resources<S>) -> State.Resources<S> & St.Stream<U32>:
  match resources:
    case State.Resources{owned,flow,level,ran,flowStream,levelStream}:consumed(~S,owned,flow,level,ran,levelStream,St.complete(~U32,flowStream,5,3n,True{}))
def declaration(~S:Data) -> T.Declaration<S,State.FlowToken,U32,State.Resources<S>,take(~S)>:
  T.Declaration{"Flow"}
