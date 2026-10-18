import Base
import ./ordinary-schema.bend as Schema
import ./resource-field-binding.bend as Tree
import ./owner-product.bend as Product
import ./ordinary-optional-resource.bend as O
# Same original descriptor, with a storage index tied to the exact identity.
type Index<-S:Data,-P:Type,-identity:Schema.Resource<S,P>> is Data:
  Index{}
def leaf(~S:Data,~P:Type,+identity:Schema.Resource<S,P>) -> Tree.Built<S,O.Slot<S,P,identity>,Index<S,P,identity>>:
  Tree.Built{Schema.entries(~S,~Unit,~P,Schema.resource_schema(~S,~P,identity)),Index{}}
type Binding<-S:Data,-R:Type,-P:Type,-Rest:Type,-identity:Schema.Resource<S,P>,-lens:Product.Lens<R,O.Slot<S,P,identity>,Rest>> is Data:
  Binding{}
def bind(~S:Data,~R:Type,~P:Type,~Rest:Type,~identity:Schema.Resource<S,P>,~lens:Product.Lens<R,O.Slot<S,P,identity>,Rest>,~cursor:Tree.Cursor<S,R,O.Slot<S,P,identity>,Rest,Index<S,P,identity>,lens>) -> Binding<S,R,P,Rest,identity,lens>:
  Binding{}
