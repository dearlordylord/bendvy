import Base
import ./gameplay.bend as G
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-composer-layout.bend as L
import ../../src/ecs/execution-resource-policy.bend as Policy
import ../../src/ecs/execution-composer-schema.bend as Setup

type Schema is Data:Schema{}
def project(body:G.Body) -> G.Body & G.Body:
  match body:
    case G.Body{+x,+y,+kind,+seed,+hp,+speed,+target,+visited,+age}:(G.Body{x,y,kind,seed,hp,speed,target,visited,age},G.Body{x,y,kind,seed,hp,speed,target,visited,age})
def components() -> L.Layout:L.LayoutLeaf{G.Body,G.Body,project,"body",Policy.Ordinary{}}
def resources() -> L.Layout:L.EmptyLayout{}
def Columns() -> Type:L.columns(~Schema,components())
def Resources() -> Type:L.resources(~Schema,resources())
def World() -> Type:W.World<Schema,Columns(),Resources(),Unit>
def create(factory:W.Factory) -> Setup.Initialized<Schema,components(),resources(),Unit>:Setup.create(~Schema,~components(),~resources(),~Unit,factory,Unit{})
