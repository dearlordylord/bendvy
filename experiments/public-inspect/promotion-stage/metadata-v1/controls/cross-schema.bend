import Base
import ../definition.bend as Meta
import ../../../bend-candidate/consumer.bend as A
import ../../../bend-candidate/query-consumer.bend as B
def bad(~Plan:Type,requirements:List<&2,Meta.Resource<B.Schema>>,plan:Plan) -> Meta.Definition<A.Schema,Plan>:
  Meta.make(~A.Schema,~Plan,"Cross",requirements,plan)
