import Base
import ./authority.bend as A

def bad(-P: Type, get: P -> A.Motion -> P & U32, cell: P) -> P & U32:
  get(cell,A.HitPoints{})
