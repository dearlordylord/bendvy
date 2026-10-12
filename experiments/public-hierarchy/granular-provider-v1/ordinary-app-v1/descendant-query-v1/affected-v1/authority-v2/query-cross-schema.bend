import Base
import ./support.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-hierarchy-query.bend as Visit
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-recipe.bend as Tree
import /workspace/formal-proofs/bendvy/src/ecs/hierarchy-provider.bend as Path
import /workspace/formal-proofs/bendvy/src/ecs/hierarchy-traversal.bend as Traversal
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as Tx
def wrong(app:C.Application(~C.Alpha)) -> C.Application(~C.Alpha) & DTO.Product<Maybe<&2,Path.Path<C.Alpha>>,Maybe<&2,DTO.Product<Tx.Outcome<Q.Error<Unit>>,List<&2,U32>>>>:
  Visit.visit_descendants_app(~C.Alpha,~Array<U32>,~Array<U32>,~U32,~C.hierarchy(~C.Alpha),~Array<U32>,~Unit,~C.prior(~C.Alpha),~C.fold(~C.Alpha),~C.Ops(~C.Alpha),~Unit,~Unit,~U32,~C.query(~C.Beta),~C.body(~C.Alpha),app,W.Handle{1,1},Traversal.Depth{},Unit{},0)
def main() -> Unit: Unit{}
