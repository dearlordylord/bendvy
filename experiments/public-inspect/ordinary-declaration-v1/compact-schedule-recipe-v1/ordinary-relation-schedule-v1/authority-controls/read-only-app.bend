import Base
import ../consumer-public.bend as Consumer
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-relation-schedule.bend as Relation
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/relation-providers.bend as P
type Schema is Data:
  Schema{}
def body(~H:Type,~caps:P.ReadOnly<H,Schema>,owner:H) -> Unit:
  Consumer.run(~Schema,owner)
def main() -> Unit:
  Unit{}
