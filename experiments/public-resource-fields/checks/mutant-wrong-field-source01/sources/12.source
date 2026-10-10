import Base
import ../../../../src/ecs/owner-product.bend as Product
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/transaction.bend as T
import ../../../../src/ecs/resource.bend as Resource
import ../../../../src/ecs/capabilities.bend as Cap
# Private feasibility plumbing. Canonical product lenses preserve affine siblings.
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
    case W.World{+namespace,+nextId,+highWater,live,+capacity,+depth,store,resource,+events,pending,+registrations,+nextSystemId,+clock}:W.observe_resource_finish(~S,~C,~R,~E,~P,replace(~R,~P,~Rest,~lens,replacement,resource),namespace,nextId,highWater,live,capacity,depth,store,events,pending,registrations,nextSystemId,clock)
def restored(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,result:W.World<S,C,R,E> & P) -> W.World<S,C,R,E>:
  match result:
    case (world,_):world
def restore(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~lens:Product.Lens<R,P,Rest>,old:P,world:W.World<S,C,R,E>) -> W.World<S,C,R,E>:
  restored(~S,~C,~R,~E,~P,replace_world(~S,~C,~R,~E,~P,~Rest,~lens,old,world))
def journaled(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~lens:Product.Lens<R,P,Rest>,undo:List<(W.World<S,C,R,E> -> W.World<S,C,R,E>)>,commands:List<(W.World<S,C,R,E> -> W.World<S,C,R,E>)>,events:List<&2,E>,result:W.World<S,C,R,E> & P) -> T.Tx<W.World<S,C,R,E>,E>:
  match result:
    case (world,old):T.Tx{world,(w=>restore(~S,~C,~R,~E,~P,~Rest,~lens,old,w)) <> undo,commands,events}
def tx_set(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~lens:Product.Lens<R,P,Rest>,tx:T.Tx<W.World<S,C,R,E>,E>,replacement:P) -> T.Tx<W.World<S,C,R,E>,E>:
  match tx:
    case T.Tx{world,undo,commands,events}:journaled(~S,~C,~R,~E,~P,~Rest,~lens,undo,commands,events,replace_world(~S,~C,~R,~E,~P,~Rest,~lens,replacement,world))
def read(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<R,P,Rest>,~view:P -> P & V) -> Cap.ValueRead<T.Tx<W.World<S,C,R,E>,E>,V>:
  Cap.ValueRead{Resource.tx_get(~S,~C,~R,~E,~V,~project(~R,~P,~Rest,~V,~lens,~view))}
def write(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<R,P,Rest>,~view:P -> P & V) -> Cap.ValueWrite<T.Tx<W.World<S,C,R,E>,E>,P,V>:
  Cap.ValueWrite{Resource.tx_get(~S,~C,~R,~E,~V,~project(~R,~P,~Rest,~V,~lens,~view)),tx_set(~S,~C,~R,~E,~P,~Rest,~lens)}
