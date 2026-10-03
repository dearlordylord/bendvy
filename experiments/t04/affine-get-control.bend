import Base
import ./alternatives.bend as V
def bad(a: Array<V.Box>) -> Array<V.Box> & V.Box:
  Array.swap(V.Box, a, 0, V.Box{0})
