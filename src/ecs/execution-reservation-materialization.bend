import Base
import ./execution-reservation-bundle.bend as Bundle
import ./execution-composer-layout.bend as Layout
import ./execution-command-permission.bend as Permission
import ./execution-query-identity.bend as Index
import ./execution-command-removed.bend as Removed
import ./owner-product.bend as Product
import ./chunk-column.bend as Column
import ./change-tick.bend as Tick
import ./world.bend as W
import ./lifecycle.bend as L
import ./chunk-partition.bend as Part
import ./execution-lifecycle-notices.bend as Notice
import ./clock-state.bend as Clock
import ./deferred-command.bend as Deferred
import ./entity-allocator.bend as A

type Remainder<-S:Data,-C:Type,-R:Type,-E:Data> is Type:
  Remainder{namespace:U32,resource:R,events:List<&2,E>,pending:List<Deferred.Command<W.World<S,C,R,E>>>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,clock:Clock.State,lifecycle:Notice.Journal<S>}

# Preflight inspects actual presence without a callback or schema refresher.
# No incoming payload is initialized until the full tree has been checked.
def reason(ok:Bool,key:String) -> Maybe<&2,Bundle.Refusal>:
  match ok:
    case True{}:None{}
    case False{}:Some{Bundle.OccupiedFamily{key}}
def first(left:Maybe<&2,Bundle.Refusal>,right:Maybe<&2,Bundle.Refusal>) -> Maybe<&2,Bundle.Refusal>:
  match left:
    case None{}:right
    case Some{error}:Some{error}
def leaf_checked(~S:Data,-P:Type,-V:Data,+key:String,-origin:Layout.Layout,bundle:Maybe<&1,P>,result:Column.Column<S,Layout.Viewed<P,V>> & Maybe<&2,Bool>) -> Layout.ColumnSlot<S,Layout.Viewed<P,V>,key,origin> & (Maybe<&1,P> & Maybe<&2,Bundle.Refusal>):
  match result:
    case (column,None{}):(Layout.ColumnSlot{column},(bundle,Some{Bundle.MalformedColumn{key}}))
    case (column,Some{vacant}):(Layout.ColumnSlot{column},(bundle,reason(vacant,key)))
def vacancy_within(~S:Data,-P:Type,-V:Data,+key:String,-origin:Layout.Layout,index:U32,bundle:Maybe<&1,P>,column:Column.Column<S,Layout.Viewed<P,V>>,within:Bool) -> Layout.ColumnSlot<S,Layout.Viewed<P,V>,key,origin> & (Maybe<&1,P> & Maybe<&2,Bundle.Refusal>):
  match within:
    case False{}:(Layout.ColumnSlot{column},(bundle,None{}))
    case True{}:leaf_checked(~S,P,V,key,origin,bundle,Column.vacancy_generic(S,Layout.Viewed<P,V>,column,index))
def shape_allowed(~S:Data,-P:Type,-V:Data,+key:String,-origin:Layout.Layout,+index:U32,capacity:U32,bundle:Maybe<&1,P>,column:Column.Column<S,Layout.Viewed<P,V>>,valid:Bool) -> Layout.ColumnSlot<S,Layout.Viewed<P,V>,key,origin> & (Maybe<&1,P> & Maybe<&2,Bundle.Refusal>):
  match valid:
    case False{}:(Layout.ColumnSlot{column},(bundle,Some{Bundle.MalformedColumn{key}}))
    case True{}:vacancy_within(~S,P,V,key,origin,index,bundle,column,U32.is_lt(index,capacity))
def shape_checked(~S:Data,-P:Type,-V:Data,+key:String,-origin:Layout.Layout,index:U32,bundle:Maybe<&1,P>,result:Column.Column<S,Layout.Viewed<P,V>> & Part.Inspection) -> Layout.ColumnSlot<S,Layout.Viewed<P,V>,key,origin> & (Maybe<&1,P> & Maybe<&2,Bundle.Refusal>):
  match result:
    case (column,Part.Inspection{_,+capacity,valid}):shape_allowed(~S,P,V,key,origin,index,capacity,bundle,column,Bool.and(valid,U32.is_le(capacity,Column.maximum_capacity())))
