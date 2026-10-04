import Base
import ./payload.bend as P
def bad(+payload: P.Payload) -> P.Payload & P.Payload:
  (payload, payload)
