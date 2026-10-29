import Base
import ./chunk-column.bend as Column
import ./execution-composer-layout.bend as L
import ./execution-query-store.bend as Store
import ./execution-query-schema.bend as Schema
import ./execution-query-matches.bend as Match
import ./execution-query-recipe.bend as Recipe
import ./execution-query-admission.bend as Admission
import ./owner-product.bend as Product
import ./lifecycle.bend as Life
import ./change-tick.bend as Tick

def sparse_left(~S:Data,-left:L.Layout,-right:L.Layout,other:Store.stores(~S,right),result:Store.stores(~S,left) & Life.Stamp) -> Store.stores(~S,L.LayoutPair{left,right}) & Life.Stamp:
  match result:
    case (owner,stamp):(Product.Owner{owner,other},stamp)
def sparse_right(~S:Data,-left:L.Layout,-right:L.Layout,other:Store.stores(~S,left),result:Store.stores(~S,right) & Life.Stamp) -> Store.stores(~S,L.LayoutPair{left,right}) & Life.Stamp:
  match result:
    case (owner,stamp):(Product.Owner{other,owner},stamp)
def sparse_stamp(~S:Data,layout:L.Layout,route:L.Route,owner:Store.stores(~S,layout),index:U32) -> Store.stores(~S,layout) & Life.Stamp:
  match layout route owner:
    case L.LayoutLeaf{P,V,refresh,key,policy} L.AtLeaf{} slot:Store.stamp_slot(S,P,V,L.LayoutLeaf{P,V,refresh,key,policy},slot,index)
    case L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,policy} L.AtLeaf{} slot:Store.stamp_slot(S,P,V,L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,policy},slot,index)
    case L.LayoutPair{left,right} L.InLeft{path} Product.Owner{l,r}:sparse_left(~S,left,right,r,sparse_stamp(~S,left,path,l,index))
    case L.LayoutPair{left,right} L.InRight{path} Product.Owner{l,r}:sparse_right(~S,left,right,l,sparse_stamp(~S,right,path,r,index))
    case _ _ owner:(owner,Life.Stamp{None{},None{}})
def sparse_changed(~S:Data,~layout:L.Layout,prior:Maybe<&2,Tick.Tick>,tick:Tick.Tick,result:Store.stores(~S,layout) & Life.Stamp) -> Store.stores(~S,layout) & Bool:
  match result:
    case (owner,stamp):(owner,Life.changed(stamp,prior,tick))
def sparse_combine(~S:Data,~layout:L.Layout,left:Bool,and:Bool,result:Store.stores(~S,layout) & Bool) -> Store.stores(~S,layout) & Bool:
  match and result:
    case True{}, (owner,right):(owner,Bool.and(left,right))
    case False{}, (owner,right):(owner,Bool.or(left,right))
def sparse_rest(~S:Data,~layout:L.Layout,and:Bool,next:Store.stores(~S,layout) -> Store.stores(~S,layout) & Bool,result:Store.stores(~S,layout) & Bool) -> Store.stores(~S,layout) & Bool:
  match result:
    case (owner,left):sparse_combine(~S,~layout,left,and,next(owner))
def sparse_bound(~S:Data,~layout:L.Layout,+info:List<&2,Schema.Info>,selection:Recipe.Bound,+index:U32,+prior:Maybe<&2,Tick.Tick>,+tick:Tick.Tick,owner:Store.stores(~S,layout)) -> Store.stores(~S,layout) & Bool:
  match selection:
    case Recipe.Changed{route}:sparse_changed(~S,~layout,prior,tick,sparse_stamp(~S,layout,route,owner,index))
    case Recipe.And{left,right}:sparse_rest(~S,~layout,True{},(owner => sparse_bound(~S,~layout,info,right,index,prior,tick,owner)),sparse_bound(~S,~layout,info,left,index,prior,tick,owner))
    case Recipe.Or{left,right}:sparse_rest(~S,~layout,False{},(owner => sparse_bound(~S,~layout,info,right,index,prior,tick,owner)),sparse_bound(~S,~layout,info,left,index,prior,tick,owner))
    case selection:(owner,Admission.bound(info,selection,index))
