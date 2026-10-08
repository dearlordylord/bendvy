import Base
import ../fixture-schema.bend as D
import ../core-v1/src/ecs/world.bend as W

def wrong_schema(target:W.Handle<D.Garden>) -> W.Handle<D.Workshop>:
  target
