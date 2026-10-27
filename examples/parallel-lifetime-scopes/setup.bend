import Base
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-resource-policy.bend as Policy
import ../../src/ecs/execution-relation-store.bend as Store
import ../../src/ecs/execution-relation-provider.bend as Provider
import ../../src/ecs/relation-types.bend as T
import ../../src/ecs/execution-lifetime-scope-provider.bend as ScopeProvider
import ../../src/ecs/execution-lifetime-scope-store.bend as ScopeStore

# Provision the graph and membership resource from the same actual namespace,
# retaining the affine application seed alongside them.
def hierarchy(~S:Data) -> T.Descriptor<S>:
  T.Descriptor{89,"scene-parent","scene-children",T.Hierarchy{}}
def graph_layout(~S:Data) -> Layout.Layout:
  Provider.layout(~S,~hierarchy(~S),"scene-hierarchy")
def right_resources(~S:Data,~P:Type,~V:Data,~refresh:P -> P & V) -> Layout.Layout:
  Layout.LayoutPair{ScopeProvider.layout(~S,"scene-scope"),Layout.LayoutLeaf{P,V,refresh,"scene-state",Policy.Ordinary{}}}
def resources(~S:Data,~P:Type,~V:Data,~refresh:P -> P & V) -> Layout.Layout:
  Layout.LayoutPair{graph_layout(~S),right_resources(~S,~P,~V,~refresh)}
def owners_shared(~S:Data,~P:Type,~V:Data,~refresh:P -> P & V,+namespace:U32,state:P) -> Layout.resources(~S,resources(~S,~P,~V,~refresh)):
  Product.Owner{Layout.ResourceSlot{Layout.initialize(graph_layout(~S),Layout.AtLeaf{},Store.fresh(~S,~hierarchy(~S),namespace)),Layout.unknown_stamp()},Product.Owner{Layout.ResourceSlot{Layout.initialize(ScopeProvider.layout(~S,"scene-scope"),Layout.AtLeaf{},ScopeStore.fresh(~S,namespace)),Layout.unknown_stamp()},Layout.ResourceSlot{Layout.initialize(Layout.LayoutLeaf{P,V,refresh,"scene-state",Policy.Ordinary{}},Layout.AtLeaf{},state),Layout.unknown_stamp()}}}
def owners(~S:Data,~P:Type,~V:Data,~refresh:P -> P & V,namespace:U32,state:P) -> Layout.resources(~S,resources(~S,~P,~V,~refresh)):
  owners_shared(~S,~P,~V,~refresh,namespace,state)
