import Base
import fast.bend as F
def duplicate(-S:Data,-C:Type,decision:F.Decision<S,C>) -> F.Decision<S,C> & F.Decision<S,C>:
  (decision,decision)
def main() -> IO(Unit):
  IO.print("unreachable")
