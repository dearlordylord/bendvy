import Base
import fixture-schema.bend as D
import fixture-query.bend as Decl
import fixture-specs.bend as Spec
import families.bend as Family
import selection.bend as Select
import query.bend as Query
import core-v1/src/ecs/component.bend as C
import core-v1/src/ecs/relation-query.bend as RQ
import core-v1/src/ecs/world.bend as W
import core-v1/src/ecs/inspector.bend as I
import core-v1/src/ecs/relation-commands.bend as A

type ResourceValues is Data:
  ResourceValues{first:U32,second:U32}
type Metadata is Data:
  Metadata{namespace:U32,clock:U32,pending:U32,cursor:U32,resources:ResourceValues}
type Snapshot<S:Data> is Data:
  Snapshot{metadata:Metadata,owners:List<&2,Query.Row<S,Select.Product<Select.Product<C.Access<U32>,C.Access<String>>,List<&2,RQ.Cell<S>>>>>}
def owners_joined(~S:Data,metadata:Metadata,observed:I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Query.Row<S,Select.Product<Select.Product<C.Access<U32>,C.Access<String>>,List<&2,RQ.Cell<S>>>>>) -> I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & Snapshot<S>:
  (frame,owners)=observed
  (frame,Snapshot{metadata,owners})
def owners(~S:Data,metadata:Metadata,frame:I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>) -> I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & Snapshot<S>:
  owners_joined(~S,metadata,Query.each(~I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,~S,~Select.Product<Select.Product<C.Access<U32>,C.Access<String>>,List<&2,RQ.Cell<S>>>,~Decl.declared(~S,~Family.Optional{},~Family.Optional{},~Spec.OptionalBoth{}),frame))
def second_done(firstValue:U32,first:Array<U32>,observed:Array<U32> & U32) -> D.Resources & ResourceValues:
  (second,secondValue)=observed
  (D.Resources{first,second},ResourceValues{firstValue,secondValue})
def first_done(second:Array<U32>,observed:Array<U32> & U32) -> D.Resources & ResourceValues:
  (first,firstValue)=observed
  second_done(firstValue,first,Array.get(U32,second,0))
def resources(value:D.Resources) -> D.Resources & ResourceValues:
  match value:
    case D.Resources{first,second}:first_done(second,Array.get(U32,first,0))
def finished(~S:Data,+cursor:U32,clock:U32,pending:U32,observed:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & ResourceValues) -> I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & Snapshot<S>:
  match observed:
    case (W.World{+namespace,+next,+high,live,+capacity,+depth,store,resource,+events,commands,+registrations,+nextSystem,+worldClock},values):owners(~S,Metadata{namespace,clock,pending,cursor,values},I.Frame{W.World{namespace,next,high,live,capacity,depth,store,resource,events,commands,registrations,nextSystem,worldClock},cursor})
def counted(~S:Data,cursor:U32,clock:U32,observed:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & U32) -> I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & Snapshot<S>:
  (world,pending)=observed
  finished(~S,cursor,clock,pending,W.observe_resource(~S,~A.Store<S,D.Components<S>>,~D.Resources,~A.Notice<S,D.FixtureEvent>,~ResourceValues,~resources,world))
def clocked(~S:Data,cursor:U32,observed:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & U32) -> I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & Snapshot<S>:
  (world,clock)=observed
  counted(~S,cursor,clock,W.pending_count(~S,~A.Store<S,D.Components<S>>,~D.Resources,~A.Notice<S,D.FixtureEvent>,world))
def observe(~S:Data,frame:I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>) -> I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & Snapshot<S>:
  match frame:
    case I.Frame{world,cursor}:clocked(~S,cursor,W.clock(~S,~A.Store<S,D.Components<S>>,~D.Resources,~A.Notice<S,D.FixtureEvent>,world))
