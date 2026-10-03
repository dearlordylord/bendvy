import Base
import ./api.bend as A

def good(c: A.ReadMotion) -> U32:
  A.read(c, A.Position{})
