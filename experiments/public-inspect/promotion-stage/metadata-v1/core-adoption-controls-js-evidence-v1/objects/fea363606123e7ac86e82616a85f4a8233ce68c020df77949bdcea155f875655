import Base
import binding-fixtures/workshop.bend as D
import binding-static-workshop.bend as P
import binding-format.bend as F
import ../../bend-candidate/consumer.bend as A
import ../../../../src/ecs/inspector.bend as I
import ../../../../src/ecs/inspector-definition.bend as G
import ../../../../src/ecs/inspector-metadata.bend as Meta
import ../../../../src/ecs/world.bend as W

type Owner is Type:
  Owner{left:Array<U32>,right:Array<U32>,extra:Array<U32>}
def done(observed:G.State<A.Schema,A.Store,D.Resources,U32,D.Ops,D.canonical_definition(),Owner> & I.Observed<A.Schema,A.Store,D.Resources,U32,P.Fields,P.Fields>) -> Unit:
  Unit{}
def read(observed:G.State<A.Schema,A.Store,D.Resources,U32,D.Ops,D.canonical_definition(),Owner> & Meta.Metadata<A.Schema>,world:W.World<A.Schema,A.Store,D.Resources,U32>) -> Unit:
  (state,_)=observed
  done(G.invoke(~A.Schema,~A.Store,~D.Resources,~U32,~D.Ops,~D.canonical_definition(),~Owner,~Unit,~P.Fields,~P.Fields,~P.body,state,I.Fresh{},Unit{},world))
def created(creation:W.Creation<A.Schema,A.Store,D.Resources,U32>) -> Unit:
  match creation:
    case W.Created{_,world}:read(G.read(~A.Schema,~A.Store,~D.Resources,~U32,~D.Ops,~D.canonical_definition(),~Owner,G.attach(~A.Schema,~A.Store,~D.Resources,~U32,~D.Ops,~D.canonical_definition(),~Owner,Owner{F.cells(401),F.cells(501),F.cells(601)})),world)
    case W.CreateRejected{_,_}:Unit{}
def main() -> Unit:
  created(W.create(~A.Schema,~A.Store,~D.Resources,~U32,~A.empty,W.factory(),D.Resources{A.Resource{F.cells(101)},A.Resource{F.cells(201)}}))
