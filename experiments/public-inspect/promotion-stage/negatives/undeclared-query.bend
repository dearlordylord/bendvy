import Base
import ../query-api.bend as API
import ../cardinality-workshop.bend as F
import ../../bend-candidate/consumer.bend as A
import ../../bend-candidate/inspect.bend as I
import ../../bend-candidate/query.bend as Q
# Trusted concrete setup cannot satisfy a universally quantified callback owner.
def bad(~H:Type,owner:H) -> H & List<&2,Q.Row<A.Schema,List<&2,U32>>>:
  API.each(~H,~A.Schema,~List<&2,U32>,~F.required(~I.Frame<A.Schema,A.Store,A.Resource,U32>,I.plan_caps(~A.Schema,~A.Store,~A.Resource,~U32,~F.Ops,F.plan())),owner)
