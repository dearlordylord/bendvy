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
type Duplicated is Type:Duplicated{first:B.Owner,second:B.Owner}
def body(~H:Type,~ops:Public.Ops(~H),owner:B.Owner,ctx:H) -> H & Duplicated:
  (ctx,Duplicated{owner,owner})
def main(frame:Public.Frame(),owner:B.Owner) -> Public.Frame() & Duplicated:
  Declared.invoke(~Unit,~B.Store(),~First.Owner,~Unit,~B.Owner,~B.Recovery(),~D.Raw,~Unit,~Unit,~B.identity(),~B.project,~B.project,~B.take,~B.put,~B.install,~B.Owner,~Duplicated,~(H => ops => owner => ctx => body(~H,~ops,owner,ctx)),frame,owner)
