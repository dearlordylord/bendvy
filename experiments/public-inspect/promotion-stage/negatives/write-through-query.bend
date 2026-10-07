import Base
import ../cardinality-workshop.bend as F
import ../../bend-candidate/consumer.bend as A
import ../../bend-candidate/query.bend as Q
import ../../../../src/ecs/capabilities.bend as Cap
def bad(~H:Type,~caps:F.Reads<H>,owner:H) -> H:
  Cap.value_set(~H,~List<&2,Q.Row<A.Schema,List<&2,U32>>>,~List<&2,Q.Row<A.Schema,List<&2,U32>>>,~F.required(~H,caps),owner,[])