def check_leaf(~S:Data,-P:Type,-V:Data,+key:String,-origin:Layout.Layout,index:U32,slot:Layout.ColumnSlot<S,Layout.Viewed<P,V>,key,origin>,bundle:Maybe<&1,P>) -> Layout.ColumnSlot<S,Layout.Viewed<P,V>,key,origin> & (Maybe<&1,P> & Maybe<&2,Bundle.Refusal>):
  match slot bundle:
    case slot None{}:(slot,(None{},None{}))
    case Layout.ColumnSlot{column} Some{owner}:shape_checked(~S,P,V,key,origin,index,Some{owner},Part.inspect(S,Layout.Viewed<P,V>,column))
def check_right(~S:Data,-left:Layout.Layout,-right:Layout.Layout,leftOwner:Layout.columns(~S,left),leftBundle:Bundle.Payload(left),leftReason:Maybe<&2,Bundle.Refusal>,result:Layout.columns(~S,right) & (Bundle.Payload(right) & Maybe<&2,Bundle.Refusal>)) -> Layout.columns(~S,Layout.LayoutPair{left,right}) & (Bundle.Payload(Layout.LayoutPair{left,right}) & Maybe<&2,Bundle.Refusal>):
  match result:
    case (rightOwner,(rightBundle,rightReason)):(Product.Owner{leftOwner,rightOwner},(Product.Owner{leftBundle,rightBundle},first(leftReason,rightReason)))
def check_left(~S:Data,-left:Layout.Layout,-right:Layout.Layout,checkRight:U32 -> Layout.columns(~S,right) -> Bundle.Payload(right) -> Layout.columns(~S,right) & (Bundle.Payload(right) & Maybe<&2,Bundle.Refusal>),index:U32,rightOwner:Layout.columns(~S,right),rightBundle:Bundle.Payload(right),result:Layout.columns(~S,left) & (Bundle.Payload(left) & Maybe<&2,Bundle.Refusal>)) -> Layout.columns(~S,Layout.LayoutPair{left,right}) & (Bundle.Payload(Layout.LayoutPair{left,right}) & Maybe<&2,Bundle.Refusal>):
  match result:
    case (leftOwner,(leftBundle,leftReason)):check_right(~S,left,right,leftOwner,leftBundle,leftReason,checkRight(index,rightOwner,rightBundle))
def check_pair(~S:Data,-left:Layout.Layout,-right:Layout.Layout,checkLeft:U32 -> Layout.columns(~S,left) -> Bundle.Payload(left) -> Layout.columns(~S,left) & (Bundle.Payload(left) & Maybe<&2,Bundle.Refusal>),checkRight:U32 -> Layout.columns(~S,right) -> Bundle.Payload(right) -> Layout.columns(~S,right) & (Bundle.Payload(right) & Maybe<&2,Bundle.Refusal>),+index:U32,store:Layout.columns(~S,Layout.LayoutPair{left,right}),bundle:Bundle.Payload(Layout.LayoutPair{left,right})) -> Layout.columns(~S,Layout.LayoutPair{left,right}) & (Bundle.Payload(Layout.LayoutPair{left,right}) & Maybe<&2,Bundle.Refusal>):
  match store bundle:
    case Product.Owner{lo,ro} Product.Owner{lb,rb}:check_left(~S,left,right,checkRight,index,ro,rb,checkLeft(index,lo,lb))
def check(~S:Data,layout:Layout.Layout) -> U32 -> Layout.columns(~S,layout) -> Bundle.Payload(layout) -> Layout.columns(~S,layout) & (Bundle.Payload(layout) & Maybe<&2,Bundle.Refusal>):
  match layout:
    case Layout.EmptyLayout{}:index => store => bundle => (store,(bundle,None{}))
    case Layout.LayoutLeaf{P,V,refresh,key}:check_leaf(~S,P,V,key,Layout.LayoutLeaf{P,V,refresh,key})
    case Layout.ClassifiedLayoutLeaf{P,V,refresh,key,policy}:check_leaf(~S,P,V,key,Layout.ClassifiedLayoutLeaf{P,V,refresh,key,policy})
    case Layout.LayoutPair{left,right}:index => store => bundle => check_pair(~S,left,right,check(~S,left),check(~S,right),index,store,bundle)

# Internal storage primitive, called only after whole-tree preflight and ensure.
# Like canonical Column.swap_leaf, it preserves the displaced affine owner and
# updates both lifecycle stamps using the captured publication tick.
def written_stamp(~S:Data,-P:Type,values:Array<Maybe<&1,P>>,previous:Maybe<&1,P>,+index:U32,tick:Tick.Tick,wasPresent:Bool,result:Array<L.Stamp> & L.Stamp) -> Column.Column<S,P> & Maybe<&1,P>:
  match result:
    case (stamps,stamp):(Column.Leaf{values,Array.set(L.Stamp,stamps,index,L.after_write(True{},wasPresent,stamp,tick))},previous)
