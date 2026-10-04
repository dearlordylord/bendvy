import Base
import ./runtime.bend as R
import ./access-control.bend as C

def printed(result: R.Cell & U32) -> IO(Unit):
  match result:
    case (_,value): IO.print(U32.show(value))
def main() -> IO(Unit):
  printed(C.control())
