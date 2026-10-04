import Base
import ./core.bend as C
def retained(-T: Type, result: T & U32) -> T:
  match result:
    case (t, _): t
def bad(-T: Type, read: T -> C.Motion -> T & U32, t: T) -> T:
  retained(T, read(t, C.Motion{}))
