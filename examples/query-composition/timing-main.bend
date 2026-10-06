import Base
import driver.bend as D
import json.bend as J

def run(fuel: Nat) -> IO(Unit):
  match fuel:
    case 0n: IO.pure(Unit,Unit{})
    case 1n+rest:
      do IO<Unit>:
        IO.print("{\"format\":1,\"application\":\"Workshop\",\"checkpoints\":" ++ J.array(D.equivalent()) ++ "}")
        run(rest)
def main() -> IO(Unit):
  run(10n)
