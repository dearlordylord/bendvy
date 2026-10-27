import Base
import ./execution-resource-store.bend as Store
import ./execution-resource-partition.bend as Partition
import ./execution-composer-layout.bend as L
import ./owner-product.bend as Product
import ./schema-fragments.bend as Fragment
import ./lifecycle.bend as Life

type Rest<-S:Data,-P:Type,-V:Data,-key:String,-origin:L.Layout> is Type:
  Rest{owner:Maybe<&1,L.ResourceSlot<S,L.Viewed<P,V>,key,origin>>,stamp:Life.Stamp}
def remainder(~S:Data,layout:L.Layout) -> Type:
  match layout:
    case L.EmptyLayout{}:Unit
    case L.LayoutLeaf{P,V,refresh,key}:Rest<S,P,V,key,L.LayoutLeaf{P,V,refresh,key}>
    case L.ClassifiedLayoutLeaf{P,V,refresh,key,kind}:Rest<S,P,V,key,L.ClassifiedLayoutLeaf{P,V,refresh,key,kind}>
    case L.LayoutPair{left,right}:Product.Owner<remainder(~S,left),remainder(~S,right)>
type Separated<-S:Data,-full:L.Layout> is Type:
  Separated{left:Store.slots(~S,full),right:Store.slots(~S,full),rest:remainder(~S,full),repack:Store.slots(~S,full) -> Store.slots(~S,full) -> remainder(~S,full) -> Partition.families(~S,full)}
def repack_family(-S:Data,-P:Type,-V:Data,-key:String,-origin:L.Layout,left:Store.Slot<S,P,V,origin>,right:Store.Slot<S,P,V,origin>,rest:Rest<S,P,V,key,origin>) -> Partition.Family<S,P,V,key,origin>:
  match rest:
    case Rest{owner,stamp}:Partition.Family{left,right,owner,stamp}
def plain(-S:Data,-P:Type,-V:Data,-refresh:P -> P & V,-key:String,family:Partition.Family<S,P,V,key,L.LayoutLeaf{P,V,refresh,key}>) -> Separated<S,L.LayoutLeaf{P,V,refresh,key}>:
  match family:
    case Partition.Family{left,right,rest,stamp}:Separated{left,right,Rest{rest,stamp},(left => right => rest => repack_family(S,P,V,key,L.LayoutLeaf{P,V,refresh,key},left,right,rest))}
def classified(-S:Data,-P:Type,-V:Data,-refresh:P -> P & V,-key:String,-kind:Fragment.PersistenceKind,family:Partition.Family<S,P,V,key,L.ClassifiedLayoutLeaf{P,V,refresh,key,kind}>) -> Separated<S,L.ClassifiedLayoutLeaf{P,V,refresh,key,kind}>:
  match family:
    case Partition.Family{left,right,rest,stamp}:Separated{left,right,Rest{rest,stamp},(left => right => rest => repack_family(S,P,V,key,L.ClassifiedLayoutLeaf{P,V,refresh,key,kind},left,right,rest))}
def repack_pair(~S:Data,-ll:L.Layout,-rr:L.Layout,leftRepack:Store.slots(~S,ll) -> Store.slots(~S,ll) -> remainder(~S,ll) -> Partition.families(~S,ll),rightRepack:Store.slots(~S,rr) -> Store.slots(~S,rr) -> remainder(~S,rr) -> Partition.families(~S,rr),left:Store.slots(~S,L.LayoutPair{ll,rr}),right:Store.slots(~S,L.LayoutPair{ll,rr}),rest:remainder(~S,L.LayoutPair{ll,rr})) -> Partition.families(~S,L.LayoutPair{ll,rr}):
  match left right rest:
    case Product.Owner{ll,lr} Product.Owner{rl,rr} Product.Owner{sl,sr}:Product.Owner{leftRepack(ll,rl,sl),rightRepack(lr,rr,sr)}
def separated_pair(~S:Data,-leftLayout:L.Layout,-rightLayout:L.Layout,left:Separated<S,leftLayout>,right:Separated<S,rightLayout>) -> Separated<S,L.LayoutPair{leftLayout,rightLayout}>:
  match left right:
    case Separated{ll,lr,ls,lp} Separated{rl,rr,rs,rp}:Separated{Product.Owner{ll,rl},Product.Owner{lr,rr},Product.Owner{ls,rs},(left => right => rest => repack_pair(~S,leftLayout,rightLayout,lp,rp,left,right,rest))}
def separate(~S:Data,layout:L.Layout,families:Partition.families(~S,layout)) -> Separated<S,layout>:
  match layout families:
    case L.EmptyLayout{} Unit{}:Separated{Unit{},Unit{},Unit{},(left => right => rest => Unit{})}
    case L.LayoutLeaf{P,V,refresh,key} family:plain(S,P,V,refresh,key,family)
    case L.ClassifiedLayoutLeaf{P,V,refresh,key,kind} family:classified(S,P,V,refresh,key,kind,family)
    case L.LayoutPair{ll,rr} Product.Owner{left,right}:separated_pair(~S,ll,rr,separate(~S,ll,left),separate(~S,rr,right))
def reunite(~S:Data,~full:L.Layout,left:Store.slots(~S,full),right:Store.slots(~S,full),rest:remainder(~S,full),repack:Store.slots(~S,full) -> Store.slots(~S,full) -> remainder(~S,full) -> Partition.families(~S,full),join:Partition.JoinOwner<S,full>) -> Partition.Joined<S,full>:
  Partition.join(~S,~full,repack(left,right,rest),join)
