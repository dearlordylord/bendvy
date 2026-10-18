import ../../../meter.bend as Meter
import Base
import deferred-command.bend as Deferred
import trace-facts.bend as TraceFacts
import owner-product.bend as Product
import world.bend as W
import transaction.bend as T
import resource.bend as Resource
import capabilities.bend as Cap
# Canonical product lenses preserve affine siblings during selected-field operations.
def viewed(~R:Type,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<R,P,Rest>,rest:Rest,result:P & V) -> R & V:
  match result:
    case (part,value):(Product.put_field(~R,~P,~Rest,lens)(rest,part),value)
def taken(~R:Type,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<R,P,Rest>,~view:P -> P & V,result:Rest & P) -> R & V:
  match result:
    case (rest,part):viewed(~R,~P,~Rest,~V,~lens,rest,view(part))
def project(~R:Type,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<R,P,Rest>,~view:P -> P & V,resource:R) -> R & V:
  taken(~R,~P,~Rest,~V,~lens,~view,Product.get_field(~R,~P,~Rest,lens)(resource))
def replacing(~R:Type,~P:Type,~Rest:Type,~lens:Product.Lens<R,P,Rest>,replacement:P,result:Rest & P) -> R & P:
  match result:
    case (rest,old):(Product.put_field(~R,~P,~Rest,lens)(rest,replacement),old)
def replace(~R:Type,~P:Type,~Rest:Type,~lens:Product.Lens<R,P,Rest>,replacement:P,resource:R) -> R & P:
  replacing(~R,~P,~Rest,~lens,replacement,Product.get_field(~R,~P,~Rest,lens)(resource))
# Runtime replacement owners cannot be captured in an erased projector template.
# Trusted engine boundary threads the same World fields through the core join.
def replace_world(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~lens:Product.Lens<R,P,Rest>,replacement:P,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & P:
  match world:
    case W.World{+namespace,allocator,store,resource,+events,pending,+registrations,+nextSystemId,+clock}:W.observe_resource_finish(~S,~C,~R,~E,~P,replace(~R,~P,~Rest,~lens,replacement,resource),namespace,allocator,store,events,pending,registrations,nextSystemId,clock)
def restored(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,result:W.World<S,C,R,E> & P) -> W.World<S,C,R,E>:
  match result:
    case (world,_):world
def restore(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~lens:Product.Lens<R,P,Rest>,old:P,world:W.World<S,C,R,E>) -> W.World<S,C,R,E>:
  restored(~S,~C,~R,~E,~P,replace_world(~S,~C,~R,~E,~P,~Rest,~lens,old,world))
def journaled(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~lens:Product.Lens<R,P,Rest>,undo:List<(W.World<S,C,R,E> -> W.World<S,C,R,E>)>,commands:List<Deferred.Command<W.World<S,C,R,E>>>,events:List<&2,E>,trace:TraceFacts.State,meter:Meter.State,result:W.World<S,C,R,E> & P) -> T.Tx<W.World<S,C,R,E>,E>:
  match result:
    case (world,old):T.Tx{world,(w=>restore(~S,~C,~R,~E,~P,~Rest,~lens,old,w)) <> undo,commands,events,trace,meter}
def tx_set(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~lens:Product.Lens<R,P,Rest>,tx:T.Tx<W.World<S,C,R,E>,E>,replacement:P) -> T.Tx<W.World<S,C,R,E>,E>:
  match tx:
    case T.Tx{world,undo,commands,events,trace,meter}:journaled(~S,~C,~R,~E,~P,~Rest,~lens,undo,commands,events,trace,meter,replace_world(~S,~C,~R,~E,~P,~Rest,~lens,replacement,world))
def read(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<R,P,Rest>,~view:P -> P & V) -> Cap.ValueRead<T.Tx<W.World<S,C,R,E>,E>,V>:
  Cap.ValueRead{Resource.tx_get(~S,~C,~R,~E,~V,~project(~R,~P,~Rest,~V,~lens,~view))}
def write(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<R,P,Rest>,~view:P -> P & V) -> Cap.ValueWrite<T.Tx<W.World<S,C,R,E>,E>,P,V>:
  Cap.ValueWrite{Resource.tx_get(~S,~C,~R,~E,~V,~project(~R,~P,~Rest,~V,~lens,~view)),tx_set(~S,~C,~R,~E,~P,~Rest,~lens)}

# The disabled arm reaches the original setter before any view or rendering.
def observed_set_ready(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<R,P,Rest>,~view:P -> P & V,~render:V -> String,key:String,result:T.Tx<W.World<S,C,R,E>,E> & V,incoming:P & V) -> T.Tx<W.World<S,C,R,E>,E>:
  match result incoming:
    case (tx,before), (replacement,after):T.record(~W.World<S,C,R,E>,~E,tx_set(~S,~C,~R,~E,~P,~Rest,~lens,tx,replacement),TraceFacts.Fact{TraceFacts.ResourceValue{},key,TraceFacts.WriteOperation{},None{},TraceFacts.DisplayedValue{render(before)},TraceFacts.DisplayedValue{render(after)},TraceFacts.Attempted{}})
def observed_set_enabled(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<R,P,Rest>,~view:P -> P & V,~render:V -> String,key:String,replacement:P,result:T.Tx<W.World<S,C,R,E>,E> & Bool) -> T.Tx<W.World<S,C,R,E>,E>:
  match result:
    case (tx,False{}):tx_set(~S,~C,~R,~E,~P,~Rest,~lens,tx,replacement)
    case (tx,True{}):observed_set_ready(~S,~C,~R,~E,~P,~Rest,~V,~lens,~view,~render,key,Resource.tx_get(~S,~C,~R,~E,~V,~project(~R,~P,~Rest,~V,~lens,~view),tx),view(replacement))
def observed_set(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<R,P,Rest>,~view:P -> P & V,~render:V -> String,~key:String,tx:T.Tx<W.World<S,C,R,E>,E>,replacement:P) -> T.Tx<W.World<S,C,R,E>,E>:
  observed_set_enabled(~S,~C,~R,~E,~P,~Rest,~V,~lens,~view,~render,key,replacement,T.trace_enabled(~W.World<S,C,R,E>,~E,tx))
def write_observed(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<R,P,Rest>,~view:P -> P & V,~render:V -> String,~key:String) -> Cap.ValueWrite<T.Tx<W.World<S,C,R,E>,E>,P,V>:
  Cap.ValueWrite{Resource.tx_get(~S,~C,~R,~E,~V,~project(~R,~P,~Rest,~V,~lens,~view)),observed_set(~S,~C,~R,~E,~P,~Rest,~V,~lens,~view,~render,~key)}
