import Base
import ./schema.bend as S
import ../../src/ecs/removals.bend as Rm
import ../../src/ecs/column.bend as Col

# A declared metadata reader has no component owner to give the public setter.
def overwrite(record: Rm.Record<S.Schema,S.AllToken>) -> Col.SwapOutcome<S.Schema,S.Owner>:
  Col.swap(~S.Schema,~S.Owner,record,1,None{})
