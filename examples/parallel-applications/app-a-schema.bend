import Base
import ./app-a-payloads.bend as P
import ../../src/ecs/world.bend as W
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-resource-policy.bend as Policy
import ../../src/ecs/execution-relation-schema-setup.bend as Setup
import ../../src/ecs/execution-relation-context.bend as Context
import ../../src/ecs/execution-event-family.bend as Event
import ../../src/ecs/execution-event-view.bend as View

def scalar(value:U32) -> U32 & U32:
  +copy=value
  (copy,copy)
def components() -> Layout.Layout:
  Layout.LayoutPair{Layout.LayoutLeaf{Array<U32>,List<&2,U32>,P.project,"array",Policy.Ordinary{}},Layout.LayoutLeaf{U32,U32,scalar,"scalar",Policy.Ordinary{}}}
def counter_layout() -> Layout.Layout:Layout.LayoutLeaf{Array<U32>,List<&2,U32>,P.project,"Counter",Policy.Ordinary{}}
def sibling_layout() -> Layout.Layout:Layout.LayoutLeaf{Array<U32>,List<&2,U32>,P.project,"Sibling",Policy.Ordinary{}}
def receipt_view(-Receipts:Type,receipts:Receipts) -> Receipts & Unit:(receipts,Unit{})
def receipts_layout(~Receipts:Type) -> Layout.Layout:Layout.LayoutLeaf{Receipts,Unit,receipt_view(Receipts),"BundleReceipts",Policy.Ordinary{}}
def sum(values:List<&2,U32>) -> U32:
  match values:
    case []:0
    case head <> tail:U32.add(head,sum(tail))
def summed(result:Array<U32> & List<&2,U32>) -> Array<U32> & U32:
  match result:
    case (owner,values):(owner,sum(values))
def event_value(owner:Array<U32>) -> Array<U32> & U32:summed(P.project(owner))
def event_layout() -> Layout.Layout:Layout.LayoutLeaf{Event.Family<P.AuditWorkshop,Array<U32>,"RecoveredCargoLog">,View.View<P.AuditWorkshop,Array<U32>,"RecoveredCargoLog",U32>,View.refresh(~P.AuditWorkshop,~Array<U32>,~"RecoveredCargoLog",~U32,~event_value),"RecoveredCargoLog",Policy.Ordinary{}}
def tail_resources(~Receipts:Type) -> Layout.Layout:Layout.LayoutPair{sibling_layout(),Layout.LayoutPair{receipts_layout(~Receipts),event_layout()}}
def resources(~Receipts:Type) -> Layout.Layout:Layout.LayoutPair{counter_layout(),tail_resources(~Receipts)}
type Seed<-Receipts:Type> is Type:
  Seed{receipts:Receipts,events:Event.Family<P.AuditWorkshop,Array<U32>,"RecoveredCargoLog">}
def owners(~Receipts:Type,namespace:U32,seed:Seed<Receipts>) -> Layout.resources(~P.AuditWorkshop,resources(~Receipts)):
  match seed:
    case Seed{receipts,events}:Product.Owner{Layout.ResourceSlot{Layout.initialize(counter_layout(),Layout.AtLeaf{},P.initial_counter()),Layout.unknown_stamp()},Product.Owner{Layout.ResourceSlot{Layout.initialize(sibling_layout(),Layout.AtLeaf{},P.sibling()),Layout.unknown_stamp()},Product.Owner{Layout.ResourceSlot{Layout.initialize(receipts_layout(~Receipts),Layout.AtLeaf{},receipts),Layout.unknown_stamp()},Layout.ResourceSlot{Layout.initialize(event_layout(),Layout.AtLeaf{},events),Layout.unknown_stamp()}}}}
def create(~Receipts:Type,factory:W.Factory,seed:Seed<Receipts>) -> Context.Initialization<P.AuditWorkshop,components(),resources(~Receipts),Unit>:
  Setup.create(~P.AuditWorkshop,~components(),~resources(~Receipts),~Unit,~Seed<Receipts>,~owners(~Receipts),factory,seed)
