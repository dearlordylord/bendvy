import Base
import ./owned-index-core.bend as A
def bad(~P: Type, get: P -> P & String, p: P) -> P:
  A.motion_set(p, 19)
