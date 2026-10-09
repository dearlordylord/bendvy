import Base
import ../../../../../library/decode-requests.bend as Request
import ../../../../../dependencies/snapshot/persistence-declaration.bend as Decl
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/bundle-batch.bend as Batch
import /workspace/formal-proofs/bendvy/src/ecs/bundle-delivery.bend as Delivery
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Query
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as C
import ../../../../../dependencies/query/ordinary-query-declaration.bend as Clause
import ../../../../../dependencies/snapshot/ordinary-declaration.bend as Identity
import ../../../../../dependencies/snapshot/decode-data.bend as D

# Application-selected mailbox. Only value participates in the resource undo;
# displaced component owners and refused delivery packets survive independently.
type Mail<R:Type,P:Type> is Type:Mail{value:R,retired:List<P>,returned:List<Request.Packet<P>>,errors:List<&2,W.WorldError>}
type Ops<S:Data,P:Type,R:Type,-H:Type> is Type:Ops{decode:Cap.OwnedRequest<H,Request.Input<S,P>,Request.Output<S,P>>,resource:Cap.OwnedRequest<H,R,Unit>}
def retire(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,previous:Maybe<&1,P>,world:W.World<S,C,Mail<R,P>,E>) -> W.World<S,C,Mail<R,P>,E>:
  match previous world:
    case None{} world:world
    case Some{old} W.World{ns,next,high,live,capacity,depth,store,Mail{value,retired,returned,errors},events,commands,registrations,system,clock}:W.World{ns,next,high,live,capacity,depth,store,Mail{value,old <> retired,returned,errors},events,commands,registrations,system,clock}
def recover(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,world:W.World<S,C,Mail<R,P>,E>,packet:Request.Packet<P>,error:W.WorldError) -> W.World<S,C,Mail<R,P>,E>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,Mail{value,retired,returned,errors},events,commands,registrations,system,clock}:W.World{ns,next,high,live,capacity,depth,store,Mail{value,retired,packet <> returned,error <> errors},events,commands,registrations,system,clock}
def swapped(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,world:W.World<S,C,Mail<R,P>,E>,incoming:R) -> W.World<S,C,Mail<R,P>,E> & R:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,Mail{old,retired,returned,errors},events,commands,registrations,system,clock}:(W.World{ns,next,high,live,capacity,depth,store,Mail{incoming,retired,returned,errors},events,commands,registrations,system,clock},old)
def restored(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,result:W.World<S,C,Mail<R,P>,E> & R) -> W.World<S,C,Mail<R,P>,E>:
  match result:
    case (world,displaced):world
# Same displaced-resource behavior as Resource.tx_replace and qualified Mail
# journal; no new finalizer, capture or global delivery recovery contract.
def replaced(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,declaration:Decl.Constructed<S,P,identity,project>,prepared:List<Batch.Prepared<S,Request.Packet<P>>>,undo:List<(W.World<S,C,Mail<R,P>,E> -> W.World<S,C,Mail<R,P>,E>)>,commands:List<(W.World<S,C,Mail<R,P>,E> -> W.World<S,C,Mail<R,P>,E>)>,events:List<&2,E>,result:W.World<S,C,Mail<R,P>,E> & R) -> Request.Owner<S,C,Mail<R,P>,E,P,identity,project> & Unit:
  match result:
    case (world,old):(Request.Owner{Batch.Batch{T.Tx{world,(w => restored(~S,~C,~R,~E,~P,swapped(~S,~C,~R,~E,~P,w,old))) <> undo,commands,events},prepared},declaration},Unit{})
def replace(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,owner:Request.Owner<S,C,Mail<R,P>,E,P,identity,project>,incoming:R) -> Request.Owner<S,C,Mail<R,P>,E,P,identity,project> & Unit:
  match owner:
    case Request.Owner{Batch.Batch{T.Tx{world,undo,commands,events},prepared},declaration}:replaced(~S,~C,~R,~E,~P,~identity,~project,declaration,prepared,undo,commands,events,swapped(~S,~C,~R,~E,~P,world,incoming))
def resource_grant(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw) -> Cap.OwnedRequest<Request.Owner<S,C,Mail<R,P>,E,P,identity,project>,R,Unit>:
  Cap.OwnedRequest{owner => value => replace(~S,~C,~R,~E,~P,~identity,~project,owner,value)}
def grants(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw) -> Ops<S,P,R,Request.Owner<S,C,Mail<R,P>,E,P,identity,project>>:
  Ops{Request.grant(~S,~C,~Mail<R,P>,~E,~P,~identity,~project),resource_grant(~S,~C,~R,~E,~P,~identity,~project)}
def invoke(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~A:Type,~U:Type,~body:@-H:Type -> @-ops:Ops<S,P,R,H> -> A -> H -> H & U,owner:Request.Owner<S,C,Mail<R,P>,E,P,identity,project>,args:A) -> Request.Owner<S,C,Mail<R,P>,E,P,identity,project> & U:
  Cap.invoke_owned(~(H => Ops<S,P,R,H>),~A,~U,~body,~Request.Owner<S,C,Mail<R,P>,E,P,identity,project>,~grants(~S,~C,~R,~E,~P,~identity,~project),args,owner)
def names(~S:Data,clauses:List<&2,Clause.Clause<S>>) -> List<&2,String>:
  match clauses:
    case []:[]
    case Clause.Clause{name,_} <> tail:name <> names(~S,tail)
def access(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~Token:Data,~identity:Identity.Declaration<S,P>,~resource:Identity.Declaration<S,R>,~view:P -> P & D.Raw,~take:C -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> C) -> List<&2,String>:
  List.append(&2,String,names(~S,Clause.clauses(~S,~Query.Frame<S,C,Mail<R,P>,E>,~Cap.Write<Query.Frame<S,C,Mail<R,P>,E>,P,D.Raw>,Clause.write(~S,~P,~C,~Mail<R,P>,~E,~Rest,~D.Raw,~Token,~identity,~view,~take,~put))),[Identity.key(~S,~R,resource)])
def attempted(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~repair:D.Raw -> Maybe<&1,P> -> Maybe<&1,P>,+original:D.Raw,+canonical:D.Raw,result:C.Replacement<W.World<S,C,Mail<R,P>,E>,P>) -> Delivery.Delivery<W.World<S,C,Mail<R,P>,E>,Request.Packet<P>>:
  match result:
    case C.Replaced{world,previous}:Delivery.Delivered{retire(~S,~C,~R,~E,~P,previous,world)}
    case C.ReplaceRejected{world,incoming,error}:Delivery.Undelivered{world,Request.Packet{repair(original,incoming),original,canonical},error}
def attempt(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~Token:Data,~take:C -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> C,~view:P -> P & D.Raw,~family:C.Family<S,C,Rest,P,D.Raw,Token,take,put,view>,~normalize:D.Raw -> Maybe<&1,P> -> Maybe<&1,P>,~repair:D.Raw -> Maybe<&1,P> -> Maybe<&1,P>,world:W.World<S,C,Mail<R,P>,E>,target:W.Handle<S>,packet:Request.Packet<P>) -> Delivery.Delivery<W.World<S,C,Mail<R,P>,E>,Request.Packet<P>>:
  match packet:
    case Request.Packet{owner,+original,+canonical}:attempted(~S,~C,~R,~E,~P,~repair,original,canonical,C.replace(~S,~C,~Mail<R,P>,~E,~Rest,~P,~D.Raw,~Token,~take,~put,~view,family,world,target,normalize(canonical,owner)))
