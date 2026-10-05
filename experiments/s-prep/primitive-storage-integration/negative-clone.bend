import Base
import ./storage.bend as S
import ./owners.bend as A
def bad(main: Array<Maybe<A.Motion>>) -> Array<Maybe<A.Motion>> & Array<Maybe<A.Motion>>:
  Array.clone(Maybe<A.Motion>,main)
