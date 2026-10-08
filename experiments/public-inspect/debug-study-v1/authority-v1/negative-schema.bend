import Base
import ../consumer.bend as A
import schema-b.bend as B
import ../skeleton.bend as F
import ../dump.bend as D
def wrong(filter:F.Filter<B.Schema,B.Token>,world:A.World()) -> A.Frame() & F.Output<D.Dump<A.Schema,A.Values,List<&2,U32>>>:
  A.run(True{},filter,world)
