import Base
import ./api.bend as A

def bad(-P: Type, read: P -> A.MotionToken -> P & U32, p: P) -> P & U32:
  (A.position_write(p, A.Position{}, 99), 99)
