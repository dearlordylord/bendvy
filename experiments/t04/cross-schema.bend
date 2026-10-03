import Base
import ./payload.bend as V
def bad(-M: Type, set: M -> V.Token -> U32 -> M, m: M) -> M:
  set(m, V.Foreign{}, 3)
