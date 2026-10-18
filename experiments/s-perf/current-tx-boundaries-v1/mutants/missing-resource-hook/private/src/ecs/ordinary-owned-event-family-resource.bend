import Base
import world.bend as W
import compose.bend as Q
import capabilities.bend as Cap
import ordinary-query-declaration.bend as Decl
import ordinary-schema.bend as Schema
import owner-product.bend as Product
import resource-field.bend as Field
import transaction.bend as T
# Only the user resource is writable; the affine event log is a retained sibling.
def lens(~R:Type,~Logs:Type) -> Product.Lens<Product.Owner<R,Logs>,R,Logs>:
  Product.lens(~R,~Logs,~Product.Left{})
def read_returned(~S:Data,~C:Type,~R:Type,~Logs:Type,~E:Data,~V:Data,handle:W.Handle<S>,error:Maybe<&2,W.WorldError>,cursor:U32,result:T.Tx<W.World<S,C,Product.Owner<R,Logs>,E>,E> & V) -> Q.Frame<S,C,Product.Owner<R,Logs>,E> & V:
  match result:
    case (tx,value):(Q.Frame{tx,handle,error,cursor},value)
def read(~S:Data,~C:Type,~R:Type,~Logs:Type,~E:Data,~V:Data,~view:R -> R & V,owner:Q.Frame<S,C,Product.Owner<R,Logs>,E>) -> Q.Frame<S,C,Product.Owner<R,Logs>,E> & V:
  match owner:
    case Q.Frame{tx,handle,error,cursor}:read_returned(~S,~C,~R,~Logs,~E,~V,handle,error,cursor,Cap.value_read(~T.Tx<W.World<S,C,Product.Owner<R,Logs>,E>,E>,~V,~Field.read(~S,~C,~Product.Owner<R,Logs>,~E,~R,~Logs,~V,~lens(~R,~Logs),~view),tx))
def set(~S:Data,~C:Type,~R:Type,~Logs:Type,~E:Data,owner:Q.Frame<S,C,Product.Owner<R,Logs>,E>,replacement:R) -> Q.Frame<S,C,Product.Owner<R,Logs>,E>:
  match owner:
    case Q.Frame{tx,handle,error,cursor}:Q.Frame{Field.tx_set(~S,~C,~Product.Owner<R,Logs>,~E,~R,~Logs,~lens(~R,~Logs),tx,replacement),handle,error,cursor}
def selected(~S:Data,~C:Type,~R:Type,~Logs:Type,~E:Data,owner:Q.Frame<S,C,Product.Owner<R,Logs>,E>) -> Q.Frame<S,C,Product.Owner<R,Logs>,E> & Bool:
  (owner,True{})
def write(~S:Data,~C:Type,~R:Type,~Logs:Type,~E:Data,~V:Data,~identity:Schema.Resource<S,R>,~view:R -> R & V) -> Decl.Declaration<S,Q.Frame<S,C,Product.Owner<R,Logs>,E>,Cap.ValueWrite<Q.Frame<S,C,Product.Owner<R,Logs>,E>,R,V>>:
  Decl.Declaration{Cap.ValueWrite{read(~S,~C,~R,~Logs,~E,~V,~view),set(~S,~C,~R,~Logs,~E)},selected(~S,~C,~R,~Logs,~E),[Decl.Clause{Schema.resource_key(~S,~R,identity),Decl.Write{}}]}
