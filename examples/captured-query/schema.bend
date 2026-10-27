import Base
import ./payload.bend as P
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-composer-layout.bend as L
import ../../src/ecs/execution-resource-policy.bend as Policy
import ../../src/ecs/execution-composer-schema.bend as Setup
import ../../src/ecs/execution-command-publication.bend as Publish
import ../../src/ecs/execution-command-buffer.bend as Buffer
import ../../src/ecs/change-tick.bend as Tick

type Workshop is Data:Workshop{}
type Garden is Data:Garden{}
def components() -> L.Layout:L.LayoutLeaf{Array<U32>,P.Tree,P.observe,"Cells",Policy.Ordinary{}}
def resources() -> L.Layout:L.EmptyLayout{}
def Store(~S:Data) -> Type:L.columns(~S,components())
def World(~S:Data) -> Type:W.World<S,Store(~S),Unit,Unit>
def cells(+start:U32) -> Array<U32>:ANode{ANode{ALeaf{start},ALeaf{U32.add(start,1)}},ANode{ALeaf{U32.add(start,2)},ALeaf{U32.add(start,3)}}}
def create() -> Setup.Initialized<Workshop,components(),resources(),Unit>:Setup.create(~Workshop,~components(),~resources(),~Unit,W.factory(),Unit{})
def inserted(~S:Data,result:World(~S) & Buffer.Receipt<S,Array<U32>,Maybe<&1,Array<U32>>>) -> World(~S):
  match result:
    case (world,_):world
def activated(~S:Data,+handle:W.Handle<S>,value:Array<U32>,result:World(~S) & W.Status) -> World(~S):
  match result:
    case (world,W.Accepted{}):inserted(~S,Publish.family(~S,~Unit,~Unit,~components(),~L.AtLeaf{},world,handle,Some{value},Tick.zero()))
    case (world,_):world
def reserved(~S:Data,value:Array<U32>,result:World(~S) & W.Reservation<S>) -> World(~S):
  match result:
    case (world,W.Reserved{+handle}):activated(~S,handle,value,W.activate(~S,~Store(~S),~Unit,~Unit,world,handle))
    case (world,_):world
def seed(~S:Data,world:World(~S)) -> World(~S):reserved(~S,cells(1),W.reserve_id(~S,~Store(~S),~Unit,~Unit,reserved(~S,cells(0),W.reserve_id(~S,~Store(~S),~Unit,~Unit,world))))
