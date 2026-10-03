import Base
import ./api.bend as A
import ./schemas.bend as S
import ./system.bend as C

def bad(c: A.Cell<S.MotionToken>) -> A.Cell<S.HealthToken> & U32:
  A.cell_get(S.HealthToken, c, S.HitPoints{})
