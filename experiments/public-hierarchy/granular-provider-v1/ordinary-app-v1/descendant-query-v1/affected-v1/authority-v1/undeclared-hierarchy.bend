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
def wrong(world:C.World(~C.Alpha),owners:Array<U32>) -> C.Application(~C.Alpha) & String:
  C.visit(~C.Alpha,"WRONG",Build.Registered{world,owners,Tree.Recipe{},False{}},Traversal.Depth{},False{})
def main() -> Unit: Unit{}
