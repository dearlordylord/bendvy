import Base
import ./lifecycle.bend as L
import ../rc1-query/api.bend as A
import ../rc1-query/schemas.bend as S

type Fixture is Type:
  Fixture{world: L.World<S.MotionToken>, a: L.Handle<S.MotionToken>, b: L.Handle<S.MotionToken>}
def reserved_b(+a: L.Handle<S.MotionToken>, result: L.World<S.MotionToken> & Maybe<&2, L.Handle<S.MotionToken>>) -> Fixture:
  match result:
    case (w, Some{b}): Fixture{w, a, b}
    case (w, None{}): Fixture{w, a, L.Handle{4294967295, 4294967295}}
def reserved_a(result: L.World<S.MotionToken> & Maybe<&2, L.Handle<S.MotionToken>>) -> Fixture:
  match result:
    case (w, Some{a}): reserved_b(a, L.reserve(~S.MotionToken, w, "b", 2))
    case (w, None{}): reserved_b(L.Handle{4294967295, 4294967295}, L.reserve(~S.MotionToken, w, "b", 2))
def created(result: L.Factory & Maybe<&1, L.World<S.MotionToken>>) -> Fixture:
  match result:
    case (_, Some{w}): reserved_a(L.reserve(~S.MotionToken, w, "a", 1))
    case (_, None{}): Fixture{L.World{4294967295, 4294967295, A.World{[]}, []}, L.Handle{4294967295, 0}, L.Handle{4294967295, 1}}
def initial() -> Fixture:
  created(L.create(~S.MotionToken, L.Factory{0}))
def advance(op: U32, w: L.World<S.MotionToken>, +a: L.Handle<S.MotionToken>, b: L.Handle<S.MotionToken>) -> L.World<S.MotionToken>:
  match op:
    case 0: L.tick(~S.MotionToken, w)
    case 1: L.flush(~S.MotionToken, w)
    case 2: L.insert(~S.MotionToken, L.insert(~S.MotionToken, w, b), a)
    case 3: L.remove(~S.MotionToken, w, a)
    case 4: L.insert(~S.MotionToken, L.despawn(~S.MotionToken, w, a), a)
    case _: w
def advance_fixture(op: U32, f: Fixture) -> Fixture:
  match f:
    case Fixture{w, +a, +b}: Fixture{advance(op, w, a, b), a, b}
def run(steps: List<U32>, limit: Nat, f: Fixture) -> Fixture:
  match steps limit:
    case Nil{} _: f
    case _ 0n: f
    case Con{op, tail} 1n+n: run(tail, n, advance_fixture(op, f))
def setup(stage: U32) -> Fixture:
  run([0, 0, 1, 2, 1, 3, 1, 4, 1, 1], U32.to_nat((stage + 1 : U32)), initial())
def selection(mode: U32) -> A.Selection:
  match mode:
    case 0: A.Required{}
    case 1: A.Present{}
    case 2: A.Absent{}
    case _: A.Optional{}
def query_text(result: L.World<S.MotionToken> & String) -> String:
  match result:
    case (_, text): text
def result_text(r: A.LookupResult) -> String:
  match r:
    case A.Matched{text}: "match:" ++ text
    case A.QueryMismatch{}: "QueryMismatch"
    case A.MissingEntity{}: "MissingEntity"
def lookup_text(result: L.World<S.MotionToken> & A.LookupResult) -> String:
  match result:
    case (_, r): result_text(r)
def query(mode: U32, f: Fixture) -> String:
  match f:
    case Fixture{w, _, _}: query_text(L.query(selection(mode), w))
def lookup(use_b: Bool, mode: U32, f: Fixture) -> String:
  match use_b f:
    case False{} Fixture{w, a, _}: lookup_text(L.lookup(selection(mode), w, a))
    case True{} Fixture{w, _, b}: lookup_text(L.lookup(selection(mode), w, b))
