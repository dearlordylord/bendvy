import Base
# Gameplay's universally affine owner cannot be duplicated by a callback.
def denied(-F:Type,owner:F) -> F & F:
  (owner,owner)
