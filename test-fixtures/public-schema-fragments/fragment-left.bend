import Base
import ../../src/ecs/schema-fragments.bend as F

type Payload is Type:
  Payload{cells: Array<U32>}
type Token is Data:
  Token{}
def declare(~S: Data) -> F.Descriptor<S,Token,Payload>:
  F.Descriptor{F.Component{},"Position","Position"}
def fragment(~S: Data) -> F.Fragment<S,Payload>:
  F.fragment(~S,~Payload,[F.entry(~S,~Token,~Payload,declare(~S))],Payload{ANode{ALeaf{10},ALeaf{11}}})
