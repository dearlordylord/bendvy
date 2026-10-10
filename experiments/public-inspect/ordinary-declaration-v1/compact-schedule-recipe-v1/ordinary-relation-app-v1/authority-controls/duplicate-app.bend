import Base
import ../consumer.bend as Consumer
import ../relation-app.bend as Relation
import ../state.bend as State
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/relation-types.bend as G
import /workspace/formal-proofs/bendvy/src/ecs/relation-failure-reader.bend as Ord
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-records.bend as Leaf
type Schema is Data:
  Schema{}
def forbidden(app:Consumer.Application(~Schema)) -> Consumer.Application(~Schema) & Consumer.Application(~Schema):
  (app,app)
def main() -> String:
  "source authority control"
