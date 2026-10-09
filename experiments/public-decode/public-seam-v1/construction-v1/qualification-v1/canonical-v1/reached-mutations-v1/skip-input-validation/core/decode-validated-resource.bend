import Base
import /workspace/formal-proofs/bendvy/src/ecs/decode-frame.bend as F
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-declaration.bend as Identity
import /workspace/formal-proofs/bendvy/src/ecs/persistence-declaration.bend as Decl
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap

type Output<R:Type> is Type:
  Replaced{canonical:D.Raw}
  Refused{owner:R,error:D.Error}
def replaced(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Q:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,canonical:D.Raw,result:F.Frame<S,C,R,E,P,Q,identity,project> & Unit) -> F.Frame<S,C,R,E,P,Q,identity,project> & Output<R>:
  match result:
    case (frame,_):(frame,Replaced{canonical})
def checked(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Q:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,frame:F.Frame<S,C,R,E,P,Q,identity,project>,receipt:D.Receipt<R>) -> F.Frame<S,C,R,E,P,Q,identity,project> & Output<R>:
  match receipt:
    case D.Receipt{owner,D.Rejected{error}}:(frame,Refused{owner,error})
    case D.Receipt{owner,D.Accepted{canonical}}:replaced(~S,~C,~R,~E,~P,~Q,~identity,~project,canonical,F.resource_set(~S,~C,~R,~E,~P,~Q,~identity,~project,frame,owner))
def request(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Q:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~resource_identity:Identity.Declaration<S,R>,~resource_project:R -> R & D.Raw,declaration:Decl.Constructed<S,R,resource_identity,resource_project>,frame:F.Frame<S,C,R,E,P,Q,identity,project>,replacement:R) -> F.Frame<S,C,R,E,P,Q,identity,project> & Output<R>:
  checked(~S,~C,~R,~E,~P,~Q,~identity,~project,frame,Decl.validate(~S,~R,~resource_identity,~resource_project,declaration,replacement))
def grant(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Q:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~resource_identity:Identity.Declaration<S,R>,~resource_project:R -> R & D.Raw,~declaration:Decl.Constructed<S,R,resource_identity,resource_project>) -> Cap.OwnedRequest<F.Frame<S,C,R,E,P,Q,identity,project>,R,Output<R>>:
  Cap.OwnedRequest{frame => replacement => request(~S,~C,~R,~E,~P,~Q,~identity,~project,~resource_identity,~resource_project,declaration,frame,replacement)}
