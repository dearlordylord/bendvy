import Base
import schema.bend as S
import ../../src/ecs/reader-domains.bend as D
import ../../src/ecs/event-runtime.bend as Ev
import ../../src/ecs/removals.bend as Rm
import ../../src/ecs/world.bend as W
import ../../src/ecs/system.bend as Sys

type Schema is Data:
  Schema{}
type Notice is Data:
  Ping{value: U32}
  Removed{id: U32}
type Token is Data:
  Token{}
def World() -> Type: W.World<Schema,Unit,Array<U32>,Notice>
def empty(unit: Unit) -> Unit: Unit{}
def classify(value: Notice) -> Bool:
  match value:
    case Ping{_}: True{}
    case _: False{}
def select(value: Notice) -> Maybe<&2,Rm.Record<Schema,Token>>:
  match value:
    case Removed{id}: Some{Rm.Removed{W.Handle{1,id},Token{}}}
    case _: None{}
def notice(value: Notice) -> String:
  match value:
    case Ping{value}: "ping:" ++ U32.show(value)
    case Removed{id}: "removed:" ++ U32.show(id)
def raw(value: String) -> String: value
def notices(xs: List<&2,Notice>) -> String:
  List.show(~&2,~Notice,~notice,xs)
def resource_observed(+eventvalues: List<&2,Notice>,+removals: List<&2,Notice>,read: World() & List<&2,U32>) -> IO(Unit):
  (world,words) = read
  IO.print(notices(eventvalues) ++ "|" ++ notices(removals) ++ "|resource:" ++ List.show(~&2,~U32,~U32.show,words))
def observed(+eventvalues: List<&2,Notice>,read: World() & List<&2,Notice>) -> IO(Unit):
  (world,+removals) = read
  resource_observed(eventvalues,removals,W.observe_resource(~Schema,~Unit,~Array<U32>,~Notice,~List<&2,U32>,~S.array_view,world))
def detached(result: D.Detached<Schema,Unit,Array<U32>,Notice>) -> IO(Unit):
  match result:
    case D.Detached{world,D.Events{_,_,_,_,_,_,_,_,_,values}}: observed(values,W.events_view(~Schema,~Unit,~Array<U32>,~Notice,world))
def publish_body(world: World(),input: Ev.Input<Notice,Unit>) -> Sys.Outcome<World(),Unit,Unit>:
  Sys.Succeeded{W.event_publish(~Schema,~Unit,~Array<U32>,~Notice,world,[Removed{4},Ping{12}]),Unit{}}
def recovered(+old_removals: List<&2,Notice>,result: Ev.RunResult<Schema,Unit,Array<U32>,Notice,Unit,Unit,Unit,publish_body>) -> IO(Unit):
  match result:
    case Ev.Ran{runtime,_,_,Ev.Succeeded{_}}: detached(D.recover(~Schema,~Unit,~Array<U32>,~Notice,~classify,runtime,old_removals))
    case _: IO.print("resource-recovery-failed")
def registered(+old_removals: List<&2,Notice>,result: Ev.Registered<Schema,Unit,Array<U32>,Notice,Unit,Unit,Unit,publish_body>) -> IO(Unit):
  match result:
    case Ev.Registered{runtime,reader,registry}: recovered(old_removals,Ev.run(~Schema,~Unit,~Array<U32>,~Notice,~Unit,~Unit,~Unit,~publish_body,runtime,reader,registry,Unit{}))
    case _: IO.print("resource-registration-failed")
def removal_view(events: D.Events<Schema,Notice>,observed: World() & List<&2,Notice>) -> IO(Unit):
  (world,+removals) = observed
  registered(removals,Ev.register(~Schema,~Unit,~Array<U32>,~Notice,~Unit,~Unit,~Unit,~publish_body,D.attach(~Schema,~Unit,~Array<U32>,~Notice,events,world),"resource-owner-reader",["Ping.read","Ping.write","removal.write"]))
def collected_detached(result: D.Detached<Schema,Unit,Array<U32>,Notice>) -> IO(Unit):
  match result:
    case D.Detached{world,events}: removal_view(events,W.events_view(~Schema,~Unit,~Array<U32>,~Notice,world))
def collected(result: D.Detached<Schema,Unit,Array<U32>,Notice>) -> IO(Unit):
  match result:
    case D.Detached{world,events}: collected_detached(D.collect(~Schema,~Unit,~Array<U32>,~Notice,~classify,events,W.event_publish(~Schema,~Unit,~Array<U32>,~Notice,world,[Removed{2},Ping{11},Removed{3}])))
def started(runtime: Ev.Runtime<Schema,Unit,Array<U32>,Notice>) -> IO(Unit):
  collected(D.detach(~Schema,~Unit,~Array<U32>,~Notice,runtime,[Removed{1}]))
def created(result: W.Creation<Schema,Unit,Array<U32>,Notice>) -> IO(Unit):
  match result:
    case W.Created{_,world}: started(Ev.start(~Schema,~Unit,~Array<U32>,~Notice,W.event_publish(~Schema,~Unit,~Array<U32>,~Notice,world,[Ping{10}]),2n))
    case _: IO.print("creation-error")
def main() -> IO(Unit):
  created(W.create(~Schema,~Unit,~Array<U32>,~Notice,~empty,W.factory(),[77 : U32*4n]))
