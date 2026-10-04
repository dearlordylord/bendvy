import Base
import ./payload.bend as P
def bad(payload: P.Payload, other: P.Payload) -> P.Payload & P.Payload:
  (payload, other)
