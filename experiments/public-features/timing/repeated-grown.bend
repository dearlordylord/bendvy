import Base
import repeated-work.bend as Work
def repeat(fuel:Nat) -> IO(Unit):
  match fuel:
    case Zero{}: IO.pure(Unit,Unit{})
    case Succ{rest}: IO.bind(Unit,Unit,IO.print(Work.render_grown()),unit => repeat(rest))
def main() -> IO(Unit):
  repeat(20n)
