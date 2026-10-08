import Base
import binding-fixtures/workshop.bend as D
import binding-static-workshop.bend as P
import binding-format.bend as F
import ../../bend-candidate/consumer.bend as A
import ../../bend-candidate/inspect.bend as I
import ../../../../src/ecs/world.bend as W
import definition.bend as Meta

def discard(observed:P.State<D.canonical_definition(),Array<U32>> & I.Observed<A.Schema,A.Store,D.Resources,U32,P.Fields,P.Fields>) -> Unit:
  Unit{}
def read_result(observed:P.State<D.canonical_definition(),Array<U32>> & Meta.Metadata<A.Schema>,world:W.World<A.Schema,A.Store,D.Resources,U32>) -> P.State<D.canonical_definition(),Array<U32>> & I.Observed<A.Schema,A.Store,D.Resources,U32,P.Fields,P.Fields>:
  (state,_)=observed
  P.invoke(~D.canonical_definition(),~Array<U32>,state,I.Fresh{},world)
def created(creation:W.Creation<A.Schema,A.Store,D.Resources,U32>) -> Unit:
  match creation:
    case W.Created{_,world}:discard(read_result(P.read(~D.canonical_definition(),~Array<U32>,P.attach(~D.canonical_definition(),~Array<U32>,F.cells(401),F.cells(501),F.cells(601))),world))
    case W.CreateRejected{_,_}:Unit{}
def main() -> Unit:
  created(W.create(~A.Schema,~A.Store,~D.Resources,~U32,~A.empty,W.factory(),D.Resources{A.Resource{F.cells(101)},A.Resource{F.cells(201)}}))
