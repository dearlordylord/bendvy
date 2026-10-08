import ../phase-v2.bend as Checked
import expected-phases.bend as Expected
import Base
import ../../../../fixture-schema.bend as D
import ../../../../fixture-pair.bend as Pairing
import ../../fixture-phase.bend as Phase
import ../../../../fixture-mutations.bend as Mutation
import ../../../../core-v1/src/ecs/world.bend as W
import ../../../../core-v1/src/ecs/relation-commands.bend as A

type Delivery<S:Data> is Type:
  Delivered{factory:W.Factory,world:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,foreign:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,phases:List<&2,Phase.Phase<S>>,errors:String}
  SetupRefused{setup:Pairing.WorldPair<S>}
def last(~S:Data,~wanted:U32 -> String,factory:W.Factory,foreign:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,earlier:List<&2,Phase.Phase<S>>,errors:String,result:Phase.Observed<S>) -> Delivery<S>:
  match result:
    case Phase.Observed{world,Done{phase}}:Delivered{factory,world,foreign,List.append(&2,Phase.Phase<S>,earlier,[phase]),errors}
    case Phase.Observed{world,Fail{error}}:Delivered{factory,world,foreign,earlier,errors ++ "last-check-diagnostic-failed:" ++ error}
def second(~S:Data,~wanted:U32 -> String,factory:W.Factory,foreign:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,+lookups:List<&2,W.Handle<S>>,first:Phase.Phase<S>,errors:String,result:Phase.Observed<S>) -> Delivery<S>:
  match result:
    case Phase.Observed{world,Done{phase}}:last(~S,~wanted,factory,foreign,[first,phase],errors,Checked.observe_world(~S,wanted(2),lookups,W.barrier(~S,~A.Store<S,D.Components<S>>,~D.Resources,~A.Notice<S,D.FixtureEvent>,world)))
    case Phase.Observed{world,Fail{error}}:Delivered{factory,world,foreign,[first],errors ++ "second-check-diagnostic-failed:" ++ error}
def queued(~S:Data,~wanted:U32 -> String,factory:W.Factory,foreign:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,+lookups:List<&2,W.Handle<S>>,first:Phase.Phase<S>,errors:String,observed:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & String) -> Delivery<S>:
  (world,error)=observed
  second(~S,~wanted,factory,foreign,lookups,first,errors ++ error,Checked.observe_world(~S,wanted(1),lookups,world))
def first(~S:Data,~wanted:U32 -> String,factory:W.Factory,foreign:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,+one:W.Handle<S>,+three:W.Handle<S>,+four:W.Handle<S>,+lookups:List<&2,W.Handle<S>>,errors:String,result:Phase.Observed<S>) -> Delivery<S>:
  match result:
    case Phase.Observed{world,Done{phase}}:queued(~S,~wanted,factory,foreign,lookups,phase,errors,Mutation.changed(~S,world,one,three,four))
    case Phase.Observed{world,Fail{error}}:Delivered{factory,world,foreign,[],errors ++ "first-check-diagnostic-failed:" ++ error}
def initialized(~S:Data,~wanted:U32 -> String,factory:W.Factory,foreign:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,+one:W.Handle<S>,+three:W.Handle<S>,+four:W.Handle<S>,+lookups:List<&2,W.Handle<S>>,errors:String,observed:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & String) -> Delivery<S>:
  (world,error)=observed
  first(~S,~wanted,factory,foreign,one,three,four,lookups,errors ++ error,Checked.observe_world(~S,wanted(0),lookups,W.barrier(~S,~A.Store<S,D.Components<S>>,~D.Resources,~A.Notice<S,D.FixtureEvent>,world)))
def prepared(~S:Data,~wanted:U32 -> String,pair:Pairing.WorldPair<S>) -> Delivery<S>:
  match pair:
    case Pairing.WorldPair{factory,world,foreign,+one,two,+three,+four,lookups,errors}:initialized(~S,~wanted,factory,foreign,one,three,four,lookups,errors,Mutation.initial(~S,world,one,two,three,four))
    case pair:SetupRefused{pair}
def run(~S:Data,~wanted:U32 -> String,base:U32) -> Delivery<S>:
  prepared(~S,~wanted,Pairing.build(~S,base))
def workshop() -> Delivery<D.Workshop>:
  run(~D.Workshop,~Expected.workshop,0)
def garden() -> Delivery<D.Garden>:
  run(~D.Garden,~Expected.garden,100)
