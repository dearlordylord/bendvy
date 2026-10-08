import Base
import consumer.bend as Consumer
import ../../fixture-schema.bend as D
import ../../core-v1/src/ecs/check.bend as K
import ../../core-v1/src/ecs/world.bend as W
import ../../core-v1/src/ecs/relation-commands.bend as A

# Trusted schedule condition unwraps actual Check.run; gameplay has no Frame.
# A failed requirement rejects the condition without fabricating a success.
def finished(~S:Data,result:K.Checked<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>) -> W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & Bool:
  match result:
    case K.Checked{world,Done{allowed}}:(world,allowed)
    case K.Checked{world,Fail{_}}:(world,False{})
def condition(~S:Data,args:Consumer.Args<S>,world:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>) -> W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & Bool:
  finished(~S,Consumer.run(~S,args,world))
