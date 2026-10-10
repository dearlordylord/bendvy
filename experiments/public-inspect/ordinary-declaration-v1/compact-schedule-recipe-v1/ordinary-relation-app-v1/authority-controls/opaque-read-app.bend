import Base
import ../consumer.bend as Consumer
import ../state.bend as State
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/relation-providers.bend as P
import /workspace/formal-proofs/bendvy/src/ecs/relation-failure-reader.bend as Ord
import /workspace/formal-proofs/bendvy/src/ecs/relation-types.bend as G
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
import ../relation-app.bend as Relation
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-records.bend as Leaf
type Schema is Data:
  Schema{}
def descriptor() -> G.Descriptor<Schema>:
  G.Descriptor{7,"Link","LinkedBy",G.Ordinary{}}

def forbidden(~H:Type,~caps:P.ReadOnly<H,Schema>,owner:H) -> Consumer.Application(~Schema) & DTO.Product<A.QueueStatus,T.Outcome<Unit>>:
  Relation.relate_app(~Schema,~State.Components<Schema>,~State.Resources<Schema>,~U32,~Consumer.declaration(~Schema),~Unit,~Unit,~Build.empty_observe(~Consumer.World(~Schema)),~Leaf.empty(~Schema),~Unit,owner,P.Targets{W.Handle{1,1},W.Handle{1,2}},T.Success{})
def main() -> String:
  "read-only system cannot obtain App owner"
