import Base
import ../condition.bend as Check
import ../../bend-candidate/consumer.bend as A
import ../../bend-candidate/query.bend as Q
import ../../../../src/ecs/capabilities.bend as Cap
def bad() -> Cap.ValueRead<Check.Frame<A.Schema,A.Store,A.Resource,U32>,List<&2,Check.Row<A.Schema,List<&2,U32>>>>:
  Check.query_grant(~A.Schema,~A.Store,~A.Resource,~U32,~Unit,~A.Payload,~List<&2,U32>,~A.Token,~A.take,~A.put,~A.project,~A.family(),~Q.Changed{})
