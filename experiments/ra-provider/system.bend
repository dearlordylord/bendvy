import Base
import ./api.bend as A

def finish(-P: Type, -V: Type, write: P -> A.MotionToken -> U32 -> P, v: V, delta: U32, px: P & U32) -> P & V:
  match px:
    case (p, x): (write(p, A.Position{}, (x + delta : U32)), v)
def with_velocity(-P: Type, -V: Type, read: P -> A.MotionToken -> P & U32, write: P -> A.MotionToken -> U32 -> P, p: P, vx: V & U32) -> P & V:
  match vx:
    case (v, delta): finish(P, V, write, v, delta, read(p, A.Position{}))
def move(-P: Type, -V: Type, read: P -> A.MotionToken -> P & U32, write: P -> A.MotionToken -> U32 -> P, velocity: V -> V & U32, p: P, v: V) -> P & V:
  with_velocity(P, V, read, write, p, velocity(v))
