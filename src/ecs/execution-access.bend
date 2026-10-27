import Base
import ./execution-query-identity.bend as Index
import ./execution-lifecycle-notices.bend as Notice
import ./execution-projection.bend as Projection
import ./execution-state.bend as State
import ./execution-declaration.bend as D
import ./world.bend as W
import ./component.bend as Component
import ./change-tick.bend as Tick
import ./chunk-column.bend as Col
import ./owner-product.bend as Product
import ./ordinary-declaration.bend as Identity
import ./ordinary-schema.bend as Schema

type ComponentRead<-S:Data,-H:Type,-V:Data> is Type:
  ComponentRead{get:H -> W.Handle<S> -> H & Maybe<&2,V>}
type ComponentWrite<-S:Data,-H:Type,-P:Type,-V:Data> is Type:
  ComponentWrite{get:H -> W.Handle<S> -> H & Maybe<&2,V>,modify:(P -> P & V) -> H -> W.Handle<S> -> H & Maybe<&2,V>,checked_get:H -> W.Handle<S> -> H & Component.Access<V>}
type ResourceRead<-H:Type,-V:Data> is Type:
  ResourceRead{get:H -> H & V}
type ResourceWrite<-H:Type,-P:Type,-V:Data> is Type:
  ResourceWrite{get:H -> H & V,modify:(P -> P & V) -> H -> H & V,own:@-Out:Type -> (P -> P & Out) -> H -> H & Out,own_at:@-Out:Type -> (Tick.Tick -> P -> P & Out) -> H -> H & Out}
def ComponentReads(~S:Data,~V:Data,H:Type) -> Type:ComponentRead<S,H,V>
def ComponentWrites(~S:Data,~P:Type,~V:Data,H:Type) -> Type:ComponentWrite<S,H,P,V>
def ResourceReads(~V:Data,H:Type) -> Type:ResourceRead<H,V>
def ResourceWrites(~P:Type,~V:Data,H:Type) -> Type:ResourceWrite<H,P,V>

def component_returned(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<C,Col.Column<S,P>,Rest>,resource:R,handles:List<&2,W.Handle<S>>,tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,rest:Rest,result:Col.Column<S,P> & Maybe<&2,V>,+lifecycleView:Notice.View<S>) -> State.Scope<S,C,R> & Maybe<&2,V>:
  match result:
    case (column,value):(State.Scope{Product.put_field(~C,~Col.Column<S,P>,~Rest,lens)(rest,column),resource,handles,tick,prior,lifecycleView},value)
def component_taken(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<C,Col.Column<S,P>,Rest>,~project:P -> P & V,resource:R,handles:List<&2,W.Handle<S>>,+tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,index:U32,result:Rest & Col.Column<S,P>,+lifecycleView:Notice.View<S>) -> State.Scope<S,C,R> & Maybe<&2,V>:
  match result:
    case (rest,column):component_returned(~S,~C,~R,~P,~Rest,~V,~lens,resource,handles,tick,prior,rest,Col.view(~S,~P,~V,~project,column,index),lifecycleView)
def component_read_physical(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<C,Col.Column<S,P>,Rest>,~project:P -> P & V,scope:State.Scope<S,C,R>,offset:Maybe<&2,U32>) -> State.Scope<S,C,R> & Maybe<&2,V>:
  match scope offset:
    case scope None{}:(scope,None{})
    case State.Scope{store,resource,handles,tick,prior,+lifecycleView} Some{offset}:component_taken(~S,~C,~R,~P,~Rest,~V,~lens,~project,resource,handles,tick,prior,offset,Product.get_field(~C,~Col.Column<S,P>,~Rest,lens)(store),lifecycleView)
def component_read_checked(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<C,Col.Column<S,P>,Rest>,~project:P -> P & V,allowed:Bool,scope:State.Scope<S,C,R>,handle:W.Handle<S>) -> State.Scope<S,C,R> & Maybe<&2,V>:
  match allowed:
    case False{}:(scope,None{})
    case True{}:component_read_physical(~S,~C,~R,~P,~Rest,~V,~lens,~project,scope,Index.physical_index(W.handle_index(~S,handle)))
