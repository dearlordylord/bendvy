import Base
import ./relation-types.bend as T
import ./execution-relation-store.bend as Store
import ./execution-relation-failure-channel.bend as Reader
import ./execution-relation-failure-message.bend as Failure
import ./execution-stream-channel.bend as Channel
import ./execution-composer-layout.bend as Layout
import ./execution-state.bend as State
import ./execution-lifecycle-notices.bend as Notice
import ./owner-product.bend as Product
import ./change-tick.bend as Tick
import ./lifecycle.bend as Life
import ./world.bend as W

type Read<-S:Data,-descriptor:T.Descriptor<S>,-full:Layout.Layout,-route:Layout.Route,-H:Type> is Type:
  Read{read:Reader.Reader<S,descriptor,full,route> -> H -> H & Reader.Reading<S,descriptor,full,route>}
def Ops(~S:Data,~descriptor:T.Descriptor<S>,~full:Layout.Layout,~route:Layout.Route,H:Type) -> Type:Read<S,descriptor,full,route,H>
def returned_store(~S:Data,~descriptor:T.Descriptor<S>,~full:Layout.Layout,~route:Layout.Route,namespace:U32,graph:T.Graph<S>,sequence:Nat,nextReader:U32,result:Channel.Store<Failure.Message<S,descriptor>> & Reader.Reading<S,descriptor,full,route>) -> Store.Store<S,descriptor> & Reader.Reading<S,descriptor,full,route>:
  match result:
    case (failures,reading):(Store.Store{namespace,graph,failures,sequence,nextReader},reading)
def read_store(~S:Data,~descriptor:T.Descriptor<S>,~full:Layout.Layout,~route:Layout.Route,reader:Reader.Reader<S,descriptor,full,route>,tick:Tick.Tick,store:Store.Store<S,descriptor>) -> Store.Store<S,descriptor> & Reader.Reading<S,descriptor,full,route>:
  match store:
    case Store.Store{+namespace,graph,failures,+sequence,nextReader}:returned_store(~S,~descriptor,~full,~route,namespace,graph,sequence,nextReader,Reader.read(~S,~descriptor,~full,~route,namespace,sequence,tick,reader,failures))
def returned_slot(~S:Data,~descriptor:T.Descriptor<S>,~full:Layout.Layout,~route:Layout.Route,view:Store.View<S,descriptor>,stamp:Life.Stamp,result:Store.Store<S,descriptor> & Reader.Reading<S,descriptor,full,route>) -> Layout.ResourceSlot<S,Layout.Viewed<Store.Store<S,descriptor>,Store.View<S,descriptor>>,Layout.key(full,route),Layout.origin(full,route)> & Reader.Reading<S,descriptor,full,route>:
  match result:
    case (store,reading):(Layout.ResourceSlot{Layout.Viewed{store,view},stamp},reading)
def read_slot(~S:Data,~descriptor:T.Descriptor<S>,~full:Layout.Layout,~route:Layout.Route,reader:Reader.Reader<S,descriptor,full,route>,tick:Tick.Tick,slot:Layout.ResourceSlot<S,Layout.Viewed<Store.Store<S,descriptor>,Store.View<S,descriptor>>,Layout.key(full,route),Layout.origin(full,route)>) -> Layout.ResourceSlot<S,Layout.Viewed<Store.Store<S,descriptor>,Store.View<S,descriptor>>,Layout.key(full,route),Layout.origin(full,route)> & Reader.Reading<S,descriptor,full,route>:
  match slot:
    case Layout.ResourceSlot{Layout.Viewed{store,view},stamp}:returned_slot(~S,~descriptor,~full,~route,view,stamp,read_store(~S,~descriptor,~full,~route,reader,tick,store))
def view_namespace(~S:Data,view:Notice.View<S>) -> U32:
  match view:
    case Notice.View{namespace,_,_}:namespace
