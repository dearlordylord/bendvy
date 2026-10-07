import Base
import ../condition.bend as Check
import ../../bend-candidate/inspect.bend as I
import ../../bend-candidate/consumer.bend as A
# An Inspector frame with cursor is not the stateless condition frame.
def bad(frame:I.Frame<A.Schema,A.Store,A.Resource,U32>) -> Check.Frame<A.Schema,A.Store,A.Resource,U32>:
  frame
