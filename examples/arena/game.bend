import Base
import ../../src/ecs/world.bend as W
import ../../src/ecs/column.bend as Col
import ../../src/ecs/component.bend as C
import ../../src/ecs/commands.bend as Cmd
import ../../src/ecs/transaction.bend as T
import ../../src/ecs/compose.bend as Q
import ../../src/ecs/capabilities.bend as Cap

type Schema is Data: Schema{}
# kind: 0 = player, 1 = enemy, 2 = pickup. Pixels at a fixed 60 Hz.
type Body is Data: Body{x: F32,y: F32,kind: U32,seed: U32}
type Token is Data: Token{}
type Store is Type: Store{bodies: Col.Column<Schema,Body>}
def take(store: Store) -> Unit & Col.Column<Schema,Body>:
  match store:
    case Store{column}: (Unit{},column)
def put(unit: Unit,column: Col.Column<Schema,Body>) -> Store: Store{column}
def project(body: Body) -> Body & Body:
  match body:
    case Body{+x,+y,+kind,+seed}: (Body{x,y,kind,seed},Body{x,y,kind,seed})
def family() -> C.Family<Schema,Store,Unit,Body,Body,Token,take,put,project>:
  C.Family{"body"}
def empty(unit: Unit) -> Store: Store{Col.empty(~Schema,~Body)}
def World() -> Type: W.World<Schema,Store,Unit,Unit>
def populate_result(result: C.Replacement<World(),Body>) -> World():
  match result:
    case C.Replaced{world,_}: world
    case C.ReplaceRejected{world,_,_}: world
def populate(world: World(),handle: W.Handle<Schema>,body: Body) -> World():
  populate_result(C.structural_replace(~Schema,~Store,~Unit,~Unit,~Unit,~Body,~Body,~Token,~take,~put,~project,family(),world,handle,Some{body}))
def spawn_finish(result: T.Tx<World(),Unit> & W.Reservation<Schema>) -> World():
  match result:
    case (T.Tx{world,_,commands,_},W.Reserved{_}): Cmd.enqueue(~Schema,~Store,~Unit,~Unit,world,commands)
    case (T.Tx{world,_,_,_},W.ReservationRejected{_}): world
# Every reservation is published, then made visible at an explicit barrier.
def spawn(world: World(),body: Body) -> World():
  spawn_finish(Cmd.tx_spawn(~Schema,~Store,~Unit,~Unit,~Body,~populate,T.Tx{world,[],[],[]},body))
def seed_x(+seed: U32) -> F32: U32.to_f32(((seed * 137 + 71) % 740 : U32))
def seed_y(+seed: U32) -> F32: U32.to_f32(((seed * 83 + 29) % 440 : U32))
def initial(+seed: U32,+kind: U32) -> Body: Body{(seed_x(seed) + 30.0 : F32),(seed_y(seed) + 30.0 : F32),kind,seed}
def populate_many(remaining: Nat,+seed: U32,+kind: U32,world: World(),+rows: List<&2,Body>) -> World() & List<&2,Body>:
  match remaining:
    case 0n: (world,rows)
    case 1n+rest: populate_many(rest,(seed + 1 : U32),kind,spawn(world,initial(seed,kind)),initial(seed,kind) <> rows)
def enemies(result: World() & List<&2,Body>) -> World() & List<&2,Body>:
  (world,+rows) = result
  populate_many(10n,30,2,world,rows)
type Boot is Type: Boot{world: World(),rows: List<&2,Body>}
  BootRefused{}
def booted(result: World() & List<&2,Body>) -> Boot:
  (world,+rows) = result
  Boot{world,rows}
def setup(created: W.Creation<Schema,Store,Unit,Unit>) -> Boot:
  match created:
    case W.Created{_,world}: booted(enemies(populate_many(6n,1,1,spawn(world,Body{400.0,250.0,0,0}),[Body{400.0,250.0,0,0}])))
    case W.CreateRejected{_,_}: BootRefused{}

type Args is Data: Args{px: F32,py: F32,tick: U32}
type Row is Data: Row{body: Body,hit: U32,points: U32}
type Error is Data: MissingBody{}
type Ops<-H: Type> is Type: Ops{body: Cap.Write<H,Body,Body>}
def OpsType(H: Type) -> Type: Ops<H>
def body_cap(~H: Type,ops: Ops<H>) -> Cap.Write<H,Body,Body>:
  match ops:
    case Ops{body}: body
