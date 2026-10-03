import Base
import ./payload.bend as V
def retain(-M: Type, m: M, detached: V.Payload & String) -> M:
  match detached:
    case (payload, text): m
def bad(-M: Type, m: M) -> M:
  retain(M, m, V.get(V.update(V.Payload{[0 : U32^2n]}, V.Items{}, 3)))
