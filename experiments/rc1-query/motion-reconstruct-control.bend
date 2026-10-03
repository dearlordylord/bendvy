import Base
import ./api.bend as A
import ./schemas.bend as S
import ./system.bend as C

def forge(-P: Type, -M: Type, result: P & U32, m: M) -> P & (M & String):
  match result:
    case (p, x): (p, (m, U32.show(x)))
def bad(-P: Type, -M: Type, get: P -> S.MotionToken -> P & U32, aux: M -> M & Maybe<&2, S.Tag>, label: String, p: P, m: M) -> P & (M & String):
  forge(P, M, get(p, S.Position{}), m)
