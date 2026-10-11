import Base
import ./ordinary-declaration.bend as Identity
import ./ordinary-component-binding.bend as Binding
import ./column.bend as Col
import ./world.bend as W
import ./structural.bend as St
import ./transaction.bend as Tx

def record(~S:Data,~C:Type,~Rest:Type,~P:Type,~V:Data,~Token:Data,~take:C -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> C,~view:P -> P & V,~E:Data,~inject:Identity.Declaration<S,P> -> W.Handle<S> -> E,~binding:Binding.Binding<S,C,Rest,P,V,Token,take,put,view>,handle:W.Handle<S>) -> E:
  inject(Binding.identity(~S,~C,~Rest,~P,~V,~Token,~take,~put,~view,binding),handle)
def remove(~S:Data,~C:Type,~R:Type,~E:Data,~Rest:Type,~P:Type,~V:Data,~Token:Data,~take:C -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> C,~view:P -> P & V,~inject:Identity.Declaration<S,P> -> W.Handle<S> -> E,~binding:Binding.Binding<S,C,Rest,P,V,Token,take,put,view>,tx:Tx.Tx<W.World<S,C,R,E>,E>,handle:W.Handle<S>) -> St.Queued<Tx.Tx<W.World<S,C,R,E>,E>,P>:
  St.tx_remove_observed(~S,~C,~R,~E,~Rest,~P,~V,~Token,~take,~put,~view,~record(~S,~C,~Rest,~P,~V,~Token,~take,~put,~view,~E,~inject,~binding),Binding.family(~S,~C,~Rest,~P,~V,~Token,~take,~put,~view,binding),tx,handle)
