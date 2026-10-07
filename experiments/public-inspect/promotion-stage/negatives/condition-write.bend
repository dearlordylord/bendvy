import Base
import ../../../../src/ecs/capabilities.bend as Cap
# A condition consumer receives an opaque owner and read-only declaration grant.
def bad(~H:Type,~read:Cap.ValueRead<H,List<&2,U32>>,owner:H) -> H:
  Cap.value_set(~H,~List<&2,U32>,~List<&2,U32>,~read,owner,[])
