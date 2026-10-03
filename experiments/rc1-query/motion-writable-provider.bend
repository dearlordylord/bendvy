import Base
import ./api.bend as A
import ./schemas.bend as S
import ./system.bend as C

def nested(-P: Type, -M: Type, result: A.World<S.MotionToken, S.TagCell> & String, m: M) -> P & (M & String):
  match result:
    case (w, text): (w, (m, text))
def bad(-P: Type, -M: Type, get: P -> S.MotionToken -> P & U32, aux: M -> M & Maybe<&2, S.Tag>, label: String, p: P, m: M) -> P & (M & String):
  nested(P, M, A.writable(~S.MotionToken, ~S.TagCell, ~Maybe<&2, S.Tag>, ~C.motion_step, ~S.tag_get, S.motion()), m)
