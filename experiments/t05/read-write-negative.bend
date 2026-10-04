import Base
import ./lifecycle.bend as L
import ../rc1-query/api.bend as A
import ../rc1-query/schemas.bend as S

def client(-P: Type, -M: Type, get: P -> S.MotionToken -> P & U32, aux: M -> M & L.TagData, p: P, m: M) -> P & (M & String):
  L.read_position(P, M, get(A.cell_set(S.MotionToken, p, S.Position{}, 99), S.Position{}), aux(m))
