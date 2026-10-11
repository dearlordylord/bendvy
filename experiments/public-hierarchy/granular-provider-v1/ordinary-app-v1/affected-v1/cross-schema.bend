import Base
import ../consumer.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-hierarchy.bend as App
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/relation-types.bend as G
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/experiments/public-hierarchy/public-delivery-v1/owners.bend as O
def wrong(app:C.Application(~C.Alpha),target:W.Handle<C.Beta>) -> C.Application(~C.Beta) & Maybe<&2,W.Handle<C.Beta>>:
  App.root_app(~C.Beta,~O.Components<C.Beta>,~Array<U32>,~U32,~C.hierarchy(~C.Beta),~Array<U32>,~String,~C.prior(~C.Beta),~C.fold(~C.Beta),app,target)
def main() -> Unit: Unit{}
