import Base
import ./deferred-command.bend as Deferred
import ./trace-facts.bend as TraceFacts
import ./owner-product.bend as Product
import ./world.bend as W
import ./transaction.bend as T
import ./resource-legacy.bend as Resource
import ./resource-field.bend as Field
import ./capabilities.bend as Cap

def journaled(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~lens:Product.Lens<R,P,Rest>,undo:List<(W.World<S,C,R,E> -> W.World<S,C,R,E>)>,commands:List<Deferred.Command<W.World<S,C,R,E>>>,events:List<&2,E>,trace:TraceFacts.State,result:W.World<S,C,R,E> & P) -> T.Tx<W.World<S,C,R,E>,E>:
  match result:
    case (world,old):T.Tx{world,(w=>Field.restore(~S,~C,~R,~E,~P,~Rest,~lens,old,w)) <> undo,commands,events,trace}
def tx_set(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~lens:Product.Lens<R,P,Rest>,tx:T.Tx<W.World<S,C,R,E>,E>,replacement:P) -> T.Tx<W.World<S,C,R,E>,E>:
  match tx:
    case T.Tx{world,undo,commands,events,trace}:journaled(~S,~C,~R,~E,~P,~Rest,~lens,undo,commands,events,trace,Field.replace_world(~S,~C,~R,~E,~P,~Rest,~lens,replacement,world))
def read(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<R,P,Rest>,~view:P -> P & V) -> Cap.ValueRead<T.Tx<W.World<S,C,R,E>,E>,V>:
  Cap.ValueRead{Resource.tx_get(~S,~C,~R,~E,~V,~Field.project(~R,~P,~Rest,~V,~lens,~view))}
def write(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<R,P,Rest>,~view:P -> P & V) -> Cap.ValueWrite<T.Tx<W.World<S,C,R,E>,E>,P,V>:
  Cap.ValueWrite{Resource.tx_get(~S,~C,~R,~E,~V,~Field.project(~R,~P,~Rest,~V,~lens,~view)),tx_set(~S,~C,~R,~E,~P,~Rest,~lens)}

# The disabled arm reaches the original setter before any view or rendering.
def observed_set_ready(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<R,P,Rest>,~view:P -> P & V,~render:V -> String,key:String,result:T.Tx<W.World<S,C,R,E>,E> & V,incoming:P & V) -> T.Tx<W.World<S,C,R,E>,E>:
  match result incoming:
    case (tx,before), (replacement,after):T.record(~W.World<S,C,R,E>,~E,tx_set(~S,~C,~R,~E,~P,~Rest,~lens,tx,replacement),TraceFacts.Fact{TraceFacts.ResourceValue{},key,TraceFacts.WriteOperation{},None{},TraceFacts.DisplayedValue{render(before)},TraceFacts.DisplayedValue{render(after)},TraceFacts.Attempted{}})
def observed_set_enabled(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<R,P,Rest>,~view:P -> P & V,~render:V -> String,key:String,replacement:P,result:T.Tx<W.World<S,C,R,E>,E> & Bool) -> T.Tx<W.World<S,C,R,E>,E>:
  match result:
    case (tx,False{}):tx_set(~S,~C,~R,~E,~P,~Rest,~lens,tx,replacement)
    case (tx,True{}):observed_set_ready(~S,~C,~R,~E,~P,~Rest,~V,~lens,~view,~render,key,Resource.tx_get(~S,~C,~R,~E,~V,~Field.project(~R,~P,~Rest,~V,~lens,~view),tx),view(replacement))
def observed_set(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<R,P,Rest>,~view:P -> P & V,~render:V -> String,~key:String,tx:T.Tx<W.World<S,C,R,E>,E>,replacement:P) -> T.Tx<W.World<S,C,R,E>,E>:
  observed_set_enabled(~S,~C,~R,~E,~P,~Rest,~V,~lens,~view,~render,key,replacement,T.trace_enabled(~W.World<S,C,R,E>,~E,tx))
def write_observed(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<R,P,Rest>,~view:P -> P & V,~render:V -> String,~key:String) -> Cap.ValueWrite<T.Tx<W.World<S,C,R,E>,E>,P,V>:
  Cap.ValueWrite{Resource.tx_get(~S,~C,~R,~E,~V,~Field.project(~R,~P,~Rest,~V,~lens,~view)),observed_set(~S,~C,~R,~E,~P,~Rest,~V,~lens,~view,~render,~key)}