# Each system is checked against abstract H; gameplay cannot see the Store.
def within(+x: F32,+y: F32,+px: F32,+py: F32) -> Bool:
  F32.is_lt(((x - px) * (x - px) + (y - py) * (y - py) : F32),324.0)
def direction(less: Bool) -> F32:
  match less:
    case True{}: 0.82
    case False{}: (0.0 - 0.82 : F32)
def relocate(+seed: U32,+tick: U32,+kind: U32) -> Body: initial((seed + tick : U32),kind)
def pickup(collided: Bool,+body: Body,+tick: U32,+seed: U32) -> Row:
  match collided:
    case True{}: Row{relocate(seed,tick,2),0,1}
    case False{}: Row{body,0,0}
def enemy(collided: Bool,+body: Body,+tick: U32,+seed: U32) -> Row:
  match collided:
    case True{}: Row{relocate(seed,tick,1),1,0}
    case False{}: Row{body,0,0}
def enemy_moved(+x: F32,+y: F32,+px: F32,+py: F32,+seed: U32,+tick: U32) -> Row:
  enemy(within(x,y,px,py),Body{x,y,1,seed},tick,seed)
def update(body: Body,args: Args) -> Row:
  match body args:
    case Body{_,_,0,+seed} Args{+px,+py,_}: Row{Body{px,py,0,seed},0,0}
    case Body{+x,+y,1,+seed} Args{+px,+py,+tick}:
      enemy_moved((x + direction(F32.is_lt(x,px)) : F32),(y + direction(F32.is_lt(y,py)) : F32),px,py,seed,tick)
    case Body{+x,+y,_,+seed} Args{+px,+py,+tick}: pickup(within(x,y,px,py),Body{x,y,2,seed},tick,seed)
def write_row(~H: Type,~ops: Ops<H>,ctx: H,+row: Row) -> H & (T.Outcome<Error> & Row):
  match row:
    case Row{+body,+hit,+points}: (Cap.set(~H,~Body,~Body,~body_cap(~H,ops),ctx,body),(T.Success{},Row{body,hit,points}))
def observed(~H: Type,~ops: Ops<H>,+args: Args,result: H & C.Access<Body>) -> H & (T.Outcome<Error> & Row):
  match result:
    case (ctx,C.Found{body}): write_row(~H,~ops,ctx,update(body,args))
    case (ctx,_): (ctx,(T.Failure{MissingBody{}},Row{Body{0.0,0.0,0,0},0,0}))
def body_system(~H: Type,~ops: Ops<H>,args: Args,ctx: H) -> H & (T.Outcome<Error> & Row):
  observed(~H,~ops,args,Cap.get(~H,~Body,~Body,~body_cap(~H,ops),ctx))
def Frame() -> Type: Q.Frame<Schema,Store,Unit,Unit>
def selected(frame: Frame()) -> Frame() & Bool:
  Q.family_match(~Schema,~Store,~Unit,~Unit,~Unit,~Body,~Body,~Token,~take,~put,~project,~family(),~Q.Required{},frame)
def plan() -> Q.Plan<Schema,Store,Unit,Unit,OpsType>:
  Q.Plan{Ops{Q.write_family(~Schema,~Store,~Unit,~Unit,~Unit,~Body,~Body,~Token,~take,~put,~project,~family())},selected}
def execute(world: World(),args: Args) -> Q.Executed<World(),Q.Error<Error>,Row>:
  Q.each(~Schema,~Store,~Unit,~Unit,~OpsType,~Args,~Error,~Row,~plan(),~body_system,args,world)

type Totals is Data: Totals{hits: U32,points: U32,bodies: List<&2,Body>}
def accumulate(rows: List<&2,Row>,+hits: U32,+points: U32,+bodies: List<&2,Body>) -> Totals:
  match rows:
    case []: Totals{hits,points,List.reverse(&2,Body,bodies)}
    case Row{+body,+hit,+point} <> rest: accumulate(rest,(hits + hit : U32),(points + point : U32),body <> bodies)
