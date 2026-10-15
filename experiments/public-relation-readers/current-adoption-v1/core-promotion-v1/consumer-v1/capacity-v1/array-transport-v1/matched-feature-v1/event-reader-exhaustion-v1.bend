import Base
import ../../../../../../../../src/ecs/world.bend as W
import ../../../../../../../../src/ecs/system.bend as Sys
import ../../../../../../../../src/ecs/event-runtime.bend as Ev
import ../../../../../../../../src/ecs/event-stream.bend as Leaf
import ../../../../../../../../src/ecs/event-family-routing.bend as Route
import ../../../../../../../../src/ecs/ordinary-event-declaration.bend as Event
import ../../../../../../../../src/ecs/string-equality.bend as SE

type Schema is Data:
  Schema{}
type Family is Type:
  Family{stream:Leaf.Stream<Schema,U32>}
type PriorAllocations is Data:
  PriorAllocations{stream:Leaf.Stream<Schema,U32>,first:U32,second:U32}

def empty(_:Unit) -> Unit:
  Unit{}
def take(state:Family) -> Family & Leaf.Stream<Schema,U32>:
  match state:
    case Family{+stream}:(Family{stream},stream)
def put(_:Family,stream:Leaf.Stream<Schema,U32>) -> Family:
  Family{stream}
def runner(world:W.World<Schema,Unit,Unit,U32>,input:Ev.Input<U32,Unit>) -> Sys.Outcome<W.World<Schema,Unit,Unit,U32>,Unit,Unit>:
  match input:
    case Ev.Input{_,_,_}:Sys.Succeeded{world,Unit{}}

def prior_stream() -> Leaf.Stream<Schema,U32>:
  Leaf.Stream{Event.Domain{"boundary"},[Ev.Batch{7n,[71]}],[Ev.Position{9,6n,5n}],4294967293,4n,5n,8n,3n}
def prior_second(result:Leaf.Stream<Schema,U32> & U32,first:U32) -> PriorAllocations:
  match result:
    case (stream,second):PriorAllocations{stream,first,second}
def prior_first(result:Leaf.Stream<Schema,U32> & U32) -> PriorAllocations:
  match result:
    case (stream,first):prior_second(Leaf.registered(~Schema,~U32,stream,1n),first)
def accepted_ids() -> PriorAllocations:
  prior_first(Leaf.registered(~Schema,~U32,prior_stream(),0n))

def u32_tail(values:List<&2,U32>) -> String:
  match values:
    case []:""
    case value <> rest:","++U32.show(value)++u32_tail(rest)
def u32_list(values:List<&2,U32>) -> String:
  match values:
    case []:"[]"
    case value <> rest:"["++U32.show(value)++u32_tail(rest)++"]"
def batches_tail(values:List<&2,Ev.Batch<U32>>) -> String:
  match values:
    case []:""
    case Ev.Batch{tick,values} <> rest:",{\"tick\":"++Nat.show(tick)++",\"values\":"++u32_list(values)++"}"++batches_tail(rest)
def render_batches(values:List<&2,Ev.Batch<U32>>) -> String:
  match values:
    case []:"[]"
    case Ev.Batch{tick,values} <> rest:"[{\"tick\":"++Nat.show(tick)++",\"values\":"++u32_list(values)++"}"++batches_tail(rest)++"]"
def position(value:Ev.Position) -> String:
  match value:
    case Ev.Position{id,cursor,registeredAt}:"{\"id\":"++U32.show(id)++",\"cursor\":"++Nat.show(cursor)++",\"registeredAt\":"++Nat.show(registeredAt)++"}"
def positions_tail(values:List<&2,Ev.Position>) -> String:
  match values:
    case []:""
    case value <> rest:","++position(value)++positions_tail(rest)
def render_positions(values:List<&2,Ev.Position>) -> String:
  match values:
    case []:"[]"
    case value <> rest:"["++position(value)++positions_tail(rest)++"]"
def stream_signature(stream:Leaf.Stream<Schema,U32>) -> String:
  match stream:
    case Leaf.Stream{Event.Domain{key},batches,positions,nextReader,frameStart,boundary,capacity,dropped}:
      "{\"domain\":\""++key++"\",\"batches\":"++render_batches(batches)++",\"positions\":"++render_positions(positions)++",\"nextReader\":"++U32.show(nextReader)++",\"frameStart\":"++Nat.show(frameStart)++",\"boundary\":"++Nat.show(boundary)++",\"capacity\":"++Nat.show(capacity)++",\"dropped\":"++Nat.show(dropped)++"}"
