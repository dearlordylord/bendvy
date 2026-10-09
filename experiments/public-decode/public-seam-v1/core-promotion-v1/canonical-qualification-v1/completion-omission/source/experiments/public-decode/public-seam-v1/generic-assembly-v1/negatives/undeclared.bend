import Base
import ../public-fixture.bend as Public
import /workspace/formal-proofs/bendvy-worktrees/ordinary-snapshot-integration/src/ecs/decode-declaration.bend as Declared
import /workspace/formal-proofs/bendvy-worktrees/ordinary-snapshot-integration/src/ecs/decode-requests.bend as Request
import ../second-owner.bend as B
import /workspace/formal-proofs/bendvy-worktrees/ordinary-snapshot-integration/src/ecs/decode-owned-component.bend as Write
import /workspace/formal-proofs/bendvy-worktrees/ordinary-snapshot-integration/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy-worktrees/ordinary-snapshot-integration/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy-worktrees/ordinary-snapshot-integration/src/ecs/compose.bend as Query
import ../../../complete-v1/controls.bend as First
import /workspace/formal-proofs/bendvy-worktrees/ordinary-snapshot-integration/src/ecs/decode-data.bend as D
def body(~H:Type,~cap:Unit,owner:B.Owner,ctx:H) -> H & Request.Output<Unit,B.Owner>:
  Cap.owned_request(~H,~B.Owner,~Request.Output<Unit,B.Owner>,~cap,ctx,owner)
def main(frame:Public.Frame(),owner:B.Owner) -> Public.Frame() & Request.Output<Unit,B.Owner>:
  Cap.invoke_owned(~(H => Unit),~B.Owner,~Request.Output<Unit,B.Owner>,~(H => cap => owner => ctx => body(~H,~cap,owner,ctx)),~Public.Frame(),~Unit{},owner,frame)
