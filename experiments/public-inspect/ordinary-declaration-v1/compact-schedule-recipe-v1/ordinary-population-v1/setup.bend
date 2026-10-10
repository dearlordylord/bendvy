import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-declaration.bend as Identity
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-component-binding.bend as Component
import /workspace/formal-proofs/bendvy/src/ecs/resource-field-binding.bend as Resource
import /workspace/formal-proofs/bendvy/src/ecs/owner-product.bend as Product
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import provision.bend as Provision
# This normal physical setup generates both operational lenses and population.
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
def provision(~S:Data,~Payload:Type,~Counter:Type,declarations:Declarations<S,Payload,Counter>) -> Provision.Provision<S,store(~S,~Payload),resources(~Counter),empty(~S,~Payload),count(~S,~Payload)>:
  match declarations:
    case Declarations{component,resource,unqueried}:Provision.product(~S,~Col.Column<S,Payload>,~Unit,~rest(~S,~Payload),~Product.Owner<Unit,Counter>,~Provision.component_empty(~S,~Payload),~Provision.component_count(~S,~Payload),~tail_empty(~S,~Payload),~tail_count(~S,~Payload),Provision.component(~S,~Payload,component),Provision.product(~S,~Col.Column<S,Payload>,~Unit,~Unit,~Counter,~Provision.component_empty(~S,~Payload),~Provision.component_count(~S,~Payload),~Provision.resource_empty,~Provision.resource_count(~S),Provision.component(~S,~Payload,unqueried),Provision.resource(~S,~Counter,resource)))
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

def schema_returned(~S:Data,~Payload:Type,~Counter:Type,value:Provision.Provision<S,store(~S,~Payload),resources(~Counter),empty(~S,~Payload),count(~S,~Payload)>) -> Schema.Schema<S,store(~S,~Payload),resources(~Counter)>:
  match value:
    case Provision.Provision{schema}:schema
def schema(~S:Data,~Payload:Type,~Counter:Type,declarations:Declarations<S,Payload,Counter>) -> Schema.Schema<S,store(~S,~Payload),resources(~Counter)>:
  schema_returned(~S,~Payload,~Counter,provision(~S,~Payload,~Counter,declarations))
