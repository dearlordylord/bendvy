import Base
import ./assembly-frame.bend as F
import ./owned-component.bend as OwnedWrite
import ./request.bend as Request
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as Cmp
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Query
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/bundle-install.bend as Install
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1/core-promotion-v1/library/ordinary-declaration.bend as Identity
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1/core-promotion-v1/library/decode-data.bend as D
import /workspace/formal-proofs/bendvy/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/declaration.bend as Clause

type Ops<S:Data,P:Type,R:Type,V:Data,-H:Type> is Type:
  Ops{read:Cap.Read<H,V>,write:Cap.OwnedRequest<H,Query.Insert<S,P>,OwnedWrite.Output<P>>,spawn:Cap.OwnedRequest<H,P,Request.Output<S,P>>,decode:Cap.OwnedRequest<H,Request.Input<S,P>,Request.Output<S,P>>,resource:Cap.OwnedRequest<H,R,Unit>}
# One ordinary query write clause supplies nominal identity, read provider,
# membership and metadata. The owned setter uses the identical family/lenses.
def query(~S:Data,~Store:Type,~R:Type,~E:Data,~P:Type,~Q:Type,~V:Data,~Rest:Type,~Token:Data,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~view:P -> P & V,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store,~install:W.World<S,Store,R,E> -> W.Handle<S> -> Request.Packet<P> -> Install.Attempt<W.World<S,Store,R,E>,Request.Packet<P>,Q>) -> Clause.Declaration<S,Query.Frame<S,Store,R,E>,Cap.Write<Query.Frame<S,Store,R,E>,P,V>>:
  Clause.write(~S,~P,~Store,~R,~E,~Rest,~V,~Token,~identity,~view,~take,~put)

def read_grant(~S:Data,~Store:Type,~R:Type,~E:Data,~P:Type,~Q:Type,~V:Data,~Rest:Type,~Token:Data,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~view:P -> P & V,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store,~install:W.World<S,Store,R,E> -> W.Handle<S> -> Request.Packet<P> -> Install.Attempt<W.World<S,Store,R,E>,Request.Packet<P>,Q>) -> Cap.Read<Query.Frame<S,Store,R,E>,V>:
  Cap.Read{Cap.write_read_field(~Query.Frame<S,Store,R,E>,~P,~V,Clause.grant(~S,~Query.Frame<S,Store,R,E>,~Cap.Write<Query.Frame<S,Store,R,E>,P,V>,query(~S,~Store,~R,~E,~P,~Q,~V,~Rest,~Token,~identity,~project,~view,~take,~put,~install)))}

def grants(~S:Data,~Store:Type,~R:Type,~E:Data,~P:Type,~Q:Type,~V:Data,~Rest:Type,~Token:Data,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~view:P -> P & V,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store,~install:W.World<S,Store,R,E> -> W.Handle<S> -> Request.Packet<P> -> Install.Attempt<W.World<S,Store,R,E>,Request.Packet<P>,Q>) -> Ops<S,P,R,V,F.Frame<S,Store,R,E,P,Q,identity,project>>:
  Ops{F.read_grant(~S,~Store,~R,~E,~P,~Q,~V,~identity,~project,~read_grant(~S,~Store,~R,~E,~P,~Q,~V,~Rest,~Token,~identity,~project,~view,~take,~put,~install)),OwnedWrite.grant(~S,~Store,~R,~E,~P,~Q,~identity,~project,~Rest,~V,~Token,~take,~put,~view,~Cmp.Family{Identity.key(~S,~P,identity)}),F.spawn_grant(~S,~Store,~R,~E,~P,~Q,~identity,~project,~install),F.request_grant(~S,~Store,~R,~E,~P,~Q,~identity,~project),F.resource_grant(~S,~Store,~R,~E,~P,~Q,~identity,~project)}

def invoke(~S:Data,~Store:Type,~R:Type,~E:Data,~P:Type,~Q:Type,~V:Data,~Rest:Type,~Token:Data,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~view:P -> P & V,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store,~install:W.World<S,Store,R,E> -> W.Handle<S> -> Request.Packet<P> -> Install.Attempt<W.World<S,Store,R,E>,Request.Packet<P>,Q>,~A:Type,~U:Type,~body:@-H:Type -> @-ops:Ops<S,P,R,V,H> -> A -> H -> H & U,frame:F.Frame<S,Store,R,E,P,Q,identity,project>,args:A) -> F.Frame<S,Store,R,E,P,Q,identity,project> & U:
  Cap.invoke_owned(~(H => Ops<S,P,R,V,H>),~A,~U,~body,~F.Frame<S,Store,R,E,P,Q,identity,project>,~grants(~S,~Store,~R,~E,~P,~Q,~V,~Rest,~Token,~identity,~project,~view,~take,~put,~install),args,frame)

def access_clauses(~S:Data,values:List<&2,Clause.Clause<S>>) -> List<&2,String>:
  match values:
    case []:[]
    case Clause.Clause{name,_} <> rest:name <> access_clauses(~S,rest)

def access(~S:Data,~Store:Type,~R:Type,~E:Data,~P:Type,~Q:Type,~V:Data,~Rest:Type,~Token:Data,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~view:P -> P & V,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store,~install:W.World<S,Store,R,E> -> W.Handle<S> -> Request.Packet<P> -> Install.Attempt<W.World<S,Store,R,E>,Request.Packet<P>,Q>,~resource:Identity.Declaration<S,R>) -> List<&2,String>:
  List.append(&2,String,access_clauses(~S,Clause.clauses(~S,~Query.Frame<S,Store,R,E>,~Cap.Write<Query.Frame<S,Store,R,E>,P,V>,query(~S,~Store,~R,~E,~P,~Q,~V,~Rest,~Token,~identity,~project,~view,~take,~put,~install))),[Identity.key(~S,~R,resource)])
