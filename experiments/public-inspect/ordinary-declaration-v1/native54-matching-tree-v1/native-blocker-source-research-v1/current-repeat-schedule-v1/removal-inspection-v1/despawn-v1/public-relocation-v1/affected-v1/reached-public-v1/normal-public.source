import Base
import ./column.bend as Col
import ./world.bend as W
import ./ordinary-declaration.bend as Identity
import ./ordinary-component-binding.bend as Binding
import ./commands.bend as Cmd
import ./transaction.bend as Tx

def handle_id(~S:Data,handle:W.Handle<S>) -> U32:
  match handle:
    case W.Handle{_,id}:id
def accepted(~S:Data,~Store:Type,~Rest:Type,~P:Type,~E:Data,~put:Rest -> Col.Column<S,P> -> Store,~emit:W.Handle<S> -> E,rest:Rest,+handle:W.Handle<S>,result:Col.SwapOutcome<S,P>) -> Store & List<&2,E>:
  match result:
    case Col.Accepted{column,Some{_}}:(put(rest,column),[emit(handle)])
    case Col.Accepted{column,None{}}:(put(rest,column),[])
    case Col.Rejected{column,_}:(put(rest,column),[])
def leaf_taken(~S:Data,~Store:Type,~Rest:Type,~P:Type,~E:Data,~put:Rest -> Col.Column<S,P> -> Store,~emit:W.Handle<S> -> E,+handle:W.Handle<S>,taken:Rest & Col.Column<S,P>) -> Store & List<&2,E>:
  (rest,column)=taken
  accepted(~S,~Store,~Rest,~P,~E,~put,~emit,rest,handle,Col.clear(~S,~P,column,handle_id(~S,handle)))
def leaf_record(~S:Data,~Store:Type,~Rest:Type,~P:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store,~view:P -> P & V,~E:Data,~inject:Identity.Declaration<S,P> -> W.Handle<S> -> E,~binding:Binding.Binding<S,Store,Rest,P,V,Token,take,put,view>,handle:W.Handle<S>) -> E:
  inject(Binding.identity(~S,~Store,~Rest,~P,~V,~Token,~take,~put,~view,binding),handle)
def leaf(~S:Data,~Store:Type,~Rest:Type,~P:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store,~view:P -> P & V,~E:Data,~inject:Identity.Declaration<S,P> -> W.Handle<S> -> E,~binding:Binding.Binding<S,Store,Rest,P,V,Token,take,put,view>,store:Store,handle:W.Handle<S>) -> Store & List<&2,E>:
  leaf_taken(~S,~Store,~Rest,~P,~E,~put,~leaf_record(~S,~Store,~Rest,~P,~V,~Token,~take,~put,~view,~E,~inject,~binding),handle,take(store))
def append(~Store:Type,~E:Data,first:List<&2,E>,second:Store & List<&2,E>) -> Store & List<&2,E>:
  (store,records)=second
  (store,List.append(&2,E,first,records))
def product_next(~S:Data,~Store:Type,~E:Data,~right:Store -> W.Handle<S> -> Store & List<&2,E>,handle:W.Handle<S>,first:Store & List<&2,E>) -> Store & List<&2,E>:
  (store,records)=first
  append(~Store,~E,records,right(store,handle))
def product(~S:Data,~Store:Type,~E:Data,~left:Store -> W.Handle<S> -> Store & List<&2,E>,~right:Store -> W.Handle<S> -> Store & List<&2,E>,store:Store,+handle:W.Handle<S>) -> Store & List<&2,E>:
  product_next(~S,~Store,~E,~right,handle,left(store,handle))

def despawn(~S:Data,~C:Type,~R:Type,~E:Data,~clear:C -> W.Handle<S> -> C & List<&2,E>,~record:W.Handle<S> -> E,tx:Tx.Tx<W.World<S,C,R,E>,E>,handle:W.Handle<S>) -> Tx.Tx<W.World<S,C,R,E>,E> & W.Status:
  Cmd.tx_despawn_observed(~S,~C,~R,~E,~clear,~record,tx,handle)
