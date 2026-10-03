import Base
import ./api.bend as A

# Compilable planted bypass: reconstruct a write grant from read data.
def bad(c: A.ReadMotion) -> A.WriteMotion:
  A.write(A.MotionWrite{A.read(c, A.Position{})}, A.Position{}, 99)

def output(c: A.WriteMotion) -> IO(Unit):
  match c:
    case A.MotionWrite{x}: IO.print(U32.show(x))

def main() -> IO(Unit):
  output(bad(A.MotionRead{0}))
