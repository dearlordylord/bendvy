import Base
import ./api.bend as A
import ./system.bend as S

def print_step(result: A.Motion & U32) -> IO(A.Motion):
  match result:
    case (world, x):
      do IO<A.Motion>:
        IO.print(U32.show(x))
        return world
def main() -> IO(Unit):
  do IO<Unit>:
    w : A.Motion <- print_step(A.observe(A.step(~S.move, A.Motion{A.PositionCell{0}, A.VelocityCell{2}})))
    w : A.Motion <- print_step(A.observe(A.step(~S.move, w)))
    w : A.Motion <- print_step(A.observe(A.step(~S.move, w)))
    return Unit{}
