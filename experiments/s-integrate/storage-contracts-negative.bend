import Base
import ./storage-contracts.bend as C

def bad(-P: Type, get: P -> C.PositionToken -> P & C.View, owner: P) -> P & C.View:
  (C.Position{[10 : U32^2n], 7}, C.View{10, 7})
