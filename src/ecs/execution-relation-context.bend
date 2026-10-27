import Base
import ./execution-composer-layout.bend as Layout
import ./world.bend as W
import ./execution-resource-policy.bend as Policy
import ./execution-relation-store.bend as Store
import ./relation-types.bend as T
import ./execution-composer-schema.bend as Schema
import ./schema-fragments.bend as Fragment

# The full resource layout is known at ordinary schema construction. Retaining
# its forward equality avoids trying to recover a layout from an affine owner.
type Context<-S:Data,-WR:Type,-resources:Layout.Layout,-same:{WR == Layout.resources(~S,resources) : Type}> is Data:
  Context{namespace:U32}
type Bound<-S:Data,-WR:Type,-resources:Layout.Layout,-same:{WR == Layout.resources(~S,resources) : Type},-Application:Type> is Type:
  Bound{context:Context<S,WR,resources,same>,application:Application}
type RunReport<-Report:Data> is Data:
  RunReported{report:Report}
  ContextRefused{}
type Binding<-S:Data,-WR:Type,-resources:Layout.Layout,-same:{WR == Layout.resources(~S,resources) : Type},-route:Layout.Route,-descriptor:T.Descriptor<S>,-payload:{Layout.payload(resources,route) == Store.Store<S,descriptor> : Type},-view:{Layout.view(resources,route) == Store.View<S,descriptor> : Data},-protected:{Layout.policy(resources,route) == Policy.ProtectedRelation{S,descriptor} : Policy.Policy}> is Data:
  Binding{context:Context<S,WR,resources,same>}
def captured(~S:Data,~C:Type,~WR:Type,~E:Data,~resources:Layout.Layout,~same:{WR == Layout.resources(~S,resources) : Type},result:W.World<S,C,WR,E> & U32) -> W.World<S,C,WR,E> & Context<S,WR,resources,same>:
  match result:
    case (world,namespace):(world,Context{namespace})
def capture(~S:Data,~C:Type,~WR:Type,~E:Data,~resources:Layout.Layout,~same:{WR == Layout.resources(~S,resources) : Type},world:W.World<S,C,WR,E>) -> W.World<S,C,WR,E> & Context<S,WR,resources,same>:
  captured(~S,~C,~WR,~E,~resources,~same,W.namespace(~S,~C,~WR,~E,world))
def checked(~S:Data,~C:Type,~WR:Type,~E:Data,~resources:Layout.Layout,~same:{WR == Layout.resources(~S,resources) : Type},context:Context<S,WR,resources,same>,result:W.World<S,C,WR,E> & U32) -> W.World<S,C,WR,E> & Bool:
  match context result:
    case Context{expected}, (world,actual):(world,U32.is_eq(expected,actual))
# The existing pending/admission path calls this before advancing its clock.
def matches(~S:Data,~C:Type,~WR:Type,~E:Data,~resources:Layout.Layout,~same:{WR == Layout.resources(~S,resources) : Type},context:Context<S,WR,resources,same>,world:W.World<S,C,WR,E>) -> W.World<S,C,WR,E> & Bool:
  checked(~S,~C,~WR,~E,~resources,~same,context,W.namespace(~S,~C,~WR,~E,world))
type Initialization<-S:Data,-components:Layout.Layout,-resources:Layout.Layout,-E:Data> is Type:
  ContextCreated{factory:W.Factory,world:W.World<S,Layout.columns(~S,components),Layout.resources(~S,resources),E>,context:Context<S,Layout.resources(~S,resources),resources,{==}>}
  SchemaRefused{factory:W.Factory,owners:Layout.resources(~S,resources),error:Fragment.Error}
  NamespaceRefused{factory:W.Factory,owners:Layout.resources(~S,resources)}
def initialized(~S:Data,~components:Layout.Layout,~resources:Layout.Layout,~E:Data,factory:W.Factory,result:W.World<S,Layout.columns(~S,components),Layout.resources(~S,resources),E> & Context<S,Layout.resources(~S,resources),resources,{==}>) -> Initialization<S,components,resources,E>:
  match result:
    case (world,context):ContextCreated{factory,world,context}
def from_schema(~S:Data,~components:Layout.Layout,~resources:Layout.Layout,~E:Data,result:Schema.Initialized<S,components,resources,E>) -> Initialization<S,components,resources,E>:
  match result:
    case Schema.SchemaCreated{factory,world}:initialized(~S,~components,~resources,~E,factory,capture(~S,~Layout.columns(~S,components),~Layout.resources(~S,resources),~E,~resources,~{==},world))
    case Schema.SchemaRefused{factory,owners,error}:SchemaRefused{factory,owners,error}
    case Schema.NamespaceRefused{factory,owners}:NamespaceRefused{factory,owners}
