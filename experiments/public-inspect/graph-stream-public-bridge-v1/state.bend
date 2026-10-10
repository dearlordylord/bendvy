import Base
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import /workspace/formal-proofs/bendvy/src/ecs/machine-stream.bend as St

type Workshop is Data:
  Workshop{}
type Garden is Data:
  Garden{}
type FlowToken is Data:
  FlowToken{}
type LevelToken is Data:
  LevelToken{}
type Components<S:Data> is Type:
  Store{cells:Array<U32>}
type Resources<S:Data> is Type:
  Resources{owned:Array<U32>,flow:M.Slot<S,FlowToken,U32>,level:M.Slot<S,LevelToken,U32>,ran:U32,flowStream:St.Stream<U32>,levelStream:St.Stream<U32>}
def flow(~S:Data,resources:Resources<S>) -> Resources<S> & M.Slot<S,FlowToken,U32>:
  match resources:
    case Resources{owned,+flow,level,ran,flowStream,levelStream}:(Resources{owned,flow,level,ran,flowStream,levelStream},flow)
def level(~S:Data,resources:Resources<S>) -> Resources<S> & M.Slot<S,LevelToken,U32>:
  match resources:
    case Resources{owned,flow,+level,ran,flowStream,levelStream}:(Resources{owned,flow,level,ran,flowStream,levelStream},level)
