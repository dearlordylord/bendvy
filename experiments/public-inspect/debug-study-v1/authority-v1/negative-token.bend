import Base
import ../consumer.bend as A
import schema-b.bend as B
import ../skeleton.bend as F
def wrong() -> F.Filter<A.Schema,A.Token>:
  F.Filter{None{},[B.Left{}],F.Unbounded{}}
