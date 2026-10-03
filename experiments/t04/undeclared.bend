import Base
import ./payload.bend as V
def bad(-M: Type, m: M) -> M & String:
  V.get(m)
