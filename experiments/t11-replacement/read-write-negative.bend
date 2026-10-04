import Base
import ./authority.bend as A
import ./runtime.bend as R

def bad(-P: Type, get: P -> A.Motion -> P & U32, cell: P) -> P & U32:
  get(A.set(cell,A.Position{},9),A.Position{})
