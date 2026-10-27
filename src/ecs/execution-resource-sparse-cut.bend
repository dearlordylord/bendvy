import Base
import ./execution-composer-layout.bend as L
import ./execution-resource-policy.bend as Policy
import ./schema-fragments.bend as Fragment
import ./execution-resource-store.bend as Store
import ./execution-resource-recipe.bend as Recipe
import ./execution-resource-partition.bend as Partition
import ./execution-query-schema.bend as Schema
import ./owner-product.bend as Product
import ./lifecycle.bend as Life

# Only Data cache/stamps are shared. The optional affine owner moves to exactly
# one admitted writer; canonical complements remain in the enclosing join.
type Memo<-V:Data> is Data:
  Memo{left:Recipe.Permission,right:Recipe.Permission,cache:Maybe<&2,V>,stamp:Life.Stamp}
def memos(layout:L.Layout) -> Type:
  match layout:
    case L.EmptyLayout{}:Unit
    case L.LayoutLeaf{P,V,refresh,key,policy}:Memo<V>
    case L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,policy}:Memo<V>
    case L.LayoutPair{left,right}:Product.Owner<memos(left),memos(right)>
def inspected_slot(-S:Data,-P:Type,-V:Data,-origin:L.Layout,compatible:Bool,result:Store.Slot<S,P,V,origin> & Bool) -> Store.Slot<S,P,V,origin> & Bool:
  match result:
    case (slot,valid):(slot,Bool.and(compatible,valid))
def inspect_slot(-S:Data,-P:Type,-V:Data,-origin:L.Layout,+left:Recipe.Permission,+right:Recipe.Permission,slot:Store.Slot<S,P,V,origin>) -> Store.Slot<S,P,V,origin> & Bool:
  inspected_slot(S,P,V,origin,Bool.not(Recipe.conflict(left,right)),Partition.check_slot(S,P,V,origin,Recipe.combine(left,right),slot))
def inspect_rest_slot(-S:Data,-P:Type,-V:Data,-origin:L.Layout,+left:Recipe.Permission,+right:Recipe.Permission,slot:Store.Slot<S,P,V,origin>) -> Store.Slot<S,P,V,origin> & Bool:
  inspected_slot(S,P,V,origin,Bool.not(Bool.and(Recipe.writes(left),Recipe.writes(right))),Partition.check_slot(S,P,V,origin,Recipe.combine(left,right),slot))
def inspected_pair(-Left:Type,-Right:Type,left:Left & Bool,right:Right & Bool) -> Product.Owner<Left,Right> & Bool:
  match left right:
    case (left,lv), (right,rv):(Product.Owner{left,right},Bool.and(lv,rv))
def inspect(~S:Data,layout:L.Layout,+route:L.Route,+left:List<&2,Recipe.Entry>,+right:List<&2,Recipe.Entry>,owner:Store.slots(~S,layout)) -> Store.slots(~S,layout) & Bool:
  match layout owner:
    case L.EmptyLayout{} Unit{}:(Unit{},True{})
    case L.LayoutLeaf{P,V,refresh,key,policy} slot:inspect_slot(S,P,V,L.LayoutLeaf{P,V,refresh,key,policy},Recipe.at(route,left),Recipe.at(route,right),slot)
    case L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,policy} slot:inspect_slot(S,P,V,L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,policy},Recipe.at(route,left),Recipe.at(route,right),slot)
    case L.LayoutPair{ll,rr} Product.Owner{l,r}:inspected_pair(Store.slots(~S,ll),Store.slots(~S,rr),inspect(~S,ll,Schema.append_route(route,L.InLeft{L.AtLeaf{}}),left,right,l),inspect(~S,rr,Schema.append_route(route,L.InRight{L.AtLeaf{}}),left,right,r))
def inspect_rest(~S:Data,layout:L.Layout,+route:L.Route,+left:List<&2,Recipe.Entry>,+right:List<&2,Recipe.Entry>,owner:Store.slots(~S,layout)) -> Store.slots(~S,layout) & Bool:
  match layout owner:
    case L.EmptyLayout{} Unit{}:(Unit{},True{})
    case L.LayoutLeaf{P,V,refresh,key,policy} slot:inspect_rest_slot(S,P,V,L.LayoutLeaf{P,V,refresh,key,policy},Recipe.at(route,left),Recipe.at(route,right),slot)
    case L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,policy} slot:inspect_rest_slot(S,P,V,L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,policy},Recipe.at(route,left),Recipe.at(route,right),slot)
    case L.LayoutPair{ll,rr} Product.Owner{l,r}:inspected_pair(Store.slots(~S,ll),Store.slots(~S,rr),inspect_rest(~S,ll,Schema.append_route(route,L.InLeft{L.AtLeaf{}}),left,right,l),inspect_rest(~S,rr,Schema.append_route(route,L.InRight{L.AtLeaf{}}),left,right,r))
