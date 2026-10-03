import Base
import ./payload.bend as V
def bad(c: V.Payload) -> V.Payload & Array<U32>:
  match c:
    case V.Payload{+a}: (V.Payload{a}, a)
