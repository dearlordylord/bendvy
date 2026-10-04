import Base
import ./payload.bend as P
# A retained owner is a valid restoration capability; no destructive transfer.
def bad(payload: P.Payload) -> P.Payload:
  payload
