import Base
import ./feature-motion.bend as Motion
import ./feature-labels.bend as Labels
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-composer-schema.bend as Schema
import ../../src/ecs/execution-composer-service.bend as Service
import ../../src/ecs/ordinary-declaration.bend as Identity
import ../../src/ecs/persistence-declaration.bend as Persist
import ../../src/ecs/decode-data.bend as Decode
import ../../src/ecs/chunk-column.bend as Col
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/world.bend as W

type Nominal is Data:Nominal{}
def position_id() -> Identity.Declaration<Nominal,Motion.Position>:Identity.component(~Nominal,~Motion.Position,"position")
def label_id() -> Identity.Declaration<Nominal,Labels.Label>:Identity.component(~Nominal,~Labels.Label,"label")
def label_form() -> Persist.Constructed<Nominal,Labels.Label,label_id(),Labels.raw_label>:
  Persist.constructed(~Nominal,~Labels.Label,~label_id(),~Labels.raw_label,Decode.Literal{Decode.BendvyText{"seed"}})
def host_id() -> Identity.Declaration<Nominal,Service.Slot<Labels.Host>>:Identity.component(~Nominal,~Service.Slot<Labels.Host>,"host")
def optional_seen(result:Array<String> & String) -> Maybe<&1,Array<String>> & String:
  match result:
    case (owner,text):(Some{owner},"some:" ++ text)
def optional(value:Maybe<&1,Array<String>>) -> Maybe<&1,Array<String>> & String:
  match value:
    case None{}:(None{},"none")
    case Some{owner}:optional_seen(Array.get(String,owner,0))
def components() -> Layout.Layout:
  Layout.LayoutPair{Schema.plain(~Nominal,~Motion.Position,~position_id(),~String,~Motion.position,Persist.plain(~Nominal,~Motion.Position,~position_id())),Schema.constructed(~Nominal,~Labels.Label,~label_id(),~Labels.raw_label,~String,~Labels.label,label_form())}
def resources() -> Layout.Layout:
  Layout.LayoutPair{Layout.LayoutLeaf{Motion.Counter,String,Motion.counter,"counter"},Layout.LayoutPair{Schema.transient(~Nominal,~Service.Slot<Labels.Host>,~host_id(),~Service.Status<String>,~Labels.ready,Persist.transient(~Nominal,~Service.Slot<Labels.Host>,~host_id())),Layout.LayoutLeaf{Maybe<&1,Array<String>>,String,optional,"optional"}}}
def left() -> Layout.Route:Layout.InLeft{Layout.AtLeaf{}}
def right() -> Layout.Route:Layout.InRight{Layout.AtLeaf{}}
def host_route() -> Layout.Route:Layout.InRight{Layout.InLeft{Layout.AtLeaf{}}}
def optional_route() -> Layout.Route:Layout.InRight{Layout.InRight{Layout.AtLeaf{}}}
def Store() -> Type:Layout.columns(~Nominal,components())
def Resources() -> Type:Layout.resources(~Nominal,resources())
def World() -> Type:W.World<Nominal,Store(),Resources(),Unit>
def inserted(~P:Type,result:Col.SwapOutcome<Nominal,P>) -> Col.Column<Nominal,P>:
  match result:
    case Col.Accepted{column,_}:column
    case Col.Rejected{column,_}:column
def label_owner(receipt:Decode.Receipt<Labels.Label>) -> Labels.Label:
  match receipt:
    case Decode.Receipt{owner,_}:owner
def seed(_:Unit) -> Store():
  Product.Owner{Layout.ColumnSlot{inserted(~Layout.stored(components(),left()),Col.swap(~Nominal,~Layout.stored(components(),left()),Layout.empty_column(Nominal,Layout.stored(components(),left())),0,Some{Layout.initialize(components(),left(),Motion.Position{ALeaf{101},10})}))},Layout.ColumnSlot{inserted(~Layout.stored(components(),right()),Col.swap(~Nominal,~Layout.stored(components(),right()),Layout.empty_column(Nominal,Layout.stored(components(),right())),1,Some{Layout.initialize(components(),right(),label_owner(Persist.validate(~Nominal,~Labels.Label,~label_id(),~Labels.raw_label,label_form(),Labels.Label{ALeaf{"LABEL-202"},"seed"})))}))}}
def resource_seed() -> Resources():
  Product.Owner{Layout.ResourceSlot{Layout.initialize(resources(),left(),Motion.Counter{ALeaf{301},0,Some{ALeaf{302}}}),Layout.unknown_stamp()},Product.Owner{Layout.ResourceSlot{Layout.initialize(resources(),host_route(),Service.Missing{}),Layout.unknown_stamp()},Layout.ResourceSlot{Layout.initialize(resources(),optional_route(),Some{ALeaf{"OPTIONAL-303"}}),Layout.unknown_stamp()}}}
def absent_optional_seed() -> Resources():
  Product.Owner{Layout.ResourceSlot{Layout.initialize(resources(),left(),Motion.Counter{ALeaf{301},0,Some{ALeaf{302}}}),Layout.unknown_stamp()},Product.Owner{Layout.ResourceSlot{Layout.initialize(resources(),host_route(),Service.Missing{}),Layout.unknown_stamp()},Layout.ResourceSlot{Layout.initialize(resources(),optional_route(),None{}),Layout.unknown_stamp()}}}
