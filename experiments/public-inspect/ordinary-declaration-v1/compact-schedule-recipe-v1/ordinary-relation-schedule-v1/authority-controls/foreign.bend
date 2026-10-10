import Base
import ../consumer-public.bend as Consumer
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-relation-schedule.bend as Relation
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import ../state.bend as State
type Schema is Data:
  Schema{}
type Other is Data:
  Other{}
def foreign(app:Consumer.Application(~Schema)) -> Unit:
  Relation.snapshot(~Other,~Unit,~State.Resources<Other>,~U32,~Consumer.declaration(~Other),~W.Handle{1,2},app,True{})
def main() -> Unit:
  Unit{}