def component_get(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<C,Col.Column<S,P>,Rest>,~project:P -> P & V,scope:State.Scope<S,C,R>,+handle:W.Handle<S>) -> State.Scope<S,C,R> & Maybe<&2,V>:
  match scope:
    case State.Scope{store,resource,+handles,tick,prior,+lifecycleView}:component_read_checked(~S,~C,~R,~P,~Rest,~V,~lens,~project,Index.captured_live(~S,handles,handle),State.Scope{store,resource,handles,tick,prior,lifecycleView},handle)
def component_access_returned(~S:Data,~C:Type,~R:Type,~V:Data,result:State.Scope<S,C,R> & Maybe<&2,V>) -> State.Scope<S,C,R> & Component.Access<V>:
  match result:
    case (scope,None{}):(scope,Component.ComponentAbsent{})
    case (scope,Some{value}):(scope,Component.Found{value})
def component_access_checked(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<C,Col.Column<S,P>,Rest>,~project:P -> P & V,allowed:Bool,scope:State.Scope<S,C,R>,handle:W.Handle<S>) -> State.Scope<S,C,R> & Component.Access<V>:
  match allowed:
    case False{}:(scope,Component.MissingEntity{})
    case True{}:component_access_returned(~S,~C,~R,~V,component_read_checked(~S,~C,~R,~P,~Rest,~V,~lens,~project,True{},scope,handle))
def component_checked_get(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<C,Col.Column<S,P>,Rest>,~project:P -> P & V,scope:State.Scope<S,C,R>,+handle:W.Handle<S>) -> State.Scope<S,C,R> & Component.Access<V>:
  match scope:
    case State.Scope{store,resource,+handles,tick,prior,+lifecycleView}:component_access_checked(~S,~C,~R,~P,~Rest,~V,~lens,~project,Index.captured_live(~S,handles,handle),State.Scope{store,resource,handles,tick,prior,lifecycleView},handle)
def component_modified(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<C,Col.Column<S,P>,Rest>,transform:P -> P & V,resource:R,handles:List<&2,W.Handle<S>>,+tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,index:U32,result:Rest & Col.Column<S,P>,+lifecycleView:Notice.View<S>) -> State.Scope<S,C,R> & Maybe<&2,V>:
  match result:
    case (rest,column):component_returned(~S,~C,~R,~P,~Rest,~V,~lens,resource,handles,tick,prior,rest,Col.modify_runtime(~S,~P,~V,transform,column,index,tick),lifecycleView)
def component_modify_physical(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<C,Col.Column<S,P>,Rest>,transform:P -> P & V,scope:State.Scope<S,C,R>,offset:Maybe<&2,U32>) -> State.Scope<S,C,R> & Maybe<&2,V>:
  match scope offset:
    case scope None{}:(scope,None{})
    case State.Scope{store,resource,handles,tick,prior,+lifecycleView} Some{offset}:component_modified(~S,~C,~R,~P,~Rest,~V,~lens,transform,resource,handles,tick,prior,offset,Product.get_field(~C,~Col.Column<S,P>,~Rest,lens)(store),lifecycleView)
def component_modify_checked(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<C,Col.Column<S,P>,Rest>,transform:P -> P & V,allowed:Bool,scope:State.Scope<S,C,R>,handle:W.Handle<S>) -> State.Scope<S,C,R> & Maybe<&2,V>:
  match allowed:
    case False{}:(scope,None{})
    case True{}:component_modify_physical(~S,~C,~R,~P,~Rest,~V,~lens,transform,scope,Index.physical_index(W.handle_index(~S,handle)))
def component_modify(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<C,Col.Column<S,P>,Rest>,transform:P -> P & V,scope:State.Scope<S,C,R>,+handle:W.Handle<S>) -> State.Scope<S,C,R> & Maybe<&2,V>:
  match scope:
    case State.Scope{store,resource,+handles,tick,prior,+lifecycleView}:component_modify_checked(~S,~C,~R,~P,~Rest,~V,~lens,transform,Index.captured_live(~S,handles,handle),State.Scope{store,resource,handles,tick,prior,lifecycleView},handle)
def component_modify_once(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<C,Col.Column<S,P>,Rest>,transform:P -> P & V,scope:State.Scope<S,C,R>,handle:W.Handle<S>) -> State.Scope<S,C,R> & Maybe<&2,V>:
  component_modify(~S,~C,~R,~P,~Rest,~V,~lens,transform,scope,handle)
