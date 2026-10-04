import Base
import ./api.bend as A
import ./system.bend as S

def bad(-R: Type, read: R -> A.Token -> R & U32, r: R) -> R & U32:
  read(r, A.OtherResource{})
