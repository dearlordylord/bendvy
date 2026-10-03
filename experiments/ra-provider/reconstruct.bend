import Base
import ./api.bend as A

def forge(-P: Type, result: P & U32) -> P & U32:
  match result:
    case (_, +x): (A.PositionCell{x}, x)
def bad(-P: Type, read: P -> A.MotionToken -> P & U32, p: P) -> P & U32:
  forge(P, read(p, A.Position{}))
