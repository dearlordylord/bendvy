import Base
import ./schema.bend as S
import ../../src/ecs/execution-query-slice.bend as Slice
import ../../src/ecs/execution-composer-layout.bend as L

def cross(slot:Slice.Slot<S.SchemaA,L.Viewed<S.Position,U32>,S.positions()>) -> Slice.Slot<S.SchemaA,L.Viewed<S.Position,U32>,S.changed_origin()>:
  slot