def component_read(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<C,Col.Column<S,P>,Rest>,~project:P -> P & V,projection:Projection.Affine<P,V,project>,identity:Identity.Declaration<S,P>) -> D.Declaration<S,C,R,ComponentReads(~S,~V)>:
  D.Declaration{ComponentRead{scope=>handle=>component_get(~S,~C,~R,~P,~Rest,~V,~lens,~project,scope,handle)},[D.Access{Identity.key(~S,~P,identity),D.ComponentAccess{},D.Exclusive{},D.ReadOnly{}}]}
def component_write(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<C,Col.Column<S,P>,Rest>,~project:P -> P & V,projection:Projection.Affine<P,V,project>,identity:Identity.Declaration<S,P>) -> D.Declaration<S,C,R,ComponentWrites(~S,~P,~V)>:
  D.Declaration{ComponentWrite{scope=>handle=>component_get(~S,~C,~R,~P,~Rest,~V,~lens,~project,scope,handle),component_modify_once(~S,~C,~R,~P,~Rest,~V,~lens),scope=>handle=>component_checked_get(~S,~C,~R,~P,~Rest,~V,~lens,~project,scope,handle)},[D.Access{Identity.key(~S,~P,identity),D.ComponentAccess{},D.Exclusive{},D.Writable{}}]}
def resource_returned(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<R,P,Rest>,store:C,handles:List<&2,W.Handle<S>>,tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,rest:Rest,result:P & V,+lifecycleView:Notice.View<S>) -> State.Scope<S,C,R> & V:
  match result:
    case (payload,value):(State.Scope{store,Product.put_field(~R,~P,~Rest,lens)(rest,payload),handles,tick,prior,lifecycleView},value)
def resource_taken(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<R,P,Rest>,~project:P -> P & V,store:C,handles:List<&2,W.Handle<S>>,tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,result:Rest & P,+lifecycleView:Notice.View<S>) -> State.Scope<S,C,R> & V:
  match result:
    case (rest,payload):resource_returned(~S,~C,~R,~P,~Rest,~V,~lens,store,handles,tick,prior,rest,project(payload),lifecycleView)
def resource_get(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<R,P,Rest>,~project:P -> P & V,scope:State.Scope<S,C,R>) -> State.Scope<S,C,R> & V:
  match scope:
    case State.Scope{store,resource,handles,tick,prior,+lifecycleView}:resource_taken(~S,~C,~R,~P,~Rest,~V,~lens,~project,store,handles,tick,prior,Product.get_field(~R,~P,~Rest,lens)(resource),lifecycleView)
def resource_transform_taken(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<R,P,Rest>,transform:P -> P & V,store:C,handles:List<&2,W.Handle<S>>,tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,result:Rest & P,+lifecycleView:Notice.View<S>) -> State.Scope<S,C,R> & V:
  match result:
    case (rest,payload):resource_returned(~S,~C,~R,~P,~Rest,~V,~lens,store,handles,tick,prior,rest,transform(payload),lifecycleView)
def resource_modify(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<R,P,Rest>,transform:P -> P & V,scope:State.Scope<S,C,R>) -> State.Scope<S,C,R> & V:
  match scope:
    case State.Scope{store,resource,handles,tick,prior,+lifecycleView}:resource_transform_taken(~S,~C,~R,~P,~Rest,~V,~lens,transform,store,handles,tick,prior,Product.get_field(~R,~P,~Rest,lens)(resource),lifecycleView)
def resource_owned_returned(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~lens:Product.Lens<R,P,Rest>,-Out:Type,store:C,handles:List<&2,W.Handle<S>>,tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,rest:Rest,result:P & Out,+lifecycleView:Notice.View<S>) -> State.Scope<S,C,R> & Out:
  match result:
    case (payload,value):(State.Scope{store,Product.put_field(~R,~P,~Rest,lens)(rest,payload),handles,tick,prior,lifecycleView},value)
def resource_owned_taken(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~lens:Product.Lens<R,P,Rest>,-Out:Type,transform:P -> P & Out,store:C,handles:List<&2,W.Handle<S>>,tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,result:Rest & P,+lifecycleView:Notice.View<S>) -> State.Scope<S,C,R> & Out:
  match result:
    case (rest,payload):resource_owned_returned(~S,~C,~R,~P,~Rest,~lens,Out,store,handles,tick,prior,rest,transform(payload),lifecycleView)
