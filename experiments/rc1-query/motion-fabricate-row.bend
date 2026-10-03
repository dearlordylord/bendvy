import Base
import ./api.bend as A
import ./schemas.bend as S
import ./system.bend as C

def bad(-P: Type, -M: Type, get: P -> S.MotionToken -> P & U32, aux: M -> M & Maybe<&2, S.Tag>, label: String, p: P, m: M) -> P & (M & String):
  (A.Row{"detached", (A.Cell{99} : A.Cell<S.MotionToken>), S.TagCell{Some{S.Tag{}}}}, (m, ""))
