import Base
import ./ordinary-schema.bend as Schema
import ./ordinary-declaration.bend as Identity
import ./ordinary-component-binding.bend as Component
import ./resource-field-binding.bend as Resource
import ./owner-product.bend as Product
import ./column.bend as Col
# The physical product paths follow the ordinary component/resource schema tree.
# Applications supply identities and opaque-value projections, not debug lenses.
# Trusted setup identities for this fixed one-component, one-resource schema.
type Declarations<-S:Data,-Payload:Type,-Counter:Type> is Data:
  Declarations{component:Identity.Declaration<S,Payload>,resource:Schema.Resource<S,Counter>}
# Nominal component-binding token; it carries no payload or runtime permission.
type Token<-S:Data,-Payload:Type> is Data:
  Token{}
# Physical component owner type for this fixed schema adapter.
def store(~S:Data,~Payload:Type) -> Type:
  Product.Owner<Col.Column<S,Payload>,Unit>
# Physical resource owner type for this fixed schema adapter.
def resources(~Counter:Type) -> Type:
  Product.Owner<Unit,Counter>
# Assemble the component/resource schema from their supplied identities.
# This adapter fixes product paths; it is not a general schema generator.
def schema(~S:Data,~Payload:Type,~Counter:Type,declarations:Declarations<S,Payload,Counter>) -> Schema.Schema<S,store(~S,~Payload),resources(~Counter)>:
  match declarations:
    case Declarations{component,resource}:Schema.product(~S,~Col.Column<S,Payload>,~Unit,~Unit,~Counter,Schema.component(~S,~Payload,component),Schema.resource_schema(~S,~Counter,resource))
# Trusted product projection: consume the store and return its remainder and
# component column for reassembly with component_put.
def component_take(~S:Data,~Payload:Type,value:store(~S,~Payload)) -> Unit & Col.Column<S,Payload>:
  Product.take(~Col.Column<S,Payload>,~Unit,Product.Left{},value)
# Reassemble the store from the projected remainder and component column.
def component_put(~S:Data,~Payload:Type,rest:Unit,value:Col.Column<S,Payload>) -> store(~S,~Payload):
  Product.put(~Col.Column<S,Payload>,~Unit,Product.Left{},rest,value)
# Recover the component declaration used by this schema adapter.
def component_identity(~S:Data,~Payload:Type,~Counter:Type,declarations:Declarations<S,Payload,Counter>) -> Identity.Declaration<S,Payload>:
  match declarations:
    case Declarations{identity,_}:identity
# Build the component binding for the fixed product path. The supplied view
# is a trusted affine payload projection returning an owner and detached Data;
# this constructor does not establish projection purity or owner identity.
def component_binding(~S:Data,~Payload:Type,~Counter:Type,~V:Data,~view:Payload -> Payload & V,~declarations:Declarations<S,Payload,Counter>) -> Component.Binding<S,store(~S,~Payload),Unit,Payload,V,Token<S,Payload>,component_take(~S,~Payload),component_put(~S,~Payload),view>:
  Component.bind(~S,~store(~S,~Payload),~Unit,~Payload,~V,~Token<S,Payload>,~component_take(~S,~Payload),~component_put(~S,~Payload),~view,component_identity(~S,~Payload,~Counter,declarations))
# Recover the resource declaration used by this schema adapter.
def resource_identity(~S:Data,~Payload:Type,~Counter:Type,declarations:Declarations<S,Payload,Counter>) -> Schema.Resource<S,Counter>:
  match declarations:
    case Declarations{_,identity}:identity
# Trusted lens selecting the resource in the fixed right product field.
def counter_lens(~Counter:Type) -> Product.Lens<resources(~Counter),Counter,Unit>:
  Product.lens(~Unit,~Counter,~Product.Right{})
# Build the resource binding from the fixed lens and supplied declaration.
# This setup binding does not itself grant a system read or write access.
def resource_binding(~S:Data,~Payload:Type,~Counter:Type,~declarations:Declarations<S,Payload,Counter>) -> Resource.Binding<S,resources(~Counter),Counter,Unit,counter_lens(~Counter),resource_identity(~S,~Payload,~Counter,declarations)>:
  Resource.Binding{}
