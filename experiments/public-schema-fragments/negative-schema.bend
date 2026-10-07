import Base
import ../../src/ecs/schema-fragments.bend as F
import fragment-left.bend as L

type First is Data:
  First{}
type Second is Data:
  Second{}
def invalid() -> F.Fragment<Second,L.Payload>:
  F.fragment(~Second,~L.Payload,[F.entry(~First,~L.Token,~L.Payload,L.declare(~First))],L.Payload{ALeaf{1}})
