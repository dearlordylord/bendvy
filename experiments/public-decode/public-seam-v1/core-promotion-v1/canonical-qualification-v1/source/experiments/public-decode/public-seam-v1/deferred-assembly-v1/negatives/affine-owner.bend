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
type Duplicated is Type:Duplicated{first:P.Owner,second:P.Owner}
def body(~H:Type,~ops:F.Ops(~H),owner:P.Owner,ctx:H) -> H & Duplicated:(ctx,Duplicated{owner,owner})
def main(owner:F.Owner(),payload:P.Owner) -> F.Owner() & Duplicated:
  A.invoke(~Unit,~P.Store(),~R.Owner,~Unit,~P.Owner,~P.identity(),~P.project,~P.Owner,~Duplicated,~(H => ops => payload => ctx => body(~H,~ops,payload,ctx)),owner,payload)
