import Base
import ../../../../../src/ecs/machine.bend as M
import ../../../../../src/ecs/machine-stream.bend as St

type Workshop is Data:
  Workshop{}
type Garden is Data:
  Garden{}
type FlowToken is Data:
  FlowToken{}
type LevelToken is Data:
  LevelToken{}
type Components<S:Data> is Type:
  Components{cells:Array<List<&2,U32>>,sibling:Array<List<&2,U32>>}
type Resources<S:Data> is Type:
  Resources{owned:Array<U32>,siblingOwned:Array<U32>,flow:M.Slot<S,FlowToken,U32>,level:M.Slot<S,LevelToken,U32>,ran:U32,flowStream:St.Stream<U32>,levelStream:St.Stream<U32>}

def flow(~S:Data,resources:Resources<S>) -> Resources<S> & M.Slot<S,FlowToken,U32>:
  match resources:
    case Resources{owned,siblingOwned,+flow,level,ran,flowStream,levelStream}:(Resources{owned,siblingOwned,flow,level,ran,flowStream,levelStream},flow)
def put_flow(~S:Data,resources:Resources<S>,replacement:M.Slot<S,FlowToken,U32>) -> Resources<S>:
  match resources:
    case Resources{owned,siblingOwned,flow,level,ran,flowStream,levelStream}:Resources{owned,siblingOwned,replacement,level,ran,flowStream,levelStream}
def level(~S:Data,resources:Resources<S>) -> Resources<S> & M.Slot<S,LevelToken,U32>:
  match resources:
    case Resources{owned,siblingOwned,flow,+level,ran,flowStream,levelStream}:(Resources{owned,siblingOwned,flow,level,ran,flowStream,levelStream},level)
def put_level(~S:Data,resources:Resources<S>,replacement:M.Slot<S,LevelToken,U32>) -> Resources<S>:
  match resources:
    case Resources{owned,siblingOwned,flow,level,ran,flowStream,levelStream}:Resources{owned,siblingOwned,flow,replacement,ran,flowStream,levelStream}
def flow_stream(~S:Data,resources:Resources<S>) -> Resources<S> & St.Stream<U32>:
  match resources:
    case Resources{owned,siblingOwned,flow,level,ran,+flowStream,levelStream}:(Resources{owned,siblingOwned,flow,level,ran,flowStream,levelStream},flowStream)
def put_flow_stream(~S:Data,resources:Resources<S>,replacement:St.Stream<U32>) -> Resources<S>:
  match resources:
    case Resources{owned,siblingOwned,flow,level,ran,flowStream,levelStream}:Resources{owned,siblingOwned,flow,level,ran,replacement,levelStream}
def level_stream(~S:Data,resources:Resources<S>) -> Resources<S> & St.Stream<U32>:
  match resources:
    case Resources{owned,siblingOwned,flow,level,ran,flowStream,+levelStream}:(Resources{owned,siblingOwned,flow,level,ran,flowStream,levelStream},levelStream)
def put_level_stream(~S:Data,resources:Resources<S>,replacement:St.Stream<U32>) -> Resources<S>:
  match resources:
    case Resources{owned,siblingOwned,flow,level,ran,flowStream,levelStream}:Resources{owned,siblingOwned,flow,level,ran,flowStream,replacement}
