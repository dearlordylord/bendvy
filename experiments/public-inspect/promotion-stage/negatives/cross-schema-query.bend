import Base
import ../query-api.bend as API
import ../cardinality-workshop.bend as F
import ../../bend-candidate/consumer.bend as A
import ../../bend-candidate/query.bend as Q
import ../../../../src/ecs/world.bend as W
def bad(~H:Type,~caps:F.Reads<H>,owner:H,target:W.Handle<A.OtherSchema>) -> H & Result<&2,&2,API.LookupError,Q.Row<A.Schema,List<&2,U32>>>:
  API.get(~H,~A.Schema,~List<&2,U32>,~F.required(~H,caps),owner,target)
