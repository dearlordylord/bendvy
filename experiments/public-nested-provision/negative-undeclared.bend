import Base
import app.bend as A
import access.bend as X
import ../../src/ecs/capabilities.bend as Cap
import ../../src/ecs/component.bend as C
def gameplay(~H:Type,~read:Cap.Read<H,List<&2,U32>>,owner:H) -> H & List<&2,U32>:
  A.projected(owner)
def positive_instantiation(owner:Array<U32>) -> Array<U32> & List<&2,U32>:
  gameplay(~Array<U32>,~Cap.Read{X.declared},owner)
