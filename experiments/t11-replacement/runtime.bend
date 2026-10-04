import Base
import ./types.bend as T
import ./model.bend as M

# Affine executable slice. Arrays are never copied; the only observed payload is
# element zero of a one-element owner. This is not a production schema API.
type Cell is Type:
  Cell{slot: U32, values: Array<U32>, tagged: Bool}
type Handle is Data:
  Handle{world: U32, slot: U32}
type Command is Data:
  Spawn{slot: U32, value: U32}
  Target{slot: U32, action: T.Action}
type World is Type:
  World{id: U32, next: U32, rows: List<Cell>, pending: List<&2,Command>}
type Factory is Type:
  Factory{next: U32}
type Step is Data:
  Reserve{value: U32}
  Publish{handle: Handle, action: T.Action}
  Bump{slot: U32}
  Barrier{}

def create_if(ok: Bool, +next: U32) -> Factory & Maybe<World>:
  match ok:
    case False{}: (Factory{next},None{})
    case True{}: (Factory{(next + 1 : U32)},Some{World{next,1,[],[]}})
def create(limit: U32, factory: Factory) -> Factory & Maybe<World>:
  match factory:
    case Factory{+next}: create_if(U32.is_lt(next,limit),next)
def reserve_if(ok: Bool, +id: U32, +next: U32, rows: List<Cell>, pending: List<&2,Command>, value: U32) -> World & Maybe<&2,Handle>:
  match ok:
    case False{}: (World{id,next,rows,pending},None{})
    case True{}: (World{id,(next + 1 : U32),rows,List.append(&2,Command,pending,[Spawn{next,value}])},Some{Handle{id,next}})
def reserve(limit: U32, world: World, value: U32) -> World & Maybe<&2,Handle>:
  match world:
    case World{+id,+next,rows,pending}: reserve_if(U32.is_lt(next,limit),id,next,rows,pending,value)
def publish_if(local: Bool, id: U32, next: U32, rows: List<Cell>, pending: List<&2,Command>, slot: U32, action: T.Action) -> World:
  match local:
    case False{}: World{id,next,rows,pending}
    case True{}: World{id,next,rows,List.append(&2,Command,pending,[Target{slot,action}])}
def publish(world: World, handle: Handle, action: T.Action) -> World:
  match world handle:
    case World{+id,next,rows,pending} Handle{namespace,slot}: publish_if(U32.is_eq(id,namespace),id,next,rows,pending,slot,action)
def modify_one(equal: Bool, action: T.Action, row: Cell, tail: List<Cell>) -> List<Cell>:
  match equal action row:
    case False{} _ r: r <> tail
    case True{} T.Insert{} Cell{slot,values,_}: Cell{slot,values,True{}} <> tail
    case True{} T.Remove{} Cell{slot,values,_}: Cell{slot,values,False{}} <> tail
    case True{} T.Despawn{} _: tail
def modify(+slot: U32, +action: T.Action, rows: List<Cell>) -> List<Cell>:
  match rows:
    case Nil{}: []
    case Con{Cell{+id,values,tag},tail}: modify_one(U32.is_eq(slot,id),action,Cell{id,values,tag},modify(slot,action,tail))
def apply(command: Command, rows: List<Cell>) -> List<Cell>:
  match command:
    case Spawn{slot,value}: Cell{slot,[value : U32^0n],False{}} <> rows
    case Target{slot,action}: modify(slot,action,rows)
def apply_all(commands: List<&2,Command>, rows: List<Cell>) -> List<Cell>:
  match commands:
    case Nil{}: rows
    case Con{command,tail}: apply_all(tail,apply(command,rows))
def flush(world: World) -> World:
  match world:
    case World{id,next,rows,pending}: World{id,next,apply_all(pending,rows),[]}

def observed_cell(+slot: U32, +tag: Bool, pair: Array<U32> & U32) -> Cell & T.Row:
  match pair:
    case (values,value): (Cell{slot,values,tag},T.Row{U32.to_nat(slot),U32.to_nat(value),tag})
def cell_observe(row: Cell) -> Cell & T.Row:
  match row:
    case Cell{slot,values,tag}: observed_cell(slot,tag,values[0])
