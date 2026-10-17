import Base
import model.bend as F
import factory.bend as Factory
import ../../../src/ecs/owner-product.bend as Product
import ../../../src/ecs/snapshot-leaf.bend as Leaf
import ../../../src/ecs/persistence-declaration.bend as Persist
import ../../../src/ecs/column.bend as Col
import ../../../src/ecs/decode-data.bend as D
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/commands.bend as Cmd
import ../../../src/ecs/transaction.bend as T
import ../../../src/ecs/owned-event-log.bend as Log

def raw(+value:U32) -> D.Raw:D.Array{[D.Number{value},D.Number{(value + 1 : U32)}]}
def payload(~S:Data,+value:U32) -> Factory.Payload<S>:Factory.Payload{raw(value),raw(value),ANode{ALeaf{value},ALeaf{(value + 1 : U32)}}}
def empty(~S:Data,unit:Unit) -> F.FullStore(~S):Product.Owner{Leaf.Component{Col.empty(~S,~Factory.Payload<S>),Persist.constructed(~S,~Factory.Payload<S>,~Factory.component_identity(~S),~Factory.project(~S),Factory.codec())},Product.Owner{Unit{},Unit{}}}
def resources(~S:Data) -> F.FullResources(~S):Product.Owner{Product.Owner{Unit{},Product.Owner{Leaf.Resource{payload(~S,30),Persist.constructed(~S,~Factory.Payload<S>,~Factory.resource_identity(~S),~Factory.project(~S),Factory.codec())},Leaf.TransientResource{ANode{ALeaf{90},ALeaf{91}},Persist.transient(~S,~Array<U32>,~Factory.transient_identity(~S))}}},Product.Owner{Log.empty(~Array<U32>),Unit{}}}
def swapped(~S:Data,+id:U32,tick:U32,declaration:Persist.Constructed<S,Factory.Payload<S>,Factory.component_identity(~S),Factory.project(~S)>,rest:F.ResourceGroupStore(~S),result:Col.SwapOutcome<S,Factory.Payload<S>>) -> F.FullStore(~S) & Unit:
  match result:
    case Col.Accepted{column,_}:(Product.Owner{Leaf.Component{Col.mark(~S,~Factory.Payload<S>,column,id,True{},False{},tick),declaration},rest},Unit{})
    case Col.Rejected{column,_}:(Product.Owner{Leaf.Component{column,declaration},rest},Unit{})
def insert(~S:Data,+id:U32,tick:U32,payload:Factory.Payload<S>,store:F.FullStore(~S)) -> F.FullStore(~S) & Unit:
  match store:
    case Product.Owner{Leaf.Component{column,declaration},rest}:swapped(~S,id,tick,declaration,rest,Col.swap(~S,~Factory.Payload<S>,Col.ensure(~S,~Factory.Payload<S>,column,id),id,Some{payload}))
def unit_returned(~S:Data,observed:F.World(~S) & Unit) -> F.World(~S):
  match observed:
    case (world,unit):world
def populated(~S:Data,+handle:W.Handle<S>,payload:Factory.Payload<S>,observed:F.World(~S) & U32) -> F.World(~S):
  match observed:
    case (world,tick):
      unit_returned(~S,W.with_store(~S,~F.FullStore(~S),~F.FullResources(~S),~F.Events(~S),~Unit,store => insert(~S,W.handle_index(~S,handle),tick,payload,store),world))

def populate(~S:Data,world:F.World(~S),handle:W.Handle<S>,payload:Factory.Payload<S>) -> F.World(~S):populated(~S,handle,payload,W.clock(~S,~F.FullStore(~S),~F.FullResources(~S),~F.Events(~S),world))
def committed(~S:Data,reservation:W.Reservation<S>,barrier:Bool,returned:T.Returned<F.World(~S),Unit>) -> F.World(~S) & W.Reservation<S>:
  match barrier returned:
    case True{},T.Returned{world,_}:(W.barrier(~S,~F.FullStore(~S),~F.FullResources(~S),~F.Events(~S),world),reservation)
    case False{},T.Returned{world,_}:(world,reservation)
def spawned(~S:Data,barrier:Bool,observed:T.Tx<F.World(~S),F.Events(~S)> & W.Reservation<S>) -> F.World(~S) & W.Reservation<S>:
  match observed:
    case (tx,reservation):committed(~S,reservation,barrier,Cmd.tx_finish(~S,~F.FullStore(~S),~F.FullResources(~S),~F.Events(~S),~Unit,tx,T.Success{}))
def spawn(~S:Data,world:F.World(~S),value:U32,barrier:Bool) -> F.World(~S) & W.Reservation<S>:spawned(~S,barrier,Cmd.tx_spawn(~S,~F.FullStore(~S),~F.FullResources(~S),~F.Events(~S),~Factory.Payload<S>,~populate(~S),T.begin(~F.World(~S),~F.Events(~S),world),payload(~S,value)))
