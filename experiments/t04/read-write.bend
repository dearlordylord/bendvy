import Base
import ./payload.bend as V
def bad(-M: Type, m: M) -> M:
  V.update(m, V.Items{}, 3)
