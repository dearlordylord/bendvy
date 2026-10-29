import Base
import ./schema.bend as S
import ../../src/ecs/chunk-partition.bend as P
import ../../src/ecs/execution-composer-layout.bend as L

def duplicate(slice:P.Slice<S.SchemaA,L.Viewed<S.Position,U32>>) -> P.Slice<S.SchemaA,L.Viewed<S.Position,U32>> & P.Slice<S.SchemaA,L.Viewed<S.Position,U32>>:
  (slice,slice)
