import Base
import ../../../src/ecs/execution-query.bend as Query
type First is Data:
  First{}
type Second is Data:
  Second{}
def wrong_schema(~H:Type,~caps:Query.Each<First,H,String>,scope:H) -> H & Query.Report<String>:
  Query.each(~Second,~H,~String,caps)(scope)
