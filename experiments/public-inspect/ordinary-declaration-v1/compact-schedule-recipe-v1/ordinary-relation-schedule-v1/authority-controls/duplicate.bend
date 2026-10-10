import Base
import ../consumer-public.bend as Consumer
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-relation-schedule.bend as Relation
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
type Schema is Data:
  Schema{}
def duplicated(app:Consumer.Application(~Schema)) -> Consumer.Application(~Schema) & Consumer.Application(~Schema):
  (app,app)
def main() -> Unit:
  Unit{}
