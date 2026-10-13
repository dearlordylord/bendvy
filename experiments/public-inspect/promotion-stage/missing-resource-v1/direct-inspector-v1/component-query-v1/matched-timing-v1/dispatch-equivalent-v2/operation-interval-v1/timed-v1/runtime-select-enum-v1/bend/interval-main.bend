import Base
import repetition.bend as Repetition
import consumer.bend as C
import schema-families.bend as D
import check-schedules.bend as G
import fixture.bend as Fixture
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import timing.bend as Clock
def after_end(~S:Data,next:C.Carry<S> -> IO(String),result:C.Operation<S>) -> IO(String):
  match result:
    case C.Operation{value,completed}:IO.bind(Unit,String,Clock.end(),u => next(C.observed(~S,C.Operation{value,completed})))
def sequence(~S:Data,~guard:G.World(~S) -> U32 -> G.World(~S) & Bool,~dispatch:G.ScheduleOwners<S> -> G.World(~S) -> U32 -> G.ScheduleOwners<S> & Sys.Outcome<G.World(~S),Unit,Unit>,actions:List<&2,C.Action>,+index:U32,value:C.Carry<S>) -> IO(String):
  match actions:
    case []:IO.pure(String,C.detached(~S,Some{value}))
    case action <> rest:IO.bind(Unit,String,Clock.begin(index),u => after_end(~S,value => sequence(~S,~guard,~dispatch,rest,U32.add(index,1),value),C.operation(~S,~guard,~dispatch,action,value)))
def schema(~S:Data,~guard:G.World(~S) -> U32 -> G.World(~S) & Bool,~dispatch:G.ScheduleOwners<S> -> G.World(~S) -> U32 -> G.ScheduleOwners<S> & Sys.Outcome<G.World(~S),Unit,Unit>,index:U32,prepared:Maybe<&1,C.Carry<S>>) -> IO(String):
  match prepared:
    case None{}:IO.pure(String,"REGISTER_REFUSED")
    case Some{value}:sequence(~S,~guard,~dispatch,C.actions(),index,value)
def workshop_done(index:U32,text:String) -> IO(String):
  IO.bind(String,String,schema(~D.Garden,~G.garden_condition,~G.garden_dispatch,U32.add(index,10),C.built(~D.Garden,Fixture.garden())),garden => IO.pure(String,"Workshop=" ++ text ++ "|Garden=" ++ garden))
def application(+index:U32) -> IO(String):
  IO.bind(String,String,schema(~D.Workshop,~G.workshop_condition,~G.workshop_dispatch,index,C.built(~D.Workshop,Fixture.workshop())),text => workshop_done(index,text))
def applications(left:Nat,+index:U32,expected:U32) -> IO(Unit):
  match left:
    case Zero{}:Clock.finish(expected)
    case Succ{rest}:IO.bind(String,Unit,application(index),text => IO.bind(Unit,Unit,Clock.capture(text),u => applications(rest,U32.add(index,20),expected)))
def selected(value:Maybe<&2,Repetition.Count>) -> IO(Unit):
  match value:
    case None{}:IO.pure(Unit,Unit{})
    case Some{Repetition.One{}}:IO.bind(Unit,Unit,Clock.reset(),u => applications(1n,0,20))
    case Some{Repetition.Two{}}:IO.bind(Unit,Unit,Clock.reset(),u => applications(2n,0,40))
    case Some{Repetition.Four{}}:IO.bind(Unit,Unit,Clock.reset(),u => applications(4n,0,80))
def invoked(values:List<String>) -> IO(Unit):selected(Repetition.invoked(values))
def main() -> IO(Unit):IO.bind(List<String>,Unit,IO.args(),invoked)
