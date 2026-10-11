import Base
import ../../main.bend as I
def repeat(fuel:Nat) -> IO(Unit):
  match fuel:
    case 0n:IO.pure(Unit{})
    case 1n+rest:IO.bind(I.main(),u => repeat(rest))
def main() -> IO(Unit):repeat(32n)
