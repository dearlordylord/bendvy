import Base
import ../full-assembly-v1/request.bend as Request
import /workspace/formal-proofs/bendvy/experiments/public-decode/typed.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Query
import /workspace/formal-proofs/bendvy/src/ecs/bundle-batch.bend as Batch
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as World
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as Component
import /workspace/formal-proofs/bendvy/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/canonical-component-declaration.bend as Identity
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1/declaration.bend as Declaration

# Trusted provisioning frame. Gameplay receives only universal H and its grants.
# Query and decode operate on the same Tx; prepared owners stay in this frame.
type Frame<S:Data,C:Type,R:Type,E:Data,P:Type,-identity:Identity.Declaration<S,P>,-project:P -> P & D.Raw> is Type:
  Frame{owner:Request.Owner<S,C,R,E,P,identity,project>,handle:World.Handle<S>,error:Maybe<&2,World.WorldError>,cursor:U32}

def read_join(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~V:Data,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,declaration:Declaration.Constructed<S,P,identity,project>,prepared:List<Batch.Prepared<S,Request.Packet<P>>>,observed:Query.Frame<S,C,R,E> & Component.Access<V>) -> Frame<S,C,R,E,P,identity,project> & Component.Access<V>:
  match observed:
    case (Query.Frame{tx,handle,error,cursor},value):(Frame{Request.Owner{Batch.Batch{tx,prepared},declaration},handle,error,cursor},value)

def read(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~V:Data,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~get:Query.Frame<S,C,R,E> -> Query.Frame<S,C,R,E> & Component.Access<V>,frame:Frame<S,C,R,E,P,identity,project>) -> Frame<S,C,R,E,P,identity,project> & Component.Access<V>:
  match frame:
    case Frame{Request.Owner{Batch.Batch{tx,prepared},declaration},handle,error,cursor}:read_join(~S,~C,~R,~E,~P,~V,~identity,~project,declaration,prepared,get(Query.Frame{tx,handle,error,cursor}))

def read_grant(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~V:Data,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~grant:Cap.Read<Query.Frame<S,C,R,E>,V>) -> Cap.Read<Frame<S,C,R,E,P,identity,project>,V>:
  Cap.Read{read(~S,~C,~R,~E,~P,~V,~identity,~project,~Cap.read_field(~Query.Frame<S,C,R,E>,~V,grant))}

def request_join(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,handle:World.Handle<S>,error:Maybe<&2,World.WorldError>,cursor:U32,result:Request.Owner<S,C,R,E,P,identity,project> & Request.Output<S,P>) -> Frame<S,C,R,E,P,identity,project> & Request.Output<S,P>:
  match result:
    case (owner,output):(Frame{owner,handle,error,cursor},output)

def request(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,frame:Frame<S,C,R,E,P,identity,project>,input:Request.Input<S,P>) -> Frame<S,C,R,E,P,identity,project> & Request.Output<S,P>:
  match frame:
    case Frame{owner,handle,error,cursor}:request_join(~S,~C,~R,~E,~P,~identity,~project,handle,error,cursor,Request.request(~S,~C,~R,~E,~P,~identity,~project,owner,input))

def request_grant(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw) -> Cap.OwnedRequest<Frame<S,C,R,E,P,identity,project>,Request.Input<S,P>,Request.Output<S,P>>:
  Cap.OwnedRequest{frame => input => request(~S,~C,~R,~E,~P,~identity,~project,frame,input)}

def selected_join(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,declaration:Declaration.Constructed<S,P,identity,project>,prepared:List<Batch.Prepared<S,Request.Packet<P>>>,observed:Query.Frame<S,C,R,E> & Bool) -> Frame<S,C,R,E,P,identity,project> & Bool:
  match observed:
    case (Query.Frame{tx,handle,error,cursor},selected):(Frame{Request.Owner{Batch.Batch{tx,prepared},declaration},handle,error,cursor},selected)

# Membership is evaluated on the current transaction for every row, never on a
# separate pre-scan world. The closed selector comes from the query declaration.
def select(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~selector:Query.Frame<S,C,R,E> -> Query.Frame<S,C,R,E> & Bool,frame:Frame<S,C,R,E,P,identity,project>) -> Frame<S,C,R,E,P,identity,project> & Bool:
  match frame:
    case Frame{Request.Owner{Batch.Batch{tx,prepared},declaration},handle,error,cursor}:selected_join(~S,~C,~R,~E,~P,~identity,~project,declaration,prepared,selector(Query.Frame{tx,handle,error,cursor}))
