import Base
import ../consumer.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-hierarchy.bend as App
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/relation-types.bend as G
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/experiments/public-hierarchy/public-delivery-v1/owners.bend as O
def other(~S:Data) -> G.HierarchyDescriptor<S>:
  G.HierarchyDescriptor{2,"OtherParent","OtherChildren"}
def wrong(app:C.Application(~C.Alpha),target:W.Handle<C.Alpha>) -> App.Application(~C.Alpha,~O.Components<C.Alpha>,~Array<U32>,~U32,~other(~C.Alpha),~Array<U32>,~String,~C.prior(~C.Alpha),~C.fold(~C.Alpha)) & Maybe<&2,W.Handle<C.Alpha>>:
  App.root_app(~C.Alpha,~O.Components<C.Alpha>,~Array<U32>,~U32,~other(~C.Alpha),~Array<U32>,~String,~C.prior(~C.Alpha),~C.fold(~C.Alpha),app,target)
def main() -> Unit: Unit{}
