import Base
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as Cmp
import ./public-fixture.bend as Public
import ./declared.bend as Declared
import ./request.bend as Request
import ./second-owner.bend as B
import ./owned-component.bend as Write
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Query
import /workspace/formal-proofs/bendvy/experiments/public-decode/complete-v1/controls.bend as First
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1/core-promotion-v1/library/decode-data.bend as D
def body(~H:Type,~cap:Cap.Read<H,D.Raw>,owner:B.Owner,ctx:H) -> H & Cmp.Access<D.Raw>:
  Cap.read(~H,~D.Raw,~cap,ctx)
def main(frame:Public.Frame(),owner:B.Owner) -> Public.Frame() & Cmp.Access<D.Raw>:
  Declared.invoke_readonly(~Unit,~B.Store(),~First.Owner,~Unit,~B.Owner,~B.Recovery(),~D.Raw,~Unit,~Unit,~B.identity(),~B.project,~B.project,~B.take,~B.put,~B.install,~B.Owner,~Cmp.Access<D.Raw>,~(H => cap => owner => ctx => body(~H,~cap,owner,ctx)),frame,owner)
