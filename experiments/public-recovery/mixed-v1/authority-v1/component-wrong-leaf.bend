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
def rejected(~H:Type,~caps:F.Ops(~First)(H),owner:H,handle:W.Handle<First>,incoming:Maybe<Array<Array<U32>>>) -> O.ComponentAttempt<H,Array<Array<U32>>>:
  O.component_replace(~First,~Array<Array<U32>>,~Schema.first_identity(~First),~H,~F.second_cap(~First,~H,~caps),owner,handle,incoming)