def written_value(~S:Data,-P:Type,stamps:Array<L.Stamp>,+index:U32,tick:Tick.Tick,result:Array<Maybe<&1,P>> & Maybe<&1,P>) -> Column.Column<S,P> & Maybe<&1,P>:
  match result:
    case (values,None{}):written_stamp(~S,P,values,None{},index,tick,False{},Array.get(L.Stamp,stamps,index))
    case (values,Some{previous}):written_stamp(~S,P,values,Some{previous},index,tick,True{},Array.get(L.Stamp,stamps,index))
def replace_left(~S:Data,-P:Type,half:U32,right:Column.Column<S,P>,result:Column.Column<S,P> & Maybe<&1,P>) -> Column.Column<S,P> & Maybe<&1,P>:
  match result:
    case (left,previous):(Column.Branch{half,left,right},previous)
def replace_right(~S:Data,-P:Type,half:U32,left:Column.Column<S,P>,result:Column.Column<S,P> & Maybe<&1,P>) -> Column.Column<S,P> & Maybe<&1,P>:
  match result:
    case (right,previous):(Column.Branch{half,left,right},previous)
def branch_results(~S:Data,-P:Type,half:U32,resultLeft:Column.Column<S,P> & Maybe<&1,P>,resultRight:Column.Column<S,P> & Maybe<&1,P>,first:Bool) -> Column.Column<S,P> & Maybe<&1,P>:
  match resultLeft resultRight first:
    case (left,previous), (right,_), True{}:(Column.Branch{half,left,right},previous)
    case (left,_), (right,previous), False{}:(Column.Branch{half,left,right},previous)
def write_branch(~S:Data,-P:Type,writeLeft:Maybe<&1,P> -> Column.Column<S,P> & Maybe<&1,P>,writeRight:Maybe<&1,P> -> Column.Column<S,P> & Maybe<&1,P>,half:U32,incoming:P,first:Bool) -> Column.Column<S,P> & Maybe<&1,P>:
  match first:
    case True{}:branch_results(~S,P,half,writeLeft(Some{incoming}),writeRight(None{}),True{})
    case False{}:branch_results(~S,P,half,writeLeft(None{}),writeRight(Some{incoming}),False{})
def write_column(~S:Data,-P:Type,column:Column.Column<S,P>,+index:U32,+tick:Tick.Tick,incoming:Maybe<&1,P>) -> Column.Column<S,P> & Maybe<&1,P>:
  match column incoming:
    case column None{}:(column,None{})
    case Column.Leaf{values,stamps} Some{incoming}:written_value(~S,P,stamps,index,tick,Array.swap(Maybe<&1,P>,values,index,Some{incoming}))
    case Column.Branch{+half,left,right} Some{incoming}:write_branch(~S,P,write_column(~S,P,left,index,tick),write_column(~S,P,right,U32.sub(index,half),tick),half,incoming,U32.is_lt(index,half))
def installed_leaf(~S:Data,-P:Type,-V:Data,-key:String,-origin:Layout.Layout,result:Column.Column<S,Layout.Viewed<P,V>> & Maybe<&1,Layout.Viewed<P,V>>) -> Layout.ColumnSlot<S,Layout.Viewed<P,V>,key,origin> & Maybe<&1,P>:
  match result:
    case (column,previous):(Layout.ColumnSlot{column},Removed.raw(P,V,previous))
def install_leaf(~S:Data,-P:Type,-V:Data,refresh:P -> P & V,-key:String,-origin:Layout.Layout,+index:U32,tick:Tick.Tick,slot:Layout.ColumnSlot<S,Layout.Viewed<P,V>,key,origin>,bundle:Maybe<&1,P>) -> Layout.ColumnSlot<S,Layout.Viewed<P,V>,key,origin> & Maybe<&1,P>:
  match slot bundle:
    case slot None{}:(slot,None{})
    case Layout.ColumnSlot{column} Some{incoming}:installed_leaf(~S,P,V,key,origin,write_column(~S,Layout.Viewed<P,V>,Column.ensure_generic(S,Layout.Viewed<P,V>,column,U32.add(index,1)),index,tick,Some{Layout.initialized(P,V,refresh(incoming))}))
