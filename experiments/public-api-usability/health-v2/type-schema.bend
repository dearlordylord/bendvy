import Base
import ../../../src/ecs/trace-facts.bend as Trace
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/column.bend as Col
import ../../../src/ecs/component.bend as Cmp
import ../../../src/ecs/commands.bend as Cmd
import ../../../src/ecs/transaction.bend as T
import ../../../src/ecs/ordinary-declaration.bend as Identity

type Schema is Data: Schema{}
type Resources is Type: Resources{}
type Store is Type: Store{cells:Col.Column<Schema,Array<U32>>}
def World() -> Type:W.World<Schema,Store,Resources,Unit>

type CellsView is Data: CellsView{first:U32,second:U32}
type CellsToken is Data: CellsToken{}

def cells(first:U32,second:U32) -> Array<U32>:
  Array.set(U32,Array.new(U32,2n,first),1,second)

def view_second(first:U32,result:Array<U32> & U32) -> Array<U32> & CellsView:
  match result:
    case (owner,second):(owner,CellsView{first,second})

def view_first(result:Array<U32> & U32) -> Array<U32> & CellsView:
  match result:
    case (owner,first):view_second(first,Array.get(U32,owner,1))

def view_cells(owner:Array<U32>) -> Array<U32> & CellsView:
  view_first(Array.get(U32,owner,0))

def take_cells(store:Store) -> Unit & Col.Column<Schema,Array<U32>>:
  match store:
    case Store{column}:(Unit{},column)

def put_cells(_:Unit,column:Col.Column<Schema,Array<U32>>) -> Store:
  Store{column}

def family() -> Cmp.Family<Schema,Store,Unit,Array<U32>,CellsView,CellsToken,take_cells,put_cells,view_cells>:
  Cmp.Family{"cells"}

def identity() -> Identity.Declaration<Schema,Array<U32>>:
  Identity.component(~Schema,~Array<U32>,"cells")

def empty(_:Unit) -> Store:
  Store{Col.empty_indexed(~Schema,~Array<U32>)}

def installed(result:Cmp.Replacement<World(),Array<U32>>) -> World():
  match result:
    case Cmp.Replaced{world,_}:world
    case Cmp.ReplaceRejected{world,_,_}:world

def populate(world:World(),handle:W.Handle<Schema>,payload:Array<U32>) -> World():
  installed(Cmp.structural_replace(~Schema,~Store,~Resources,~Unit,~Unit,~Array<U32>,~CellsView,~CellsToken,~take_cells,~put_cells,~view_cells,family(),world,handle,Some{payload}))

type Spawned is Type:
  Spawned{world:World(),handle:W.Handle<Schema>}
  SpawnRejected{world:World(),error:W.WorldError}

def spawn_finished(result:T.Tx<World(),Unit> & W.Reservation<Schema>) -> Spawned:
  match result:
    case (T.Tx{world,_,commands,_,_},W.Reserved{handle}):Spawned{Cmd.enqueue(~Schema,~Store,~Resources,~Unit,world,commands),handle}
    case (T.Tx{world,_,_,_,_},W.ReservationRejected{error}):SpawnRejected{world,error}

def spawn(world:World(),payload:Array<U32>) -> Spawned:
  spawn_finished(Cmd.tx_spawn(~Schema,~Store,~Resources,~Unit,~Array<U32>,~populate,T.Tx{world,[],[],[],Trace.Off{}},payload))

def barrier(world:World()) -> World():
  W.barrier(~Schema,~Store,~Resources,~Unit,world)

def text_result(result:World() & Cmp.Access<CellsView>) -> World() & String:
  match result:
    case (world,Cmp.Found{CellsView{first,second}}):(world,U32.show(first) ++ "," ++ U32.show(second))
    case (world,_):(world,"missing")

def read_text_keep(returned:W.Handle<Schema>,result:World() & Cmp.Access<CellsView>) -> World() & (W.Handle<Schema> & String):
  match result:
    case (world,Cmp.Found{CellsView{first,second}}):(world,(returned,U32.show(first) ++ "," ++ U32.show(second)))
    case (world,_):(world,(returned,"missing"))

def read_text(world:World(),handle:W.Handle<Schema>) -> World() & (W.Handle<Schema> & String):
  match handle:
    case W.Handle{+namespace,+key}:
      read_text_keep(W.Handle{namespace,key},Cmp.get(~Schema,~Store,~Resources,~Unit,~Unit,~Array<U32>,~CellsView,~CellsToken,~take_cells,~put_cells,~view_cells,family(),world,W.Handle{namespace,key}))
