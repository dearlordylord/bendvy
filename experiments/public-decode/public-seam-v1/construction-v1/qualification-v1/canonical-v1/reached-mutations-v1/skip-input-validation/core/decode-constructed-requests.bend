import Base
import /workspace/formal-proofs/bendvy-worktrees/parity-46-public-seam/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/reached-mutations-v1/skip-input-validation/core/decode-construction.bend as Constructor
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-declaration.bend as Identity
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/bundle-construction.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/decode-requests.bend as Request
import /workspace/formal-proofs/bendvy/src/ecs/bundle-requests.bend as Commands
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap

type Input<S:Data,I:Type> is Type:Input{operation:Commands.Operation<S>,raw:I}
type Output<S:Data,I:Type,P:Type> is Type:
  Accepted{target:W.Handle<S>,spawned:Bool,canonical:D.Raw,undo:P -> I}
  Refused{owner:Maybe<&1,I>,error:Request.Error}
def refused(~S:Data,~I:Type,~P:Type,undo:P -> I,owner:Maybe<&1,P>,error:Request.Error) -> Output<S,I,P>:
  match owner:
    case None{}:Refused{None{},error}
    case Some{owner}:Refused{Some{undo(owner)},error}
def returned(~S:Data,~I:Type,~P:Type,~H:Type,undo:P -> I,result:H & Request.Output<S,P>) -> H & Output<S,I,P>:
  match result:
    case (ctx,Request.Accepted{target,spawned,canonical}):(ctx,Accepted{target,spawned,canonical,undo})
    case (ctx,Request.Refused{owner,error}):(ctx,refused(~S,~I,~P,undo,owner,error))
def constructed(~S:Data,~I:Type,~P:Type,~H:Type,~request:Cap.OwnedRequest<H,Request.Input<S,P>,Request.Output<S,P>>,ctx:H,operation:Commands.Operation<S>,result:Build.Construction<I,P,D.Error>) -> H & Output<S,I,P>:
  match result:
    case Build.Invalid{owner,error}:(ctx,Refused{Some{owner},Request.Validation{error}})
    case Build.Constructed{owner,undo}:returned(~S,~I,~P,~H,undo,Cap.owned_request(~H,~Request.Input<S,P>,~Request.Output<S,P>,~request,ctx,Request.Input{operation,owner}))
def apply(~S:Data,~I:Type,~P:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~incoming:I -> I & D.Raw,~build:I -> D.Raw -> Build.Construction<I,P,D.Error>,~factory:Constructor.Factory<S,I,P,identity,project,incoming,build>,~H:Type,~request:Cap.OwnedRequest<H,Request.Input<S,P>,Request.Output<S,P>>,ctx:H,input:Input<S,I>) -> H & Output<S,I,P>:
  match input:
    case Input{operation,raw}:constructed(~S,~I,~P,~H,~request,ctx,operation,Constructor.construct(~S,~I,~P,~identity,~project,~incoming,~build,factory,raw))
def grant(~S:Data,~I:Type,~P:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~incoming:I -> I & D.Raw,~build:I -> D.Raw -> Build.Construction<I,P,D.Error>,~factory:Constructor.Factory<S,I,P,identity,project,incoming,build>,~H:Type,~request:Cap.OwnedRequest<H,Request.Input<S,P>,Request.Output<S,P>>) -> Cap.OwnedRequest<H,Input<S,I>,Output<S,I,P>>:
  Cap.OwnedRequest{ctx => input => apply(~S,~I,~P,~identity,~project,~incoming,~build,~factory,~H,~request,ctx,input)}
