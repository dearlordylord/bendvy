import Base
import ./core.bend as C
def bad(-T: Type, read: T -> C.Motion -> T & U32, t: T) -> T:
  C.write(t, C.Motion{}, 99)
