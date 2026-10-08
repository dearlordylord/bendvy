import Base
import ../binding-fixtures/workshop.bend as D
import ../binding-static-workshop.bend as P
import ../definition.bend as Meta
import ../../../bend-candidate/consumer.bend as A
import ../../../bend-candidate/inspect.bend as I
def alternative() -> Meta.Definition<A.Schema,I.Plan<A.Schema,A.Store,D.Resources,U32,D.Ops>>:
  D.define("Workshop/Other",D.bonus(),D.score())
def bad(owner:P.State<D.canonical_definition(),Array<U32>>) -> P.State<alternative(),Array<U32>>:
  owner
