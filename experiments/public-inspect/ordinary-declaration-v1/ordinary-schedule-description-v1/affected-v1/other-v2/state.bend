import Base
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/schema-fragments.bend as Fragment
import /workspace/formal-proofs/bendvy/src/ecs/persistence-declaration.bend as Persist
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-binding-provision.bend as Provision
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-component-binding.bend as Binding
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-declaration.bend as Identity
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as Cmp
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema-dump.bend as DumpProvision
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-dump.bend as Dump
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-population.bend as Population
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schema.bend as SchemaApp
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-records.bend as Leaf
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-dump-filter.bend as Filter
import /workspace/formal-proofs/bendvy-worktrees/ordinary-schedule-debug-v1/experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/ordinary-schema-debug-v1/refusal-preservation-v1/public-successor/consumer/owner-observer.bend as O
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-service-declaration.bend as Service
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as Machine
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-machine-declaration.bend as MachineDeclaration
import /workspace/formal-proofs/bendvy/src/ecs/owner-product.bend as Product
import /workspace/formal-proofs/bendvy/src/ecs/resource-field-binding.bend as ResourceBinding
import /workspace/formal-proofs/bendvy/src/ecs/event-publication.bend as Publication
type Other is Data:
  Other{}
type First is Data:
  First{}
type Second is Data:
  Second{}
type Store is Type:
  Store{first:Col.Column<Other,Array<U32>>,second:Col.Column<Other,Array<U32>>,sibling:Array<U32>}
type Rest is Type:
  Rest{column:Col.Column<Other,Array<U32>>,sibling:Array<U32>}
def first_take(store:Store) -> Rest & Col.Column<Other,Array<U32>>:
  match store:
    case Store{first,second,sibling}:(Rest{second,sibling},first)
def first_put(rest:Rest,column:Col.Column<Other,Array<U32>>) -> Store:
  match rest:
    case Rest{second,sibling}:Store{column,second,sibling}
def second_take(store:Store) -> Rest & Col.Column<Other,Array<U32>>:
  match store:
    case Store{first,second,sibling}:(Rest{first,sibling},second)
def second_put(rest:Rest,column:Col.Column<Other,Array<U32>>) -> Store:
  match rest:
    case Rest{first,sibling}:Store{first,column,sibling}
def view(value:Array<U32>) -> Array<U32> & U32:
  Array.get(U32,value,0)
