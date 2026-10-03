import Base
import ./api.bend as A

def main() -> A.WriteMotion:
  A.write(A.MotionRead{0}, A.Position{}, 1)
