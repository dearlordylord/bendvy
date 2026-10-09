import Base
import /workspace/formal-proofs/bendvy-worktrees/parity-46-public-seam/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/reached-mutations-v1/skip-validation/core/decode-construction.bend as Constructor
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-declaration.bend as Identity
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/bundle-construction.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/decode-requests.bend as Request
import /workspace/formal-proofs/bendvy/src/ecs/bundle-requests.bend as Commands
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap

type Input<S:Data,I:Type> is Type:Input{operation:Commands.Operation<S>,raw:I}
type Error<Custom:Data> is Data:Construction{error:Constructor.Error<Custom>} Operation{error:Request.Error}
type Output<S:Data,I:Type,P:Type,Custom:Data> is Type:
  Accepted{target:W.Handle<S>,spawned:Bool,canonical:D.Raw,undo:P -> I}
  Refused{owner:Maybe<&1,I>,error:Error<Custom>}
def refused(~S:Data,~I:Type,~P:Type,~Custom:Data,undo:P -> I,owner:Maybe<&1,P>,error:Request.Error) -> Output<S,I,P,Custom>:
  match owner:
    case None{}:Refused{None{},Operation{error}}
    case Some{owner}:Refused{Some{undo(owner)},Operation{error}}
def returned(~S:Data,~I:Type,~P:Type,~Custom:Data,~H:Type,undo:P -> I,result:H & Request.Output<S,P>) -> H & Output<S,I,P,Custom>:
  match result:
    case (ctx,Request.Accepted{target,spawned,canonical}):(ctx,Accepted{target,spawned,canonical,undo})
    case (ctx,Request.Refused{owner,error}):(ctx,refused(~S,~I,~P,~Custom,undo,owner,error))
def constructed(~S:Data,~I:Type,~P:Type,~Custom:Data,~H:Type,~request:Cap.OwnedRequest<H,Request.Input<S,P>,Request.Output<S,P>>,ctx:H,operation:Commands.Operation<S>,result:Build.Construction<I,P,Constructor.Error<Custom>>) -> H & Output<S,I,P,Custom>:
  match result:
    case Build.Invalid{owner,error}:(ctx,Refused{Some{owner},Construction{error}})
    case Build.Constructed{owner,undo}:returned(~S,~I,~P,~Custom,~H,undo,Cap.owned_request(~H,~Request.Input<S,P>,~Request.Output<S,P>,~request,ctx,Request.Input{operation,owner}))
def apply(~S:Data,~I:Type,~P:Type,~Custom:Data,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~incoming:I -> I & D.Raw,~build:I -> D.Raw -> Build.Construction<I,P,Custom>,~factory:Constructor.FallibleFactory<S,I,P,Custom,identity,project,incoming,build>,~H:Type,~request:Cap.OwnedRequest<H,Request.Input<S,P>,Request.Output<S,P>>,ctx:H,input:Input<S,I>) -> H & Output<S,I,P,Custom>:
  match input:
    case Input{operation,raw}:constructed(~S,~I,~P,~Custom,~H,~request,ctx,operation,Constructor.fallible_construct(~S,~I,~P,~Custom,~identity,~project,~incoming,~build,factory,raw))
def grant(~S:Data,~I:Type,~P:Type,~Custom:Data,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~incoming:I -> I & D.Raw,~build:I -> D.Raw -> Build.Construction<I,P,Custom>,~factory:Constructor.FallibleFactory<S,I,P,Custom,identity,project,incoming,build>,~H:Type,~request:Cap.OwnedRequest<H,Request.Input<S,P>,Request.Output<S,P>>) -> Cap.OwnedRequest<H,Input<S,I>,Output<S,I,P,Custom>>:
  Cap.OwnedRequest{ctx => input => apply(~S,~I,~P,~Custom,~identity,~project,~incoming,~build,~factory,~H,~request,ctx,input)}
