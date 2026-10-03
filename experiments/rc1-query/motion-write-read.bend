import Base
import ./api.bend as A
import ./schemas.bend as S
import ./system.bend as C

def bad(-P: Type, -M: Type, get: P -> S.MotionToken -> P & U32, aux: M -> M & Maybe<&2, S.Tag>, label: String, p: P, m: M) -> P & (M & String):
  (A.cell_set(S.MotionToken, p, S.Position{}, 99), (m, ""))
