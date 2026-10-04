import Base
import ./owned-index-core.bend as A
def good(~P: Type, get: P -> P & String, p: P) -> P & String:
  get(p)