def empty(unit:Unit) -> Store:Store{Col.empty(~Other,~Array<U32>),Col.empty(~Other,~Array<U32>),ANode{ALeaf{91},ALeaf{92}}}
def first_binding() -> Binding.Binding<Other,Store,Rest,Array<U32>,U32,First,first_take,first_put,view>:Binding.bind(~Other,~Store,~Rest,~Array<U32>,~U32,~First,~first_take,~first_put,~view,Identity.component(~Other,~Array<U32>,"First"))
def first_family() -> Cmp.Family<Other,Store,Rest,Array<U32>,U32,First,first_take,first_put,view>:Binding.family(~Other,~Store,~Rest,~Array<U32>,~U32,~First,~first_take,~first_put,~view,first_binding())
def first_count() -> Store -> List<&2,W.Handle<Other>> -> Store & List<&2,Maybe<&2,U32>>:Provision.count(~Other,~Store,~Rest,~Array<U32>,~first_take,~first_put)
def first_values() -> Store -> U32 -> Store & List<&2,Maybe<&2,String>>:Provision.values(~Other,~Store,~Rest,~Array<U32>,~U32,~first_take,~first_put,~view,~U32.show)
def first_provision() -> DumpProvision.Provision<Other,Store,Unit,empty,first_count(),first_values(),Provision.no_resource>:Provision.component_plain(~Other,~Store,~Rest,~Array<U32>,~U32,~First,~first_take,~first_put,~view,~U32.show,~empty,~first_binding(),Persist.plain(~Other,~Array<U32>,~Binding.identity(~Other,~Store,~Rest,~Array<U32>,~U32,~First,~first_take,~first_put,~view,first_binding())))
def second_binding() -> Binding.Binding<Other,Store,Rest,Array<U32>,U32,Second,second_take,second_put,view>:Binding.bind(~Other,~Store,~Rest,~Array<U32>,~U32,~Second,~second_take,~second_put,~view,Identity.component(~Other,~Array<U32>,"Second"))
def second_family() -> Cmp.Family<Other,Store,Rest,Array<U32>,U32,Second,second_take,second_put,view>:Binding.family(~Other,~Store,~Rest,~Array<U32>,~U32,~Second,~second_take,~second_put,~view,second_binding())
def second_count() -> Store -> List<&2,W.Handle<Other>> -> Store & List<&2,Maybe<&2,U32>>:Provision.count(~Other,~Store,~Rest,~Array<U32>,~second_take,~second_put)
def second_values() -> Store -> U32 -> Store & List<&2,Maybe<&2,String>>:Provision.values(~Other,~Store,~Rest,~Array<U32>,~U32,~second_take,~second_put,~view,~U32.show)
def second_provision() -> DumpProvision.Provision<Other,Store,Unit,empty,second_count(),second_values(),Provision.no_resource>:Provision.component_transient(~Other,~Store,~Rest,~Array<U32>,~U32,~Second,~second_take,~second_put,~view,~U32.show,~empty,~second_binding(),Persist.transient(~Other,~Array<U32>,~Binding.identity(~Other,~Store,~Rest,~Array<U32>,~U32,~Second,~second_take,~second_put,~view,second_binding())))
def component_counts() -> Store -> List<&2,W.Handle<Other>> -> Store & List<&2,Maybe<&2,U32>>:Provision.append_count(~Other,~Store,~first_count(),~second_count())
def component_values() -> Store -> U32 -> Store & List<&2,Maybe<&2,String>>:Provision.append_values(~Store,~first_values(),~second_values())
def resource_prefix() -> Unit -> Unit & List<&2,Maybe<&2,String>>:Provision.append_resources(~Provision.no_resource,~Provision.no_resource)
def component_provision() -> DumpProvision.Provision<Other,Store,Unit,empty,component_counts(),component_values(),resource_prefix()>:Provision.append(~Other,~Store,~empty,~first_count(),~second_count(),~first_values(),~second_values(),~Provision.no_resource,~Provision.no_resource,first_provision(),second_provision())
type FirstEvent is Data:FirstEvent{value:U32}
type SecondEvent is Data:SecondEvent{value:Bool}
type UnusedEvent is Data:UnusedEvent{value:U32}
def PairEvents() -> Data:Publication.Publication<FirstEvent,SecondEvent>
def Events() -> Data:Publication.Publication<PairEvents(),UnusedEvent>
type Mode is Data:Mode{}
type Resources is Type:
  Resources{clock:Service.Slot<Array<U32>>,machine:Machine.Slot<Other,Mode,U32>,inventory:Array<U32>,sibling:Array<U32>,barriers:U32}
type ClockRest is Type:
  ClockRest{machine:Machine.Slot<Other,Mode,U32>,inventory:Array<U32>,sibling:Array<U32>,barriers:U32}
def clock_take(value:Resources) -> ClockRest & Service.Slot<Array<U32>>:
  match value:
    case Resources{clock,machine,inventory,sibling,barriers}:(ClockRest{machine,inventory,sibling,barriers},clock)
def clock_put(rest:ClockRest,clock:Service.Slot<Array<U32>>) -> Resources:
  match rest:
    case ClockRest{machine,inventory,sibling,barriers}:Resources{clock,machine,inventory,sibling,barriers}
def incremented(result:Array<U32> & U32) -> Array<U32>:
  match result:
    case (owner,value):Array.set(U32,owner,0,U32.add(value,1))
def clock_call(owner:Array<U32>) -> Array<U32>:incremented(Array.get(U32,owner,0))
def clock_declaration() -> Service.Declaration<Other,Resources,Array<U32>,ClockRest,clock_take,clock_put,clock_call>:
  Service.declare(~Other,~Resources,~Array<U32>,~ClockRest,~clock_take,~clock_put,~clock_call,1,"Clock")
def machine_take(value:Resources) -> Resources & Machine.Slot<Other,Mode,U32>:
  match value:
    case Resources{clock,+machine,inventory,sibling,barriers}:(Resources{clock,machine,inventory,sibling,barriers},machine)
