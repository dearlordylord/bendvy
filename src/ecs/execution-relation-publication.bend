import Base
import ./entity-allocator.bend as A
import ./relation-types.bend as T
import ./execution-relation-operation.bend as O
import ./execution-relation-store.bend as Store
import ./execution-composer-layout.bend as Layout
import ./lifecycle.bend as Life
import ./change-tick.bend as Tick

# The shared barrier validates full route, origin, descriptor policy and grant
# before taking this exact canonical slot. No caller chooses a replacement graph.
def refreshed(~S:Data,~descriptor:T.Descriptor<S>,~key:String,~origin:Layout.Layout,allocator:A.Allocator,stamp:Life.Stamp,operation:O.Operation<S>,result:Store.Store<S,descriptor> & Store.View<S,descriptor>) -> A.Allocator & (Layout.ResourceSlot<S,Layout.Viewed<Store.Store<S,descriptor>,Store.View<S,descriptor>>,key,origin> & Store.Receipt<S>):
  match result:
    case (store,view):(allocator,(Layout.ResourceSlot{Layout.Viewed{store,view},stamp},Store.Applied{operation}))
def returned(~S:Data,~descriptor:T.Descriptor<S>,~key:String,~origin:Layout.Layout,tick:Tick.Tick,stamp:Life.Stamp,priorView:Store.View<S,descriptor>,result:A.Allocator & (Store.Store<S,descriptor> & Store.Receipt<S>)) -> A.Allocator & (Layout.ResourceSlot<S,Layout.Viewed<Store.Store<S,descriptor>,Store.View<S,descriptor>>,key,origin> & Store.Receipt<S>):
  match result:
    case (allocator,(store,Store.Applied{operation})):refreshed(~S,~descriptor,~key,~origin,allocator,Life.after_write(True{},True{},stamp,tick),operation,Store.project(~S,~descriptor,store))
    case (allocator,(store,Store.Refused{operation,reason})):(allocator,(Layout.ResourceSlot{Layout.Viewed{store,priorView},stamp},Store.Refused{operation,reason}))
def apply(~S:Data,~descriptor:T.Descriptor<S>,~key:String,~origin:Layout.Layout,namespace:U32,allocator:A.Allocator,slot:Layout.ResourceSlot<S,Layout.Viewed<Store.Store<S,descriptor>,Store.View<S,descriptor>>,key,origin>,operation:O.Operation<S>,tick:Tick.Tick) -> A.Allocator & (Layout.ResourceSlot<S,Layout.Viewed<Store.Store<S,descriptor>,Store.View<S,descriptor>>,key,origin> & Store.Receipt<S>):
  match slot:
    case Layout.ResourceSlot{Layout.Viewed{store,view},stamp}:returned(~S,~descriptor,~key,~origin,tick,stamp,view,Store.apply(~S,~descriptor,namespace,allocator,store,operation))
