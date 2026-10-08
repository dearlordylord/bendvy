import Base
import ../../../../../../src/ecs/capabilities.bend as Cap
import ../../../../../../src/ecs/component.bend as Cmp
def getter(owner:Unit) -> Unit & Cmp.Access<U32>:
  (owner,Cmp.Found{0})
def readonly() -> Cap.Read<Unit,U32>:
  Cap.Read{getter}
def wrong(owner:Unit) -> Unit:
  Cap.set(~Unit,~U32,~U32,~readonly(),owner,1)
