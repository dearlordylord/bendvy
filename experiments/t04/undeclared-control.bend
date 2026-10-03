import Base
import ./payload.bend as V
def bad(-M: Type, get: M -> M & String, m: M) -> M & String:
  get(m)
