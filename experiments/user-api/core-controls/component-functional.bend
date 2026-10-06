import Base
import ../../../src/ecs/component.bend as C
import ../../../src/ecs/column.bend as Col
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/transaction.bend as T

type Game is Data:
  Game{}
type Token is Data:
  Token{}
type Cell is Type:
  Cell{owned: Array<U32>, x: U32}
type Store is Type:
  Store{column: Col.Column<Game,Cell>}
type Res is Type:
  Res{tick: U32}
type GameEvent is Data:
  GameEvent{amount: U32}
def World() -> Type:
  W.World<Game,Store,Res,GameEvent>
def Tx() -> Type:
  T.Tx<World(),GameEvent>
def take(store: Store) -> Unit & Col.Column<Game,Cell>:
  match store:
    case Store{column}: (Unit{},column)
def put(rest: Unit,column: Col.Column<Game,Cell>) -> Store:
  Store{column}
def projected(+x: U32,owned: Array<U32> & U32) -> Cell & U32:
  match owned:
    case (owned,v): (Cell{owned,x},((x * 100 : U32) + v : U32))
def project(cell: Cell) -> Cell & U32:
  match cell:
    case Cell{owned,+x}: projected(x,Array.get(U32,owned,0))
def Family() -> Data:
  C.Family<Game,Store,Unit,Cell,U32,Token,take,put,project>
def family() -> Family():
  C.define(~Game,~Store,~Res,~GameEvent,~Unit,~Cell,~U32,~Token,~take,~put,~project,"cell")
def initial() -> World():
  W.World{1,2,1,Array.new(Bool,1n,True{}),2,1n,Store{Col.Column{ALeaf{Some{Cell{[7 : U32^1n],1}}},[]}},Res{0},[],[],[],1,0}
def read_value(result: C.Access<U32>) -> U32:
  match result:
    case C.Found{value}: value
    case C.MissingEntity{}: 999
    case C.ComponentAbsent{}: 998
def record(observed: World() & C.Access<U32>,values: List<&2,U32>) -> List<&2,U32>:
  match observed:
    case (_,value): List.append(&2,U32,values,[read_value(value)])
def reverted(tx: Tx(),values: List<&2,U32>) -> List<&2,U32>:
  match tx:
    case T.Tx{world,undo,_,_}:
      record(C.get(~Game,~Store,~Res,~GameEvent,~Unit,~Cell,~U32,~Token,~take,~put,~project,family(),T.rollback(~World(),undo,world),W.Handle{1,1}),values)
def second_read(observed: Tx() & C.Access<U32>,values: List<&2,U32>) -> List<&2,U32>:
  match observed:
    case (tx,value): reverted(tx,List.append(&2,U32,values,[read_value(value)]))
def second_written(result: C.SetResult<Tx(),Cell>,values: List<&2,U32>) -> List<&2,U32>:
  match result:
    case C.Written{tx}: second_read(C.tx_get(~Game,~Store,~Res,~GameEvent,~Unit,~Cell,~U32,~Token,~take,~put,~project,family(),tx,W.Handle{1,1}),values)
    case _: [997]
def first_read(observed: Tx() & C.Access<U32>,values: List<&2,U32>) -> List<&2,U32>:
  match observed:
    case (tx,value): second_written(C.tx_set(~Game,~Store,~Res,~GameEvent,~Unit,~Cell,~U32,~Token,~take,~put,~project,family(),tx,W.Handle{1,1},Cell{[9 : U32^1n],3}),List.append(&2,U32,values,[read_value(value)]))
def first_written(result: C.SetResult<Tx(),Cell>,values: List<&2,U32>) -> List<&2,U32>:
  match result:
    case C.Written{tx}: first_read(C.tx_get(~Game,~Store,~Res,~GameEvent,~Unit,~Cell,~U32,~Token,~take,~put,~project,family(),tx,W.Handle{1,1}),values)
    case _: [996]
def start(observed: World() & C.Access<U32>) -> List<&2,U32>:
  match observed:
    case (world,value): first_written(C.tx_set(~Game,~Store,~Res,~GameEvent,~Unit,~Cell,~U32,~Token,~take,~put,~project,family(),T.begin(~World(),~GameEvent,world),W.Handle{1,1},Cell{[8 : U32^1n],2}),[read_value(value)])
def rollback_demo() -> List<&2,U32>:
  start(C.get(~Game,~Store,~Res,~GameEvent,~Unit,~Cell,~U32,~Token,~take,~put,~project,family(),initial(),W.Handle{1,1}))

def foreign_value(world: World(),owner: Cell & U32) -> List<&2,U32>:
  match owner:
    case (_,value): record(C.get(~Game,~Store,~Res,~GameEvent,~Unit,~Cell,~U32,~Token,~take,~put,~project,family(),world,W.Handle{1,1}),[value])
def foreign(result: C.Replacement<World(),Cell>) -> List<&2,U32>:
  match result:
    case C.ReplaceRejected{world,Some{owner},W.MissingEntity{}}: foreign_value(world,project(owner))
    case _: [995]
def removed(result: C.RemoveResult<Tx()>) -> List<&2,U32>:
  match result:
    case C.Removed{tx}: second_read(C.tx_get(~Game,~Store,~Res,~GameEvent,~Unit,~Cell,~U32,~Token,~take,~put,~project,family(),tx,W.Handle{1,1}),[])
    case _: [994]
def main() -> List<&2,List<&2,U32>>:
  [rollback_demo(),foreign(C.replace(~Game,~Store,~Res,~GameEvent,~Unit,~Cell,~U32,~Token,~take,~put,~project,family(),initial(),W.Handle{2,1},Some{Cell{[4 : U32^1n],4}})),removed(C.tx_remove(~Game,~Store,~Res,~GameEvent,~Unit,~Cell,~U32,~Token,~take,~put,~project,family(),T.begin(~World(),~GameEvent,initial()),W.Handle{1,1}))]
