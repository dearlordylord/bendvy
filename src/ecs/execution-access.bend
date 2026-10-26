import Base
import ./execution-state.bend as State
import ./execution-declaration.bend as D
import ./world.bend as W
import ./change-tick.bend as Tick
import ./chunk-column.bend as Col
import ./owner-product.bend as Product
import ./ordinary-declaration.bend as Identity
import ./ordinary-schema.bend as Schema

type Read<-H:Type,-V:Data> is Type:
  Read{get:H -> W.Handle<Unit> -> H & Maybe<&2,V>}
type ComponentRead<-S:Data,-H:Type,-V:Data> is Type:
  ComponentRead{get:H -> W.Handle<S> -> H & Maybe<&2,V>}
type ComponentWrite<-S:Data,-H:Type,-P:Type,-V:Data> is Type:
  ComponentWrite{get:H -> W.Handle<S> -> H & Maybe<&2,V>,modify:@-transform:(P -> P & V) -> H -> W.Handle<S> -> H & Maybe<&2,V>}
type ResourceRead<-H:Type,-V:Data> is Type:
  ResourceRead{get:H -> H & V}
type ResourceWrite<-H:Type,-P:Type,-V:Data> is Type:
  ResourceWrite{get:H -> H & V,modify:@-transform:(P -> P & V) -> H -> H & V}
def ComponentReads(~S:Data,~V:Data,H:Type) -> Type:ComponentRead<S,H,V>
def ComponentWrites(~S:Data,~P:Type,~V:Data,H:Type) -> Type:ComponentWrite<S,H,P,V>
def ResourceReads(~V:Data,H:Type) -> Type:ResourceRead<H,V>
def ResourceWrites(~P:Type,~V:Data,H:Type) -> Type:ResourceWrite<H,P,V>

def component_returned(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<C,Col.Column<S,P>,Rest>,resource:R,handles:List<&2,W.Handle<S>>,tick:Tick.Tick,rest:Rest,result:Col.Column<S,P> & Maybe<&2,V>) -> State.Scope<S,C,R> & Maybe<&2,V>:
  match result:
    case (column,value):(State.Scope{Product.put_field(~C,~Col.Column<S,P>,~Rest,lens)(rest,column),resource,handles,tick},value)
def component_taken(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<C,Col.Column<S,P>,Rest>,~project:P -> P & V,resource:R,handles:List<&2,W.Handle<S>>,tick:Tick.Tick,index:U32,result:Rest & Col.Column<S,P>) -> State.Scope<S,C,R> & Maybe<&2,V>:
  match result:
    case (rest,column):component_returned(~S,~C,~R,~P,~Rest,~V,~lens,resource,handles,tick,rest,Col.view(~S,~P,~V,~project,column,index))
def component_read_checked(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<C,Col.Column<S,P>,Rest>,~project:P -> P & V,allowed:Bool,scope:State.Scope<S,C,R>,handle:W.Handle<S>) -> State.Scope<S,C,R> & Maybe<&2,V>:
  match allowed scope:
    case False{} scope:(scope,None{})
    case True{} State.Scope{store,resource,handles,tick}:component_taken(~S,~C,~R,~P,~Rest,~V,~lens,~project,resource,handles,tick,W.handle_index(~S,handle),Product.get_field(~C,~Col.Column<S,P>,~Rest,lens)(store))
def component_get(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<C,Col.Column<S,P>,Rest>,~project:P -> P & V,scope:State.Scope<S,C,R>,+handle:W.Handle<S>) -> State.Scope<S,C,R> & Maybe<&2,V>:
  match scope:
    case State.Scope{store,resource,+handles,tick}:component_read_checked(~S,~C,~R,~P,~Rest,~V,~lens,~project,State.member(~S,handle,handles),State.Scope{store,resource,handles,tick},handle)
def component_modified(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<C,Col.Column<S,P>,Rest>,~transform:P -> P & V,resource:R,handles:List<&2,W.Handle<S>>,+tick:Tick.Tick,index:U32,result:Rest & Col.Column<S,P>) -> State.Scope<S,C,R> & Maybe<&2,V>:
  match result:
    case (rest,column):component_returned(~S,~C,~R,~P,~Rest,~V,~lens,resource,handles,tick,rest,Col.modify_at(~S,~P,~V,~transform,column,index,tick))
def component_modify_checked(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<C,Col.Column<S,P>,Rest>,~transform:P -> P & V,allowed:Bool,scope:State.Scope<S,C,R>,handle:W.Handle<S>) -> State.Scope<S,C,R> & Maybe<&2,V>:
  match allowed scope:
    case False{} scope:(scope,None{})
    case True{} State.Scope{store,resource,handles,tick}:component_modified(~S,~C,~R,~P,~Rest,~V,~lens,~transform,resource,handles,tick,W.handle_index(~S,handle),Product.get_field(~C,~Col.Column<S,P>,~Rest,lens)(store))
