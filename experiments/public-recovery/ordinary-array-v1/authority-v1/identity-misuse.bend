import Base
import ../fixture.bend as F
import ../../../../src/ecs/ordinary-recoverable-array-resource.bend as O
import ../../../../src/ecs/ordinary-schema.bend as Schema
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/transaction.bend as T
import ../../../../src/ecs/recovery-journal.bend as Journal
import ../../../../src/ecs/recoverable-array.bend as A
type First is Data:
  First{}
type Other is Data:
  Other{}
def rejected(~H:Type,~caps:F.Ops(~First,H),owner:H,replacement:Array<Array<U32>>) -> H:
  O.replace(~First,~Array<U32>,~Schema.resource(~First,~Array<Array<U32>>,"OtherPayload"),~H,~caps,owner,replacement)
