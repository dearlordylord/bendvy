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
def positive(registry:F.Registry(~First),world:W.World<First,Unit,Array<Array<U32>>,Unit>,args:F.Args) -> O.Run<W.World<First,Unit,Array<Array<U32>>,Unit>,F.Registry(~First),F.Args,F.Error,F.Output,Array<U32>>:
  F.run(~First,registry,world,args)