def installed_right(~S:Data,-left:Layout.Layout,-right:Layout.Layout,leftOwner:Layout.columns(~S,left),leftPrevious:Bundle.Payload(left),result:Layout.columns(~S,right) & Bundle.Payload(right)) -> Layout.columns(~S,Layout.LayoutPair{left,right}) & Bundle.Payload(Layout.LayoutPair{left,right}):
  match result:
    case (rightOwner,rightPrevious):(Product.Owner{leftOwner,rightOwner},Product.Owner{leftPrevious,rightPrevious})
def installed_left(~S:Data,-left:Layout.Layout,-right:Layout.Layout,installRight:U32 -> Tick.Tick -> Layout.columns(~S,right) -> Bundle.Payload(right) -> Layout.columns(~S,right) & Bundle.Payload(right),index:U32,tick:Tick.Tick,rightOwner:Layout.columns(~S,right),rightBundle:Bundle.Payload(right),result:Layout.columns(~S,left) & Bundle.Payload(left)) -> Layout.columns(~S,Layout.LayoutPair{left,right}) & Bundle.Payload(Layout.LayoutPair{left,right}):
  match result:
    case (leftOwner,leftPrevious):installed_right(~S,left,right,leftOwner,leftPrevious,installRight(index,tick,rightOwner,rightBundle))
def install_pair(~S:Data,-left:Layout.Layout,-right:Layout.Layout,installLeft:U32 -> Tick.Tick -> Layout.columns(~S,left) -> Bundle.Payload(left) -> Layout.columns(~S,left) & Bundle.Payload(left),installRight:U32 -> Tick.Tick -> Layout.columns(~S,right) -> Bundle.Payload(right) -> Layout.columns(~S,right) & Bundle.Payload(right),+index:U32,+tick:Tick.Tick,store:Layout.columns(~S,Layout.LayoutPair{left,right}),bundle:Bundle.Payload(Layout.LayoutPair{left,right})) -> Layout.columns(~S,Layout.LayoutPair{left,right}) & Bundle.Payload(Layout.LayoutPair{left,right}):
  match store bundle:
    case Product.Owner{lo,ro} Product.Owner{lb,rb}:installed_left(~S,left,right,installRight,index,tick,ro,rb,installLeft(index,tick,lo,lb))
def install(~S:Data,layout:Layout.Layout) -> U32 -> Tick.Tick -> Layout.columns(~S,layout) -> Bundle.Payload(layout) -> Layout.columns(~S,layout) & Bundle.Payload(layout):
  match layout:
    case Layout.EmptyLayout{}:index => tick => store => bundle => (store,Unit{})
    case Layout.LayoutLeaf{P,V,refresh,key}:index => tick => slot => bundle => install_leaf(~S,P,V,refresh,key,Layout.LayoutLeaf{P,V,refresh,key},index,tick,slot,bundle)
    case Layout.ClassifiedLayoutLeaf{P,V,refresh,key,policy}:index => tick => slot => bundle => install_leaf(~S,P,V,refresh,key,Layout.ClassifiedLayoutLeaf{P,V,refresh,key,policy},index,tick,slot,bundle)
    case Layout.LayoutPair{left,right}:index => tick => store => bundle => install_pair(~S,left,right,install(~S,left),install(~S,right),index,tick,store,bundle)

def assembled(~S:Data,~R:Type,~E:Data,~layout:Layout.Layout,allocator:A.Allocator,rest:Remainder<S,Layout.columns(~S,layout),R,E>,store:Layout.columns(~S,layout)) -> W.World<S,Layout.columns(~S,layout),R,E>:
  match rest:
    case Remainder{namespace,resource,events,pending,registrations,nextSystemId,clock,lifecycle}:W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock,lifecycle}
def installed(~S:Data,~R:Type,~E:Data,~layout:Layout.Layout,allocator:A.Allocator,rest:Remainder<S,Layout.columns(~S,layout),R,E>,+handle:W.Handle<S>,result:Layout.columns(~S,layout) & Bundle.Payload(layout)) -> Bundle.Publication<S,Layout.columns(~S,layout),R,E,layout>:
  match result:
    case (store,previous):Bundle.Materialized{assembled(~S,~R,~E,~layout,A.write_phase(allocator,W.handle_key(~S,handle),A.Live{}),rest,store),handle,previous}
