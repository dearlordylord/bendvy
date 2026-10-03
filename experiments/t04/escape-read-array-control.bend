import Base
import ./payload.bend as V
def bad(c: V.Payload) -> V.Payload & String:
  V.get(c)
