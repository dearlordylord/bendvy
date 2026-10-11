import Base
import ./resource-field-binding.bend as Binding
import ./resource-field.bend as Field
import ./owner-product.bend as Product
import ./ordinary-schema.bend as Schema
import ./ordinary-query-declaration.bend as Query
import ./inspector.bend as Inspector
import ./capabilities.bend as Cap

# Identity and physical path come from the same ordinary generated binding.
# The closed view remains trusted and must return its supplied affine owner.
type Read<-S:Data,-P:Type,-identity:Schema.Resource<S,P>,-H:Type,-V:Data> is Type:
  Read{operation:Cap.ValueRead<H,V>}
type Declaration<-S:Data,-H:Type,-Ops:Type> is Type:
  Declaration{grant:Ops,clauses:List<&2,Query.Clause<S>>}
def read_field(~S:Data,~P:Type,~identity:Schema.Resource<S,P>,~H:Type,~V:Data,value:Read<S,P,identity,H,V>) -> H -> H & V:
  match value:
    case Read{operation}:Cap.value_read_field(~H,~V,operation)
def get(~S:Data,~P:Type,~identity:Schema.Resource<S,P>,~H:Type,~V:Data,~value:Read<S,P,identity,H,V>,owner:H) -> H & V:
  read_field(~S,~P,~identity,~H,~V,value)(owner)
def bind(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<R,P,Rest>,~identity:Schema.Resource<S,P>,~binding:Binding.Binding<S,R,P,Rest,lens,identity>,~view:P -> P & V) -> Declaration<S,Inspector.Frame<S,C,R,E>,Read<S,P,identity,Inspector.Frame<S,C,R,E>,V>>:
  Declaration{Read{Inspector.read_resource(~S,~C,~R,~E,~V,~Field.project(~R,~P,~Rest,~V,~lens,~view))},[Query.Clause{Schema.resource_key(~S,~P,identity),Query.Read{}}]}
def grant(~S:Data,~H:Type,~Ops:Type,value:Declaration<S,H,Ops>) -> Ops:
  match value:
    case Declaration{grant,_}:grant
def clauses(~S:Data,~H:Type,~Ops:Type,value:Declaration<S,H,Ops>) -> List<&2,Query.Clause<S>>:
  match value:
    case Declaration{_,clauses}:clauses
