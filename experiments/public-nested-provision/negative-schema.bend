import Base
import app.bend as A
import other.bend as B
import ../../src/ecs/schedule-provision.bend as P
def composed() -> P.Plan<A.Schema>:
  P.Sequence{A.nested(0),B.nested(0)}
