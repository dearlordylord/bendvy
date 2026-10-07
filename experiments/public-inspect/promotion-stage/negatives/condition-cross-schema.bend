import Base
import ../condition.bend as Check
import ../../bend-candidate/consumer.bend as A
import ../../../../src/ecs/capabilities.bend as Cap
# The detached row schema remains nominal across condition declarations.
def bad(~H:Type,~read:Cap.ValueRead<H,List<&2,Check.Row<A.Schema,List<&2,U32>>>>,owner:H) -> H & List<&2,Check.Row<A.OtherSchema,List<&2,U32>>>:
  Cap.value_read(~H,~List<&2,Check.Row<A.Schema,List<&2,U32>>>,~read,owner)
