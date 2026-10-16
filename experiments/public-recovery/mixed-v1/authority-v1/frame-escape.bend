import Base
import ../fixture.bend as F
import ../../heterogeneous-v1/schema.bend as Schema
import ../../../../src/ecs/ordinary-recoverable-component-capture.bend as O
import ../../../../src/ecs/ordinary-recoverable-array-resource.bend as Resource
import ../../../../src/ecs/ordinary-schema.bend as Identity
import ../../../../src/ecs/ordinary-declaration.bend as D
import ../../../../src/ecs/world.bend as W
type First is Data:First{}
type Other is Data:Other{}
def escaped(~H:Type,~caps:F.Ops(~First)(H),owner:H) -> Resource.Frame<F.State(~First),F.Recovery(~First)>:
  owner
