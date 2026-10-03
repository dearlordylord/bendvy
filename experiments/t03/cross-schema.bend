import Base
import ./api.bend as A

def main() -> A.WriteMotion:
  A.write(A.MotionWrite{0}, A.HitPoints{}, 1)
