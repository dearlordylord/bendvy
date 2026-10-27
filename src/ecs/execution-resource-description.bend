import Base
import ./execution-resource-policy.bend as Policy
import ./execution-composer-layout.bend as L
import ./execution-query-schema.bend as Routes
import ./owner-product.bend as Product
import ./lifecycle.bend as Life

type Info is Data:
  Info{route:L.Route,key:String,stamp:Life.Stamp}
type Description<-S:Data,-full:L.Layout> is Type:
  Description{resources:L.resources(~S,full),info:List<&2,Info>}
def described_pair(~S:Data,-ll:L.Layout,-rr:L.Layout,left:Description<S,ll>,right:Description<S,rr>) -> Description<S,L.LayoutPair{ll,rr}>:
  match left right:
    case Description{left,li} Description{right,ri}:Description{Product.Owner{left,right},List.append(&2,Info,li,ri)}
# Describes genuine stored stamps without projecting, refreshing or stamping P.
def describe(~S:Data,layout:L.Layout,+route:L.Route,resources:L.resources(~S,layout)) -> Description<S,layout>:
  match layout resources:
    case L.EmptyLayout{} Unit{}:Description{Unit{},[]}
    case L.LayoutLeaf{P,V,refresh,+key,_} L.ResourceSlot{owner,+stamp}:Description{L.ResourceSlot{owner,stamp},[Info{route,key,stamp}]}
    case L.ClassifiedLayoutLeaf{P,V,refresh,+key,kind,_} L.ResourceSlot{owner,+stamp}:Description{L.ResourceSlot{owner,stamp},[Info{route,key,stamp}]}
    case L.LayoutPair{ll,rr} Product.Owner{left,right}:described_pair(~S,ll,rr,describe(~S,ll,Routes.append_route(route,L.InLeft{L.AtLeaf{}}),left),describe(~S,rr,Routes.append_route(route,L.InRight{L.AtLeaf{}}),right))
