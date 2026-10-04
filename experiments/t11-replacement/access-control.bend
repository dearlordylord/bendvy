import Base
import ./authority.bend as A
import ./runtime.bend as R

def read(-P: Type, get: P -> A.Motion -> P & U32, cell: P) -> P & U32:
  get(cell,A.Position{})
def write(-P: Type, get: P -> A.Motion -> P & U32, set: P -> A.Motion -> U32 -> P, cell: P) -> P & U32:
  get(set(cell,A.Position{},7),A.Position{})
def control() -> R.Cell & U32:
  A.writable(~write,R.Cell{0,[1 : U32^0n],False{}})
