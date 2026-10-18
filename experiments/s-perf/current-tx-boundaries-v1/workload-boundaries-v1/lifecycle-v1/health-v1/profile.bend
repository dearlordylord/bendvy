import Base
import ../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/meter.bend as Meter
import ../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/world.bend as W
import ../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/entity-key.bend as Key

type HandleFact is Data:
  HandleFact{namespace:U32,index:U32,generation:U32}
type Observation is Data:
  Observation{handle:Maybe<&2,HandleFact>,cursor:Maybe<&2,U32>,report:Meter.Report}
type Action is Data:
  Finish{committed:Bool}
  Unselect{}
type Sample is Data:
  Sample{kind:String,iteration:Maybe<&2,U32>,phase:Maybe<&2,U32>,call:Maybe<&2,U32>,ordinal:Nat,action:Action,observation:Observation}
def handle(~S:Data,value:W.Handle<S>) -> HandleFact:
  match value:
    case W.Handle{namespace,+key}:HandleFact{namespace,Key.index(key),Key.generation(key)}
def witness_events(~S:Data,~C:Type,~R:Type,~E:Data,report:Meter.Report,namespace:U32,tick:U32,pending:U32,observed:W.World<S,C,R,E> & List<&2,E>) -> W.World<S,C,R,E> & Meter.Report:
  match observed:
    case (world,events):(world,Meter.settled(report,Meter.Witness{namespace,tick,pending,List.length(&2,E,events)}))
def witness_pending(~S:Data,~C:Type,~R:Type,~E:Data,report:Meter.Report,namespace:U32,tick:U32,observed:W.World<S,C,R,E> & U32) -> W.World<S,C,R,E> & Meter.Report:
  match observed:
    case (world,pending):witness_events(~S,~C,~R,~E,report,namespace,tick,pending,W.events_view(~S,~C,~R,~E,world))
def witness_clock(~S:Data,~C:Type,~R:Type,~E:Data,report:Meter.Report,namespace:U32,observed:W.World<S,C,R,E> & U32) -> W.World<S,C,R,E> & Meter.Report:
  match observed:
    case (world,tick):witness_pending(~S,~C,~R,~E,report,namespace,tick,W.pending_count(~S,~C,~R,~E,world))
def witness_namespace(~S:Data,~C:Type,~R:Type,~E:Data,report:Meter.Report,observed:W.World<S,C,R,E> & U32) -> W.World<S,C,R,E> & Meter.Report:
  match observed:
    case (world,namespace):witness_clock(~S,~C,~R,~E,report,namespace,W.clock(~S,~C,~R,~E,world))
def witness(~S:Data,~C:Type,~R:Type,~E:Data,world:W.World<S,C,R,E>,report:Meter.Report) -> W.World<S,C,R,E> & Meter.Report:witness_namespace(~S,~C,~R,~E,report,W.namespace(~S,~C,~R,~E,world))
def action(value:Action) -> String:
  match value:
    case Finish{_}:"finish"
    case Unselect{}:"unselect"
def committed(value:Action) -> String:
  match value:
    case Finish{value}:Meter.boolean(value)
    case Unselect{}:"null"
def handle_fact(value:Maybe<&2,HandleFact>) -> String:
  match value:
    case None{}:"null"
    case Some{HandleFact{namespace,index,generation}}:"{\"namespace\":" ++ U32.show(namespace) ++ ",\"index\":" ++ U32.show(index) ++ ",\"generation\":" ++ U32.show(generation) ++ "}"
def observed(+kind:String,value:Observation) -> String:
  match value:
    case Observation{handle,cursor,report}:"{\"handle\":" ++ handle_fact(handle) ++ ",\"cursor\":" ++ Meter.optional(cursor) ++ ",\"tx\":" ++ Meter.render(kind,report) ++ "}"
def render(value:Sample) -> String:
  match value:
    case Sample{+kind,iteration,phase,call,ordinal,+effect,value}:"{\"kind\":\"" ++ kind ++ "\",\"iteration\":" ++ Meter.optional(iteration) ++ ",\"phase\":" ++ Meter.optional(phase) ++ ",\"call\":" ++ Meter.optional(call) ++ ",\"ordinal\":" ++ Nat.show(ordinal) ++ ",\"action\":\"" ++ action(effect) ++ "\",\"committed\":" ++ committed(effect) ++ ",\"observation\":" ++ observed(kind,value) ++ "}"
def tail(values:List<&2,Sample>) -> String:
  match values:
    case []:"]"
    case value <> rest:"," ++ render(value) ++ tail(rest)
def samples(values:List<&2,Sample>) -> String:
  match values:
    case []:"[]"
    case value <> rest:"[" ++ render(value) ++ tail(rest)

def at_ordinal(value:Sample,ordinal:Nat) -> Sample:
  match value:
    case Sample{kind,iteration,phase,call,_,effect,observed}:Sample{kind,iteration,phase,call,ordinal,effect,observed}
def ordinal(value:Sample) -> Nat:
  match value:
    case Sample{_,_,_,_,value,_,_}:value