def resource_own(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~lens:Product.Lens<R,P,Rest>,-Out:Type,transform:P -> P & Out,scope:State.Scope<S,C,R>) -> State.Scope<S,C,R> & Out:
  match scope:
    case State.Scope{store,resource,handles,tick,prior,+lifecycleView}:resource_owned_taken(~S,~C,~R,~P,~Rest,~lens,Out,transform,store,handles,tick,prior,Product.get_field(~R,~P,~Rest,lens)(resource),lifecycleView)
# The interpreter supplies the admitted execution tick; gameplay cannot choose it.
def resource_own_at(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~lens:Product.Lens<R,P,Rest>,-Out:Type,transform:Tick.Tick -> P -> P & Out,scope:State.Scope<S,C,R>) -> State.Scope<S,C,R> & Out:
  match scope:
    case State.Scope{store,resource,handles,+tick,prior,+lifecycleView}:resource_owned_taken(~S,~C,~R,~P,~Rest,~lens,Out,transform(tick),store,handles,tick,prior,Product.get_field(~R,~P,~Rest,lens)(resource),lifecycleView)
def resource_read(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<R,P,Rest>,~project:P -> P & V,projection:Projection.Affine<P,V,project>,identity:Schema.Resource<S,P>) -> D.Declaration<S,C,R,ResourceReads(~V)>:
  D.Declaration{ResourceRead{resource_get(~S,~C,~R,~P,~Rest,~V,~lens,~project)},[D.Access{Schema.resource_key(~S,~P,identity),D.ResourceAccess{},D.Exclusive{},D.ReadOnly{}}]}
def resource_write(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<R,P,Rest>,~project:P -> P & V,projection:Projection.Affine<P,V,project>,identity:Schema.Resource<S,P>) -> D.Declaration<S,C,R,ResourceWrites(~P,~V)>:
  D.Declaration{ResourceWrite{resource_get(~S,~C,~R,~P,~Rest,~V,~lens,~project),resource_modify(~S,~C,~R,~P,~Rest,~V,~lens),resource_own(~S,~C,~R,~P,~Rest,~lens),resource_own_at(~S,~C,~R,~P,~Rest,~lens)},[D.Access{Schema.resource_key(~S,~P,identity),D.ResourceAccess{},D.Exclusive{},D.Writable{}}]}
def component_modify_field(~S:Data,~H:Type,~P:Type,~V:Data,cap:ComponentWrite<S,H,P,V>) -> (P -> P & V) -> H -> W.Handle<S> -> H & Maybe<&2,V>:
  match cap:
    case ComponentWrite{_,modify,_}:modify
def resource_modify_field(~H:Type,~P:Type,~V:Data,cap:ResourceWrite<H,P,V>) -> (P -> P & V) -> H -> H & V:
  match cap:
    case ResourceWrite{_,modify,_,_}:modify
def component_read_field(~S:Data,~H:Type,~V:Data,cap:ComponentRead<S,H,V>) -> H -> W.Handle<S> -> H & Maybe<&2,V>:
  match cap:
    case ComponentRead{get}:get
def resource_read_field(~H:Type,~V:Data,cap:ResourceRead<H,V>) -> H -> H & V:
  match cap:
    case ResourceRead{get}:get

def resource_own_field(~H:Type,~P:Type,~V:Data,-Out:Type,cap:ResourceWrite<H,P,V>) -> (P -> P & Out) -> H -> H & Out:
  match cap:
    case ResourceWrite{_,_,own,_}:own(Out)

def resource_own_at_field(~H:Type,~P:Type,~V:Data,-Out:Type,cap:ResourceWrite<H,P,V>) -> (Tick.Tick -> P -> P & Out) -> H -> H & Out:
  match cap:
    case ResourceWrite{_,_,_,own_at}:own_at(Out)

def component_checked_get_field(~S:Data,~H:Type,~P:Type,~V:Data,cap:ComponentWrite<S,H,P,V>) -> H -> W.Handle<S> -> H & Component.Access<V>:
  match cap:
    case ComponentWrite{_,_,checked_get}:checked_get
