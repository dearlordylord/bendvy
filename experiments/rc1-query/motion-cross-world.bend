import Base
import ./api.bend as A
import ./schemas.bend as S
import ./system.bend as C

def bad() -> A.World<S.MotionToken, S.TagCell> & String:
  A.query(~S.MotionToken, ~S.TagCell, ~Maybe<&2, S.Tag>, ~C.motion_read, ~S.tag_get, ~S.tag_has, A.Optional{}, S.health())
