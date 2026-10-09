import Base
import ../assembly.bend as A
import ../fixture.bend as F
import /workspace/formal-proofs/bendvy-worktrees/ordinary-snapshot-integration/src/ecs/decode-requests.bend as Request
import ../../generic-assembly-v1/second-owner.bend as P
import ../../../complete-v1/controls.bend as R
import /workspace/formal-proofs/bendvy-worktrees/ordinary-snapshot-integration/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy-worktrees/ordinary-snapshot-integration/src/ecs/bundle-requests.bend as Commands
import /workspace/formal-proofs/bendvy-worktrees/ordinary-snapshot-integration/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy-worktrees/ordinary-snapshot-integration/src/ecs/decode-data.bend as D
def body(~H:Type,~cap:Cap.Read<H,D.Raw>,input:Request.Input<Unit,P.Owner>,ctx:H) -> H & Request.Output<Unit,P.Owner>:
  Cap.owned_request(~H,~Request.Input<Unit,P.Owner>,~Request.Output<Unit,P.Owner>,~cap,ctx,input)
def main(owner:F.Owner(),input:Request.Input<Unit,P.Owner>) -> F.Owner() & Request.Output<Unit,P.Owner>:
  A.invoke(~Unit,~P.Store(),~R.Owner,~Unit,~P.Owner,~P.identity(),~P.project,~Request.Input<Unit,P.Owner>,~Request.Output<Unit,P.Owner>,~(H => ops => input => ctx => body(~H,~Cap.Read{ctx => (ctx,Cmp.Missing{})},input,ctx)),owner,input)
