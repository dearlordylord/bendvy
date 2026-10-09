import Base
import ./request.bend as Request
import ./owned-journal.bend as Journal
import ./immediate.bend as Immediate
import /workspace/formal-proofs/bendvy/src/ecs/bundle-install.bend as Install
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1/core-promotion-v1/library/decode-data.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Query
import /workspace/formal-proofs/bendvy/src/ecs/bundle-batch.bend as Batch
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as World
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as Component
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/resource.bend as Resource
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1/core-promotion-v1/library/ordinary-declaration.bend as Identity
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1/core-promotion-v1/library/persistence-declaration.bend as Declaration

# Trusted provisioning frame. Gameplay receives only universal H and its grants.
# Query and decode operate on the same Tx; prepared owners stay in this frame.
type Frame<S:Data,C:Type,R:Type,E:Data,P:Type,Q:Type,-identity:Identity.Declaration<S,P>,-project:P -> P & D.Raw> is Type:
  Frame{owner:Request.Owner<S,C,R,E,P,identity,project>,handle:World.Handle<S>,error:Maybe<&2,World.WorldError>,cursor:U32,receipts:List<Journal.Receipt<World.World<S,C,R,E>,Request.Packet<P>,Q>>,pending:List<Journal.Pending<Q>>}

def read_join(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Q:Type,~V:Data,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,declaration:Declaration.Constructed<S,P,identity,project>,prepared:List<Batch.Prepared<S,Request.Packet<P>>>,receipts:List<Journal.Receipt<World.World<S,C,R,E>,Request.Packet<P>,Q>>,pending:List<Journal.Pending<Q>>,observed:Query.Frame<S,C,R,E> & Component.Access<V>) -> Frame<S,C,R,E,P,Q,identity,project> & Component.Access<V>:
  match observed:
    case (Query.Frame{tx,handle,error,cursor},value):(Frame{Request.Owner{Batch.Batch{tx,prepared},declaration},handle,error,cursor,receipts,pending},value)

def read(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Q:Type,~V:Data,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~get:Query.Frame<S,C,R,E> -> Query.Frame<S,C,R,E> & Component.Access<V>,frame:Frame<S,C,R,E,P,Q,identity,project>) -> Frame<S,C,R,E,P,Q,identity,project> & Component.Access<V>:
  match frame:
    case Frame{Request.Owner{Batch.Batch{tx,prepared},declaration},handle,error,cursor,receipts,pending}:read_join(~S,~C,~R,~E,~P,~Q,~V,~identity,~project,declaration,prepared,receipts,pending,get(Query.Frame{tx,handle,error,cursor}))

def read_grant(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Q:Type,~V:Data,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~grant:Cap.Read<Query.Frame<S,C,R,E>,V>) -> Cap.Read<Frame<S,C,R,E,P,Q,identity,project>,V>:
  Cap.Read{read(~S,~C,~R,~E,~P,~Q,~V,~identity,~project,~Cap.read_field(~Query.Frame<S,C,R,E>,~V,grant))}

def request_join(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Q:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,handle:World.Handle<S>,error:Maybe<&2,World.WorldError>,cursor:U32,receipts:List<Journal.Receipt<World.World<S,C,R,E>,Request.Packet<P>,Q>>,pending:List<Journal.Pending<Q>>,result:Request.Owner<S,C,R,E,P,identity,project> & Request.Output<S,P>) -> Frame<S,C,R,E,P,Q,identity,project> & Request.Output<S,P>:
  match result:
    case (owner,output):(Frame{owner,handle,error,cursor,receipts,pending},output)

def request(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Q:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,frame:Frame<S,C,R,E,P,Q,identity,project>,input:Request.Input<S,P>) -> Frame<S,C,R,E,P,Q,identity,project> & Request.Output<S,P>:
  match frame:
    case Frame{owner,handle,error,cursor,receipts,pending}:request_join(~S,~C,~R,~E,~P,~Q,~identity,~project,handle,error,cursor,receipts,pending,Request.request(~S,~C,~R,~E,~P,~identity,~project,owner,input))