def join_rest(cell: Cell, data: T.Row, rest: List<Cell> & List<&2,T.Row>) -> List<Cell> & List<&2,T.Row>:
  match rest:
    case (cells,rows): (cell <> cells,data <> rows)
def join_projection(first: Cell & T.Row, rest: List<Cell> & List<&2,T.Row>) -> List<Cell> & List<&2,T.Row>:
  match first:
    case (cell,data): join_rest(cell,data,rest)
def rows_observe(rows: List<Cell>) -> List<Cell> & List<&2,T.Row>:
  match rows:
    case Nil{}: ([],[])
    case Con{row,tail}: join_projection(cell_observe(row),rows_observe(tail))
def commands_project(commands: List<&2,Command>) -> List<&2,T.Command>:
  match commands:
    case Nil{}: []
    case Con{Spawn{slot,value},tail}: T.Spawn{U32.to_nat(slot),U32.to_nat(value)} <> commands_project(tail)
    case Con{Target{slot,action},tail}: T.Target{U32.to_nat(slot),action} <> commands_project(tail)
def world_projection(+id: U32, +next: U32, +pending: List<&2,Command>, result: List<Cell> & List<&2,T.Row>) -> World & T.World:
  match result:
    case (cells,rows): (World{id,next,cells,pending},T.World{U32.to_nat(id),U32.to_nat(next),rows,commands_project(pending)})
def project(world: World) -> World & T.World:
  match world:
    case World{id,next,rows,pending}: world_projection(id,next,pending,rows_observe(rows))
def query_project(selection: T.Selection, result: World & T.World) -> World & List<&2,T.Row>:
  match result:
    case (world,data): (world,M.query(data,selection))
def query(world: World, selection: T.Selection) -> World & List<&2,T.Row>:
  query_project(selection,project(world))
def lookup_data(id: U32, slot: U32, selection: T.Selection, result: World & T.World) -> World & T.Lookup:
  match result:
    case (world,data): (world,M.lookup(data,T.Handle{U32.to_nat(id),U32.to_nat(slot)},selection))
def lookup_project(handle: Handle, selection: T.Selection, result: World & T.World) -> World & T.Lookup:
  match handle:
    case Handle{id,slot}: lookup_data(id,slot,selection,result)
def lookup(world: World, handle: Handle, selection: T.Selection) -> World & T.Lookup:
  lookup_project(handle,selection,project(world))

# Every array has length one by construction. Index zero is established here;
# arbitrary Array<Cell> indices and an indexed layout are separate #16 subjects.
def bumped_cell(slot: U32, tag: Bool, pair: Array<U32> & U32) -> Cell:
  match pair:
    case (values,value): Cell{slot, values[0] <- (value + 1 : U32), tag}
def bump_cell(equal: Bool, row: Cell) -> Cell:
  match equal row:
    case False{} r: r
    case True{} Cell{slot,values,tag}: bumped_cell(slot,tag,values[0])
def bump_rows(+slot: U32, rows: List<Cell>) -> List<Cell>:
  match rows:
    case Nil{}: []
    case Con{Cell{+id,values,tag},tail}: bump_cell(U32.is_eq(slot,id),Cell{id,values,tag}) <> bump_rows(slot,tail)
def bump(world: World, slot: U32) -> World:
  match world:
    case World{id,next,rows,pending}: World{id,next,bump_rows(slot,rows),pending}
def reserve_world(result: World & Maybe<&2,Handle>) -> World:
  match result:
    case (world,_): world
def step(limit: U32, world: World, step: Step) -> World:
  match step:
    case Reserve{value}: reserve_world(reserve(limit,world,value))
    case Publish{handle,action}: publish(world,handle,action)
    case Bump{slot}: bump(world,slot)
    case Barrier{}: flush(world)
def tick(steps: List<&2,Step>, +limit: U32, world: World) -> World:
  match steps:
    case Nil{}: world
    case Con{s,tail}: tick(tail,limit,step(limit,world,s))

# Projections used by propositions; live operations still return their owner.
def snapshot(result: World & T.World) -> T.World:
  match result:
    case (_,data): data
def returned_owner(result: World & T.World) -> World:
  match result:
    case (world,_): world
