import Base
import ../../consumer.bend as Consumer
import ../../condition.bend as Condition
import expected-gate-strings.bend as Expected
import ../../../../fixture-schema.bend as D
import ../../../../core-v1/src/ecs/world.bend as W
import ../../../../core-v1/src/ecs/relation-commands.bend as A

# Trusted fixture keys agree with the genuine same-Factory WorldPair namespaces.
# The foreign World is retained by the outer driver; public valid still checks it.
def targets(~S:Data) -> List<&2,W.Handle<S>>:
  [W.Handle{1,1},W.Handle{1,2},W.Handle{1,3},W.Handle{1,4},W.Handle{1,0},W.Handle{1,5},W.Handle{2,1}]
def expected(allowed:Bool,value:String) -> String:
  match allowed:
    case True{}:value
    case False{}:"!" ++ value
def condition(~S:Data,~wanted:Unit -> String,world:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,id:U32) -> W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & Bool:
  Condition.condition(~S,Consumer.Args{targets(~S),expected(U32.is_eq(id,1),wanted(Unit{}))},world)
def workshop(world:W.World<D.Workshop,A.Store<D.Workshop,D.Components<D.Workshop>>,D.Resources,A.Notice<D.Workshop,D.FixtureEvent>>,id:U32) -> W.World<D.Workshop,A.Store<D.Workshop,D.Components<D.Workshop>>,D.Resources,A.Notice<D.Workshop,D.FixtureEvent>> & Bool:
  condition(~D.Workshop,~(_ => Expected.workshop()),world,id)
def garden(world:W.World<D.Garden,A.Store<D.Garden,D.Components<D.Garden>>,D.Resources,A.Notice<D.Garden,D.FixtureEvent>>,id:U32) -> W.World<D.Garden,A.Store<D.Garden,D.Components<D.Garden>>,D.Resources,A.Notice<D.Garden,D.FixtureEvent>> & Bool:
  condition(~D.Garden,~(_ => Expected.garden()),world,id)
