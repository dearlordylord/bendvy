import Base
import ./core.bend as C
def bad(-T: Type, t: T) -> T & U32:
  C.read(t, C.Motion{})
