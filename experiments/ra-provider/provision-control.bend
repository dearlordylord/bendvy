import Base
import ./api.bend as A

def identity(-P: Type, read: P -> A.MotionToken -> P & U32, p: P) -> P & U32:
  read(p, A.Position{})
def main() -> A.Motion:
  A.readonly(~identity, A.Motion{A.position_write(A.PositionCell{0}, A.Position{}, 99), A.VelocityCell{2}})
