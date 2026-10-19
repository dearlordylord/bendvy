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
def main() -> IO(Unit):
  IO.print("[" ++ token(Walk.force([])) ++ "," ++ token(Walk.force(case_one())) ++ "," ++ token(Walk.force(case_two())) ++ "," ++ token(Walk.force(case_three())) ++ "," ++ token(Walk.run(0n,Walk.State{[Walk.ValueTask{J.Null{}}],0})) ++ "," ++ token(cached(999n)) ++ "," ++ token(cached(0n)) ++ "]")
