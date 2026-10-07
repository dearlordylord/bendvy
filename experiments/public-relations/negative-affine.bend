import Base
import owned-world.bend as O
def bad(owner: O.Payload) -> O.Payload & O.Payload:
  (owner,owner)
