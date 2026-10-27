import Base
import ./schema.bend as S
import ../../src/ecs/execution-composer-layout.bend as L

def cross(columns:L.columns(~S.SchemaA,S.layout_a())) -> L.columns(~S.SchemaB,S.layout_b()):
  columns
