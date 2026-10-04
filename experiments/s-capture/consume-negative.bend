import Base
import ./local.bend as L
def bad(f: Unit -> L.Local & U32) -> L.Local & U32:
  _ = f(Unit{})
  f(Unit{})
