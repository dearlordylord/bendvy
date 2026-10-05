import Base
import ./types.bend as T
import ./held-adapter.bend as HA
def bad(~Owner:Type,get:Owner -> T.PositionToken -> Owner & T.Access<T.PositionView>,owner:Owner) -> Owner:
  HA.motion_set_main0(owner,T.PositionToken{},0)
