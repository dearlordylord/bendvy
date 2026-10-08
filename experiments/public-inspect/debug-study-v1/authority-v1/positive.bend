import Base
import ../consumer.bend as A
import schema-b.bend as B
import ../skeleton.bend as F
import ../dump.bend as D
# Two independent nominal schemas, same arbitrary affine families/resources.
def left(world:A.World()) -> A.Frame() & F.Output<D.Dump<A.Schema,A.Values,List<&2,U32>>>:
  A.run(True{},F.Filter{None{},[],F.BoundedDecimal{[2]}},world)
def right(world:B.World()) -> B.Frame() & F.Output<D.Dump<B.Schema,B.Values,List<&2,U32>>>:
  B.run(True{},F.Filter{None{},[],F.BoundedDecimal{[2]}},world)
