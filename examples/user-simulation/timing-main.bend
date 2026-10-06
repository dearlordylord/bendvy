import Base
import driver.bend as D
import main.bend as M

def iterations(count: Nat) -> IO(Unit):
  match count:
    case 0n: IO.pure(Unit,Unit{})
    case 1n++rest:
      do IO<Unit>:
        IO.print("{\"format\":1,\"checkpoints\":[" ++ M.checkpoints(D.equivalent()) ++ "]}")
        iterations(rest)

def main() -> IO(Unit):
  iterations(10n)