def machine_put(value:Resources,machine:Machine.Slot<Other,Mode,U32>) -> Resources:
  match value:
    case Resources{clock,_,inventory,sibling,barriers}:Resources{clock,machine,inventory,sibling,barriers}
def mode() -> MachineDeclaration.Declaration<Other,Mode,U32,Resources,machine_take>:
  MachineDeclaration.declared(~Other,~Mode,~U32,~Resources,~machine_take,"Mode",[3,4])
type InventoryRest is Type:
  InventoryRest{clock:Service.Slot<Array<U32>>,machine:Machine.Slot<Other,Mode,U32>,sibling:Array<U32>,barriers:U32}
def inventory_take(value:Resources) -> InventoryRest & Array<U32>:
  match value:
    case Resources{clock,machine,inventory,sibling,barriers}:(InventoryRest{clock,machine,sibling,barriers},inventory)
def inventory_put(rest:InventoryRest,inventory:Array<U32>) -> Resources:
  match rest:
    case InventoryRest{clock,machine,sibling,barriers}:Resources{clock,machine,inventory,sibling,barriers}
def inventory_lens() -> Product.Lens<Resources,Array<U32>,InventoryRest>:Product.Lens{inventory_take,inventory_put}
def inventory_identity() -> Schema.Resource<Other,Array<U32>>:Schema.resource(~Other,~Array<U32>,"Inventory")
def inventory_binding() -> ResourceBinding.Binding<Other,Resources,Array<U32>,InventoryRest,inventory_lens(),inventory_identity()>:
  ResourceBinding.bind(~Other,~Resources,~Array<U32>,~InventoryRest,~inventory_lens(),~ResourceBinding.Cursor{inventory_identity()})
def initial_resources() -> Resources:
  Resources{Service.Ready{ANode{ALeaf{11},ALeaf{12}}},Machine.Present{3,Machine.NoPending{},None{},False{}},ANode{ALeaf{81},ALeaf{82}},ANode{ALeaf{71},ALeaf{72}},0}
def count() -> Store -> List<&2,W.Handle<Other>> -> Store & List<&2,Maybe<&2,U32>>:Provision.resource_count(~Other,~Store,~component_counts())
def values() -> Store -> U32 -> Store & List<&2,Maybe<&2,String>>:Provision.resource_values(~Store,~component_values())
def inventory_rendered(clock:Service.Slot<Array<U32>>,machine:Machine.Slot<Other,Mode,U32>,sibling:Array<U32>,barriers:U32,result:Array<U32> & String) -> Resources & String:
  match result:
    case (inventory,text):(Resources{clock,machine,inventory,sibling,barriers},text)
def inventory_text(value:Resources) -> Resources & String:
  match value:
    case Resources{clock,machine,inventory,sibling,barriers}:inventory_rendered(clock,machine,sibling,barriers,O.u32_array(inventory))
def resources() -> Resources -> Resources & List<&2,Maybe<&2,String>>:Provision.resources(~Resources,~resource_prefix(),~inventory_text)
def resource_identity() -> Identity.Declaration<Other,Resources>:Identity.component(~Other,~Resources,Schema.resource_key(~Other,~Array<U32>,inventory_identity()))
def resource_projected(clock:Service.Slot<Array<U32>>,machine:Machine.Slot<Other,Mode,U32>,sibling:Array<U32>,barriers:U32,result:Array<U32> & U32) -> Resources & D.Raw:
  match result:
    case (inventory,value):(Resources{clock,machine,inventory,sibling,barriers},D.Number{value})
def resource_project(value:Resources) -> Resources & D.Raw:
  match value:
    case Resources{clock,machine,inventory,sibling,barriers}:resource_projected(clock,machine,sibling,barriers,view(inventory))
def resource_extension() -> Persist.Constructed<Other,Resources,resource_identity(),resource_project>:
  Persist.constructed(~Other,~Resources,~resource_identity(),~resource_project,D.Integer{})
def provision() -> DumpProvision.Provision<Other,Store,Resources,empty,count(),values(),resources()>:
  Provision.with_resource_constructed(~Other,~Store,~Resources,~empty,~component_counts(),~component_values(),~resource_prefix(),~inventory_text,~resource_identity(),~resource_project,resource_extension(),component_provision())
def World() -> Type:W.World<Other,Store,Resources,Events()>
