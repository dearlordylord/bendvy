import check-observation.bend as CheckObservation
import Base
import ../fixture-phase.bend as Phase
import ../consumer.bend as Consumer
import ../../../fixture-schema.bend as D
import ../../../core-v1/src/ecs/check.bend as K
import ../../../core-v1/src/ecs/world.bend as W
import ../../../core-v1/src/ecs/relation-commands.bend as A

type Observed<S:Data> is Type:
  Observed{world:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,check:CheckObservation.Observation,value:Result<&2,&2,String,Phase.Phase<S>>}
def observed(~S:Data,check:Result<&2,&2,K.Error,Bool>,diagnostic:Phase.Observed<S>) -> Observed<S>:
  match diagnostic:
    case Phase.Observed{world,value}:Observed{world,CheckObservation.from_result(check),value}
def checked(~S:Data,targets:List<&2,W.Handle<S>>,result:K.Checked<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>) -> Observed<S>:
  match result:
    case K.Checked{world,check}:observed(~S,check,Phase.observe_world(~S,targets,world))
def observe_world(~S:Data,expected:String,+targets:List<&2,W.Handle<S>>,world:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>) -> Observed<S>:
  checked(~S,targets,Consumer.run(~S,Consumer.Args{targets,expected},world))
