import Base
import ./alternatives.bend as V
def bad(a: Array<V.Box>) -> Array<V.Box> & V.Box:
  Array.get(V.Box, a, 0)
