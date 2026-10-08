import Base
import fixture-schema.bend as D
import fixture-pair.bend as Pairing
import fixture-phase.bend as Phase
import fixture-mutations.bend as Mutation
import core-v1/src/ecs/world.bend as W
import core-v1/src/ecs/inspector.bend as I
import core-v1/src/ecs/relation-commands.bend as A

type Delivery<S:Data> is Type:
  Delivered{factory:W.Factory,world:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,foreign:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,instance:I.Instance<S>,phases:List<&2,Phase.Phase<S>>,errors:String}
  SetupRefused{setup:Pairing.WorldPair<S>}
def last(~S:Data,factory:W.Factory,foreign:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,earlier:List<&2,Phase.Phase<S>>,errors:String,result:I.Observed<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>,String,Phase.Phase<S>>) -> Delivery<S>:
  match result:
    case I.Observed{world,instance,Done{phase}}:Delivered{factory,world,foreign,instance,List.append(&2,Phase.Phase<S>,earlier,[phase]),errors}
    case I.Observed{world,instance,Fail{error}}:Delivered{factory,world,foreign,instance,earlier,errors ++ "last-inspector-failed:" ++ error}
def second(~S:Data,factory:W.Factory,foreign:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,+lookups:List<&2,W.Handle<S>>,first:Phase.Phase<S>,errors:String,result:I.Observed<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>,String,Phase.Phase<S>>) -> Delivery<S>:
  match result:
    case I.Observed{world,instance,Done{phase}}:last(~S,factory,foreign,[first,phase],errors,Phase.inspect(~S,instance,lookups,W.barrier(~S,~A.Store<S,D.Components<S>>,~D.Resources,~A.Notice<S,D.FixtureEvent>,world)))
    case I.Observed{world,instance,Fail{error}}:Delivered{factory,world,foreign,instance,[first],errors ++ "second-inspector-failed:" ++ error}
def queued(~S:Data,factory:W.Factory,foreign:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,+lookups:List<&2,W.Handle<S>>,instance:I.Instance<S>,first:Phase.Phase<S>,errors:String,observed:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & String) -> Delivery<S>:
  (world,error)=observed
  second(~S,factory,foreign,lookups,first,errors ++ error,Phase.inspect(~S,instance,lookups,world))
def first(~S:Data,factory:W.Factory,foreign:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,+one:W.Handle<S>,+three:W.Handle<S>,+four:W.Handle<S>,+lookups:List<&2,W.Handle<S>>,errors:String,result:I.Observed<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>,String,Phase.Phase<S>>) -> Delivery<S>:
  match result:
    case I.Observed{world,instance,Done{phase}}:queued(~S,factory,foreign,lookups,instance,phase,errors,Mutation.changed(~S,world,one,three,four))
    case I.Observed{world,instance,Fail{error}}:Delivered{factory,world,foreign,instance,[],errors ++ "first-inspector-failed:" ++ error}
def initialized(~S:Data,factory:W.Factory,foreign:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,+one:W.Handle<S>,+three:W.Handle<S>,+four:W.Handle<S>,+lookups:List<&2,W.Handle<S>>,errors:String,observed:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & String) -> Delivery<S>:
  (world,error)=observed
  first(~S,factory,foreign,one,three,four,lookups,errors ++ error,Phase.inspect(~S,I.Fresh{},lookups,W.barrier(~S,~A.Store<S,D.Components<S>>,~D.Resources,~A.Notice<S,D.FixtureEvent>,world)))
def prepared(~S:Data,pair:Pairing.WorldPair<S>) -> Delivery<S>:
  match pair:
    case Pairing.WorldPair{factory,world,foreign,+one,two,+three,+four,lookups,errors}:initialized(~S,factory,foreign,one,three,four,lookups,errors,Mutation.initial(~S,world,one,two,three,four))
    case pair:SetupRefused{pair}
def run(~S:Data,base:U32) -> Delivery<S>:
  prepared(~S,Pairing.build(~S,base))
def workshop() -> Delivery<D.Workshop>:
  run(~D.Workshop,0)
def garden() -> Delivery<D.Garden>:
  run(~D.Garden,100)
