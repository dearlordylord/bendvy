import Base
import ./api.bend as A
import ./schemas.bend as S
import ./system.bend as C

def looked(-P: Type, -M: Type, result: A.World<S.MotionToken, S.TagCell> & A.LookupResult, m: M) -> P & (M & String):
  match result:
    case (w, _): (w, (m, ""))
def bad(-P: Type, -M: Type, get: P -> S.MotionToken -> P & U32, aux: M -> M & Maybe<&2, S.Tag>, label: String, p: P, m: M) -> P & (M & String):
  looked(P, M, A.lookup(~S.MotionToken, ~S.TagCell, ~Maybe<&2, S.Tag>, ~C.motion_read, ~S.tag_get, ~S.tag_has, A.Optional{}, "b", S.motion()), m)
