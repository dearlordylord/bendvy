import Base
import ./fixture.bend as F
import ../basic-world-statefree-v1/setup.bend as Original
import ../basic-world-statefree-v1/factory.bend as Factory
import ../../../src/ecs/relation-commands.bend as Relation
import ../../../src/ecs/relation-types.bend as G
import ../../../src/ecs/relation-failure-reader.bend as Decl
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/transaction.bend as T
import ../../../src/ecs/commands.bend as Cmd
import ../../../src/ecs/owner-product.bend as Product
import ../../../src/ecs/ordinary-machine-initialization.bend as Init
import ../../../src/ecs/ordinary-machine-operations.bend as Ops
import ../../../src/ecs/machine.bend as M
import ../../../src/ecs/restore-data.bend as R
import ../basic-world-statefree-v1/model.bend as OriginalModel
import ../../../src/ecs/restore-leaf.bend as Stage

def empty(~S:Data,unit:Unit) -> F.Store(~S):Relation.empty(~S,~F.Components(~S),Original.empty(~S,unit))
def initial_resources(~S:Data,resource:OriginalModel.FullResources(~S)) -> F.Resources(~S):
  match resource:
    case Product.Owner{user,_}:Product.Owner{user,Product.Owner{Init.empty(~S,~F.Mode,~U32),Init.empty(~S,~F.Weather,~U32)}}
def resources(~S:Data) -> F.Resources(~S):initial_resources(~S,Original.resources(~S))
def state(~S:Data) -> F.State(~S):Product.Owner{Stage.State{Factory.context(100),[],[],[],[]},Product.Owner{Stage.State{Factory.context(200),[],[],[],[]},Unit{}}}
def stored(~S:Data,graph:G.Graph<S>,observed:F.Components(~S) & Unit) -> F.Store(~S) & Unit:
  match observed:
    case (store,unit):(Relation.Store{store,graph},unit)
def insert(~S:Data,id:U32,tick:U32,payload:Factory.Payload<S>,store:F.Store(~S)) -> F.Store(~S) & Unit:
  match store:
    case Relation.Store{components,graph}:stored(~S,graph,Original.insert(~S,id,tick,payload,components))
def joined(~S:Data,observed:F.World(~S) & Unit) -> F.World(~S):
  match observed:
    case (world,_):world
def populated(~S:Data,+handle:W.Handle<S>,payload:Factory.Payload<S>,observed:F.World(~S) & U32) -> F.World(~S):
  match observed:
    case (world,tick):joined(~S,W.with_store(~S,~F.Store(~S),~F.Resources(~S),~F.Events(~S),~Unit,(store => insert(~S,W.handle_index(~S,handle),tick,payload,store)),world))
def populate(~S:Data,world:F.World(~S),handle:W.Handle<S>,payload:Factory.Payload<S>) -> F.World(~S):populated(~S,handle,payload,W.clock(~S,~F.Store(~S),~F.Resources(~S),~F.Events(~S),world))
def committed(~S:Data,reservation:W.Reservation<S>,barrier:Bool,returned:T.Returned<F.World(~S),Unit>) -> F.World(~S) & W.Reservation<S>:
  match barrier returned:
    case True{},T.Returned{world,_}:(W.barrier(~S,~F.Store(~S),~F.Resources(~S),~F.Events(~S),world),reservation)
    case False{},T.Returned{world,_}:(world,reservation)
def spawned(~S:Data,barrier:Bool,observed:T.Tx<F.World(~S),F.Events(~S)> & W.Reservation<S>) -> F.World(~S) & W.Reservation<S>:
  match observed:
    case (tx,reservation):committed(~S,reservation,barrier,Cmd.tx_finish(~S,~F.Store(~S),~F.Resources(~S),~F.Events(~S),~Unit,tx,T.Success{}))
def spawn(~S:Data,world:F.World(~S),value:U32,barrier:Bool) -> F.World(~S) & W.Reservation<S>:
  spawned(~S,barrier,Cmd.tx_spawn(~S,~F.Store(~S),~F.Resources(~S),~F.Events(~S),~Factory.Payload<S>,~populate(~S),T.begin(~F.World(~S),~F.Events(~S),world),Original.payload(~S,value)))
def initialized(~S:Data,world:F.World(~S)) -> F.World(~S):
  Init.insert_state(~S,~F.Mode,~U32,~F.Resources(~S),~F.mode_take(~S),~F.mode_put(~S),~F.Store(~S),~F.Events(~S),~F.mode_declaration(~S),Init.insert_state(~S,~F.Weather,~U32,~F.Resources(~S),~F.weather_take(~S),~F.weather_put(~S),~F.Store(~S),~F.Events(~S),~F.weather_declaration(~S),world,0),0)
def finished(~S:Data,result:T.Returned<F.World(~S),Unit>) -> F.World(~S):
  match result:
    case T.Returned{world,_}:world
def pending_machines(~S:Data,world:F.World(~S)) -> F.World(~S):
  finished(~S,Cmd.tx_finish(~S,~F.Store(~S),~F.Resources(~S),~F.Events(~S),~Unit,Ops.set(~S,~F.Mode,~U32,~F.Store(~S),~F.Resources(~S),~F.Events(~S),~Init.take_slot(~S,~F.Mode,~U32,~F.Resources(~S),~F.mode_take(~S),~F.mode_put(~S)),~Init.put_slot(~S,~F.Mode,~U32,~F.Resources(~S),~F.mode_take(~S),~F.mode_put(~S),~F.same),~F.same,~F.mode_declaration(~S),Ops.set(~S,~F.Weather,~U32,~F.Store(~S),~F.Resources(~S),~F.Events(~S),~Init.take_slot(~S,~F.Weather,~U32,~F.Resources(~S),~F.weather_take(~S),~F.weather_put(~S)),~Init.put_slot(~S,~F.Weather,~U32,~F.Resources(~S),~F.weather_take(~S),~F.weather_put(~S),~F.same),~F.same,~F.weather_declaration(~S),T.begin(~F.World(~S),~F.Events(~S),world),M.Set{1,False{}}),M.Set{2,False{}}),T.Success{}))
def related(~S:Data,result:T.Tx<F.World(~S),F.Events(~S)> & Relation.QueueStatus) -> F.World(~S):
  match result:
    case (tx,_):finished(~S,Cmd.tx_finish(~S,~F.Store(~S),~F.Resources(~S),~F.Events(~S),~Unit,tx,T.Success{}))
def relate(~S:Data,world:F.World(~S),declaration:Decl.Declaration<S>,source:W.Handle<S>,target:W.Handle<S>) -> F.World(~S):
  match declaration:
    case Decl.Declaration{descriptor}:related(~S,Relation.queue_relate(~S,~F.Components(~S),~F.Resources(~S),~R.Change<S>,T.begin(~F.World(~S),~F.Events(~S),world),descriptor,source,target))
