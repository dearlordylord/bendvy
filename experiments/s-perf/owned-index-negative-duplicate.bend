import Base
import ./owned-index-core.bend as A
def bad(~P: Type, p: P) -> P & P:
  (p, p)