def request_grant(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Q:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw) -> Cap.OwnedRequest<Frame<S,C,R,E,P,Q,identity,project>,Request.Input<S,P>,Request.Output<S,P>>:
  Cap.OwnedRequest{frame => input => request(~S,~C,~R,~E,~P,~Q,~identity,~project,frame,input)}

def selected_join(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Q:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,declaration:Declaration.Constructed<S,P,identity,project>,prepared:List<Batch.Prepared<S,Request.Packet<P>>>,receipts:List<Journal.Receipt<World.World<S,C,R,E>,Request.Packet<P>,Q>>,pending:List<Journal.Pending<Q>>,observed:Query.Frame<S,C,R,E> & Bool) -> Frame<S,C,R,E,P,Q,identity,project> & Bool:
  match observed:
    case (Query.Frame{tx,handle,error,cursor},selected):(Frame{Request.Owner{Batch.Batch{tx,prepared},declaration},handle,error,cursor,receipts,pending},selected)

# Membership is evaluated on the current transaction for every row, never on a
# separate pre-scan world. The closed selector comes from the query declaration.
def select(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Q:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~selector:Query.Frame<S,C,R,E> -> Query.Frame<S,C,R,E> & Bool,frame:Frame<S,C,R,E,P,Q,identity,project>) -> Frame<S,C,R,E,P,Q,identity,project> & Bool:
  match frame:
    case Frame{Request.Owner{Batch.Batch{tx,prepared},declaration},handle,error,cursor,receipts,pending}:selected_join(~S,~C,~R,~E,~P,~Q,~identity,~project,declaration,prepared,receipts,pending,selector(Query.Frame{tx,handle,error,cursor}))

def receipt_added(~W:Type,~P:Type,~Q:Type,receipts:List<Journal.Receipt<W,P,Q>>,receipt:Maybe<&1,Journal.Receipt<W,P,Q>>) -> List<Journal.Receipt<W,P,Q>>:
  match receipt:
    case None{}:receipts
    case Some{receipt}:receipt <> receipts

def pending_added(~Q:Type,pending:List<Journal.Pending<Q>>,next:Maybe<&1,Journal.Pending<Q>>) -> List<Journal.Pending<Q>>:
  match next:
    case None{}:pending
    case Some{next}:next <> pending

def spawn_output(~S:Data,~P:Type,canonical:D.Raw,result:Result<&2,&2,World.WorldError,World.Handle<S>>,packet:Maybe<&1,Request.Packet<P>>) -> Request.Output<S,P>:
  match result packet:
    case Done{target} _:Request.Accepted{target,True{},canonical}
    case Fail{error} None{}:Request.Refused{None{},Request.Entity{error}}
    case Fail{error} Some{Request.Packet{owner,_,_}}:Request.Refused{owner,Request.Entity{error}}

def spawned(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Q:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,declaration:Declaration.Constructed<S,P,identity,project>,prepared:List<Batch.Prepared<S,Request.Packet<P>>>,handle:World.Handle<S>,error:Maybe<&2,World.WorldError>,cursor:U32,receipts:List<Journal.Receipt<World.World<S,C,R,E>,Request.Packet<P>,Q>>,pending:List<Journal.Pending<Q>>,canonical:D.Raw,result:T.Tx<World.World<S,C,R,E>,E> & (Result<&2,&2,World.WorldError,World.Handle<S>> & (Maybe<&1,Request.Packet<P>> & (Maybe<&1,Journal.Receipt<World.World<S,C,R,E>,Request.Packet<P>,Q>> & Maybe<&1,Journal.Pending<Q>>)))) -> Frame<S,C,R,E,P,Q,identity,project> & Request.Output<S,P>:
  match result:
    case (tx,(result,(packet,(receipt,next)))):(Frame{Request.Owner{Batch.Batch{tx,prepared},declaration},handle,error,cursor,receipt_added(~World.World<S,C,R,E>,~Request.Packet<P>,~Q,receipts,receipt),pending_added(~Q,pending,next)},spawn_output(~S,~P,canonical,result,packet))

