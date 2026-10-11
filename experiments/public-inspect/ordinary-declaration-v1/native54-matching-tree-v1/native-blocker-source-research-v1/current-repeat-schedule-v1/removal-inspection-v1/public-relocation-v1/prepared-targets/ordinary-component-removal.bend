import Base
import ./ordinary-removal-provision.bend as Provision
import ./ordinary-declaration.bend as Identity
import ./ordinary-component-binding.bend as Binding
import ./column.bend as Col
import ./world.bend as W
import ./removals.bend as Rm
import ./structural.bend as St
import ./transaction.bend as Tx

type Returned<T:Type,P:Type> is Type:
  Queued{result:St.Queued<T,P>}
  SelectionRejected{tx:T}
def record(~S:Data,~C:Type,~Rest:Type,~P:Type,~V:Data,~Token:Data,~take:C -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> C,~view:P -> P & V,~E:Data,~inject:Identity.Declaration<S,P> -> W.Handle<S> -> E,~binding:Binding.Binding<S,C,Rest,P,V,Token,take,put,view>,handle:W.Handle<S>) -> E:
  inject(Binding.identity(~S,~C,~Rest,~P,~V,~Token,~take,~put,~view,binding),handle)
def checked(~S:Data,~C:Type,~R:Type,~E:Data,~Rest:Type,~P:Type,~V:Data,~Token:Data,~take:C -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> C,~view:P -> P & V,~record:W.Handle<S> -> E,allowed:Bool,binding:Binding.Binding<S,C,Rest,P,V,Token,take,put,view>,tx:Tx.Tx<W.World<S,C,R,E>,E>,handle:W.Handle<S>) -> Returned<Tx.Tx<W.World<S,C,R,E>,E>,P>:
  match allowed:
    case False{}:SelectionRejected{tx}
    case True{}:Queued{St.tx_remove_observed(~S,~C,~R,~E,~Rest,~P,~V,~Token,~take,~put,~view,~record,Binding.family(~S,~C,~Rest,~P,~V,~Token,~take,~put,~view,binding),tx,handle)}
def selected_identity(~S:Data,~P:Type,~E:Data,~inject:Identity.Declaration<S,P> -> W.Handle<S> -> E,~select:E -> Maybe<&2,Rm.Record<S,Identity.Declaration<S,P>>>,selection:Provision.Selection<S,P,E,inject,select>) -> Identity.Declaration<S,P>:
  match selection:
    case Provision.Selection{identity}:identity
def remove(~S:Data,~C:Type,~R:Type,~E:Data,~Rest:Type,~P:Type,~V:Data,~Token:Data,~take:C -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> C,~view:P -> P & V,~inject:Identity.Declaration<S,P> -> W.Handle<S> -> E,~select:E -> Maybe<&2,Rm.Record<S,Identity.Declaration<S,P>>>,~binding:Binding.Binding<S,C,Rest,P,V,Token,take,put,view>,~selection:Provision.Selection<S,P,E,inject,select>,tx:Tx.Tx<W.World<S,C,R,E>,E>,handle:W.Handle<S>) -> Returned<Tx.Tx<W.World<S,C,R,E>,E>,P>:
  checked(~S,~C,~R,~E,~Rest,~P,~V,~Token,~take,~put,~view,~record(~S,~C,~Rest,~P,~V,~Token,~take,~put,~view,~E,~inject,~binding),String.eq(Identity.key(~S,~P,Binding.identity(~S,~C,~Rest,~P,~V,~Token,~take,~put,~view,binding)),Identity.key(~S,~P,selected_identity(~S,~P,~E,~inject,~select,selection))),binding,tx,handle)
