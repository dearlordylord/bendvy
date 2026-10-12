import Base
import /workspace/formal-proofs/bendvy/experiments/public-hierarchy/granular-provider-v1/ordinary-app-v1/consumer.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-hierarchy.bend as App
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/relation-types.bend as G
import /workspace/formal-proofs/bendvy/src/ecs/relation-reorder.bend as Reorder
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as Tx
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/experiments/public-hierarchy/public-delivery-v1/owners.bend as O
def wrong(app:C.Application(~C.Alpha),target:W.Handle<C.Beta>) -> C.Application(~C.Alpha) & DTO.Product<A.QueueStatus,Tx.Outcome<Unit>>:
  App.reorder_app(~C.Alpha,~O.Components<C.Alpha>,~Array<U32>,~U32,~C.hierarchy(~C.Alpha),~Array<U32>,~String,~C.prior(~C.Alpha),~C.fold(~C.Alpha),~Unit,app,Reorder.Args{target,[]},Tx.Success{})
def main() -> Unit: Unit{}