def restored(~S:Data,~descriptor:T.Descriptor<S>,~full:Layout.Layout,~route:Layout.Route,~C:Type,~R:Type,~Rest:Type,~lens:Product.Lens<R,Layout.ResourceSlot<S,Layout.Viewed<Store.Store<S,descriptor>,Store.View<S,descriptor>>,Layout.key(full,route),Layout.origin(full,route)>,Rest>,columns:C,handles:List<&2,W.Handle<S>>,tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,view:Notice.View<S>,rest:Rest,result:Layout.ResourceSlot<S,Layout.Viewed<Store.Store<S,descriptor>,Store.View<S,descriptor>>,Layout.key(full,route),Layout.origin(full,route)> & Reader.Reading<S,descriptor,full,route>) -> State.Scope<S,C,R> & Reader.Reading<S,descriptor,full,route>:
  match result:
    case (slot,reading):(State.Scope{columns,Product.put_field(~R,~Layout.ResourceSlot<S,Layout.Viewed<Store.Store<S,descriptor>,Store.View<S,descriptor>>,Layout.key(full,route),Layout.origin(full,route)>,~Rest,lens)(rest,slot),handles,tick,prior,view},reading)
def taken(~S:Data,~descriptor:T.Descriptor<S>,~full:Layout.Layout,~route:Layout.Route,~C:Type,~R:Type,~Rest:Type,~lens:Product.Lens<R,Layout.ResourceSlot<S,Layout.Viewed<Store.Store<S,descriptor>,Store.View<S,descriptor>>,Layout.key(full,route),Layout.origin(full,route)>,Rest>,reader:Reader.Reader<S,descriptor,full,route>,columns:C,handles:List<&2,W.Handle<S>>,+tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,view:Notice.View<S>,result:Rest & Layout.ResourceSlot<S,Layout.Viewed<Store.Store<S,descriptor>,Store.View<S,descriptor>>,Layout.key(full,route),Layout.origin(full,route)>) -> State.Scope<S,C,R> & Reader.Reading<S,descriptor,full,route>:
  match result:
    case (rest,slot):restored(~S,~descriptor,~full,~route,~C,~R,~Rest,~lens,columns,handles,tick,prior,view,rest,read_slot(~S,~descriptor,~full,~route,reader,tick,slot))
def checked(~S:Data,~descriptor:T.Descriptor<S>,~full:Layout.Layout,~route:Layout.Route,~C:Type,~R:Type,~Rest:Type,~lens:Product.Lens<R,Layout.ResourceSlot<S,Layout.Viewed<Store.Store<S,descriptor>,Store.View<S,descriptor>>,Layout.key(full,route),Layout.origin(full,route)>,Rest>,allowed:Bool,reader:Reader.Reader<S,descriptor,full,route>,scope:State.Scope<S,C,R>) -> State.Scope<S,C,R> & Reader.Reading<S,descriptor,full,route>:
  match allowed scope:
    case False{} scope:(scope,Reader.Refused{reader})
    case True{} State.Scope{columns,resource,handles,tick,prior,view}:taken(~S,~descriptor,~full,~route,~C,~R,~Rest,~lens,reader,columns,handles,tick,prior,view,Product.get_field(~R,~Layout.ResourceSlot<S,Layout.Viewed<Store.Store<S,descriptor>,Store.View<S,descriptor>>,Layout.key(full,route),Layout.origin(full,route)>,~Rest,lens)(resource))
def read(~S:Data,~descriptor:T.Descriptor<S>,~full:Layout.Layout,~route:Layout.Route,~C:Type,~R:Type,~Rest:Type,~lens:Product.Lens<R,Layout.ResourceSlot<S,Layout.Viewed<Store.Store<S,descriptor>,Store.View<S,descriptor>>,Layout.key(full,route),Layout.origin(full,route)>,Rest>,reader:Reader.Reader<S,descriptor,full,route>,scope:State.Scope<S,C,R>) -> State.Scope<S,C,R> & Reader.Reading<S,descriptor,full,route>:
  match reader scope:
    case Reader.Reader{+namespace,id,cursor} State.Scope{columns,resource,handles,tick,prior,+view}:checked(~S,~descriptor,~full,~route,~C,~R,~Rest,~lens,U32.is_eq(namespace,view_namespace(~S,view)),Reader.Reader{namespace,id,cursor},State.Scope{columns,resource,handles,tick,prior,view})
def cap(~S:Data,~descriptor:T.Descriptor<S>,~full:Layout.Layout,~route:Layout.Route,~C:Type,~R:Type,~Rest:Type,~lens:Product.Lens<R,Layout.ResourceSlot<S,Layout.Viewed<Store.Store<S,descriptor>,Store.View<S,descriptor>>,Layout.key(full,route),Layout.origin(full,route)>,Rest>) -> Read<S,descriptor,full,route,State.Scope<S,C,R>>:
  Read{read(~S,~descriptor,~full,~route,~C,~R,~Rest,~lens)}