def cache_for(-V:Data,permission:Recipe.Permission,cache:Maybe<&2,V>) -> Maybe<&2,V>:
  match permission:
    case Recipe.Unused{}:None{}
    case _:cache
def divide_slot(-S:Data,-P:Type,-V:Data,-origin:L.Layout,+left:Recipe.Permission,+right:Recipe.Permission,slot:Store.Slot<S,P,V,origin>) -> Store.Slot<S,P,V,origin> & (Store.Slot<S,P,V,origin> & Memo<V>):
  match left right slot:
    case Recipe.Writable{} Recipe.Unused{} Store.Slot{owner,+cache,+stamp,_}:(Store.Slot{owner,cache,stamp,left},(Store.Slot{None{},None{},stamp,right},Memo{left,right,cache,stamp}))
    case Recipe.Unused{} Recipe.Writable{} Store.Slot{owner,+cache,+stamp,_}:(Store.Slot{None{},None{},stamp,left},(Store.Slot{owner,cache,stamp,right},Memo{left,right,cache,stamp}))
    case left right Store.Slot{owner,+cache,+stamp,_}:(Store.Slot{owner,cache_for(V,left,cache),stamp,left},(Store.Slot{None{},cache_for(V,right,cache),stamp,right},Memo{left,right,cache,stamp}))
type Pieces<-S:Data,-layout:L.Layout> is Type:
  Pieces{left:Store.slots(~S,layout),right:Store.slots(~S,layout),memo:memos(layout)}
def paired_pieces(~S:Data,-ll:L.Layout,-rr:L.Layout,left:Pieces<S,ll>,right:Pieces<S,rr>) -> Pieces<S,L.LayoutPair{ll,rr}>:
  match left right:
    case Pieces{ll,lr,lm} Pieces{rl,rr,rm}:Pieces{Product.Owner{ll,rl},Product.Owner{lr,rr},Product.Owner{lm,rm}}
def family_0(-S:Data,-P:Type,-V:Data,-refresh:P -> P & V,-key:String,-policy:Policy.Policy,result:Store.Slot<S,P,V,L.LayoutLeaf{P,V,refresh,key,policy}> & (Store.Slot<S,P,V,L.LayoutLeaf{P,V,refresh,key,policy}> & Memo<V>)) -> Pieces<S,L.LayoutLeaf{P,V,refresh,key,policy}>:
  match result:
    case (left,(right,memo)):Pieces{left,right,memo}
def family_1(-S:Data,-P:Type,-V:Data,-refresh:P -> P & V,-key:String,-kind:Fragment.PersistenceKind,-policy:Policy.Policy,result:Store.Slot<S,P,V,L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,policy}> & (Store.Slot<S,P,V,L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,policy}> & Memo<V>)) -> Pieces<S,L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,policy}>:
  match result:
    case (left,(right,memo)):Pieces{left,right,memo}
def divide(~S:Data,layout:L.Layout,+route:L.Route,+left:List<&2,Recipe.Entry>,+right:List<&2,Recipe.Entry>,owner:Store.slots(~S,layout)) -> Pieces<S,layout>:
  match layout owner:
    case L.EmptyLayout{} Unit{}:Pieces{Unit{},Unit{},Unit{}}
    case L.LayoutLeaf{P,V,refresh,key,policy} slot:family_0(S,P,V,refresh,key,policy,divide_slot(S,P,V,L.LayoutLeaf{P,V,refresh,key,policy},Recipe.at(route,left),Recipe.at(route,right),slot))
    case L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,policy} slot:family_1(S,P,V,refresh,key,kind,policy,divide_slot(S,P,V,L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,policy},Recipe.at(route,left),Recipe.at(route,right),slot))
    case L.LayoutPair{ll,rr} Product.Owner{l,r}:paired_pieces(~S,ll,rr,divide(~S,ll,Schema.append_route(route,L.InLeft{L.AtLeaf{}}),left,right,l),divide(~S,rr,Schema.append_route(route,L.InRight{L.AtLeaf{}}),left,right,r))
def inspected_children(-S:Data,-P:Type,-V:Data,-origin:L.Layout,memo:Memo<V>,left:Store.Slot<S,P,V,origin> & Bool,right:Store.Slot<S,P,V,origin> & Bool) -> (Store.Slot<S,P,V,origin> & (Store.Slot<S,P,V,origin> & Memo<V>)) & Bool:
  match left right:
    case (left,lv), (right,rv):((left,(right,memo)),Bool.and(lv,rv))
