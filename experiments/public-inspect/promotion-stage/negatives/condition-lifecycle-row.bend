import Base
import ../condition.bend as Check
import ../../bend-candidate/consumer.bend as A
import ../../bend-candidate/query.bend as Q
import ../../bend-candidate/inspect.bend as I
# Plain condition rows expose Access only, never added/changed reader flags.
def bad(row:Check.Row<A.Schema,List<&2,U32>>) -> Bool:
  match row:
    case Q.Row{_,I.Value{_,added,_}}:added
