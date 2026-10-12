import Base
import ./ordinary-schema.bend as Schema
import ./resource-field-binding.bend as Tree
import ./owner-product.bend as Product
import ./ordinary-optional-resource.bend as O
# Same ordinary descriptor tree; its physical leaf stores an optional owner.
def leaf(~S:Data,~P:Type,+identity:Schema.Resource<S,P>) -> Tree.Built<S,O.Slot<S,P,identity>,Schema.Resource<S,P>>:
  Tree.Built{Schema.entries(~S,~Unit,~P,Schema.resource_schema(~S,~P,identity)),identity}
type Binding<-S:Data,-R:Type,-P:Type,-Rest:Type,-identity:Schema.Resource<S,P>,-lens:Product.Lens<R,O.Slot<S,P,identity>,Rest>> is Data:
  Binding{}
def bind(~S:Data,~R:Type,~P:Type,~Rest:Type,~identity:Schema.Resource<S,P>,~lens:Product.Lens<R,O.Slot<S,P,identity>,Rest>,~cursor:Tree.Cursor<S,R,O.Slot<S,P,identity>,Rest,Schema.Resource<S,P>,lens>) -> Binding<S,R,P,Rest,identity,lens>:
  Binding{}
