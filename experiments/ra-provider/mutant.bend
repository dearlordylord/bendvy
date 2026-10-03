import Base
import ./api.bend as A
import ./main.bend as M

def noop(-P: Type, -V: Type, read: P -> A.MotionToken -> P & U32, write: P -> A.MotionToken -> U32 -> P, velocity: V -> V & U32, p: P, v: V) -> P & V:
  (p, v)
def main() -> IO(Unit):
  do IO<Unit>:
    w : A.Motion <- M.print_step(A.observe(A.step(~noop, A.Motion{A.PositionCell{0}, A.VelocityCell{2}})))
    w : A.Motion <- M.print_step(A.observe(A.step(~noop, w)))
    w : A.Motion <- M.print_step(A.observe(A.step(~noop, w)))
    return Unit{}
