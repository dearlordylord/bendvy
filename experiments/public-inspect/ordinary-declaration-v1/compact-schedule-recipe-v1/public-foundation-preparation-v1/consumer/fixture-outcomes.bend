import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-dispatch-result.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
def component_outcome(~S:Data,~C:Type,~R:Type,~E:Data,~CE:Data,~CO:Data,~RE:Data,~RO:Type,outcome:Sys.Outcome<W.World<S,C,R,E>,CE,List<&2,CO>>) -> Sys.Outcome<W.World<S,C,R,E>,D.Error<CE,RE>,D.Output<CO,RO>>:
  match outcome:
    case Sys.Succeeded{world,value}:Sys.Succeeded{world,D.ComponentOutput{value}}
    case Sys.Failed{world,error}:Sys.Failed{world,D.ComponentError{error}}
def resource_outcome(~S:Data,~C:Type,~R:Type,~E:Data,~CE:Data,~CO:Data,~RE:Data,~RO:Type,outcome:Sys.Outcome<W.World<S,C,R,E>,RE,RO>) -> Sys.Outcome<W.World<S,C,R,E>,D.Error<CE,RE>,D.Output<CO,RO>>:
  match outcome:
    case Sys.Succeeded{world,value}:Sys.Succeeded{world,D.ResourceOutput{value}}
    case Sys.Failed{world,error}:Sys.Failed{world,D.ResourceError{error}}
