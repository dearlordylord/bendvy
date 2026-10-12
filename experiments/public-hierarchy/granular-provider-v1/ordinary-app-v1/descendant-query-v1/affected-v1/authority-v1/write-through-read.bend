import Base
import ../../consumer.bend as C
import ../../owners.bend as O
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-hierarchy-query.bend as Visit
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-hierarchy.bend as App
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-recipe.bend as Tree
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/hierarchy-traversal.bend as Traversal
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as Tx
def wrong(~H:Type,~read:Cap.ValueRead<H,W.Handle<C.Alpha>>,owner:H) -> H:
  Cap.set(~H,~Array<U32>,~List<&2,U32>,~read,owner,ALeaf{7})
def main() -> Unit: Unit{}
