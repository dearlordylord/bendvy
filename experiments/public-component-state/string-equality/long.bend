import Base
import equality.bend as E

def fill(n: Nat,tail: String) -> String:
  match n:
    case 0n: tail
    case 1n+rest: fill(rest,SCon{'😀',tail})
def shown(x: Bool) -> String:
  match x:
    case True{}: "true"
    case False{}: "false"
def long(+s: String) -> List<&2,String>:
  [shown(E.equal(s,s)),shown(E.equal(s ++ "a",s ++ "b")),shown(E.equal("a" ++ s,"b" ++ s)),shown(E.equal(s,s ++ "a"))]
def oldnew(+s: String) -> String:
  shown(E.equal(s,s ++ "x")) ++ ":" ++ shown(String.eq(s,s ++ "x"))
def print_lines(lines: List<&2,String>) -> IO(Unit):
  match lines:
    case []: IO.pure(Unit,Unit{})
    case line <> rest: IO.bind(Unit,Unit,IO.print(line),u => print_lines(rest))
def main() -> IO(Unit):
  print_lines(oldnew(fill(128n,"")) <> long(fill(U32.to_nat(20000),"")))
