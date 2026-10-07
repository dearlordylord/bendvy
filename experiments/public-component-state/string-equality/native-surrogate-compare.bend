import Base
import equality.bend as E

def shown(x: Bool) -> String:
  match x:
    case True{}: "true"
    case False{}: "false"
def pair(+a: String,+b: String) -> String:
  shown(E.equal(a,b)) ++ ":" ++ shown(String.eq(a,b))
def print_lines(lines: List<&2,String>) -> IO(Unit):
  match lines:
    case []: IO.pure(Unit,Unit{})
    case line <> rest: IO.bind(Unit,Unit,IO.print(line),u => print_lines(rest))
def main() -> IO(Unit):
  print_lines([pair("\u{D800}","\u{D800}"),pair("\u{D800}","\u{D801}"),pair("\u{D800}","\u{DC00}"),pair("\u{D800}a","\u{D800}b"),pair("\u{D800}","\u{D800}a"),pair("a\u{DC00}","a\u{DC00}"),pair("\u{D800}\u{DC00}","😀")])
