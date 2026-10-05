import Base
import ./types.bend as T
def bad(~Owner:Type,get:Owner -> T.PositionToken -> Owner & T.Access<T.PositionView>,owner:Owner) -> Owner & T.Access<T.PositionView>:
  get(owner,T.VitalsToken{})
