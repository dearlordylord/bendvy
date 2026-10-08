import Base
import fixture-driver.bend as Driver
import ../../fixture-phase.bend as Phase
import ../../fixture-snapshot.bend as Snap
import ../../gated-observe.bend as Gate
import gated-condition.bend as Condition
import ../../../../fixture-schema.bend as D
import ../../../../core-v1/src/ecs/check.bend as K
import ../../../../core-v1/src/ecs/world.bend as W
import ../../../../core-v1/src/ecs/relation-commands.bend as A

type Delivery<S:Data> is Type:
  Delivered{factory:W.Factory,primary:Gate.Observed<S>,foreign:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,phases:List<&2,Phase.Phase<S>>,foreignBefore:Snap.Snapshot<S>,foreignAfter:Snap.Snapshot<S>,errors:String}
  SetupRefused{original:Driver.Delivery<S>}
def final(~S:Data,factory:W.Factory,primary:Gate.Observed<S>,phases:List<&2,Phase.Phase<S>>,first:Snap.Snapshot<S>,errors:String,result:K.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & Snap.Snapshot<S>) -> Delivery<S>:
  match result:
    case (K.Frame{world},last):Delivered{factory,primary,world,phases,first,last,errors}
def before(~S:Data,~condition:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> -> U32 -> W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & Bool,factory:W.Factory,world:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,phases:List<&2,Phase.Phase<S>>,errors:String,result:K.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & Snap.Snapshot<S>) -> Delivery<S>:
  match result:
    case (K.Frame{foreign},first):final(~S,factory,Gate.run(~S,~condition,world),phases,first,errors,Snap.observe(~S,K.Frame{foreign}))
def run(~S:Data,~condition:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> -> U32 -> W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & Bool,original:Driver.Delivery<S>) -> Delivery<S>:
  match original:
    case Driver.Delivered{factory,world,foreign,phases,errors}:before(~S,~condition,factory,world,phases,errors,Snap.observe(~S,K.Frame{foreign}))
    case original:SetupRefused{original}
def workshop() -> Delivery<D.Workshop>:
  run(~D.Workshop,~Condition.workshop,Driver.workshop())
def garden() -> Delivery<D.Garden>:
  run(~D.Garden,~Condition.garden,Driver.garden())
