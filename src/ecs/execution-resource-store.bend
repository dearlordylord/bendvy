import Base
import ./execution-resource-policy.bend as Policy
import ./execution-composer-layout.bend as L
import ./execution-resource-recipe.bend as Recipe
import ./owner-product.bend as Product
import ./lifecycle.bend as Life
import ./change-tick.bend as Tick

# Full origin and schema remain type brands even for cached Data-only reads.
type Slot<-S:Data,-P:Type,-V:Data,-origin:L.Layout> is Type:
  Slot{owner:Maybe<&1,L.Viewed<P,V>>,cache:Maybe<&2,V>,stamp:Life.Stamp,permission:Recipe.Permission}
def slots(~S:Data,layout:L.Layout) -> Type:
  match layout:
    case L.EmptyLayout{}:Unit
    case L.LayoutLeaf{P,V,refresh,key,accessPolicy}:Slot<S,P,V,L.LayoutLeaf{P,V,refresh,key,accessPolicy}>
    case L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,accessPolicy}:Slot<S,P,V,L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,accessPolicy}>
    case L.LayoutPair{left,right}:Product.Owner<slots(~S,left),slots(~S,right)>
type Model is Data:
  Whole{}
  Sparse{}
type Storage<-S:Data,-full:L.Layout> is Type:
  Storage{namespace:U32,slots:slots(~S,full),recipes:List<&2,Recipe.Entry>}
def owner(~S:Data,full:L.Layout,model:Model) -> Type:
  match model:
    case Whole{}:L.resources(~S,full)
    case Sparse{}:Storage<S,full>
type Lookup<-V:Data> is Data:
  Viewed{view:V,stamp:Life.Stamp}
  LookupRefused{}
def lookup_checked(-V:Data,cache:Maybe<&2,V>,stamp:Life.Stamp,permission:Recipe.Permission) -> Lookup<V>:
  match cache permission:
    case Some{view} Recipe.ReadOnly{}:Viewed{view,stamp}
    case Some{view} Recipe.Writable{}:Viewed{view,stamp}
    case _ _:LookupRefused{}
def read(-S:Data,-P:Type,-V:Data,-origin:L.Layout,slot:Slot<S,P,V,origin>) -> Slot<S,P,V,origin> & Lookup<V>:
  match slot:
    case Slot{owner,+cache,+stamp,+permission}:(Slot{owner,cache,stamp,permission},lookup_checked(V,cache,stamp,permission))
type Edit<-P:Type,-Out:Type> is Type:
  Edited{output:Out}
  Unchanged{unused:P -> P & Out}
def refreshed(~S:Data,~full:L.Layout,~route:L.Route,-Out:Type,stamp:Life.Stamp,tick:Tick.Tick,result:L.stored(full,route) & Out) -> Slot<S,L.payload(full,route),L.view(full,route),L.origin(full,route)> & Edit<L.payload(full,route),Out>:
  match result:
    case (L.Viewed{owner,+view},out):(Slot{Some{L.Viewed{owner,view}},Some{view},Life.after_write(True{},True{},stamp,tick),Recipe.Writable{}},Edited{out})
def edit(~S:Data,~full:L.Layout,~route:L.Route,-Out:Type,tick:Tick.Tick,slot:Slot<S,L.payload(full,route),L.view(full,route),L.origin(full,route)>,transform:L.payload(full,route) -> L.payload(full,route) & Out) -> Slot<S,L.payload(full,route),L.view(full,route),L.origin(full,route)> & Edit<L.payload(full,route),Out>:
  match slot:
    case Slot{Some{value},_,stamp,Recipe.Writable{}}:refreshed(~S,~full,~route,Out,stamp,tick,L.rewrite(~full,~route,Out,transform,value))
    case slot:(slot,Unchanged{transform})

def route_rest(~S:Data,layout:L.Layout,route:L.Route) -> Type:
  match layout route:
    case L.LayoutLeaf{_,_,_,_,_} L.AtLeaf{}:Unit
    case L.ClassifiedLayoutLeaf{_,_,_,_,_,_} L.AtLeaf{}:Unit
    case L.LayoutPair{left,right} L.InLeft{rest}:slots(~S,right) & route_rest(~S,left,rest)
    case L.LayoutPair{left,right} L.InRight{rest}:slots(~S,left) & route_rest(~S,right,rest)
    case layout _:slots(~S,layout)