def inspect_children(-S:Data,-P:Type,-V:Data,-origin:L.Layout,left:Store.Slot<S,P,V,origin>,right:Store.Slot<S,P,V,origin>,memo:Memo<V>) -> (Store.Slot<S,P,V,origin> & (Store.Slot<S,P,V,origin> & Memo<V>)) & Bool:
  match memo:
    case Memo{+lp,+rp,cache,stamp}:inspected_children(S,P,V,origin,Memo{lp,rp,cache,stamp},Partition.check_slot(S,P,V,origin,lp,left),Partition.check_slot(S,P,V,origin,rp,right))
def checked_family_0(-S:Data,-P:Type,-V:Data,-refresh:P -> P & V,-key:String,-policy:Policy.Policy,result:(Store.Slot<S,P,V,L.LayoutLeaf{P,V,refresh,key,policy}> & (Store.Slot<S,P,V,L.LayoutLeaf{P,V,refresh,key,policy}> & Memo<V>)) & Bool) -> Pieces<S,L.LayoutLeaf{P,V,refresh,key,policy}> & Bool:
  match result:
    case ((left,(right,memo)),valid):(Pieces{left,right,memo},valid)
def checked_family_1(-S:Data,-P:Type,-V:Data,-refresh:P -> P & V,-key:String,-kind:Fragment.PersistenceKind,-policy:Policy.Policy,result:(Store.Slot<S,P,V,L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,policy}> & (Store.Slot<S,P,V,L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,policy}> & Memo<V>)) & Bool) -> Pieces<S,L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,policy}> & Bool:
  match result:
    case ((left,(right,memo)),valid):(Pieces{left,right,memo},valid)
def inspected_pieces(~S:Data,-ll:L.Layout,-rr:L.Layout,left:Pieces<S,ll> & Bool,right:Pieces<S,rr> & Bool) -> Pieces<S,L.LayoutPair{ll,rr}> & Bool:
  match left right:
    case (left,lv), (right,rv):(paired_pieces(~S,ll,rr,left,right),Bool.and(lv,rv))
def inspect_join(~S:Data,layout:L.Layout,left:Store.slots(~S,layout),right:Store.slots(~S,layout),memo:memos(layout)) -> Pieces<S,layout> & Bool:
  match layout left right memo:
    case L.EmptyLayout{} Unit{} Unit{} Unit{}:(Pieces{Unit{},Unit{},Unit{}},True{})
    case L.LayoutLeaf{P,V,refresh,key,policy} left right memo:checked_family_0(S,P,V,refresh,key,policy,inspect_children(S,P,V,L.LayoutLeaf{P,V,refresh,key,policy},left,right,memo))
    case L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,policy} left right memo:checked_family_1(S,P,V,refresh,key,kind,policy,inspect_children(S,P,V,L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,policy},left,right,memo))
    case L.LayoutPair{ll,rr} Product.Owner{l1,r1} Product.Owner{l2,r2} Product.Owner{lm,rm}:inspected_pieces(~S,ll,rr,inspect_join(~S,ll,l1,l2,lm),inspect_join(~S,rr,r1,r2,rm))
def merged_slot(-S:Data,-P:Type,-V:Data,-origin:L.Layout,left:Store.Slot<S,P,V,origin>,right:Store.Slot<S,P,V,origin>,memo:Memo<V>) -> Store.Slot<S,P,V,origin>:
  match left right memo:
    case left _ Memo{Recipe.Writable{},_,_,_}:left
    case _ right Memo{_,Recipe.Writable{},_,_}:right
    case _ _ Memo{lp,rp,cache,stamp}:Store.Slot{None{},cache,stamp,Recipe.combine(lp,rp)}
def merge(~S:Data,layout:L.Layout,pieces:Pieces<S,layout>) -> Store.slots(~S,layout):
  match layout pieces:
    case L.EmptyLayout{} Pieces{Unit{},Unit{},Unit{}}:Unit{}
    case L.LayoutLeaf{P,V,refresh,key,policy} Pieces{left,right,memo}:merged_slot(S,P,V,L.LayoutLeaf{P,V,refresh,key,policy},left,right,memo)
    case L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,policy} Pieces{left,right,memo}:merged_slot(S,P,V,L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,policy},left,right,memo)
    case L.LayoutPair{ll,rr} Pieces{Product.Owner{l1,r1},Product.Owner{l2,r2},Product.Owner{lm,rm}}:Product.Owner{merge(~S,ll,Pieces{l1,l2,lm}),merge(~S,rr,Pieces{r1,r2,rm})}
