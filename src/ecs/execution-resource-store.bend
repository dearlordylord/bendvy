import Base
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
    case L.LayoutLeaf{P,V,refresh,key}:Slot<S,P,V,L.LayoutLeaf{P,V,refresh,key}>
    case L.ClassifiedLayoutLeaf{P,V,refresh,key,kind}:Slot<S,P,V,L.ClassifiedLayoutLeaf{P,V,refresh,key,kind}>
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
  Viewed{view:V}
  LookupRefused{}
def lookup_checked(-V:Data,cache:Maybe<&2,V>,permission:Recipe.Permission) -> Lookup<V>:
  match cache permission:
    case Some{view} Recipe.ReadOnly{}:Viewed{view}
    case Some{view} Recipe.Writable{}:Viewed{view}
    case _ _:LookupRefused{}
def read(-S:Data,-P:Type,-V:Data,-origin:L.Layout,slot:Slot<S,P,V,origin>) -> Slot<S,P,V,origin> & Lookup<V>:
  match slot:
    case Slot{owner,+cache,+stamp,+permission}:(Slot{owner,cache,stamp,permission},lookup_checked(V,cache,permission))
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