def route_joined(-Outer:Type,-Inner:Type,-Selected:Type,outer:Outer,result:Inner & Selected) -> (Outer & Inner) & Selected:
  match result:
    case (inner,slot):((outer,inner),slot)
def empty_slot(-S:Data,-P:Type,-V:Data,-origin:L.Layout) -> Slot<S,P,V,origin>:
  Slot{None{},None{},Life.Stamp{None{},None{}},Recipe.Unused{}}
def take(~S:Data,layout:L.Layout,route:L.Route,owner:slots(~S,layout)) -> route_rest(~S,layout,route) & Slot<S,L.payload(layout,route),L.view(layout,route),L.origin(layout,route)>:
  match layout route owner:
    case L.EmptyLayout{} _ owner:(owner,empty_slot(S,Unit,Unit,L.EmptyLayout{}))
    case L.LayoutLeaf{_,_,_,_,_} L.AtLeaf{} owner:(Unit{},owner)
    case L.ClassifiedLayoutLeaf{_,_,_,_,_,_} L.AtLeaf{} owner:(Unit{},owner)
    case L.LayoutLeaf{_,_,_,_,_} L.InLeft{_} owner:(owner,empty_slot(S,Unit,Unit,L.EmptyLayout{}))
    case L.LayoutLeaf{_,_,_,_,_} L.InRight{_} owner:(owner,empty_slot(S,Unit,Unit,L.EmptyLayout{}))
    case L.ClassifiedLayoutLeaf{_,_,_,_,_,_} L.InLeft{_} owner:(owner,empty_slot(S,Unit,Unit,L.EmptyLayout{}))
    case L.ClassifiedLayoutLeaf{_,_,_,_,_,_} L.InRight{_} owner:(owner,empty_slot(S,Unit,Unit,L.EmptyLayout{}))
    case L.LayoutPair{_,_} L.AtLeaf{} owner:(owner,empty_slot(S,Unit,Unit,L.EmptyLayout{}))
    case L.LayoutPair{left,right} L.InLeft{rest} Product.Owner{l,r}:route_joined(slots(~S,right),route_rest(~S,left,rest),Slot<S,L.payload(left,rest),L.view(left,rest),L.origin(left,rest)>,r,take(~S,left,rest,l))
    case L.LayoutPair{left,right} L.InRight{rest} Product.Owner{l,r}:route_joined(slots(~S,left),route_rest(~S,right,rest),Slot<S,L.payload(right,rest),L.view(right,rest),L.origin(right,rest)>,l,take(~S,right,rest,r))
def put(~S:Data,layout:L.Layout,route:L.Route,rest:route_rest(~S,layout,route),slot:Slot<S,L.payload(layout,route),L.view(layout,route),L.origin(layout,route)>) -> slots(~S,layout):
  match layout route rest:
    case L.EmptyLayout{} _ rest:rest
    case L.LayoutLeaf{_,_,_,_,_} L.AtLeaf{} _:slot
    case L.ClassifiedLayoutLeaf{_,_,_,_,_,_} L.AtLeaf{} _:slot
    case L.LayoutLeaf{_,_,_,_,_} L.InLeft{_} rest:rest
    case L.LayoutLeaf{_,_,_,_,_} L.InRight{_} rest:rest
    case L.ClassifiedLayoutLeaf{_,_,_,_,_,_} L.InLeft{_} rest:rest
    case L.ClassifiedLayoutLeaf{_,_,_,_,_,_} L.InRight{_} rest:rest
    case L.LayoutPair{_,_} L.AtLeaf{} rest:rest
    case L.LayoutPair{left,right} L.InLeft{path}, (outer,inner):Product.Owner{put(~S,left,path,inner,slot),outer}
    case L.LayoutPair{left,right} L.InRight{path}, (outer,inner):Product.Owner{outer,put(~S,right,path,inner,slot)}
