import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-declaration.bend as Identity
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-component-binding.bend as Component
import /workspace/formal-proofs/bendvy/src/ecs/resource-field-binding.bend as Resource
import /workspace/formal-proofs/bendvy/src/ecs/owner-product.bend as Product
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
# The physical product paths follow the ordinary component/resource schema tree.
# Applications supply identities and opaque-value projections, not debug lenses.
type Declarations<-S:Data,-Payload:Type,-Counter:Type> is Data:
  Declarations{component:Identity.Declaration<S,Payload>,resource:Schema.Resource<S,Counter>}
type Token<-S:Data,-Payload:Type> is Data:
  Token{}
def store(~S:Data,~Payload:Type) -> Type:
  Product.Owner<Col.Column<S,Payload>,Unit>
def resources(~Counter:Type) -> Type:
  Product.Owner<Unit,Counter>
def schema(~S:Data,~Payload:Type,~Counter:Type,declarations:Declarations<S,Payload,Counter>) -> Schema.Schema<S,store(~S,~Payload),resources(~Counter)>:
  match declarations:
    case Declarations{component,resource}:Schema.product(~S,~Col.Column<S,Payload>,~Unit,~Unit,~Counter,Schema.component(~S,~Payload,component),Schema.resource_schema(~S,~Counter,resource))
def component_take(~S:Data,~Payload:Type,value:store(~S,~Payload)) -> Unit & Col.Column<S,Payload>:
  Product.take(~Col.Column<S,Payload>,~Unit,Product.Left{},value)
def component_put(~S:Data,~Payload:Type,rest:Unit,value:Col.Column<S,Payload>) -> store(~S,~Payload):
  Product.put(~Col.Column<S,Payload>,~Unit,Product.Left{},rest,value)
def component_identity(~S:Data,~Payload:Type,~Counter:Type,declarations:Declarations<S,Payload,Counter>) -> Identity.Declaration<S,Payload>:
  match declarations:
    case Declarations{identity,_}:identity
def component_binding(~S:Data,~Payload:Type,~Counter:Type,~V:Data,~view:Payload -> Payload & V,~declarations:Declarations<S,Payload,Counter>) -> Component.Binding<S,store(~S,~Payload),Unit,Payload,V,Token<S,Payload>,component_take(~S,~Payload),component_put(~S,~Payload),view>:
  Component.bind(~S,~store(~S,~Payload),~Unit,~Payload,~V,~Token<S,Payload>,~component_take(~S,~Payload),~component_put(~S,~Payload),~view,component_identity(~S,~Payload,~Counter,declarations))
def resource_identity(~S:Data,~Payload:Type,~Counter:Type,declarations:Declarations<S,Payload,Counter>) -> Schema.Resource<S,Counter>:
  match declarations:
    case Declarations{_,identity}:identity
def counter_lens(~Counter:Type) -> Product.Lens<resources(~Counter),Counter,Unit>:
  Product.lens(~Unit,~Counter,~Product.Right{})
def resource_binding(~S:Data,~Payload:Type,~Counter:Type,~declarations:Declarations<S,Payload,Counter>) -> Resource.Binding<S,resources(~Counter),Counter,Unit,counter_lens(~Counter),resource_identity(~S,~Payload,~Counter,declarations)>:
  Resource.Binding{}
