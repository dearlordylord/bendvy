import Base
import ../library/types.bend as T
import ../library/payload.bend as Raw

def observe_get(result: T.Position & T.PositionView) -> T.PositionView:
  match result:
    case (_,view): view
def observe(result: T.Position & U32) -> T.PositionView:
  match result:
    case (owner,_): observe_get(Raw.position_get(owner))
def main() -> T.PositionView:
  observe(Raw.position_swap(T.Position{[3 : U32^2n],0},9))
