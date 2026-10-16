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
def rejected(~H:Type,~caps:F.Ops(~First)(H),owner:H,incoming:Array<Array<U32>>) -> F.World(~First) & Array<Array<U32>>:
  W.replace_resource(~First,~Schema.Store(~First),~Array<Array<U32>>,~Unit,owner,incoming)
