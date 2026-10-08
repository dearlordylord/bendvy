import Base
import ../fixture-phase.bend as Phase
import ../consumer.bend as Consumer
import ../../../fixture-schema.bend as D
import ../../../core-v1/src/ecs/check.bend as K
import ../../../core-v1/src/ecs/world.bend as W
import ../../../core-v1/src/ecs/relation-commands.bend as A

def checked(~S:Data,targets:List<&2,W.Handle<S>>,result:K.Checked<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>) -> Phase.Observed<S>:
  match result:
    case K.Checked{world,Done{True{}}}:Phase.observe_world(~S,targets,world)
    case K.Checked{world,Done{False{}}}:Phase.Observed{world,Fail{"FullCheckPredicateMismatch"}}
    case K.Checked{world,Fail{_}}:Phase.Observed{world,Fail{"FullCheckPreflightRefused"}}
def observe_world(~S:Data,expected:String,+targets:List<&2,W.Handle<S>>,world:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>) -> Phase.Observed<S>:
  checked(~S,targets,Consumer.run(~S,Consumer.Args{targets,expected},world))
