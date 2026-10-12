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
def wrong(app:C.Application(~C.Alpha)) -> C.Application(~C.Alpha) & String:
  C.visit_done(~C.Alpha,"WRONG",Visit.visit_descendants_app(~C.Alpha,~O.Components<C.Alpha>,~Array<U32>,~U32,~C.hierarchy(~C.Alpha),~Array<U32>,~String,~C.prior(~C.Alpha),~C.fold(~C.Alpha),~C.Ops(~C.Alpha),~Bool,~U32,~String,~C.query(~C.Beta),~C.body(~C.Alpha),app,W.Handle{1,1},Traversal.Depth{},False{},0))
def main() -> Unit: Unit{}