def component_modify(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<C,Col.Column<S,P>,Rest>,~transform:P -> P & V,scope:State.Scope<S,C,R>,+handle:W.Handle<S>) -> State.Scope<S,C,R> & Maybe<&2,V>:
  match scope:
    case State.Scope{store,resource,+handles,tick}:component_modify_checked(~S,~C,~R,~P,~Rest,~V,~lens,~transform,State.member(~S,handle,handles),State.Scope{store,resource,handles,tick},handle)
def component_modify_once(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<C,Col.Column<S,P>,Rest>,~transform:P -> P & V,scope:State.Scope<S,C,R>,handle:W.Handle<S>) -> State.Scope<S,C,R> & Maybe<&2,V>:
  component_modify(~S,~C,~R,~P,~Rest,~V,~lens,~transform,scope,handle)
def component_read(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<C,Col.Column<S,P>,Rest>,~project:P -> P & V,identity:Identity.Declaration<S,P>) -> D.Declaration<S,C,R,ComponentReads(~S,~V)>:
  D.Declaration{ComponentRead{scope=>handle=>component_get(~S,~C,~R,~P,~Rest,~V,~lens,~project,scope,handle)},[Identity.key(~S,~P,identity)]}
def component_write(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<C,Col.Column<S,P>,Rest>,~project:P -> P & V,identity:Identity.Declaration<S,P>) -> D.Declaration<S,C,R,ComponentWrites(~S,~P,~V)>:
  D.Declaration{ComponentWrite{scope=>handle=>component_get(~S,~C,~R,~P,~Rest,~V,~lens,~project,scope,handle),component_modify_once(~S,~C,~R,~P,~Rest,~V,~lens)},[Identity.key(~S,~P,identity)]}
def resource_returned(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<R,P,Rest>,store:C,handles:List<&2,W.Handle<S>>,tick:Tick.Tick,rest:Rest,result:P & V) -> State.Scope<S,C,R> & V:
  match result:
    case (payload,value):(State.Scope{store,Product.put_field(~R,~P,~Rest,lens)(rest,payload),handles,tick},value)
def resource_taken(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<R,P,Rest>,~project:P -> P & V,store:C,handles:List<&2,W.Handle<S>>,tick:Tick.Tick,result:Rest & P) -> State.Scope<S,C,R> & V:
  match result:
    case (rest,payload):resource_returned(~S,~C,~R,~P,~Rest,~V,~lens,store,handles,tick,rest,project(payload))
def resource_get(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<R,P,Rest>,~project:P -> P & V,scope:State.Scope<S,C,R>) -> State.Scope<S,C,R> & V:
  match scope:
    case State.Scope{store,resource,handles,tick}:resource_taken(~S,~C,~R,~P,~Rest,~V,~lens,~project,store,handles,tick,Product.get_field(~R,~P,~Rest,lens)(resource))
def resource_modify(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<R,P,Rest>,~transform:P -> P & V,scope:State.Scope<S,C,R>) -> State.Scope<S,C,R> & V:
  resource_get(~S,~C,~R,~P,~Rest,~V,~lens,~transform,scope)
def resource_read(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<R,P,Rest>,~project:P -> P & V,identity:Schema.Resource<S,P>) -> D.Declaration<S,C,R,ResourceReads(~V)>:
  D.Declaration{ResourceRead{resource_get(~S,~C,~R,~P,~Rest,~V,~lens,~project)},[Schema.resource_key(~S,~P,identity)]}
def resource_write(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<R,P,Rest>,~project:P -> P & V,identity:Schema.Resource<S,P>) -> D.Declaration<S,C,R,ResourceWrites(~P,~V)>:
  D.Declaration{ResourceWrite{resource_get(~S,~C,~R,~P,~Rest,~V,~lens,~project),resource_modify(~S,~C,~R,~P,~Rest,~V,~lens)},[Schema.resource_key(~S,~P,identity)]}
def component_modify_field(~S:Data,~H:Type,~P:Type,~V:Data,cap:ComponentWrite<S,H,P,V>) -> @-transform:(P -> P & V) -> H -> W.Handle<S> -> H & Maybe<&2,V>:
  match cap:
    case ComponentWrite{_,modify}:modify
def resource_modify_field(~H:Type,~P:Type,~V:Data,cap:ResourceWrite<H,P,V>) -> @-transform:(P -> P & V) -> H -> H & V:
  match cap:
    case ResourceWrite{_,modify}:modify
