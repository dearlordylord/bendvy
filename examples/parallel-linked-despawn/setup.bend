import Base
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-resource-policy.bend as Policy
import ../../src/ecs/execution-relation-store.bend as Store
import ../../src/ecs/execution-relation-provider.bend as Provider
import ../../src/ecs/relation-types.bend as T
import ../../src/ecs/execution-lifetime-scope-provider.bend as ScopeProvider
import ../../src/ecs/execution-lifetime-scope-store.bend as ScopeStore
import ../../src/ecs/execution-schema-provisioning.bend as Provision
import ../../src/ecs/execution-schema-provisioning-pair.bend as Pair

def hierarchy(~S:Data) -> T.Descriptor<S>:
  T.Descriptor{89,"scene-parent","scene-children",T.Hierarchy{}}
def link(~S:Data) -> T.Descriptor<S>:
  T.Descriptor{90,"scene-link","scene-linked-by",T.Ordinary{}}
def graph_layout(~S:Data) -> Layout.Layout:
  Layout.LayoutPair{Provider.layout(~S,~hierarchy(~S),"scene-hierarchy"),Provider.layout(~S,~link(~S),"scene-link")}
def right_resources(~S:Data,~P:Type,~V:Data,~refresh:P -> P & V) -> Layout.Layout:
  Layout.LayoutPair{ScopeProvider.layout(~S,"scene-scope"),Layout.LayoutLeaf{P,V,refresh,"scene-state",Policy.Ordinary{}}}
def resources(~S:Data,~P:Type,~V:Data,~refresh:P -> P & V) -> Layout.Layout:
  Layout.LayoutPair{graph_layout(~S),right_resources(~S,~P,~V,~refresh)}
def owners_shared(~S:Data,~P:Type,~V:Data,~refresh:P -> P & V,+namespace:U32,state:P) -> Layout.resources(~S,resources(~S,~P,~V,~refresh)):
  Product.Owner{Product.Owner{Layout.ResourceSlot{Layout.initialize(Provider.layout(~S,~hierarchy(~S),"scene-hierarchy"),Layout.AtLeaf{},Store.fresh(~S,~hierarchy(~S),namespace)),Layout.unknown_stamp()},Layout.ResourceSlot{Layout.initialize(Provider.layout(~S,~link(~S),"scene-link"),Layout.AtLeaf{},Store.fresh(~S,~link(~S),namespace)),Layout.unknown_stamp()}},Product.Owner{Layout.ResourceSlot{Layout.initialize(ScopeProvider.layout(~S,"scene-scope"),Layout.AtLeaf{},ScopeStore.fresh(~S,namespace)),Layout.unknown_stamp()},Layout.ResourceSlot{Layout.initialize(Layout.LayoutLeaf{P,V,refresh,"scene-state",Policy.Ordinary{}},Layout.AtLeaf{},state),Layout.unknown_stamp()}}}
def owners(~S:Data,~P:Type,~V:Data,~refresh:P -> P & V,namespace:U32,state:P) -> Layout.resources(~S,resources(~S,~P,~V,~refresh)):
  owners_shared(~S,~P,~V,~refresh,namespace,state)

def Seed(~P:Type) -> Type:Product.Owner<Product.Owner<Unit,Unit>,Product.Owner<Unit,P>>
def blueprint(~S:Data,~P:Type,~V:Data,~refresh:P -> P & V) -> Provision.Blueprint<S,resources(~S,~P,~V,~refresh),Seed(~P)>:
  Pair.pair(~S,~graph_layout(~S),~right_resources(~S,~P,~V,~refresh),~Product.Owner<Unit,Unit>,~Product.Owner<Unit,P>,Pair.pair(~S,~Provider.layout(~S,~hierarchy(~S),"scene-hierarchy"),~Provider.layout(~S,~link(~S),"scene-link"),~Unit,~Unit,Provision.graph(~S,~hierarchy(~S),~"scene-hierarchy"),Provision.graph(~S,~link(~S),~"scene-link")),Pair.pair(~S,~ScopeProvider.layout(~S,"scene-scope"),~Provision.ordinary_layout(~P,~V,~refresh,"scene-state"),~Unit,~P,Provision.scope(~S,~"scene-scope"),Provision.ordinary(~S,~P,~V,~refresh,~"scene-state")))
