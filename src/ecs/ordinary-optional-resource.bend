import Base
import ./ordinary-schema.bend as Schema
import ./owner-product.bend as Product
import ./world.bend as W
import ./inspector.bend as I
import ./check.bend as K
import ./capabilities.bend as Cap

# Storage absence is distinct from an optional value of a present resource.
# Identity still names P; the physical field holds its optional affine owner.
type Slot<-S:Data,-P:Type,-identity:Schema.Resource<S,P>> is Type:
  Missing{}
  Present{owner:P}
type Declaration<-S:Data,-R:Type,-P:Type,-Rest:Type,-V:Data,-identity:Schema.Resource<S,P>,-lens:Product.Lens<R,Slot<S,P,identity>,Rest>,-view:P -> P & V> is Data:
  Declaration{}
def viewed(~S:Data,~R:Type,~P:Type,~Rest:Type,~V:Data,~identity:Schema.Resource<S,P>,~lens:Product.Lens<R,Slot<S,P,identity>,Rest>,rest:Rest,result:P & V) -> R & Maybe<&2,V>:
  match result:
    case (owner,value):(Product.put_field(~R,~Slot<S,P,identity>,~Rest,lens)(rest,Present{owner}),Some{value})
def selected(~S:Data,~R:Type,~P:Type,~Rest:Type,~V:Data,~identity:Schema.Resource<S,P>,~lens:Product.Lens<R,Slot<S,P,identity>,Rest>,~view:P -> P & V,result:Rest & Slot<S,P,identity>) -> R & Maybe<&2,V>:
  match result:
    case (rest,Missing{}):(Product.put_field(~R,~Slot<S,P,identity>,~Rest,lens)(rest,Missing{}),None{})
    case (rest,Present{owner}):viewed(~S,~R,~P,~Rest,~V,~identity,~lens,rest,view(owner))
def project(~S:Data,~R:Type,~P:Type,~Rest:Type,~V:Data,~identity:Schema.Resource<S,P>,~lens:Product.Lens<R,Slot<S,P,identity>,Rest>,~view:P -> P & V,resource:R) -> R & Maybe<&2,V>:
  selected(~S,~R,~P,~Rest,~V,~identity,~lens,~view,Product.get_field(~R,~Slot<S,P,identity>,~Rest,lens)(resource))
def observe(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~V:Data,~identity:Schema.Resource<S,P>,~lens:Product.Lens<R,Slot<S,P,identity>,Rest>,~view:P -> P & V,~declaration:Declaration<S,R,P,Rest,V,identity,lens,view>,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & Maybe<&2,V>:
  W.observe_resource(~S,~C,~R,~E,~Maybe<&2,V>,~project(~S,~R,~P,~Rest,~V,~identity,~lens,~view),world)
def inspect(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~V:Data,~identity:Schema.Resource<S,P>,~lens:Product.Lens<R,Slot<S,P,identity>,Rest>,~view:P -> P & V,~declaration:Declaration<S,R,P,Rest,V,identity,lens,view>) -> Cap.ValueRead<I.Frame<S,C,R,E>,Maybe<&2,V>>:
  I.read_resource(~S,~C,~R,~E,~Maybe<&2,V>,~project(~S,~R,~P,~Rest,~V,~identity,~lens,~view))
def condition(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~V:Data,~identity:Schema.Resource<S,P>,~lens:Product.Lens<R,Slot<S,P,identity>,Rest>,~view:P -> P & V,~declaration:Declaration<S,R,P,Rest,V,identity,lens,view>) -> Cap.ValueRead<K.Frame<S,C,R,E>,Maybe<&2,V>>:
  K.resource_grant(~S,~C,~R,~E,~Maybe<&2,V>,~project(~S,~R,~P,~Rest,~V,~identity,~lens,~view))
# Preflight examines only the slot; it must not invoke the value presenter.
def slot_available(~S:Data,~R:Type,~P:Type,~Rest:Type,~identity:Schema.Resource<S,P>,~lens:Product.Lens<R,Slot<S,P,identity>,Rest>,result:Rest & Slot<S,P,identity>) -> R & List<&2,String>:
  match result:
    case (rest,Missing{}):(Product.put_field(~R,~Slot<S,P,identity>,~Rest,lens)(rest,Missing{}),[Schema.resource_key(~S,~P,identity)])
    case (rest,Present{owner}):(Product.put_field(~R,~Slot<S,P,identity>,~Rest,lens)(rest,Present{owner}),[])
def availability(~S:Data,~R:Type,~P:Type,~Rest:Type,~identity:Schema.Resource<S,P>,~lens:Product.Lens<R,Slot<S,P,identity>,Rest>,resource:R) -> R & List<&2,String>:
  slot_available(~S,~R,~P,~Rest,~identity,~lens,Product.get_field(~R,~Slot<S,P,identity>,~Rest,lens)(resource))
def required(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~V:Data,~identity:Schema.Resource<S,P>,~lens:Product.Lens<R,Slot<S,P,identity>,Rest>,~view:P -> P & V,~declaration:Declaration<S,R,P,Rest,V,identity,lens,view>,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & List<&2,String>:
  W.observe_resource(~S,~C,~R,~E,~List<&2,String>,~availability(~S,~R,~P,~Rest,~identity,~lens),world)
