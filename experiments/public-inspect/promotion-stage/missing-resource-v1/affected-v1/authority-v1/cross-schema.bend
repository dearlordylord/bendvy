import Base
import ../../consumer-source-v1/state.bend as State
import ../../consumer-source-v1/consumer.bend as Consumer
import /workspace/formal-proofs/bendvy/src/ecs/optional-resource-binding.bend as B
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
def wrong() -> B.Binding<State.Garden,State.Resource(~State.Garden),Array<U32>,Unit & State.Tail(),State.payload(~State.Garden),State.slot_lens(~State.Garden)>:
  State.slot_binding(~State.Workshop)
