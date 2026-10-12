import Base
import ../../consumer-source-v1/state.bend as State
import /workspace/formal-proofs/bendvy/src/ecs/optional-resource-binding.bend as B
def wrong(index:B.Index<State.Workshop,Array<U32>,State.payload(~State.Workshop)>) -> B.Index<State.Workshop,Array<U32>,State.counter(~State.Workshop)>:
  index
