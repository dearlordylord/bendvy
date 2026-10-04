import Base
import ./payload.bend as P
def discard(payload: P.Payload) -> Unit:
  Unit{}
# An actual destructive transfer consumes the sole owner. Keeping an old alias
# for abort is unavailable even though affine discarding itself is permitted.
def bad(payload: P.Payload) -> P.Payload:
  _ = discard(payload)
  payload