def checked_store(~S:Data,~R:Type,~E:Data,~layout:Layout.Layout,installTree:U32 -> Tick.Tick -> Layout.columns(~S,layout) -> Bundle.Payload(layout) -> Layout.columns(~S,layout) & Bundle.Payload(layout),allocator:A.Allocator,rest:Remainder<S,Layout.columns(~S,layout),R,E>,handle:W.Handle<S>,index:U32,tick:Tick.Tick,result:Layout.columns(~S,layout) & (Bundle.Payload(layout) & Maybe<&2,Bundle.Refusal>)) -> Bundle.Publication<S,Layout.columns(~S,layout),R,E,layout>:
  match result:
    case (store,(bundle,Some{reason})):Bundle.RefusedPublication{assembled(~S,~R,~E,~layout,allocator,rest,store),handle,bundle,reason}
    case (store,(bundle,None{})):installed(~S,~R,~E,~layout,allocator,rest,handle,installTree(index,tick,store,bundle))
def preflight(~S:Data,~R:Type,~E:Data,~layout:Layout.Layout,world:W.World<S,Layout.columns(~S,layout),R,E>,handle:W.Handle<S>,bundle:Bundle.Payload(layout),+index:U32,tick:Tick.Tick) -> Bundle.Publication<S,Layout.columns(~S,layout),R,E,layout>:
  match world:
    case W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock,lifecycle}:checked_store(~S,~R,~E,~layout,install(~S,layout),allocator,Remainder{namespace,resource,events,pending,registrations,nextSystemId,clock,lifecycle},handle,index,tick,check(~S,layout,index,store,bundle))
def physical(~S:Data,~R:Type,~E:Data,~layout:Layout.Layout,world:W.World<S,Layout.columns(~S,layout),R,E>,handle:W.Handle<S>,bundle:Bundle.Payload(layout),tick:Tick.Tick,offset:Maybe<&2,U32>) -> Bundle.Publication<S,Layout.columns(~S,layout),R,E,layout>:
  match offset:
    case None{}:Bundle.RefusedPublication{world,handle,bundle,Bundle.PhysicalIndex{}}
    case Some{index}:preflight(~S,~R,~E,layout,world,handle,bundle,index,tick)
def unique(~S:Data,~R:Type,~E:Data,~layout:Layout.Layout,world:W.World<S,Layout.columns(~S,layout),R,E>,+handle:W.Handle<S>,bundle:Bundle.Payload(layout),tick:Tick.Tick,valid:Bool) -> Bundle.Publication<S,Layout.columns(~S,layout),R,E,layout>:
  match valid:
    case False{}:Bundle.RefusedPublication{world,handle,bundle,Bundle.DuplicateFamily{}}
    case True{}:physical(~S,~R,~E,layout,world,handle,bundle,tick,Index.physical_index(W.handle_index(~S,handle)))
def permitted(~S:Data,~R:Type,~E:Data,~layout:Layout.Layout,world:W.World<S,Layout.columns(~S,layout),R,E>,handle:W.Handle<S>,bundle:Bundle.Payload(layout),tick:Tick.Tick,permission:Permission.Permission) -> Bundle.Publication<S,Layout.columns(~S,layout),R,E,layout>:
  match permission:
    case Permission.FamilyOnly{}:Bundle.RefusedPublication{world,handle,bundle,Bundle.PermissionDenied{}}
    case Permission.EntityStructural{}:unique(~S,~R,~E,layout,world,handle,bundle,tick,Layout.unique(layout))
def pending_checked(~S:Data,~R:Type,~E:Data,~layout:Layout.Layout,permission:Permission.Permission,handle:W.Handle<S>,bundle:Bundle.Payload(layout),tick:Tick.Tick,result:W.World<S,Layout.columns(~S,layout),R,E> & Bool) -> Bundle.Publication<S,Layout.columns(~S,layout),R,E,layout>:
  match result:
    case (world,False{}):Bundle.RefusedPublication{world,handle,bundle,Bundle.InvalidPending{W.MissingEntity{}}}
    case (world,True{}):permitted(~S,~R,~E,layout,world,handle,bundle,tick,permission)
# Existing command publication calls this only at its barrier, with captured tick.
# Pending namespace/generation/phase validation precedes even bundle preflight.
def apply_at(~S:Data,~R:Type,~E:Data,~layout:Layout.Layout,permission:Permission.Permission,world:W.World<S,Layout.columns(~S,layout),R,E>,+handle:W.Handle<S>,bundle:Bundle.Payload(layout),tick:Tick.Tick) -> Bundle.Publication<S,Layout.columns(~S,layout),R,E,layout>:
  pending_checked(~S,~R,~E,layout,permission,handle,bundle,tick,W.pending_valid(~S,~(Layout.columns(~S,layout)),~R,~E,world,handle))
