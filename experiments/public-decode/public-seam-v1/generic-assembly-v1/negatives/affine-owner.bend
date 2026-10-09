import Base
import ../public-fixture.bend as Public
import ../declared.bend as Declared
import ../request.bend as Request
import ../second-owner.bend as B
import ../owned-component.bend as Write
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Query
import /workspace/formal-proofs/bendvy/experiments/public-decode/complete-v1/controls.bend as First
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1/core-promotion-v1/library/decode-data.bend as D
type Duplicated is Type:Duplicated{first:B.Owner,second:B.Owner}
def body(~H:Type,~ops:Public.Ops(~H),owner:B.Owner,ctx:H) -> H & Duplicated:
  (ctx,Duplicated{owner,owner})
def main(frame:Public.Frame(),owner:B.Owner) -> Public.Frame() & Duplicated:
  Declared.invoke(~Unit,~B.Store(),~First.Owner,~Unit,~B.Owner,~B.Recovery(),~D.Raw,~Unit,~Unit,~B.identity(),~B.project,~B.project,~B.take,~B.put,~B.install,~B.Owner,~Duplicated,~(H => ops => owner => ctx => body(~H,~ops,owner,ctx)),frame,owner)
