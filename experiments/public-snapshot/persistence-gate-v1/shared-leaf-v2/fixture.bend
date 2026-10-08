import Base
import ./gate.bend as G
import ./reference-source/canonical-component-declaration.bend as C
import ./reference-source/typed.bend as D

type Workshop is Data:
  Workshop{}
type Garden is Data:
  Garden{}
type Payload is Type:
  Payload{values:Array<U32>}
def declaration(~S:Data) -> C.Declaration<S,Payload>:
  C.component(~S,~Payload,"Payload")
def projected(values:Array<U32> & U32) -> Payload & D.Raw:
  match values:
    case (owner,value):(Payload{owner},D.Number{value})
def project(owner:Payload) -> Payload & D.Raw:
  match owner:
    case Payload{values}:projected(Array.get(values,0))
def ordinary(~S:Data,owner:Payload) -> Payload & G.Field:
  G.export_owner(~S,~Payload,~declaration(~S),G.persisted(~S,~Payload,~declaration(~S),D.Integer{},project),owner)
def omitted(~S:Data,owner:Payload) -> Payload & G.Field:
  G.export_owner(~S,~Payload,~declaration(~S),G.transient(~S,~Payload,~declaration(~S)),owner)
