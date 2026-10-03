import Base
import ./api.bend as A

# Callback granted only read; direct call must reject.
def bad(c: A.ReadMotion) -> A.WriteMotion:
  A.write(c, A.Position{}, 1)