def whole_left(~S:Data,-left:L.Layout,-right:L.Layout,other:L.columns(~S,right),result:L.columns(~S,left) & Life.Stamp) -> L.columns(~S,L.LayoutPair{left,right}) & Life.Stamp:
  match result:
    case (owner,stamp):(Product.Owner{owner,other},stamp)
def whole_right(~S:Data,-left:L.Layout,-right:L.Layout,other:L.columns(~S,left),result:L.columns(~S,right) & Life.Stamp) -> L.columns(~S,L.LayoutPair{left,right}) & Life.Stamp:
  match result:
    case (owner,stamp):(Product.Owner{other,owner},stamp)
def whole_cached(-S:Data,-P:Type,-V:Data,-key:String,-origin:L.Layout,index:U32,result:Column.Column<S,L.Viewed<P,V>> & List<&2,Match.Row<V>>) -> L.ColumnSlot<S,L.Viewed<P,V>,key,origin> & Life.Stamp:
  match result:
    case (column,rows):(L.ColumnSlot{column},Store.cached_stamp(V,rows,index))
def whole_stamp(~S:Data,layout:L.Layout,route:L.Route,owner:L.columns(~S,layout),index:U32) -> L.columns(~S,layout) & Life.Stamp:
  match layout route owner:
    case L.LayoutLeaf{P,V,refresh,key,policy} L.AtLeaf{} L.ColumnSlot{column}:whole_cached(S,P,V,key,L.LayoutLeaf{P,V,refresh,key,policy},index,Schema.cache_column(S,P,V,column,0))
    case L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,policy} L.AtLeaf{} L.ColumnSlot{column}:whole_cached(S,P,V,key,L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,policy},index,Schema.cache_column(S,P,V,column,0))
    case L.LayoutPair{left,right} L.InLeft{path} Product.Owner{l,r}:whole_left(~S,left,right,r,whole_stamp(~S,left,path,l,index))
    case L.LayoutPair{left,right} L.InRight{path} Product.Owner{l,r}:whole_right(~S,left,right,l,whole_stamp(~S,right,path,r,index))
    case _ _ owner:(owner,Life.Stamp{None{},None{}})
def whole_changed(~S:Data,~layout:L.Layout,prior:Maybe<&2,Tick.Tick>,tick:Tick.Tick,result:L.columns(~S,layout) & Life.Stamp) -> L.columns(~S,layout) & Bool:
  match result:
    case (owner,stamp):(owner,Life.changed(stamp,prior,tick))
def whole_combine(~S:Data,~layout:L.Layout,left:Bool,and:Bool,result:L.columns(~S,layout) & Bool) -> L.columns(~S,layout) & Bool:
  match and result:
    case True{}, (owner,right):(owner,Bool.and(left,right))
    case False{}, (owner,right):(owner,Bool.or(left,right))
def whole_rest(~S:Data,~layout:L.Layout,and:Bool,next:L.columns(~S,layout) -> L.columns(~S,layout) & Bool,result:L.columns(~S,layout) & Bool) -> L.columns(~S,layout) & Bool:
  match result:
    case (owner,left):whole_combine(~S,~layout,left,and,next(owner))
def whole_bound(~S:Data,~layout:L.Layout,+info:List<&2,Schema.Info>,selection:Recipe.Bound,+index:U32,+prior:Maybe<&2,Tick.Tick>,+tick:Tick.Tick,owner:L.columns(~S,layout)) -> L.columns(~S,layout) & Bool:
  match selection:
    case Recipe.Changed{route}:whole_changed(~S,~layout,prior,tick,whole_stamp(~S,layout,route,owner,index))
    case Recipe.And{left,right}:whole_rest(~S,~layout,True{},(owner => whole_bound(~S,~layout,info,right,index,prior,tick,owner)),whole_bound(~S,~layout,info,left,index,prior,tick,owner))
    case Recipe.Or{left,right}:whole_rest(~S,~layout,False{},(owner => whole_bound(~S,~layout,info,right,index,prior,tick,owner)),whole_bound(~S,~layout,info,left,index,prior,tick,owner))
    case selection:(owner,Admission.bound(info,selection,index))
