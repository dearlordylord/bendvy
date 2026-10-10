import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-declaration.bend as Identity
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-component-binding.bend as Component
import /workspace/formal-proofs/bendvy/src/ecs/resource-field-binding.bend as Resource
import /workspace/formal-proofs/bendvy/src/ecs/owner-product.bend as Product
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema-provision.bend as Provision
import ./provision.bend as DumpProvision
import ./builtin.bend as Builtin
# Same normal declarations generate operational lenses and dump traversal.
type Declarations<-S:Data,-Payload:Type,-Counter:Type> is Data:
  Declarations{component:Identity.Declaration<S,Payload>,resource:Schema.Resource<S,Counter>,unqueried:Identity.Declaration<S,Payload>}
type Token<-S:Data,-Payload:Type> is Data:
  Token{}
def rest(~S:Data,~Payload:Type) -> Type:Product.Owner<Col.Column<S,Payload>,Unit>
def store(~S:Data,~Payload:Type) -> Type:Product.Owner<Col.Column<S,Payload>,rest(~S,~Payload)>
def resources(~Counter:Type) -> Type:Product.Owner<Unit,Product.Owner<Unit,Counter>>
def tail_count(~S:Data,~Payload:Type) -> rest(~S,~Payload) -> List<&2,W.Handle<S>> -> rest(~S,~Payload) & List<&2,Maybe<&2,U32>>:
  Provision.product_count(~S,~Col.Column<S,Payload>,~Unit,~Provision.component_count(~S,~Payload),~Provision.resource_count(~S))
def count(~S:Data,~Payload:Type) -> store(~S,~Payload) -> List<&2,W.Handle<S>> -> store(~S,~Payload) & List<&2,Maybe<&2,U32>>:
  Provision.product_count(~S,~Col.Column<S,Payload>,~rest(~S,~Payload),~Provision.component_count(~S,~Payload),~tail_count(~S,~Payload))
def tail_empty(~S:Data,~Payload:Type) -> Unit -> rest(~S,~Payload):
  Provision.product_empty(~Col.Column<S,Payload>,~Unit,~Provision.component_empty(~S,~Payload),~Provision.resource_empty)
def empty(~S:Data,~Payload:Type) -> Unit -> store(~S,~Payload):
  Provision.product_empty(~Col.Column<S,Payload>,~rest(~S,~Payload),~Provision.component_empty(~S,~Payload),~tail_empty(~S,~Payload))
def component_take(~S:Data,~Payload:Type,value:store(~S,~Payload)) -> rest(~S,~Payload) & Col.Column<S,Payload>:
  Product.take(~Col.Column<S,Payload>,~rest(~S,~Payload),Product.Left{},value)
def component_put(~S:Data,~Payload:Type,remainder:rest(~S,~Payload),value:Col.Column<S,Payload>) -> store(~S,~Payload):
  Product.put(~Col.Column<S,Payload>,~rest(~S,~Payload),Product.Left{},remainder,value)
def component_identity(~S:Data,~Payload:Type,~Counter:Type,declarations:Declarations<S,Payload,Counter>) -> Identity.Declaration<S,Payload>:
  match declarations:
    case Declarations{identity,_,_}:identity
def component_binding(~S:Data,~Payload:Type,~Counter:Type,~V:Data,~view:Payload -> Payload & V,~declarations:Declarations<S,Payload,Counter>) -> Component.Binding<S,store(~S,~Payload),rest(~S,~Payload),Payload,V,Token<S,Payload>,component_take(~S,~Payload),component_put(~S,~Payload),view>:
  Component.bind(~S,~store(~S,~Payload),~rest(~S,~Payload),~Payload,~V,~Token<S,Payload>,~component_take(~S,~Payload),~component_put(~S,~Payload),~view,component_identity(~S,~Payload,~Counter,declarations))
def resource_identity(~S:Data,~Payload:Type,~Counter:Type,declarations:Declarations<S,Payload,Counter>) -> Schema.Resource<S,Counter>:
  match declarations:
    case Declarations{_,identity,_}:identity
def counter_lens(~Counter:Type) -> Product.Lens<resources(~Counter),Counter,Unit & Unit>:
  Product.compose(~resources(~Counter),~Product.Owner<Unit,Counter>,~Unit,~Counter,~Unit,~Product.lens(~Unit,~Product.Owner<Unit,Counter>,~Product.Right{}),~Product.lens(~Unit,~Counter,~Product.Right{}))
