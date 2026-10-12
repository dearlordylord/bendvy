import Base
import ../../consumer-source-v1/state.bend as State
import ../../consumer-source-v1/consumer.bend as Consumer
import /workspace/formal-proofs/bendvy/src/ecs/optional-resource-binding.bend as B
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
def wrong(app:Consumer.App1(~State.Workshop)) -> Consumer.App1(~State.Workshop) & Consumer.App1(~State.Workshop):
  (app,app)
