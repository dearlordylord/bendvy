import Base
import ../../src/ecs/world.bend as W
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-resource-policy.bend as Policy
import ../../src/ecs/execution-relation-provider.bend as Relation
import ../../src/ecs/execution-relation-store.bend as Store
import ../../src/ecs/execution-relation-schema-setup.bend as Setup
import ../../src/ecs/execution-relation-context.bend as Context
import ../../src/ecs/execution-machine-access.bend as Machine
import ../../src/ecs/execution-machine-state.bend as State
import ../../src/ecs/execution-machine-stream.bend as Stream
import ../../src/ecs/machine.bend as M
import ../../src/ecs/relation-types.bend as T

type Scene is Data:
  Scene{}
type PhaseToken is Data:
  PhaseToken{}
def project_join(left:Array<U32> & List<&2,U32>,right:Array<U32> & List<&2,U32>) -> Array<U32> & List<&2,U32>:
  match left right:
    case (left,xs), (right,ys):(ANode{left,right},List.append(&2,U32,xs,ys))
def project(values:Array<U32>) -> Array<U32> & List<&2,U32>:
  match values:
    case ALeaf{+value}:(ALeaf{value},[value])
    case ANode{left,right}:project_join(project(left),project(right))
def scalar(value:U32) -> U32 & U32:
  +copy=value
  (copy,copy)
def components() -> Layout.Layout:
  Layout.LayoutPair{Layout.LayoutLeaf{Array<U32>,List<&2,U32>,project,"array",Policy.Ordinary{}},Layout.LayoutLeaf{U32,U32,scalar,"scalar",Policy.Ordinary{}}}
def parent() -> T.Descriptor<Scene>:
  T.Descriptor{1,"Parent","Children",T.Hierarchy{}}
def link() -> T.Descriptor<Scene>:
  T.Descriptor{2,"Link","LinkedBy",T.Ordinary{}}
def parent_layout() -> Layout.Layout:Relation.layout(~Scene,~parent(),"Parent")
def link_layout() -> Layout.Layout:Relation.layout(~Scene,~link(),"Link")
def phase_layout() -> Layout.Layout:Machine.leaf(Scene,PhaseToken,U32,"ScenePhase")
def sibling_layout() -> Layout.Layout:
  Layout.LayoutLeaf{Array<U32>,List<&2,U32>,project,"Sibling",Policy.Ordinary{}}
def receipt_view(-Receipts:Type,receipts:Receipts) -> Receipts & Unit:(receipts,Unit{})
def receipts_layout(~Receipts:Type) -> Layout.Layout:
  Layout.LayoutLeaf{Receipts,Unit,receipt_view(Receipts),"BundleReceipts",Policy.Ordinary{}}
def tail_resources(~Receipts:Type) -> Layout.Layout:
  Layout.LayoutPair{link_layout(),Layout.LayoutPair{phase_layout(),Layout.LayoutPair{sibling_layout(),receipts_layout(~Receipts)}}}
def resources(~Receipts:Type) -> Layout.Layout:
  Layout.LayoutPair{parent_layout(),tail_resources(~Receipts)}
def phase(namespace:U32) -> State.Cell<Scene,PhaseToken,U32>:
  State.Cell{M.Present{1,M.Queued{2,False{}},None{},False{}},Stream.empty(~U32),0n,None{},None{},0n,False{},Some{namespace},State.Idle{}}
def owners(~Receipts:Type,namespace:U32,receipts:Receipts) -> Layout.resources(~Scene,resources(~Receipts)):
  +actualNamespace=namespace
  Product.Owner{Layout.ResourceSlot{Layout.initialize(parent_layout(),Layout.AtLeaf{},Store.fresh(~Scene,~parent(),actualNamespace)),Layout.unknown_stamp()},Product.Owner{Layout.ResourceSlot{Layout.initialize(link_layout(),Layout.AtLeaf{},Store.fresh(~Scene,~link(),actualNamespace)),Layout.unknown_stamp()},Product.Owner{Layout.ResourceSlot{Layout.initialize(phase_layout(),Layout.AtLeaf{},phase(actualNamespace)),Layout.unknown_stamp()},Product.Owner{Layout.ResourceSlot{Layout.initialize(sibling_layout(),Layout.AtLeaf{},ANode{ALeaf{100},ALeaf{101}}),Layout.unknown_stamp()},Layout.ResourceSlot{Layout.initialize(receipts_layout(~Receipts),Layout.AtLeaf{},receipts),Layout.unknown_stamp()}}}}}
def create(~Receipts:Type,factory:W.Factory,receipts:Receipts) -> Context.Initialization<Scene,components(),resources(~Receipts),Unit>:
  Setup.create(~Scene,~components(),~resources(~Receipts),~Unit,~Receipts,~owners(~Receipts),factory,receipts)
def sample_array() -> Array<U32>:ANode{ALeaf{7},ALeaf{9}}
def sample_scalar() -> U32:11
