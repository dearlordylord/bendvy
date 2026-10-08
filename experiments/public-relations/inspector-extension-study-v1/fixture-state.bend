import Base
import root-source/machine.bend as M
import root-source/machine-stream.bend as St

type Workshop is Data:
  Workshop{}
type Garden is Data:
  Garden{}
type FlowToken is Data:
  FlowToken{}
type LevelToken is Data:
  LevelToken{}
type Store<S:Data> is Type:
  Store{cells:Array<U32>}
type Resources<S:Data> is Type:
  Resources{owned:Array<U32>,flow:M.Slot<S,FlowToken,U32>,level:M.Slot<S,LevelToken,U32>,ran:U32,flowStream:St.Stream<U32>,levelStream:St.Stream<U32>}
def flow(~S:Data,resources:Resources<S>) -> Resources<S> & M.Slot<S,FlowToken,U32>:
  match resources:
    case Resources{owned,+flow,level,ran,flowStream,levelStream}:(Resources{owned,flow,level,ran,flowStream,levelStream},flow)
def level(~S:Data,resources:Resources<S>) -> Resources<S> & M.Slot<S,LevelToken,U32>:
  match resources:
    case Resources{owned,flow,+level,ran,flowStream,levelStream}:(Resources{owned,flow,level,ran,flowStream,levelStream},level)
def put_flow(~S:Data,resources:Resources<S>,flow:M.Slot<S,FlowToken,U32>) -> Resources<S>:
  match resources:
    case Resources{owned,_,level,ran,flowStream,levelStream}:Resources{owned,flow,level,ran,flowStream,levelStream}
def put_level(~S:Data,resources:Resources<S>,level:M.Slot<S,LevelToken,U32>) -> Resources<S>:
  match resources:
    case Resources{owned,flow,_,ran,flowStream,levelStream}:Resources{owned,flow,level,ran,flowStream,levelStream}
def increment(~S:Data,resources:Resources<S>) -> Resources<S> & Unit:
  match resources:
    case Resources{owned,flow,level,ran,flowStream,levelStream}:(Resources{owned,flow,level,(ran+1:U32),flowStream,levelStream},Unit{})

def flow_event(~S:Data,tick:Nat,event:M.Transition<U32>,resources:Resources<S>) -> Resources<S> & Unit:
  match resources:
    case Resources{owned,flow,level,ran,stream,other}:(Resources{owned,flow,level,ran,St.publish(~U32,stream,tick,event),other},Unit{})
def level_event(~S:Data,tick:Nat,event:M.Transition<U32>,resources:Resources<S>) -> Resources<S> & Unit:
  match resources:
    case Resources{owned,flow,level,ran,other,stream}:(Resources{owned,flow,level,ran,other,St.publish(~U32,stream,tick,event)},Unit{})