def spawn_projected(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Q:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~install:World.World<S,C,R,E> -> World.Handle<S> -> Request.Packet<P> -> Install.Attempt<World.World<S,C,R,E>,Request.Packet<P>,Q>,frame:Frame<S,C,R,E,P,Q,identity,project>,+canonical:D.Raw,result:P & D.Raw) -> Frame<S,C,R,E,P,Q,identity,project> & Request.Output<S,P>:
  match frame result:
    case Frame{Request.Owner{Batch.Batch{tx,prepared},declaration},handle,error,cursor,receipts,pending}, (owner,original):spawned(~S,~C,~R,~E,~P,~Q,~identity,~project,declaration,prepared,handle,error,cursor,receipts,pending,canonical,Immediate.spawn(~S,~C,~R,~E,~P,~Q,~install,tx,Request.Packet{Some{owner},original,canonical}))

def spawn_validated(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Q:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~install:World.World<S,C,R,E> -> World.Handle<S> -> Request.Packet<P> -> Install.Attempt<World.World<S,C,R,E>,Request.Packet<P>,Q>,frame:Frame<S,C,R,E,P,Q,identity,project>,receipt:D.Receipt<P>) -> Frame<S,C,R,E,P,Q,identity,project> & Request.Output<S,P>:
  match receipt:
    case D.Receipt{owner,D.Rejected{error}}:(frame,Request.Refused{Some{owner},Request.Validation{error}})
    case D.Receipt{owner,D.Accepted{canonical}}:spawn_projected(~S,~C,~R,~E,~P,~Q,~identity,~project,~install,frame,canonical,project(owner))

def spawn(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Q:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~install:World.World<S,C,R,E> -> World.Handle<S> -> Request.Packet<P> -> Install.Attempt<World.World<S,C,R,E>,Request.Packet<P>,Q>,frame:Frame<S,C,R,E,P,Q,identity,project>,owner:P) -> Frame<S,C,R,E,P,Q,identity,project> & Request.Output<S,P>:
  match frame:
    case Frame{Request.Owner{batch,+declaration},handle,error,cursor,receipts,pending}:spawn_validated(~S,~C,~R,~E,~P,~Q,~identity,~project,~install,Frame{Request.Owner{batch,declaration},handle,error,cursor,receipts,pending},Declaration.validate(~S,~P,~identity,~project,declaration,owner))

def spawn_grant(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Q:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~install:World.World<S,C,R,E> -> World.Handle<S> -> Request.Packet<P> -> Install.Attempt<World.World<S,C,R,E>,Request.Packet<P>,Q>) -> Cap.OwnedRequest<Frame<S,C,R,E,P,Q,identity,project>,P,Request.Output<S,P>>:
  Cap.OwnedRequest{frame => owner => spawn(~S,~C,~R,~E,~P,~Q,~identity,~project,~install,frame,owner)}

def resource_join(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Q:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,declaration:Declaration.Constructed<S,P,identity,project>,prepared:List<Batch.Prepared<S,Request.Packet<P>>>,handle:World.Handle<S>,error:Maybe<&2,World.WorldError>,cursor:U32,receipts:List<Journal.Receipt<World.World<S,C,R,E>,Request.Packet<P>,Q>>,pending:List<Journal.Pending<Q>>,tx:T.Tx<World.World<S,C,R,E>,E>) -> Frame<S,C,R,E,P,Q,identity,project> & Unit:
  (Frame{Request.Owner{Batch.Batch{tx,prepared},declaration},handle,error,cursor,receipts,pending},Unit{})

def resource_set(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Q:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,frame:Frame<S,C,R,E,P,Q,identity,project>,replacement:R) -> Frame<S,C,R,E,P,Q,identity,project> & Unit:
  match frame:
    case Frame{Request.Owner{Batch.Batch{tx,prepared},declaration},handle,error,cursor,receipts,pending}:resource_join(~S,~C,~R,~E,~P,~Q,~identity,~project,declaration,prepared,handle,error,cursor,receipts,pending,Resource.tx_replace(~S,~C,~R,~E,tx,replacement))

def resource_grant(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Q:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw) -> Cap.OwnedRequest<Frame<S,C,R,E,P,Q,identity,project>,R,Unit>:
  Cap.OwnedRequest{frame => replacement => resource_set(~S,~C,~R,~E,~P,~Q,~identity,~project,frame,replacement)}
