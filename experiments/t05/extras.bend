import Base
import ./lifecycle.bend as L
import ./fixture.bend as F
import ../rc1-query/api.bend as A
import ../rc1-query/schemas.bend as S

def absent_slot(f: F.Fixture, slot: U32) -> String:
  match f:
    case F.Fixture{w, _, _}: F.lookup_text(L.lookup(A.Required{}, w, L.Handle{0, slot}))
def exhausted_world(r: L.Factory & Maybe<&1, L.World<S.MotionToken>>) -> String:
  match r:
    case (L.Factory{n}, None{}): "exhausted:" ++ U32.show(n)
    case (_, Some{_}): "unexpected-world"
def exhausted_entity(r: L.World<S.MotionToken> & Maybe<&2, L.Handle<S.MotionToken>>) -> String:
  match r:
    case (L.World{_, n, _, _}, None{}): "exhausted:" ++ U32.show(n)
    case (_, Some{_}): "unexpected-entity"
def reuse_reserved(r: L.World<S.MotionToken> & Maybe<&2, L.Handle<S.MotionToken>>) -> String:
  match r:
    case (w, Some{L.Handle{_, slot}}): U32.show(slot) ++ ":" ++ F.query_text(L.query(A.Required{}, L.flush(~S.MotionToken, w)))
    case (_, None{}): "unexpected-exhaustion"
def no_reuse(f: F.Fixture) -> String:
  match f:
    case F.Fixture{w, _, _}: reuse_reserved(L.reserve(~S.MotionToken, w, "c", 3))
def duplicate_second(r: L.World<S.MotionToken> & Maybe<&2, L.Handle<S.MotionToken>>) -> String:
  match r:
    case (w, Some{h}): F.query_text(L.query(A.Optional{}, L.flush(~S.MotionToken, L.insert(~S.MotionToken, w, h))))
    case (_, None{}): "unexpected-exhaustion"
def duplicate_first(r: L.World<S.MotionToken> & Maybe<&2, L.Handle<S.MotionToken>>) -> String:
  match r:
    case (w, _): duplicate_second(L.reserve(~S.MotionToken, w, "same", 2))
def duplicate_created(r: L.Factory & Maybe<&1, L.World<S.MotionToken>>) -> String:
  match r:
    case (_, Some{w}): duplicate_first(L.reserve(~S.MotionToken, w, "same", 1))
    case (_, None{}): "unexpected-exhaustion"
def foreign_command(w: L.World<S.MotionToken>, h: L.Handle<S.MotionToken>) -> String:
  F.query_text(L.query(A.Optional{}, L.flush(~S.MotionToken, L.insert(~S.MotionToken, w, h))))
def foreign_local_reserved(h: L.Handle<S.MotionToken>, r: L.World<S.MotionToken> & Maybe<&2, L.Handle<S.MotionToken>>) -> String:
  match r:
    case (w, _): foreign_command(w, h)
def foreign_local_created(h: L.Handle<S.MotionToken>, r: L.Factory & Maybe<&1, L.World<S.MotionToken>>) -> String:
  match r:
    case (_, Some{w}): foreign_local_reserved(h, L.reserve(~S.MotionToken, w, "local", 7))
    case (_, None{}): "unexpected-exhaustion"
def foreign_reserved(f: L.Factory, r: L.World<S.MotionToken> & Maybe<&2, L.Handle<S.MotionToken>>) -> String:
  match r:
    case (_, Some{h}): foreign_local_created(h, L.create(~S.MotionToken, f))
    case (_, None{}): "unexpected-exhaustion"
def foreign_created(r: L.Factory & Maybe<&1, L.World<S.MotionToken>>) -> String:
  match r:
    case (f, Some{w}): foreign_reserved(f, L.reserve(~S.MotionToken, w, "foreign", 99))
    case (_, None{}): "unexpected-exhaustion"
def choose(n: U32) -> String:
  match n:
    case 0: absent_slot(F.setup(2), 4)
    case 1: absent_slot(F.setup(2), 4294967295)
    case 2: exhausted_world(L.create(~S.MotionToken, L.Factory{4294967295}))
    case 3: exhausted_entity(L.reserve(~S.MotionToken, L.World{0, 4294967295, A.World{[]}, []}, "never", 1))
    case 4: no_reuse(F.setup(9))
    case 5: duplicate_created(L.create(~S.MotionToken, L.Factory{0}))
    case _: foreign_created(L.create(~S.MotionToken, L.Factory{0}))
def digit(s: String) -> U32:
  match s:
    case SNil{}: 0
    case SCon{Chr{code}, _}: U32.sub(code, 48)
def args(xs: List<String>) -> IO(Unit):
  match xs:
    case Con{_, Con{n, _}}: IO.print(choose(digit(n)))
    case _: IO.print("invalid-arguments")
def main() -> IO(Unit):
  do IO<Unit>:
    xs : List<String> <- IO.args()
    args(xs)
