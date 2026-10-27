import Base
import ./execution-composer-layout.bend as Layout
import ./owner-product.bend as Product
import ./chunk-column.bend as Column
import ./chunk-partition.bend as Part
import ./entity-allocator.bend as A
import ./world.bend as W
import ./deferred-command.bend as Deferred
import ./clock-state.bend as Clock
import ./execution-lifecycle-notices.bend as Notice
import ./snapshot-data.bend as LegacyPending

type Reason is Data:PendingWork{} ActiveExecution{} MalformedColumns{} Capacity{}
type Prepared<-S:Data,-layout:Layout.Layout,-R:Type,-E:Data> is Type:
  Ready{world:W.World<S,Layout.columns(~S,layout),R,E>,handles:List<&2,W.Handle<S>>}
  Refused{world:W.World<S,Layout.columns(~S,layout),R,E>,reason:Reason}
def inspected(-S:Data,-P:Type,-V:Data,-key:String,-origin:Layout.Layout,result:Column.Column<S,Layout.Viewed<P,V>> & Part.Inspection) -> Layout.ColumnSlot<S,Layout.Viewed<P,V>,key,origin> & Bool:
  match result:
    case (column,Part.Inspection{_,capacity,valid}):(Layout.ColumnSlot{column},Bool.and(valid,U32.is_le(capacity,Column.maximum_capacity())))
def inspect_leaf(-S:Data,-P:Type,-V:Data,-key:String,-origin:Layout.Layout,slot:Layout.ColumnSlot<S,Layout.Viewed<P,V>,key,origin>) -> Layout.ColumnSlot<S,Layout.Viewed<P,V>,key,origin> & Bool:
  match slot:
    case Layout.ColumnSlot{column}:inspected(S,P,V,key,origin,Part.inspect(S,Layout.Viewed<P,V>,column))
def pair_right(-L:Type,-R:Type,left:L,valid:Bool,result:R & Bool) -> Product.Owner<L,R> & Bool:
  match result:
    case (right,other):(Product.Owner{left,right},Bool.and(valid,other))
def pair_left(-L:Type,-R:Type,right:R -> R & Bool,owner:R,result:L & Bool) -> Product.Owner<L,R> & Bool:
  match result:
    case (left,valid):pair_right(L,R,left,valid,right(owner))
def pair(-L:Type,-R:Type,left:L -> L & Bool,right:R -> R & Bool,owners:Product.Owner<L,R>) -> Product.Owner<L,R> & Bool:
  match owners:
    case Product.Owner{l,r}:pair_left(L,R,right,r,left(l))
def inspect(~S:Data,layout:Layout.Layout) -> Layout.columns(~S,layout) -> Layout.columns(~S,layout) & Bool:
  match layout:
    case Layout.EmptyLayout{}:owner => (owner,True{})
    case Layout.LayoutLeaf{P,V,refresh,key,access}:inspect_leaf(S,P,V,key,Layout.LayoutLeaf{P,V,refresh,key,access})
    case Layout.ClassifiedLayoutLeaf{P,V,refresh,key,policy,access}:inspect_leaf(S,P,V,key,Layout.ClassifiedLayoutLeaf{P,V,refresh,key,policy,access})
    case Layout.LayoutPair{left,right}:owner => pair(Layout.columns(~S,left),Layout.columns(~S,right),inspect(~S,left),inspect(~S,right),owner)
def handles(~S:Data,~layout:Layout.Layout,~R:Type,~E:Data,result:W.World<S,Layout.columns(~S,layout),R,E> & List<&2,W.Handle<S>>) -> Prepared<S,layout,R,E>:
  match result:
    case (world,handles):Ready{world,handles}
def capacity(~S:Data,~layout:Layout.Layout,~R:Type,~E:Data,world:W.World<S,Layout.columns(~S,layout),R,E>,valid:Bool) -> Prepared<S,layout,R,E>:
  match valid:
    case False{}:Refused{world,Capacity{}}
    case True{}:handles(~S,~layout,~R,~E,W.handles(~S,~Layout.columns(~S,layout),~R,~E,world))
def room(~S:Data,~layout:Layout.Layout,~R:Type,~E:Data,namespace:U32,store:Layout.columns(~S,layout),resource:R,events:List<&2,E>,pending:List<Deferred.Command<W.World<S,Layout.columns(~S,layout),R,E>>>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,clock:Clock.State,journal:Notice.Journal<S>,result:A.Allocator & Bool) -> Prepared<S,layout,R,E>:
  match result:
    case (allocator,valid):capacity(~S,~layout,~R,~E,W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock,journal},valid)
def columns(~S:Data,~layout:Layout.Layout,~R:Type,~E:Data,needed:Nat,namespace:U32,allocator:A.Allocator,resource:R,events:List<&2,E>,pending:List<Deferred.Command<W.World<S,Layout.columns(~S,layout),R,E>>>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,clock:Clock.State,journal:Notice.Journal<S>,result:Layout.columns(~S,layout) & Bool) -> Prepared<S,layout,R,E>:
  match result:
    case (store,False{}):Refused{W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock,journal},MalformedColumns{}}
    case (store,True{}):room(~S,~layout,~R,~E,namespace,store,resource,events,pending,registrations,nextSystemId,clock,journal,A.restore_room(allocator,1,needed))
def ready(~S:Data,~layout:Layout.Layout,~R:Type,~E:Data,needed:Nat,result:W.World<S,Layout.columns(~S,layout),R,E> & Bool) -> Prepared<S,layout,R,E>:
  match result:
    case (world,False{}):Refused{world,PendingWork{}}
    case (W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,Clock.State{tick,[]},journal},True{}):columns(~S,~layout,~R,~E,needed,namespace,allocator,resource,events,pending,registrations,nextSystemId,Clock.State{tick,[]},journal,inspect(~S,layout)(store))
    case (world,True{}):Refused{world,ActiveExecution{}}
# Ordinary Application adapters must first fold their real scheduled owner
# buffers. This additional World gate never flushes or discards its queue.
def prepare(~S:Data,~layout:Layout.Layout,~R:Type,~E:Data,needed:Nat,world:W.World<S,Layout.columns(~S,layout),R,E>) -> Prepared<S,layout,R,E>:
  ready(~S,~layout,~R,~E,needed,LegacyPending.ready(~S,~Layout.columns(~S,layout),~R,~E,world))
