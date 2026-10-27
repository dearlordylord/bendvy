import Base
import ../../src/ecs/world.bend as W
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-resource-policy.bend as Policy
import ../../src/ecs/execution-relation-store.bend as Store
import ../../src/ecs/execution-relation-provider.bend as Provider
import ../../src/ecs/execution-relation-schema-setup.bend as Setup
import ../../src/ecs/execution-relation-context.bend as Context
import ../../src/ecs/relation-types.bend as T

# Scene provisioning retains arbitrary affine application state alongside the
# protected graph. Command execution is supplied by the ordinary scheduler;
# this module only constructs its schema and the exact graph binding.
def hierarchy(~S:Data) -> T.Descriptor<S>:
  T.Descriptor{89,"scene-parent","scene-children",T.Hierarchy{}}
def graph_layout(~S:Data) -> Layout.Layout:
  Provider.layout(~S,~hierarchy(~S),"scene-hierarchy")
def resources(~S:Data,~P:Type,~V:Data,~refresh:P -> P & V) -> Layout.Layout:
  Layout.LayoutPair{graph_layout(~S),Layout.LayoutLeaf{P,V,refresh,"scene-state",Policy.Ordinary{}}}
def owners(~S:Data,~P:Type,~V:Data,~refresh:P -> P & V,namespace:U32,state:P) -> Layout.resources(~S,resources(~S,~P,~V,~refresh)):
  Product.Owner{Layout.ResourceSlot{Layout.initialize(graph_layout(~S),Layout.AtLeaf{},Store.fresh(~S,~hierarchy(~S),namespace)),Layout.unknown_stamp()},Layout.ResourceSlot{Layout.initialize(resources(~S,~P,~V,~refresh),Layout.InRight{Layout.AtLeaf{}},state),Layout.unknown_stamp()}}
def create(~S:Data,~P:Type,~V:Data,~refresh:P -> P & V,factory:W.Factory,state:P) -> Context.Initialization<S,Layout.EmptyLayout{},resources(~S,~P,~V,~refresh),Unit>:
  Setup.create(~S,~Layout.EmptyLayout{},~resources(~S,~P,~V,~refresh),~Unit,~P,~owners(~S,~P,~V,~refresh),factory,state)
def binding(~S:Data,~P:Type,~V:Data,~refresh:P -> P & V,context:Context.Context<S,Layout.resources(~S,resources(~S,~P,~V,~refresh)),resources(~S,~P,~V,~refresh),{==}>) -> Context.Binding<S,Layout.resources(~S,resources(~S,~P,~V,~refresh)),resources(~S,~P,~V,~refresh),{==},Layout.InLeft{Layout.AtLeaf{}},hierarchy(~S),{==},{==},{==}>:
  Provider.bind(~S,~Layout.resources(~S,resources(~S,~P,~V,~refresh)),~resources(~S,~P,~V,~refresh),~{==},~Layout.InLeft{Layout.AtLeaf{}},~{==},~hierarchy(~S),~{==},~{==},~{==},context)
