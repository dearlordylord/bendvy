import Base
import ./lifecycle.bend as L
import ./fixture.bend as F
import ../rc1-query/api.bend as A
import ../rc1-query/schemas.bend as S

def reserved_collision(+foreign: L.Handle<S.MotionToken>, result: L.World<S.MotionToken> & Maybe<&2, L.Handle<S.MotionToken>>) -> String:
  match result:
    case (w, _): F.lookup_text(L.lookup(A.Required{}, L.flush(~S.MotionToken, w), foreign))
def created_collision(foreign: L.Handle<S.MotionToken>, result: L.Factory & Maybe<&1, L.World<S.MotionToken>>) -> String:
  match result:
    case (_, Some{w}): reserved_collision(foreign, L.reserve(~S.MotionToken, w, "local", 7))
    case (_, None{}): "factory-exhausted"
def reserved_foreign(f: L.Factory, result: L.World<S.MotionToken> & Maybe<&2, L.Handle<S.MotionToken>>) -> String:
  match result:
    case (_, Some{h}): created_collision(h, L.create(~S.MotionToken, f))
    case (_, None{}): "entity-exhausted"
def created_foreign(result: L.Factory & Maybe<&1, L.World<S.MotionToken>>) -> String:
  match result:
    case (f, Some{w}): reserved_foreign(f, L.reserve(~S.MotionToken, w, "foreign", 99))
    case (_, None{}): "factory-exhausted"
def main() -> String:
  created_foreign(L.create(~S.MotionToken, L.Factory{0}))
