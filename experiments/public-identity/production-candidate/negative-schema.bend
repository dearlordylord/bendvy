import Base
import ../../public-schedule-readers/schema.bend as S
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/component.bend as C

type Other is Data:
  Other{}
def cross(world:S.World(),handle:W.Handle<Other>) -> S.World() & C.Access<S.StockView>:
  S.get_stock(world,handle)
