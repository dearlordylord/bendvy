import Base
import ../../query-api.bend as API
import ../../cardinality-workshop.bend as F
import ../../../bend-candidate/consumer.bend as A
import ../../../bend-candidate/query.bend as Q
def good(~H:Type,~caps:F.Reads<H>,owner:H) -> H & List<&2,Q.Row<A.Schema,List<&2,U32>>>:
  API.each(~H,~A.Schema,~List<&2,U32>,~F.required(~H,caps),owner)
