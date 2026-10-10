import Base
import ../consumer-public.bend as Consumer
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-relation-schedule.bend as Relation
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import ../state.bend as State
import /workspace/formal-proofs/bendvy/src/ecs/relation-failure-reader.bend as Ord
import /workspace/formal-proofs/bendvy/src/ecs/relation-types.bend as G
type Schema is Data:
  Schema{}
def different(app:Consumer.Application(~Schema)) -> Unit:
  Relation.snapshot(~Schema,~Unit,~State.Resources<Schema>,~U32,~Ord.relation(~Schema,G.Descriptor{8,"OtherLink","OtherLinkedBy",G.Ordinary{}}),~W.Handle{1,2},app,True{})
def main() -> Unit:
  Unit{}
