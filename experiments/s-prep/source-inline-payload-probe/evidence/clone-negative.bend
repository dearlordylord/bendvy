import Base
import ./experiments/s-integrate/types.bend as T
def clone(+owner:T.Position) -> U32:
  match owner:
    case T.Position{a,b,c,d,frame}: a
def main() -> U32: clone(T.Position{1,2,3,4,7})
