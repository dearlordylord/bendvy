import Base
import ./core.bend as A

def client(-T: Type, get: T -> T & A.View, t: T) -> T & A.View:
  get(A.set(t, 99, 99, 99))
