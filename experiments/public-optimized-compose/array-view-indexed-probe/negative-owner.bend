import Base
import view.bend as V
def duplicate(array:Array<U32>) -> (Array<U32> & List<&2,U32>) & Array<U32>:
  (V.array_view(array),array)
def main() -> IO(Unit):
  IO.print("unreachable")
