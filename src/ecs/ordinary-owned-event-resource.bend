import Base
import ./change-tick.bend as Tick
import ./world.bend as W
import ./compose.bend as Q
import ./capabilities.bend as Cap
import ./ordinary-query-declaration.bend as Decl
import ./ordinary-schema.bend as Schema
import ./owned-event-storage.bend as Storage
import ./owned-event-log.bend as Log
import ./owner-product.bend as Product
import ./resource-field.bend as Field
import ./transaction.bend as T
# Only the user resource is writable; the affine event log is a retained sibling.
def take(~R:Type,~P:Type,resources:Storage.Resources<R,P>) -> Log.Log<P> & R:
  match resources:
    case Storage.Resources{resource,log}:(log,resource)
def put(~R:Type,~P:Type,log:Log.Log<P>,resource:R) -> Storage.Resources<R,P>:
  Storage.Resources{resource,log}
def lens(~R:Type,~P:Type) -> Product.Lens<Storage.Resources<R,P>,R,Log.Log<P>>:
  Product.Lens{take(~R,~P),put(~R,~P)}
def read_returned(~S:Data,~C:Type,~R:Type,~P:Type,~V:Data,handle:W.Handle<S>,error:Maybe<&2,W.WorldError>,cursor:Maybe<&2,Tick.Tick>,result:T.Tx<W.World<S,C,Storage.Resources<R,P>,Nat>,Nat> & V) -> Q.Frame<S,C,Storage.Resources<R,P>,Nat> & V:
  match result:
    case (tx,value):(Q.Frame{tx,handle,error,cursor},value)
def read(~S:Data,~C:Type,~R:Type,~P:Type,~V:Data,~view:R -> R & V,owner:Q.Frame<S,C,Storage.Resources<R,P>,Nat>) -> Q.Frame<S,C,Storage.Resources<R,P>,Nat> & V:
  match owner:
    case Q.Frame{tx,handle,error,cursor}:read_returned(~S,~C,~R,~P,~V,handle,error,cursor,Cap.value_read(~T.Tx<W.World<S,C,Storage.Resources<R,P>,Nat>,Nat>,~V,~Field.read(~S,~C,~Storage.Resources<R,P>,~Nat,~R,~Log.Log<P>,~V,~lens(~R,~P),~view),tx))
def set(~S:Data,~C:Type,~R:Type,~P:Type,owner:Q.Frame<S,C,Storage.Resources<R,P>,Nat>,replacement:R) -> Q.Frame<S,C,Storage.Resources<R,P>,Nat>:
  match owner:
    case Q.Frame{tx,handle,error,cursor}:Q.Frame{Field.tx_set(~S,~C,~Storage.Resources<R,P>,~Nat,~R,~Log.Log<P>,~lens(~R,~P),tx,replacement),handle,error,cursor}
def selected(~S:Data,~C:Type,~R:Type,~P:Type,owner:Q.Frame<S,C,Storage.Resources<R,P>,Nat>) -> Q.Frame<S,C,Storage.Resources<R,P>,Nat> & Bool:
  (owner,True{})
def write(~S:Data,~C:Type,~R:Type,~P:Type,~V:Data,~identity:Schema.Resource<S,R>,~view:R -> R & V) -> Decl.Declaration<S,Q.Frame<S,C,Storage.Resources<R,P>,Nat>,Cap.ValueWrite<Q.Frame<S,C,Storage.Resources<R,P>,Nat>,R,V>>:
  Decl.Declaration{Cap.ValueWrite{read(~S,~C,~R,~P,~V,~view),set(~S,~C,~R,~P)},selected(~S,~C,~R,~P),[Decl.Clause{Schema.resource_key(~S,~R,identity),Decl.Write{}}]}
