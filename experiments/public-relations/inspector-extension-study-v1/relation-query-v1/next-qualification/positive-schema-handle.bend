import Base
import ../fixture-schema.bend as D
import ../core-v1/src/ecs/world.bend as W

def same_schema(target:W.Handle<D.Workshop>) -> W.Handle<D.Workshop>:
  target
