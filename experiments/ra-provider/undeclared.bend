import Base
import ./api.bend as A

def bad(-P: Type, read: P -> A.MotionToken -> P & U32, p: P) -> P & U32:
  A.velocity_read(p)
