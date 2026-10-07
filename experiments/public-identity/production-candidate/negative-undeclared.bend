import Base
import ../../../src/ecs/world.bend as W
import ../../public-schedule-readers/schema.bend as S
def access(~H:Type,ctx:H) -> H & List<&2,W.Handle<S.Schema>>:
  W.handles(~S.Schema,~S.Store,~Unit,~S.Notice,ctx)
