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
def rejected(~H:Type,~caps:F.Ops(~First)(H),owner:H,incoming:Array<Array<U32>>) -> H:
  Resource.replace(~First,~Array<U32>,~Identity.resource(~First,~Array<Array<U32>>,"Wrong"),~H,~F.resource_cap(~First,~H,~caps),owner,incoming)
