import Base
import /workspace/formal-proofs/bendvy-worktrees/parity-46-public-seam/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/reached-mutations-v1/partial-write/core/decode-construction.bend as Constructor
import /workspace/formal-proofs/bendvy-worktrees/parity-46-public-seam/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/reached-mutations-v1/partial-write/core/decode-validated-resource.bend as Resource
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-declaration.bend as Identity
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/bundle-construction.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap

type Output<I:Type,R:Type> is Type:
  Replaced{canonical:D.Raw,undo:R -> I}
  Refused{owner:I,error:D.Error}
def returned(~I:Type,~R:Type,~H:Type,undo:R -> I,result:H & Resource.Output<R>) -> H & Output<I,R>:
  match result:
    case (ctx,Resource.Replaced{canonical}):(ctx,Replaced{canonical,undo})
    case (ctx,Resource.Refused{owner,error}):(ctx,Refused{undo(owner),error})
def constructed(~I:Type,~R:Type,~H:Type,~request:Cap.OwnedRequest<H,R,Resource.Output<R>>,ctx:H,value:Build.Construction<I,R,D.Error>) -> H & Output<I,R>:
  match value:
    case Build.Invalid{owner,error}:(ctx,Refused{owner,error})
    case Build.Constructed{owner,undo}:returned(~I,~R,~H,undo,Cap.owned_request(~H,~R,~Resource.Output<R>,~request,ctx,owner))
def apply(~S:Data,~I:Type,~R:Type,~identity:Identity.Declaration<S,R>,~project:R -> R & D.Raw,~incoming:I -> I & D.Raw,~build:I -> D.Raw -> Build.Construction<I,R,D.Error>,~factory:Constructor.Factory<S,I,R,identity,project,incoming,build>,~H:Type,~request:Cap.OwnedRequest<H,R,Resource.Output<R>>,ctx:H,input:I) -> H & Output<I,R>:
  constructed(~I,~R,~H,~request,ctx,Constructor.construct(~S,~I,~R,~identity,~project,~incoming,~build,factory,input))
def grant(~S:Data,~I:Type,~R:Type,~identity:Identity.Declaration<S,R>,~project:R -> R & D.Raw,~incoming:I -> I & D.Raw,~build:I -> D.Raw -> Build.Construction<I,R,D.Error>,~factory:Constructor.Factory<S,I,R,identity,project,incoming,build>,~H:Type,~request:Cap.OwnedRequest<H,R,Resource.Output<R>>) -> Cap.OwnedRequest<H,I,Output<I,R>>:
  Cap.OwnedRequest{ctx => input => apply(~S,~I,~R,~identity,~project,~incoming,~build,~factory,~H,~request,ctx,input)}
