import Base
import driver.bend as D

def print_lines(lines: List<&2,String>) -> IO(Unit):
  match lines:
    case []: IO.pure(Unit,Unit{})
    case line <> rest: IO.bind(Unit,Unit,IO.print(line),unit => print_lines(rest))
def main() -> IO(Unit):
  print_lines(D.main())
