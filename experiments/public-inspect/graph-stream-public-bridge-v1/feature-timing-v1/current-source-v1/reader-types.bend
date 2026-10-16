import Base
import ../../../../../src/ecs/machine.bend as M
import ../../../../../src/ecs/event-runtime.bend as Ev
import ../../../../../src/ecs/relation-types.bend as G
import ./state.bend as State

type Streams<S:Data> is Data:
  Streams{flowCurrent:M.CurrentView<S,State.FlowToken,U32>,levelCurrent:M.CurrentView<S,State.LevelToken,U32>,flow:Ev.Reading<M.Transition<U32>>,level:Ev.Reading<M.Transition<U32>>,parentFailures:List<&2,G.Failure<S>>,parentLagged:Bool}
