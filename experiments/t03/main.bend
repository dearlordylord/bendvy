import Base
import ./api.bend as A

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(A.show_motion(A.motion(~A.move, A.motion(~A.move, A.motion(~A.move, A.MotionStore{0, 2})))))
    IO.print(A.show_health(A.health(~A.hurt, A.health(~A.hurt, A.health(~A.hurt, A.HealthStore{20, 3, 1})))))
