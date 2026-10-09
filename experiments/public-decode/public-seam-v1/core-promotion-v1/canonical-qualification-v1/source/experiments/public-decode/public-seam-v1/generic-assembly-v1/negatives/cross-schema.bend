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
type Other is Data:Other{}
type Args is Type:Args{target:W.Handle<Other>,owner:B.Owner}
def write_field(~H:Type,ops:Public.Ops(~H)) -> Cap.OwnedRequest<H,Query.Insert<Unit,B.Owner>,Write.Output<B.Owner>>:
  match ops:
    case Declared.Ops{_,cap,_,_,_}:cap
def body(~H:Type,~ops:Public.Ops(~H),args:Args,ctx:H) -> H & Write.Output<B.Owner>:
  match args:
    case Args{target,owner}:Cap.owned_request(~H,~Query.Insert<Unit,B.Owner>,~Write.Output<B.Owner>,~write_field(~H,ops),ctx,Query.Insert{target,owner})
def main(frame:Public.Frame(),args:Args) -> Public.Frame() & Write.Output<B.Owner>:
  Declared.invoke(~Unit,~B.Store(),~First.Owner,~Unit,~B.Owner,~B.Recovery(),~D.Raw,~Unit,~Unit,~B.identity(),~B.project,~B.project,~B.take,~B.put,~B.install,~Args,~Write.Output<B.Owner>,~(H => ops => args => ctx => body(~H,~ops,args,ctx)),frame,args)
