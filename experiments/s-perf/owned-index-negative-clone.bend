import Base
import ./owned-index-core.bend as A
def bad(col: Array<Maybe<A.Motion>>) -> Array<Maybe<A.Motion>> & Array<Maybe<A.Motion>>:
  Array.clone(Maybe<A.Motion>, col)
