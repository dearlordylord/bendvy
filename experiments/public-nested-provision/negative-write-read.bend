import Base
import access.bend as X
import ../../src/ecs/capabilities.bend as Cap
def gameplay(~H:Type,~read:Cap.Read<H,List<&2,U32>>,owner:H) -> H:
  Cap.set(~H,~Array<U32>,~List<&2,U32>,~read,owner,ANode{ALeaf{7},ALeaf{8}})
def positive_instantiation(owner:Array<U32>) -> Array<U32>:
  gameplay(~Array<U32>,~Cap.Read{X.declared},owner)
