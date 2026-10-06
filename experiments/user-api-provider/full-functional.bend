import Base
import ../../src/ecs/component.bend as C
import ../../src/ecs/column.bend as Col
import ../../src/ecs/world.bend as W
import ../../src/ecs/transaction.bend as T
import ../../src/ecs/query.bend as Q
import ../../src/ecs/provider.bend as Pv

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
  W.World{1,2,1,Array.new(Bool,1n,True{}),2,1n,Store{Col.Column{ALeaf{Some{Cell{[7 : U32^1n],1}}}}},Res{0},[],[],[],1}
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

type CanaryError is Data:
  CanaryRejected{}
def resource_project(res: Res) -> Res & U32:
  match res:
    case Res{+tick}: (Res{tick},tick)
def populate(world: World(),handle: W.Handle<Game>,payload: Cell) -> World():
  world
def clear(store: Store,handle: W.Handle<Game>) -> Store:
  store

def spawned(~H: Type,~get: H -> H & C.Access<U32>,~set: H -> Cell -> H,~aux: H -> H & C.Access<U32>,~rg: H -> H & U32,~rs: H -> Res -> H,~emit: H -> GameEvent -> H,~despawn: H -> H,~spawn: H -> Cell -> H & W.Reservation<Game>,result: H & W.Reservation<Game>,fail: Bool,handle: W.Handle<Game>) -> H & T.Outcome<CanaryError>:
  match result fail:
    case (ctx,W.Reserved{_}) True{}: (ctx,T.Failure{CanaryRejected{}})
    case (ctx,W.Reserved{_}) False{}: (ctx,T.Success{})
    case (ctx,_) _: (ctx,T.Failure{CanaryRejected{}})
def third(~H: Type,~get: H -> H & C.Access<U32>,~set: H -> Cell -> H,~aux: H -> H & C.Access<U32>,~rg: H -> H & U32,~rs: H -> Res -> H,~emit: H -> GameEvent -> H,~despawn: H -> H,~spawn: H -> Cell -> H & W.Reservation<Game>,fail: Bool,+handle: W.Handle<Game>,result: H & C.Access<U32>) -> H & T.Outcome<CanaryError>:
  match result:
    case (ctx,C.Found{309}): spawned(~H,~get,~set,~aux,~rg,~rs,~emit,~despawn,~spawn,spawn(emit(rs(ctx,Res{12}),GameEvent{309}),Cell{[4 : U32^1n],4}),fail,handle)
    case (ctx,_): (ctx,T.Failure{CanaryRejected{}})
def second(~H: Type,~get: H -> H & C.Access<U32>,~set: H -> Cell -> H,~aux: H -> H & C.Access<U32>,~rg: H -> H & U32,~rs: H -> Res -> H,~emit: H -> GameEvent -> H,~despawn: H -> H,~spawn: H -> Cell -> H & W.Reservation<Game>,fail: Bool,handle: W.Handle<Game>,result: H & C.Access<U32>) -> H & T.Outcome<CanaryError>:
  match result:
    case (ctx,C.Found{208}): third(~H,~get,~set,~aux,~rg,~rs,~emit,~despawn,~spawn,fail,handle,get(set(ctx,Cell{[9 : U32^1n],3})))
    case (ctx,_): (ctx,T.Failure{CanaryRejected{}})
def first(~H: Type,~get: H -> H & C.Access<U32>,~set: H -> Cell -> H,~aux: H -> H & C.Access<U32>,~rg: H -> H & U32,~rs: H -> Res -> H,~emit: H -> GameEvent -> H,~despawn: H -> H,~spawn: H -> Cell -> H & W.Reservation<Game>,fail: Bool,handle: W.Handle<Game>,result: H & C.Access<U32>) -> H & T.Outcome<CanaryError>:
  match result:
    case (ctx,C.Found{107}): second(~H,~get,~set,~aux,~rg,~rs,~emit,~despawn,~spawn,fail,handle,get(set(ctx,Cell{[8 : U32^1n],2})))
    case (ctx,_): (ctx,T.Failure{CanaryRejected{}})
def body(~H: Type,~get: H -> H & C.Access<U32>,~set: H -> Cell -> H,~aux: H -> H & C.Access<U32>,~rg: H -> H & U32,~rs: H -> Res -> H,~emit: H -> GameEvent -> H,~despawn: H -> H,~spawn: H -> Cell -> H & W.Reservation<Game>,fail: Bool,handle: W.Handle<Game>,ctx: H) -> H & T.Outcome<CanaryError>:
  first(~H,~get,~set,~aux,~rg,~rs,~emit,~despawn,~spawn,fail,handle,get(ctx))

def pending_join(command: World() -> World(),sized: List<(World() -> World())> & U32) -> List<(World() -> World())> & U32:
  match sized:
    case (commands,size): (command <> commands,(size + 1 : U32))
def pending_size(commands: List<(World() -> World())>) -> List<(World() -> World())> & U32:
  match commands:
    case []: ([],0)
    case command <> rest: pending_join(command,pending_size(rest))
def metadata_join(+ns: U32,+next: U32,+high: U32,live: Array<Bool>,+cap: U32,+depth: Nat,store: Store,+tick: U32,+events: List<&2,GameEvent>,+regs: List<&2,W.RegistrationMeta>,+sys: U32,sized: List<(World() -> World())> & U32) -> World() & U32:
  match sized:
    case (pending,count):
      (W.World{ns,next,high,live,cap,depth,store,Res{tick},events,pending,regs,sys},((next + (tick * 10 : U32) : U32) + ((U32.from_nat(List.length(&2,GameEvent,events)) * 1000 : U32) + (count * 10000 : U32) : U32) : U32))
def metadata(world: World()) -> World() & U32:
  match world:
    case W.World{+ns,+next,+high,live,+cap,+depth,store,Res{+tick},+events,pending,+regs,+sys}:
      metadata_join(ns,next,high,live,cap,depth,store,tick,events,regs,sys,pending_size(pending))
def final_observed(observed: World() & C.Access<U32>,meta: U32) -> List<&2,U32>:
  match observed:
    case (_,C.Found{value}): [value,meta]
    case _: [993]
def final_metadata(observed: World() & U32) -> List<&2,U32>:
  match observed:
    case (world,meta): final_observed(C.get(~Game,~Store,~Res,~GameEvent,~Unit,~Cell,~U32,~Token,~take,~put,~project,family(),world,W.Handle{1,1}),meta)
def finished(result: T.Returned<World(),Pv.Error<CanaryError>>) -> List<&2,U32>:
  match result:
    case T.Returned{world,_}: final_metadata(metadata(world))
def main() -> List<&2,List<&2,U32>>:
  [finished(Q.each_rw_read(~Game,~Store,~Res,~GameEvent,~Unit,~Cell,~U32,~Token,~take,~put,~project,~Unit,~Cell,~U32,~Token,~take,~put,~project,~U32,~resource_project,~Cell,~populate,~clear,~Bool,~CanaryError,~body,family(),family(),Q.Optional{},initial(),True{})),finished(Q.each_rw_read(~Game,~Store,~Res,~GameEvent,~Unit,~Cell,~U32,~Token,~take,~put,~project,~Unit,~Cell,~U32,~Token,~take,~put,~project,~U32,~resource_project,~Cell,~populate,~clear,~Bool,~CanaryError,~body,family(),family(),Q.Optional{},initial(),False{}))]
