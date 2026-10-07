import Base
import compat-library.bend as C
import ../../../src/ecs/lifecycle.bend as L
def carrier(~A:Type,owner:C.Carrier<A>) -> A:
  match owner:
    case C.Owned{owner}: owner
    case C.Wrapped{inner}: carrier(~A,inner)
# Existing exhaustive generic and nominal consumers, unchanged between stages.
def column(~A:Type,value:C.Column<A>) -> A:
  match value:
    case C.Column{owner,_}: owner
    case C.Prepared{box}: carrier(~A,box)
def nominal(value:C.Nominal) -> Array<U32>:
  match value:
    case C.Nominal{owner}: owner
def value(observed:Array<U32> & U32) -> U32:
  match observed:
    case (_,value): value
def main() -> IO(Unit):
  IO.print(U32.show(U32.add(value(Array.get(U32,column(~Array<U32>,C.Prepared{C.Wrapped{C.Owned{ALeaf{7}}}}),0)),value(Array.get(U32,nominal(C.Nominal{ALeaf{11}}),0)))))