def resource_binding(~S:Data,~Payload:Type,~Counter:Type,~declarations:Declarations<S,Payload,Counter>) -> Resource.Binding<S,resources(~Counter),Counter,Unit & Unit,counter_lens(~Counter),resource_identity(~S,~Payload,~Counter,declarations)>:
  Resource.Binding{}

def tail_components(~S:Data) -> rest(~S,~Array<U32>) -> U32 -> rest(~S,~Array<U32>) & List<&2,Maybe<&2,String>>:
  DumpProvision.product_components(~Col.Column<S,Array<U32>>,~Unit,~DumpProvision.component_read(~S,~Array<U32>,~Builtin.array),~DumpProvision.resource_components)
def components(~S:Data) -> store(~S,~Array<U32>) -> U32 -> store(~S,~Array<U32>) & List<&2,Maybe<&2,String>>:
  DumpProvision.product_components(~Col.Column<S,Array<U32>>,~rest(~S,~Array<U32>),~DumpProvision.component_read(~S,~Array<U32>,~Builtin.array),~tail_components(~S))
def tail_resources(~S:Data) -> Product.Owner<Unit,Array<U32>> -> Product.Owner<Unit,Array<U32>> & List<&2,Maybe<&2,String>>:
  DumpProvision.product_resources(~Unit,~Array<U32>,~DumpProvision.component_resources,~DumpProvision.resource_read(~Array<U32>,~Builtin.array))
def resource_values(~S:Data) -> resources(~Array<U32>) -> resources(~Array<U32>) & List<&2,Maybe<&2,String>>:
  DumpProvision.product_resources(~Unit,~Product.Owner<Unit,Array<U32>>,~DumpProvision.component_resources,~tail_resources(~S))
def dump_provision(~S:Data,declarations:Declarations<S,Array<U32>,Array<U32>>) -> DumpProvision.Provision<S,store(~S,~Array<U32>),resources(~Array<U32>),empty(~S,~Array<U32>),count(~S,~Array<U32>),components(~S),resource_values(~S)>:
  match declarations:
    case Declarations{component,resource,unqueried}:DumpProvision.product(~S,~Col.Column<S,Array<U32>>,~Unit,~rest(~S,~Array<U32>),~Product.Owner<Unit,Array<U32>>,~Provision.component_empty(~S,~Array<U32>),~Provision.component_count(~S,~Array<U32>),~DumpProvision.component_read(~S,~Array<U32>,~Builtin.array),~DumpProvision.component_resources,~tail_empty(~S,~Array<U32>),~tail_count(~S,~Array<U32>),~tail_components(~S),~tail_resources(~S),DumpProvision.array_component(~S,component),DumpProvision.product(~S,~Col.Column<S,Array<U32>>,~Unit,~Unit,~Array<U32>,~Provision.component_empty(~S,~Array<U32>),~Provision.component_count(~S,~Array<U32>),~DumpProvision.component_read(~S,~Array<U32>,~Builtin.array),~DumpProvision.component_resources,~Provision.resource_empty,~Provision.resource_count(~S),~DumpProvision.resource_components,~DumpProvision.resource_read(~Array<U32>,~Builtin.array),DumpProvision.array_component(~S,unqueried),DumpProvision.array_resource(~S,resource)))
def schema_returned(~S:Data,value:DumpProvision.Provision<S,store(~S,~Array<U32>),resources(~Array<U32>),empty(~S,~Array<U32>),count(~S,~Array<U32>),components(~S),resource_values(~S)>) -> Schema.Schema<S,store(~S,~Array<U32>),resources(~Array<U32>)>:
  match value:
    case DumpProvision.Provision{Provision.Provision{schema}}:schema
def schema(~S:Data,declarations:Declarations<S,Array<U32>,Array<U32>>) -> Schema.Schema<S,store(~S,~Array<U32>),resources(~Array<U32>)>:
  schema_returned(~S,dump_provision(~S,declarations))
def unqueried_identity(~S:Data,~Payload:Type,~Counter:Type,declarations:Declarations<S,Payload,Counter>) -> Identity.Declaration<S,Payload>:
  match declarations:
    case Declarations{_,_,identity}:identity
