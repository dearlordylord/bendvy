import Base
import ./core.bend as C
def bad(-T: Type, read: T -> C.Motion -> T & U32, t: T) -> T & U32:
  read(t, C.Motion{})
