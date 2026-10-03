import Base
import ./api.bend as A
import ./schemas.bend as S
import ./system.bend as C

def bad(c: A.Cell<S.HealthToken>) -> A.Cell<S.MotionToken> & U32:
  A.cell_get(S.MotionToken, c, S.Position{})
