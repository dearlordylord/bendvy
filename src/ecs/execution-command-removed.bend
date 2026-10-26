import Base
import ./execution-lifecycle-notices.bend as Notice
import ./change-tick.bend as Tick
import ./execution-composer-layout.bend as Layout
import ./chunk-column.bend as Column
import ./owner-product.bend as Product

# Structural receipts retain each actual raw owner, including unlike affine
# families. Removing a cached row never invokes its refresher.
def Removed(layout:Layout.Layout) -> Type:
  match layout:
    case Layout.EmptyLayout{}:Unit
    case Layout.LayoutLeaf{P,_,_,_}:Maybe<&1,P>
    case Layout.ClassifiedLayoutLeaf{P,_,_,_,_}:Maybe<&1,P>
    case Layout.LayoutPair{left,right}:Product.Owner<Removed(left),Removed(right)>
def raw(-P:Type,-V:Data,value:Maybe<&1,Layout.Viewed<P,V>>) -> Maybe<&1,P>:
  match value:
    case None{}:None{}
    case Some{Layout.Viewed{owner,_}}:Some{owner}
def leaf_done(~S:Data,-P:Type,-V:Data,-key:String,-origin:Layout.Layout,result:Column.Column<S,Layout.Viewed<P,V>> & Maybe<&1,Layout.Viewed<P,V>>) -> Layout.ColumnSlot<S,Layout.Viewed<P,V>,key,origin> & Maybe<&1,P>:
  match result:
    case (column,previous):(Layout.ColumnSlot{column},raw(P,V,previous))
def leaf(~S:Data,-P:Type,-V:Data,-key:String,-origin:Layout.Layout,index:U32,slot:Layout.ColumnSlot<S,Layout.Viewed<P,V>,key,origin>) -> Layout.ColumnSlot<S,Layout.Viewed<P,V>,key,origin> & Maybe<&1,P>:
  match slot:
    case Layout.ColumnSlot{column}:leaf_done(~S,P,V,key,origin,Column.take(S,Layout.Viewed<P,V>,column,index))
def joined(~S:Data,-left:Layout.Layout,-right:Layout.Layout,leftOwner:Layout.columns(~S,left),removed:Removed(left),result:Layout.columns(~S,right) & Removed(right)) -> Product.Owner<Layout.columns(~S,left),Layout.columns(~S,right)> & Product.Owner<Removed(left),Removed(right)>:
  match result:
    case (rightOwner,rightRemoved):(Product.Owner{leftOwner,rightOwner},Product.Owner{removed,rightRemoved})
def took_left(~S:Data,-left:Layout.Layout,-right:Layout.Layout,takeRight:U32 -> Layout.columns(~S,right) -> Layout.columns(~S,right) & Removed(right),index:U32,rightOwner:Layout.columns(~S,right),result:Layout.columns(~S,left) & Removed(left)) -> Product.Owner<Layout.columns(~S,left),Layout.columns(~S,right)> & Product.Owner<Removed(left),Removed(right)>:
  match result:
    case (leftOwner,removed):joined(~S,left,right,leftOwner,removed,takeRight(index,rightOwner))
def pair(~S:Data,-left:Layout.Layout,-right:Layout.Layout,takeLeft:U32 -> Layout.columns(~S,left) -> Layout.columns(~S,left) & Removed(left),takeRight:U32 -> Layout.columns(~S,right) -> Layout.columns(~S,right) & Removed(right),+index:U32,owner:Product.Owner<Layout.columns(~S,left),Layout.columns(~S,right)>) -> Product.Owner<Layout.columns(~S,left),Layout.columns(~S,right)> & Product.Owner<Removed(left),Removed(right)>:
  match owner:
    case Product.Owner{leftOwner,rightOwner}:took_left(~S,left,right,takeRight,index,rightOwner,takeLeft(index,leftOwner))
def take(~S:Data,layout:Layout.Layout) -> U32 -> Layout.columns(~S,layout) -> Layout.columns(~S,layout) & Removed(layout):
  match layout:
    case Layout.EmptyLayout{}:index => owner => (owner,Unit{})
    case Layout.LayoutLeaf{P,V,refresh,key}:leaf(~S,P,V,key,Layout.LayoutLeaf{P,V,refresh,key})
    case Layout.ClassifiedLayoutLeaf{P,V,refresh,key,policy}:leaf(~S,P,V,key,Layout.ClassifiedLayoutLeaf{P,V,refresh,key,policy})
    case Layout.LayoutPair{left,right}:index => owner => pair(~S,left,right,take(~S,left),take(~S,right),index,owner)

# Inspect actual displaced owners once and return those same owners. No cached
# view or presence metadata can manufacture a removal notice or refresh payloads.
def noticed_leaf(~S:Data,-P:Type,key:String,entity:Notice.Identity<S>,tick:Tick.Tick,journal:Notice.Journal<S>,removed:Maybe<&1,P>) -> Notice.Journal<S> & Maybe<&1,P>:
  match removed:
    case None{}:(journal,None{})
    case Some{owner}:(Notice.append(~S,Notice.Removed{key},entity,tick,journal),Some{owner})
def noticed_right(~S:Data,-left:Layout.Layout,-right:Layout.Layout,leftOwner:Removed(left),result:Notice.Journal<S> & Removed(right)) -> Notice.Journal<S> & Removed(Layout.LayoutPair{left,right}):
  match result:
    case (journal,rightOwner):(journal,Product.Owner{leftOwner,rightOwner})
def noticed_left(~S:Data,-left:Layout.Layout,-right:Layout.Layout,noticeRight:Notice.Identity<S> -> Tick.Tick -> Notice.Journal<S> -> Removed(right) -> Notice.Journal<S> & Removed(right),entity:Notice.Identity<S>,tick:Tick.Tick,rightOwner:Removed(right),result:Notice.Journal<S> & Removed(left)) -> Notice.Journal<S> & Removed(Layout.LayoutPair{left,right}):
  match result:
    case (journal,leftOwner):noticed_right(~S,left,right,leftOwner,noticeRight(entity,tick,journal,rightOwner))
def noticed_pair(~S:Data,-left:Layout.Layout,-right:Layout.Layout,noticeLeft:Notice.Identity<S> -> Tick.Tick -> Notice.Journal<S> -> Removed(left) -> Notice.Journal<S> & Removed(left),noticeRight:Notice.Identity<S> -> Tick.Tick -> Notice.Journal<S> -> Removed(right) -> Notice.Journal<S> & Removed(right),+entity:Notice.Identity<S>,+tick:Tick.Tick,journal:Notice.Journal<S>,removed:Removed(Layout.LayoutPair{left,right})) -> Notice.Journal<S> & Removed(Layout.LayoutPair{left,right}):
  match removed:
    case Product.Owner{leftOwner,rightOwner}:noticed_left(~S,left,right,noticeRight,entity,tick,rightOwner,noticeLeft(entity,tick,journal,leftOwner))
def notices(~S:Data,layout:Layout.Layout) -> Notice.Identity<S> -> Tick.Tick -> Notice.Journal<S> -> Removed(layout) -> Notice.Journal<S> & Removed(layout):
  match layout:
    case Layout.EmptyLayout{}:entity => tick => journal => removed => (journal,removed)
    case Layout.LayoutLeaf{P,_,_,key}:noticed_leaf(~S,P,key)
    case Layout.ClassifiedLayoutLeaf{P,_,_,key,_}:noticed_leaf(~S,P,key)
    case Layout.LayoutPair{left,right}:entity => tick => journal => removed => noticed_pair(~S,left,right,notices(~S,left),notices(~S,right),entity,tick,journal,removed)
