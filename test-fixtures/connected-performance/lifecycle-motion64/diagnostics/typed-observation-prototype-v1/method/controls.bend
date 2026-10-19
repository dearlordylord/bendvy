import Base
import ../../../method/json.bend as J
import walk.bend as Walk

def large() -> Nat:Nat.add(Nat.mul(65536n,4294967295n),65535n)
def case_one() -> List<&2,J.Value>:
  [J.Null{},J.Boolean{False{}},J.Boolean{True{}},J.Number{0n},J.Number{4294967295n},J.Number{Walk.radix()},J.Number{large()},J.Text{""},J.Text{"A\né😀"},J.array([]),J.object([]),J.object([J.Field{"a",J.array([J.Number{1n},J.object([J.Field{"x",J.Text{"\\\""}}])])},J.Field{"b",J.Null{}}])]
def case_two() -> List<&2,J.Value>: [J.object([J.Field{"a",J.Number{1n}},J.Field{"b",J.Number{2n}}])]
def case_three() -> List<&2,J.Value>: [J.object([J.Field{"b",J.Number{2n}},J.Field{"a",J.Number{1n}}])]
def token(result:Walk.Outcome) -> String:
  match result:
    case Walk.Complete{value}:U32.show(value)
    case Walk.Exhausted{}:"\"exhausted\""
def cached(value:Nat) -> Walk.Outcome:Walk.run(32n,Walk.State{[Walk.ValueTask{J.Array{[J.Array{[],value}],0n}}],0})
def report() -> IO(Unit):
  IO.print("[" ++ token(Walk.force([])) ++ "," ++ token(Walk.force(case_one())) ++ "," ++ token(Walk.force(case_two())) ++ "," ++ token(Walk.force(case_three())) ++ "," ++ token(Walk.run(0n,Walk.State{[Walk.ValueTask{J.Null{}}],0})) ++ "," ++ token(cached(999n)) ++ "," ++ token(cached(0n)) ++ "]")

def is_token(expected:U32,value:Walk.Outcome) -> Bool:
  match value:
    case Walk.Complete{token}:U32.is_eq(expected,token)
    case Walk.Exhausted{}:False{}
def is_exhausted(value:Walk.Outcome) -> Bool:
  match value:
    case Walk.Complete{_}:False{}
    case Walk.Exhausted{}:True{}
def characters(fuel:Nat,text:String) -> Walk.Outcome:
  Walk.run(fuel,Walk.State{[Walk.CharsTask{text}],7})
def character_boundaries() -> Bool:
  empty_done=is_token(7,Walk.run(0n,Walk.State{[],7}))
  empty_exhausted=is_exhausted(characters(0n,""))
  empty_exact=is_token(7,characters(1n,""))
  ascii_short=is_exhausted(characters(1n,"A"))
  ascii_exact=is_token(296,characters(2n,"A"))
  unicode_short=is_exhausted(characters(2n,"é😀"))
  unicode_exact=is_token(143824,characters(3n,"é😀"))
  pending_short=is_exhausted(Walk.run(2n,Walk.State{[Walk.CharsTask{"A"},Walk.ValueTask{J.Null{}}],7}))
  pending_exact=is_token(9768,Walk.run(3n,Walk.State{[Walk.CharsTask{"A"},Walk.ValueTask{J.Null{}}],7}))
  Bool.and(empty_done,Bool.and(empty_exhausted,Bool.and(empty_exact,Bool.and(ascii_short,Bool.and(ascii_exact,Bool.and(unicode_short,Bool.and(unicode_exact,Bool.and(pending_short,pending_exact))))))))
def checked(accepted:Bool) -> IO(Unit):
  match accepted:
    case True{}:report()
    case False{}:IO.die(Unit,8,"character fuel boundary mismatch")
def main() -> IO(Unit):checked(character_boundaries())
