import Base
import ../../../../../src/ecs/capabilities.bend as Cap
def good(~H:Type,~read:Cap.ValueRead<H,List<&2,U32>>,owner:H) -> H & List<&2,U32>:
  Cap.value_read(~H,~List<&2,U32>,~read,owner)
