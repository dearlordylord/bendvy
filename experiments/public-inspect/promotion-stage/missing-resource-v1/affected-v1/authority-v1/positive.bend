import Base
import ../../consumer-source-v1/state.bend as State
import ../../consumer-source-v1/consumer.bend as Consumer
import /workspace/formal-proofs/bendvy/src/ecs/optional-resource-binding.bend as B
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
def accepted() -> B.Binding<State.Workshop,State.Resource(~State.Workshop),Array<U32>,Unit & State.Tail(),State.payload(~State.Workshop),State.slot_lens(~State.Workshop)>:
  State.slot_binding(~State.Workshop)
