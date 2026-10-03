import Base
import ./api.bend as A

def identity(-Q: Type, read: Q -> A.MotionToken -> Q & U32, q: Q) -> Q & U32:
  read(q, A.Position{})

def bad(-P: Type, read: P -> A.MotionToken -> P & U32, p: P) -> P & U32:
  (A.readonly(~identity, A.Motion{A.PositionCell{99}, A.VelocityCell{2}}), 99)
