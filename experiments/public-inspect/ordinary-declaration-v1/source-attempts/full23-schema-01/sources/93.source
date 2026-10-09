import Base
import ./decode-frame.bend as F
import ./decode-owned-component.bend as OwnedWrite
import ./decode-requests.bend as Request
import ./world.bend as W
import ./column.bend as Col
import ./component.bend as Cmp
import ./compose.bend as Query
import ./capabilities.bend as Cap
import ./bundle-install.bend as Install
import ./ordinary-declaration.bend as Identity
import ./decode-data.bend as D
import ./ordinary-query-declaration.bend as Clause

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

# Read-only assembly grants no owned writer/spawn/resource capability.
def readonly_query(~S:Data,~Store:Type,~R:Type,~E:Data,~P:Type,~Q:Type,~V:Data,~Rest:Type,~Token:Data,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~view:P -> P & V,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store,~install:W.World<S,Store,R,E> -> W.Handle<S> -> Request.Packet<P> -> Install.Attempt<W.World<S,Store,R,E>,Request.Packet<P>,Q>) -> Clause.Declaration<S,Query.Frame<S,Store,R,E>,Cap.Read<Query.Frame<S,Store,R,E>,V>>:
  Clause.read(~S,~P,~Store,~R,~E,~Rest,~V,~Token,~identity,~view,~take,~put)
def readonly_grant(~S:Data,~Store:Type,~R:Type,~E:Data,~P:Type,~Q:Type,~V:Data,~Rest:Type,~Token:Data,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~view:P -> P & V,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store,~install:W.World<S,Store,R,E> -> W.Handle<S> -> Request.Packet<P> -> Install.Attempt<W.World<S,Store,R,E>,Request.Packet<P>,Q>) -> Cap.Read<F.Frame<S,Store,R,E,P,Q,identity,project>,V>:
  F.read_grant(~S,~Store,~R,~E,~P,~Q,~V,~identity,~project,~Clause.grant(~S,~Query.Frame<S,Store,R,E>,~Cap.Read<Query.Frame<S,Store,R,E>,V>,readonly_query(~S,~Store,~R,~E,~P,~Q,~V,~Rest,~Token,~identity,~project,~view,~take,~put,~install)))
def invoke_readonly(~S:Data,~Store:Type,~R:Type,~E:Data,~P:Type,~Q:Type,~V:Data,~Rest:Type,~Token:Data,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~view:P -> P & V,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store,~install:W.World<S,Store,R,E> -> W.Handle<S> -> Request.Packet<P> -> Install.Attempt<W.World<S,Store,R,E>,Request.Packet<P>,Q>,~A:Type,~U:Type,~body:@-H:Type -> @-cap:Cap.Read<H,V> -> A -> H -> H & U,frame:F.Frame<S,Store,R,E,P,Q,identity,project>,args:A) -> F.Frame<S,Store,R,E,P,Q,identity,project> & U:
  Cap.invoke_owned(~(H => Cap.Read<H,V>),~A,~U,~body,~F.Frame<S,Store,R,E,P,Q,identity,project>,~readonly_grant(~S,~Store,~R,~E,~P,~Q,~V,~Rest,~Token,~identity,~project,~view,~take,~put,~install),args,frame)
