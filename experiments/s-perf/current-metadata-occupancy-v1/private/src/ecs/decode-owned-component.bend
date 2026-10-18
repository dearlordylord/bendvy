import Base
import ./decode-frame.bend as F
import ./decode-owned-journal.bend as Journal
import ./decode-requests.bend as Request
import ./component.bend as Cmp
import ./column.bend as Col
import ./compose.bend as Query
import ./capabilities.bend as Cap
import ./world.bend as W
import ./transaction.bend as T
import ./bundle-batch.bend as Batch
import ./decode-data.bend as D
import ./ordinary-declaration.bend as Identity
import ./persistence-declaration.bend as Declaration

type Output<P:Type> is Type:Written{} Refused{owner:Maybe<&1,P>,error:W.WorldError}
def written(~S:Data,~Store:Type,~R:Type,~E:Data,~P:Type,~Q:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,declaration:Declaration.Constructed<S,P,identity,project>,prepared:List<Batch.Prepared<S,Request.Packet<P>>>,handle:W.Handle<S>,error:Maybe<&2,W.WorldError>,cursor:U32,receipts:List<Journal.Receipt<W.World<S,Store,R,E>,Request.Packet<P>,Q>>,pending:List<Journal.Pending<Q>>,result:Cmp.SetResult<T.Tx<W.World<S,Store,R,E>,E>,P>) -> F.Frame<S,Store,R,E,P,Q,identity,project> & Output<P>:
  match result:
    case Cmp.Written{tx}:(F.Frame{Request.Owner{Batch.Batch{tx,prepared},declaration},handle,error,cursor,receipts,pending},Written{})
    case Cmp.WriteRejected{tx,owner,+reason}:(F.Frame{Request.Owner{Batch.Batch{tx,prepared},declaration},handle,Query.first_error(error,reason),cursor,receipts,pending},Refused{Some{owner},reason})
    case Cmp.WriteFailure{tx,+reason}:(F.Frame{Request.Owner{Batch.Batch{tx,prepared},declaration},handle,Query.first_error(error,reason),cursor,receipts,pending},Refused{None{},reason})

def set(~S:Data,~Store:Type,~R:Type,~E:Data,~P:Type,~Q:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~Rest:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store,~view:P -> P & V,~family:Cmp.Family<S,Store,Rest,P,V,Token,take,put,view>,frame:F.Frame<S,Store,R,E,P,Q,identity,project>,input:Query.Insert<S,P>) -> F.Frame<S,Store,R,E,P,Q,identity,project> & Output<P>:
  match frame input:
    case F.Frame{Request.Owner{Batch.Batch{tx,prepared},declaration},handle,error,cursor,receipts,pending} Query.Insert{target,owner}:written(~S,~Store,~R,~E,~P,~Q,~identity,~project,declaration,prepared,handle,error,cursor,receipts,pending,Cmp.tx_set(~S,~Store,~R,~E,~Rest,~P,~V,~Token,~take,~put,~view,family,tx,target,owner))

def grant(~S:Data,~Store:Type,~R:Type,~E:Data,~P:Type,~Q:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~Rest:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store,~view:P -> P & V,~family:Cmp.Family<S,Store,Rest,P,V,Token,take,put,view>) -> Cap.OwnedRequest<F.Frame<S,Store,R,E,P,Q,identity,project>,Query.Insert<S,P>,Output<P>>:
  Cap.OwnedRequest{frame => input => set(~S,~Store,~R,~E,~P,~Q,~identity,~project,~Rest,~V,~Token,~take,~put,~view,~family,frame,input)}
