import Base
import app.bend as A
import ../../src/ecs/capabilities.bend as Cap
import ../../src/ecs/component.bend as C
def accessed(result:Array<U32> & List<&2,U32>) -> Array<U32> & C.Access<List<&2,U32>>:
  (owner,view)=result
  (owner,C.Found{view})
def declared(owner:Array<U32>) -> Array<U32> & C.Access<List<&2,U32>>:
  accessed(A.projected(owner))
def gameplay(~H:Type,~read:Cap.Read<H,List<&2,U32>>,owner:H) -> H & C.Access<List<&2,U32>>:
  Cap.read(~H,~List<&2,U32>,~read,owner)
def positive(owner:Array<U32>) -> Array<U32> & C.Access<List<&2,U32>>:
  gameplay(~Array<U32>,~Cap.Read{declared},owner)
def main() -> IO(Unit):
  IO.print("access-positive")
