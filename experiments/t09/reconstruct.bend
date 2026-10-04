import Base
import ./api.bend as A
import ./system.bend as S

def bad(-R: Type, -r: R) -> R:
  A.Cell{42}