type State is Type: State{world: World(),px: F32,py: F32,hp: U32,score: U32,tick: U32,cooldown: U32,bodies: List<&2,Body>}
type Packet is Type: Packet{state: State,frame: String}
  Failed{error: String}
def body_json(body: Body) -> String:
  match body:
    case Body{x,y,kind,_}: "[" ++ F32.show(x) ++ "," ++ F32.show(y) ++ "," ++ U32.show(kind) ++ "]"
def rows_json(rows: List<&2,Body>) -> String:
  match rows:
    case []: ""
    case body <> []: body_json(body)
    case body <> rest: body_json(body) ++ "," ++ rows_json(rest)
def packet(state: State) -> Packet:
  match state:
    case State{world,+px,+py,+hp,+score,+tick,+cooldown,+bodies}:
      Packet{State{world,px,py,hp,score,tick,cooldown,bodies},"{\"hp\":" ++ U32.show(hp) ++ ",\"score\":" ++ U32.show(score) ++ ",\"tick\":" ++ U32.show(tick) ++ ",\"cooldown\":" ++ U32.show(cooldown) ++ ",\"bodies\":[" ++ rows_json(bodies) ++ "]}"}
def started(result: Boot) -> Packet:
  match result:
    case Boot{world,+bodies}: packet(State{W.barrier(~Schema,~Store,~Unit,~Unit,world),400.0,250.0,5,0,0,0,bodies})
    case BootRefused{}: Failed{"World creation refused"}
def start() -> Packet: started(setup(W.create(~Schema,~Store,~Unit,~Unit,~empty,W.factory(),Unit{})))
def clamp_low(value: F32,below: Bool) -> F32:
  match below:
    case True{}: 20.0
    case False{}: value
def clamp_high(value: F32,above: Bool,limit: F32) -> F32:
  match above:
    case True{}: limit
    case False{}: value
def clamp(+value: F32,+limit: F32) -> F32: clamp_low(clamp_high(value,F32.is_lt(limit,value),limit),F32.is_lt(value,20.0))
def damage(active: Bool,+hp: U32,+cooldown: U32) -> U32 & U32:
  match active:
    case True{}: ((hp - 1 : U32),60)
    case False{}: (hp,cooldown)
def cooled(cooldown: U32) -> U32:
  match cooldown:
    case 0: 0
    case +value: (value - 1 : U32)
def damaged(world: World(),+px: F32,+py: F32,+score: U32,+tick: U32,+bodies: List<&2,Body>,result: U32 & U32) -> Packet:
  (hp,cooldown) = result
  packet(State{world,px,py,hp,score,tick,cooldown,bodies})
def totals(world: World(),+px: F32,+py: F32,+hp: U32,+score: U32,+tick: U32,+cooldown: U32,value: Totals) -> Packet:
  match value:
    case Totals{+hits,+points,+bodies}:
      damaged(world,px,py,(score + points : U32),tick,bodies,damage(Bool.and(U32.is_lt(0,hits),U32.is_eq(cooldown,0)),hp,cooldown))
def executed(+px: F32,+py: F32,+hp: U32,+score: U32,+tick: U32,+cooldown: U32,+prior: List<&2,Body>,result: Q.Executed<World(),Q.Error<Error>,Row>) -> Packet:
  match result:
    case Q.Executed{world,T.Success{},rows}: totals(world,px,py,hp,score,tick,cooldown,accumulate(rows,0,0,[]))
    case Q.Executed{_,T.Failure{_},_}: Failed{"ECS query failed"}
def advance(state: State,+dx: F32,+dy: F32) -> Packet:
  match state:
    case State{world,+px,+py,0,+score,+tick,+cooldown,+bodies}: packet(State{world,px,py,0,score,tick,cooldown,bodies})
    case State{world,+px,+py,+hp,+score,+tick,+cooldown,+bodies}:
      executed(clamp((px + dx * 2.8 : F32),780.0),clamp((py + dy * 2.8 : F32),480.0),hp,score,(tick + 1 : U32),cooled(cooldown),bodies,execute(world,Args{clamp((px + dx * 2.8 : F32),780.0),clamp((py + dy * 2.8 : F32),480.0),(tick + 1 : U32)}))
