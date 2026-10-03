import Base
import ./api.bend as A
import ./schemas.bend as S
import ./system.bend as C

def bad(-P: Type, -M: Type, get: P -> S.MotionToken -> P & U32, set: P -> S.MotionToken -> U32 -> P, after: P -> S.MotionToken -> P & U32, aux: M -> M & Maybe<&2, S.Tag>, label: String, p: P, m: M) -> P & (M & String):
  (A.cell_set(S.MotionToken, A.Cell{0}, S.Position{}, 99), (m, ""))
