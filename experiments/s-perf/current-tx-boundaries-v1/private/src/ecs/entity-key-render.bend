import Base
import entity-key.bend as K

def show(key:K.Key) -> String:
  match key:
    case K.EntityKey{index,generation}:U32.show(index) ++ ":" ++ U32.show(generation)
