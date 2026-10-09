import Base
import ../assembly.bend as A
import ../fixture.bend as F
import ../../generic-assembly-v1/request.bend as Request
import ../../generic-assembly-v1/second-owner.bend as P
import /workspace/formal-proofs/bendvy/experiments/public-decode/complete-v1/controls.bend as R
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/bundle-requests.bend as Commands
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1/core-promotion-v1/library/decode-data.bend as D
def body(~H:Type,~cap:Unit,input:Request.Input<Unit,P.Owner>,ctx:H) -> H & Request.Output<Unit,P.Owner>:
  Cap.owned_request(~H,~Request.Input<Unit,P.Owner>,~Request.Output<Unit,P.Owner>,~cap,ctx,input)
def main(owner:F.Owner(),input:Request.Input<Unit,P.Owner>) -> F.Owner() & Request.Output<Unit,P.Owner>:
  A.invoke(~Unit,~P.Store(),~R.Owner,~Unit,~P.Owner,~P.identity(),~P.project,~Request.Input<Unit,P.Owner>,~Request.Output<Unit,P.Owner>,~(H => ops => input => ctx => body(~H,~Unit{},input,ctx)),owner,input)
