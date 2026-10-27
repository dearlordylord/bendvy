import Base
import ./owner-product.bend as Product
import ./world.bend as W
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
    case W.World{+namespace,allocator,store,resource,+events,pending,+registrations,+nextSystemId,+clock,lifecycle}:W.observe_resource_finish(~S,~C,~R,~E,~P,replace(~R,~P,~Rest,~lens,replacement,resource),namespace,allocator,store,events,pending,registrations,nextSystemId,clock,lifecycle)
def restored(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,result:W.World<S,C,R,E> & P) -> W.World<S,C,R,E>:
  match result:
    case (world,_):world
def restore(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~lens:Product.Lens<R,P,Rest>,old:P,world:W.World<S,C,R,E>) -> W.World<S,C,R,E>:
  restored(~S,~C,~R,~E,~P,replace_world(~S,~C,~R,~E,~P,~Rest,~lens,old,world))
