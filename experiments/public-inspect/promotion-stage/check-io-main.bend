import Base
import check-main.bend as Pure
# IO.print adds one LF to the exact unchanged pure String result.
def main() -> IO(Unit):
  IO.print(Pure.main())