def present(world:W.World<Schema,Unit,Unit,U32>,id:U32,name:String) -> W.World<Schema,Unit,Unit,U32> & Bool:
  W.registration_matches(~Schema,~Unit,~Unit,~U32,world,id,name,[Event.access(~Schema,~U32,Event.read(~Schema,~U32,Event.domain(~Schema,~U32,"boundary")))])
def absent_second(first:Bool,result:W.World<Schema,Unit,Unit,U32> & Bool) -> W.World<Schema,Unit,Unit,U32> & Bool:
  match result:
    case (world,second):(world,Bool.and(Bool.not(first),Bool.not(second)))
def absent_first(result:W.World<Schema,Unit,Unit,U32> & Bool) -> W.World<Schema,Unit,Unit,U32> & Bool:
  match result:
    case (world,first):absent_second(first,present(world,2,"exhausted-2"))
def absent_registrations(world:W.World<Schema,Unit,Unit,U32>) -> W.World<Schema,Unit,Unit,U32> & Bool:
  absent_first(present(world,1,"exhausted-1"))
def bool(value:Bool) -> String:
  match value:
    case True{}:"true"
    case False{}:"false"
def exhausted_render(priorStream:Leaf.Stream<Schema,U32>,first:U32,second:U32,registrationsAbsent:Bool,registered:Leaf.Stream<Schema,U32> & U32) -> String:
  match registered:
    case (+stream,sentinel):
      "{\"acceptedReaderIds\":["++U32.show(first)++","++U32.show(second)++"],\"nextReaderAfterAccepted\":"++U32.show(4294967295)++",\"directExhaustedId\":"++U32.show(sentinel)++",\"streamUnchanged\":"++bool(SE.equal(stream_signature(priorStream),stream_signature(stream)))++",\"streamAfter\":"++stream_signature(stream)++",\"registrationsAbsent\":"++bool(registrationsAbsent)++"}"
def exhausted_observed(prior:PriorAllocations,registrationsAbsent:Bool,registered:Leaf.Stream<Schema,U32> & U32) -> String:
  match prior:
    case PriorAllocations{stream,first,second}:exhausted_render(stream,first,second,registrationsAbsent,registered)
def exhausted_result(prior:PriorAllocations,registered:Leaf.Stream<Schema,U32> & U32,absence:W.World<Schema,Unit,Unit,U32> & Bool) -> String:
  match absence:
    case (_,registrationsAbsent):exhausted_observed(prior,registrationsAbsent,registered)
def exhausted_leaf(world:W.World<Schema,Unit,Unit,U32>,prior:PriorAllocations,+stream:Leaf.Stream<Schema,U32>,+tick:Nat) -> String:
  exhausted_result(prior,Leaf.registered(~Schema,~U32,stream,tick),absent_registrations(world))
def exhausted_family(world:W.World<Schema,Unit,Unit,U32>,prior:PriorAllocations,family:Family,+tick:Nat) -> String:
  match family:
    case Family{+stream}:exhausted_leaf(world,prior,stream,tick)
def RegistrationType() -> Type:
  Route.Registration<Schema,Unit,Unit,U32,U32,Family,Unit,Unit,Unit,take,put,runner>
def second_refusal(result:RegistrationType(),prior:PriorAllocations) -> String:
  match result:
    case Route.RegistrationFailed{Route.Runtime{world,family,tick}}:exhausted_family(world,prior,family,tick)
    case Route.Registered{_,_,_}:"unexpected-registration-at-exhaustion"
def first_refusal(result:RegistrationType(),prior:PriorAllocations) -> String:
  match result:
    case Route.RegistrationFailed{runtime}:second_refusal(Route.register(~Schema,~Unit,~Unit,~U32,~U32,~Family,~Unit,~Unit,~Unit,~take,~put,~runner,runtime,"exhausted-2"),prior)
    case Route.Registered{_,_,_}:"unexpected-registration-at-exhaustion"
def route_after_acceptances(world:W.World<Schema,Unit,Unit,U32>,prior:PriorAllocations) -> String:
  match prior:
    case PriorAllocations{+stream,first,second}:first_refusal(Route.register(~Schema,~Unit,~Unit,~U32,~U32,~Family,~Unit,~Unit,~Unit,~take,~put,~runner,Route.Runtime{world,Family{stream},0n},"exhausted-1"),PriorAllocations{stream,first,second})
def created(result:W.Creation<Schema,Unit,Unit,U32>) -> String:
  match result:
    case W.CreateRejected{_,_}:"world-creation-rejected"
    case W.Created{_,world}:route_after_acceptances(world,accepted_ids())
def main() -> IO(Unit):
  IO.print(created(W.create(~Schema,~Unit,~Unit,~U32,~empty,W.factory(),Unit{})))
