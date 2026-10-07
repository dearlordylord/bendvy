import Base
import ./schema.bend as S
import ../../src/ecs/removals.bend as Rm
import ../../src/ecs/world.bend as W

type Other is Data:
  Other{}
def cross_schema(record: Rm.Record<S.Schema,S.AllToken>) -> Rm.Record<Other,S.AllToken>:
  record
