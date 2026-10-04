import Base
import ./authority.bend as A
import ./runtime.bend as R

def bad(-P: Type, get: P -> A.Motion -> P & U32, cell: P) -> P & U32:
  (R.Cell{0,[9 : U32^0n],False{}},9)
