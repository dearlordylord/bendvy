import Base
import ../../src/ecs/world.bend as W
import ../../src/ecs/column.bend as Col
import ../../src/ecs/component.bend as C
import ../../src/ecs/commands.bend as Cmd
import ../../src/ecs/transaction.bend as T
import ../../src/ecs/compose.bend as Q
import ../../src/ecs/capabilities.bend as Cap

type Schema is Data: Schema{}
# player=0, enemy=1, pickup=2, bolt=3, chain=4, pulse=5.
# Enemy hp is quarter-units; projectile hp is remaining impacts.
type Body is Data: Body{x: F32,y: F32,kind: U32,seed: U32,hp: U32,speed: F32,target: U32,visited: List<&2,U32>,age: U32}
type Token is Data: Token{}
type Store is Type: Store{bodies: Col.Column<Schema,Body>}
def take(store: Store) -> Unit & Col.Column<Schema,Body>:
  match store:
    case Store{column}: (Unit{},column)
def put(unit: Unit,column: Col.Column<Schema,Body>) -> Store: Store{column}
def project(body: Body) -> Body & Body:
  match body:
    case Body{+x,+y,+kind,+seed,+hp,+speed,+target,+visited,+age}: (Body{x,y,kind,seed,hp,speed,target,visited,age},Body{x,y,kind,seed,hp,speed,target,visited,age})
def family() -> C.Family<Schema,Store,Unit,Body,Body,Token,take,put,project>: C.Family{"body"}
def empty(unit: Unit) -> Store: Store{Col.empty_indexed(~Schema,~Body)}
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
def spawn(world: World(),body: Body) -> World():
  spawn_finish(Cmd.tx_spawn(~Schema,~Store,~Unit,~Unit,~Body,~populate,T.Tx{world,[],[],[]},body))
def cleared(result: Col.SwapOutcome<Schema,Body>) -> Store:
  match result:
    case Col.Accepted{column,_}: Store{column}
    case Col.Rejected{column,_}: Store{column}
def clear(store: Store,handle: W.Handle<Schema>) -> Store:
  match store handle:
    case Store{column} W.Handle{_,id}: cleared(Col.clear(~Schema,~Body,column,id))
def seed_x(+seed: U32) -> F32: U32.to_f32(((seed * 137 + 71) % 740 : U32))
def seed_y(+seed: U32) -> F32: U32.to_f32(((seed * 83 + 29) % 440 : U32))
# Only newborn enemies use the current count. Existing speeds remain unchanged.
def spawn_speed(+count: U32) -> F32: (1.8 / (1.0 + 0.35 * F32.log((1.0 + U32.to_f32(count) : F32))) : F32)
def enemy_edge(side: U32,+seed: U32,+speed: F32) -> Body:
  match side:
    case 0: Body{8.0,(seed_y(seed) + 30.0 : F32),1,seed,4,speed,0,[],0}
    case 1: Body{792.0,(seed_y(seed) + 30.0 : F32),1,seed,4,speed,0,[],0}
    case 2: Body{(seed_x(seed) + 30.0 : F32),8.0,1,seed,4,speed,0,[],0}
    case _: Body{(seed_x(seed) + 30.0 : F32),492.0,1,seed,4,speed,0,[],0}
def new_enemy(+seed: U32,count: U32) -> Body: enemy_edge((seed % 4 : U32),seed,spawn_speed(count))
def new_pickup(+seed: U32) -> Body: Body{(seed_x(seed) + 30.0 : F32),(seed_y(seed) + 30.0 : F32),2,seed,0,0.0,0,[],0}
def bootstrap_enemies(remaining: Nat,+seed: U32,world: World(),+rows: List<&2,Body>) -> World() & List<&2,Body>:
  match remaining:
    case 0n: (world,rows)
    case 1n+rest: bootstrap_enemies(rest,(seed + 1 : U32),spawn(world,new_enemy(seed,(seed - 1 : U32))),new_enemy(seed,(seed - 1 : U32)) <> rows)
def bootstrap_pickups(remaining: Nat,+seed: U32,world: World(),+rows: List<&2,Body>) -> World() & List<&2,Body>:
  match remaining:
    case 0n: (world,rows)
    case 1n+rest: bootstrap_pickups(rest,(seed + 1 : U32),spawn(world,new_pickup(seed)),new_pickup(seed) <> rows)
def pickups(result: World() & List<&2,Body>) -> World() & List<&2,Body>:
  (world,+rows) = result
  bootstrap_pickups(10n,10000,world,rows)
type Boot is Type: Boot{world: World(),rows: List<&2,Body>}
  BootRefused{}
def booted(result: World() & List<&2,Body>) -> Boot:
  (world,+rows) = result
  Boot{world,rows}
def setup(created: W.Creation<Schema,Store,Unit,Unit>) -> Boot:
  match created:
    case W.Created{_,world}: booted(pickups(bootstrap_enemies(512n,1,spawn(world,Body{400.0,250.0,0,0,5,0.0,0,[],0}),[Body{400.0,250.0,0,0,5,0.0,0,[],0}])))
    case W.CreateRejected{_,_}: BootRefused{}

def distance2(+x: F32,+y: F32,+px: F32,+py: F32) -> F32: ((x - px) * (x - px) + (y - py) * (y - py) : F32)
def close(+x: F32,+y: F32,+px: F32,+py: F32,+radius: F32) -> Bool: F32.is_le(distance2(x,y,px,py),(radius * radius : F32))
def contains(values: List<&2,U32>,+value: U32) -> Bool:
  match values:
    case []: False{}
    case +head <> rest: Bool.or(U32.is_eq(head,value),contains(rest,value))
type Target is Data: ArenaAim{seed: U32,x: F32,y: F32,distance: F32}
  ArenaNoAim{}
def best_distance(target: Target) -> F32:
  match target:
    case ArenaAim{_,_,_,distance}: distance
    case ArenaNoAim{}: 1000000.0
def target_seed(target: Target) -> U32:
  match target:
    case ArenaAim{seed,_,_,_}: seed
    case ArenaNoAim{}: 0
def prefer(wanted: Bool,distance: F32) -> F32:
  match wanted:
    case True{}: (0.0 - 1.0 : F32)
    case False{}: distance
def candidate(accepted: Bool,+seed: U32,+x: F32,+y: F32,+distance: F32,target: Target) -> Target:
  match accepted:
    case True{}: ArenaAim{seed,x,y,distance}
    case False{}: target
def nearest(rows: List<&2,Body>,+px: F32,+py: F32,+wanted: U32,+visited: List<&2,U32>,+target: Target) -> Target:
  match rows:
    case []: target
    case Body{+x,+y,1,+seed,_,_,_,_,_} <> rest:
      nearest(rest,px,py,wanted,visited,candidate(Bool.and(Bool.not(contains(visited,seed)),F32.is_lt(prefer(U32.is_eq(seed,wanted),distance2(x,y,px,py)),best_distance(target))),seed,x,y,prefer(U32.is_eq(seed,wanted),distance2(x,y,px,py)),target))
    case _ <> rest: nearest(rest,px,py,wanted,visited,target)
# 100 enemies => seven bounces, plus the initial impact. Zero enemies => zero.
def bounce_budget(count: U32) -> U32: F32.to_u32(F32.ceil(F32.log2(U32.to_f32(U32.max(1,count)))))
def shot_rate(count: U32) -> F32: (10.0 + U32.to_f32(count) * 0.25 : F32)
def lose_health(+hp: U32,damage: U32) -> U32: U32.sub(hp,U32.min(hp,damage))
def cooled(cooldown: U32) -> U32:
  match cooldown:
    case 0: 0
    case +value: (value - 1 : U32)
def reset_clock(fired: Bool,period: U32,current: U32) -> U32:
  match fired:
    case True{}: period
    case False{}: cooled(current)

type Impact is Data: Impact{seed: U32,body: Body,enemy: U32,amount: U32,dead: U32}
def projectile_hit(collided: Bool,+x: F32,+y: F32,+kind: U32,+seed: U32,+hp: U32,+speed: F32,+target: U32,+visited: List<&2,U32>,+age: U32,+tx: F32,+ty: F32) -> Impact:
  match collided:
    case True{}: Impact{seed,Body{tx,ty,kind,seed,(hp - 1 : U32),speed,0,target <> visited,(age + 1 : U32)},target,1,Bool.to_u32(U32.is_eq(hp,1))}
    case False{}: Impact{seed,Body{x,y,kind,seed,hp,speed,target,visited,(age + 1 : U32)},0,0,0}
def projectile_aim(+x: F32,+y: F32,+kind: U32,+seed: U32,+hp: U32,+speed: F32,+visited: List<&2,U32>,+age: U32,target: Target) -> Impact:
  match target:
    case ArenaNoAim{}: Impact{seed,Body{x,y,kind,seed,hp,speed,0,visited,age},0,0,1}
    case ArenaAim{+target,+tx,+ty,_}:
      projectile_hit(close(x,y,tx,ty,(speed + 3.0 : F32)),(x + (tx - x) / F32.max(1.0,F32.sqrt(distance2(x,y,tx,ty))) * speed : F32),(y + (ty - y) / F32.max(1.0,F32.sqrt(distance2(x,y,tx,ty))) * speed : F32),kind,seed,hp,speed,target,visited,age,tx,ty)
def projectile_expired(expired: Bool,+body: Body,+snapshot: List<&2,Body>) -> Impact:
  match expired body:
    case True{} Body{+x,+y,+kind,+seed,+hp,+speed,+target,+visited,+age}: Impact{seed,Body{x,y,kind,seed,hp,speed,target,visited,age},0,0,1}
    case False{} Body{+x,+y,+kind,+seed,+hp,+speed,+target,+visited,+age}: projectile_aim(x,y,kind,seed,hp,speed,visited,age,nearest(snapshot,x,y,target,visited,ArenaNoAim{}))
def projectile_step(body: Body,+snapshot: List<&2,Body>) -> Impact:
  match body:
    case Body{+x,+y,+kind,+seed,+hp,+speed,+target,+visited,+age}: projectile_expired(U32.is_le(360,age),Body{x,y,kind,seed,hp,speed,target,visited,age},snapshot)
def impacts(rows: List<&2,Body>,+snapshot: List<&2,Body>,+planned: List<&2,Impact>) -> List<&2,Impact>:
  match rows:
    case []: planned
    case Body{+x,+y,3,+seed,+hp,+speed,+target,+visited,+age} <> rest: impacts(rest,snapshot,projectile_step(Body{x,y,3,seed,hp,speed,target,visited,age},snapshot) <> planned)
    case Body{+x,+y,4,+seed,+hp,+speed,+target,+visited,+age} <> rest: impacts(rest,snapshot,projectile_step(Body{x,y,4,seed,hp,speed,target,visited,age},snapshot) <> planned)
    case _ <> rest: impacts(rest,snapshot,planned)
def impact_damage(rows: List<&2,Impact>,+seed: U32) -> U32:
  match rows:
    case []: 0
    case Impact{_,_,+enemy,+amount,_} <> rest: (amount * Bool.to_u32(U32.is_eq(enemy,seed)) + impact_damage(rest,seed) : U32)

type Args is Data: Args{px: F32,py: F32,hp: U32,tick: U32,pulse: Bool,impacts: List<&2,Impact>}
type Row is Data: Row{body: Body,hit: U32,points: U32,killed: U32,dead: U32}
type Error is Data: MissingBody{}
type Ops<-H: Type> is Type: Ops{body: Cap.Write<H,Body,Body>,despawn: Cap.Action<H>}
def OpsType(H: Type) -> Type: Ops<H>
def body_cap(~H: Type,ops: Ops<H>) -> Cap.Write<H,Body,Body>:
  match ops:
    case Ops{body,_}: body
def despawn_cap(~H: Type,ops: Ops<H>) -> Cap.Action<H>:
  match ops:
    case Ops{_,despawn}: despawn
# Gameplay is checked against abstract H; it cannot inspect the Store.
def moved_enemy(+x: F32,+y: F32,+seed: U32,+hp: U32,+speed: F32,args: Args) -> Row:
  match args:
    case Args{+px,+py,_,_,_,_}: Row{Body{x,y,1,seed,hp,speed,0,[],0},Bool.to_u32(close(x,y,px,py,7.0)),0,0,0}
def enemy_alive(hp: U32,+x: F32,+y: F32,+seed: U32,+speed: F32,+args: Args) -> Row:
  match hp:
    case 0: Row{Body{x,y,1,seed,0,speed,0,[],0},0,0,1,1}
    case +hp: moved_enemy(x,y,seed,hp,speed,args)
def enemy_update(body: Body,args: Args) -> Row:
  match body args:
    case Body{+x,+y,_,+seed,+hp,+speed,_,_,_} Args{+px,+py,+playerHp,+tick,+pulse,+plans}:
      enemy_alive(lose_health(hp,(impact_damage(plans,seed) + 2 * Bool.to_u32(Bool.and(pulse,close(x,y,px,py,90.0))) : U32)),(x + (px - x) / F32.max(1.0,F32.sqrt(distance2(x,y,px,py))) * speed : F32),(y + (py - y) / F32.max(1.0,F32.sqrt(distance2(x,y,px,py))) * speed : F32),seed,speed,Args{px,py,playerHp,tick,pulse,plans})
def pickup(collided: Bool,+x: F32,+y: F32,+tick: U32,+seed: U32) -> Row:
  match collided:
    case True{}: Row{Body{(seed_x((seed + tick : U32)) + 30.0 : F32),(seed_y((seed + tick : U32)) + 30.0 : F32),2,seed,0,0.0,0,[],0},0,1,0,0}
    case False{}: Row{Body{x,y,2,seed,0,0.0,0,[],0},0,0,0,0}
def planned_row(accepted: Bool,body: Body,+dead: U32,rest: Row) -> Row:
  match accepted:
    case True{}: Row{body,0,0,0,dead}
    case False{}: rest
def find_plan(plans: List<&2,Impact>,+seed: U32,body: Body) -> Row:
  match plans:
    case []: Row{body,0,0,0,1}
    case Impact{+id,+planned,_,_,+dead} <> rest: planned_row(U32.is_eq(id,seed),planned,dead,find_plan(rest,seed,body))
def pulse_row(expired: Bool,+x: F32,+y: F32,+seed: U32,+age: U32) -> Row:
  match expired:
    case True{}: Row{Body{x,y,5,seed,0,0.0,0,[],age},0,0,0,1}
    case False{}: Row{Body{x,y,5,seed,0,0.0,0,[],(age + 1 : U32)},0,0,0,0}
def update(body: Body,args: Args) -> Row:
  match body args:
    case Body{_,_,0,+seed,_,_,_,_,_} Args{+px,+py,+hp,_,_,_}: Row{Body{px,py,0,seed,hp,0.0,0,[],0},0,0,0,0}
    case Body{+x,+y,1,+seed,+hp,+speed,+target,+visited,+age} args: enemy_update(Body{x,y,1,seed,hp,speed,target,visited,age},args)
    case Body{+x,+y,2,+seed,_,_,_,_,_} Args{+px,+py,_,+tick,_,_}: pickup(close(x,y,px,py,9.0),x,y,tick,seed)
    case Body{+x,+y,5,+seed,_,_,_,_,+age} _: pulse_row(U32.is_le(24,age),x,y,seed,age)
    case Body{+x,+y,+kind,+seed,+hp,+speed,+target,+visited,+age} Args{_,_,_,_,_,+plans}: find_plan(plans,seed,Body{x,y,kind,seed,hp,speed,target,visited,age})
def dispose_dead(~H: Type,~ops: Ops<H>,dead: Bool,ctx: H) -> H:
  match dead:
    case True{}: Cap.action(~H,~despawn_cap(~H,ops),ctx)
    case False{}: ctx
def write_row(~H: Type,~ops: Ops<H>,ctx: H,row: Row) -> H & (T.Outcome<Error> & Row):
  match row:
    case Row{+body,+hit,+points,+killed,+dead}: (dispose_dead(~H,~ops,U32.is_eq(dead,1),Cap.set(~H,~Body,~Body,~body_cap(~H,ops),ctx,body)),(T.Success{},Row{body,hit,points,killed,dead}))
def observed(~H: Type,~ops: Ops<H>,+args: Args,result: H & C.Access<Body>) -> H & (T.Outcome<Error> & Row):
  match result:
    case (ctx,C.Found{body}): write_row(~H,~ops,ctx,update(body,args))
    case (ctx,_): (ctx,(T.Failure{MissingBody{}},Row{Body{0.0,0.0,0,0,0,0.0,0,[],0},0,0,0,0}))
def body_system(~H: Type,~ops: Ops<H>,args: Args,ctx: H) -> H & (T.Outcome<Error> & Row):
  observed(~H,~ops,args,Cap.get(~H,~Body,~Body,~body_cap(~H,ops),ctx))
def Frame() -> Type: Q.Frame<Schema,Store,Unit,Unit>
def selected(frame: Frame()) -> Frame() & Bool:
  Q.family_match(~Schema,~Store,~Unit,~Unit,~Unit,~Body,~Body,~Token,~take,~put,~project,~family(),~Q.Required{},frame)
def plan() -> Q.Plan<Schema,Store,Unit,Unit,OpsType>:
  Q.Plan{Ops{Q.write_family(~Schema,~Store,~Unit,~Unit,~Unit,~Body,~Body,~Token,~take,~put,~project,~family()),Q.command_despawn(~Schema,~Store,~Unit,~Unit,~clear)},selected}
def execute(world: World(),args: Args) -> Q.Executed<World(),Q.Error<Error>,Row>:
  Q.each(~Schema,~Store,~Unit,~Unit,~OpsType,~Args,~Error,~Row,~plan(),~body_system,args,world)

type Totals is Data: Totals{hits: U32,points: U32,kills: U32,count: U32,projectiles: U32,bodies: List<&2,Body>}
def accumulate(rows: List<&2,Row>,+hits: U32,+points: U32,+kills: U32,+count: U32,+projectiles: U32,+bodies: List<&2,Body>) -> Totals:
  match rows:
    case []: Totals{hits,points,kills,count,projectiles,List.reverse(&2,Body,bodies)}
    case Row{_,_,_,+killed,1} <> rest: accumulate(rest,hits,points,(kills + killed : U32),count,projectiles,bodies)
    case Row{Body{+x,+y,+kind,+seed,+hp,+speed,+target,+visited,+age},+hit,+point,_,_} <> rest:
      accumulate(rest,(hits + hit : U32),(points + point : U32),kills,(count + Bool.to_u32(U32.is_eq(kind,1)) : U32),(projectiles + Bool.to_u32(U32.is_le(3,kind)) : U32),Body{x,y,kind,seed,hp,speed,target,visited,age} <> bodies)
type State is Type: State{world: World(),px: F32,py: F32,hp: U32,score: U32,kills: U32,tick: U32,cooldown: U32,charge: F32,pulseClock: U32,chainClock: U32,nextEnemy: U32,nextProjectile: U32,count: U32,projectiles: U32,bodies: List<&2,Body>}
type Packet is Type: Packet{state: State,frame: String}
  Failed{error: String}
def body_json(body: Body) -> String:
  match body:
    case Body{x,y,kind,seed,hp,speed,target,visited,age}: "[" ++ F32.show(x) ++ "," ++ F32.show(y) ++ "," ++ U32.show(kind) ++ "," ++ U32.show(hp) ++ "," ++ F32.show(speed) ++ "," ++ U32.show(seed) ++ "," ++ U32.show(age) ++ "," ++ U32.show(target) ++ "," ++ Nat.show(List.length(&2,U32,visited)) ++ "]"
def rows_json(rows: List<&2,Body>) -> String:
  match rows:
    case []: ""
    case body <> []: body_json(body)
    case body <> rest: body_json(body) ++ "," ++ rows_json(rest)
def packet(state: State) -> Packet:
  match state:
    case State{world,+px,+py,+hp,+score,+kills,+tick,+cooldown,+charge,+pulseClock,+chainClock,+nextEnemy,+nextProjectile,+count,+projectiles,+bodies}:
      Packet{State{world,px,py,hp,score,kills,tick,cooldown,charge,pulseClock,chainClock,nextEnemy,nextProjectile,count,projectiles,bodies},"{\"hp\":" ++ U32.show(hp) ++ ",\"score\":" ++ U32.show(score) ++ ",\"kills\":" ++ U32.show(kills) ++ ",\"enemies\":" ++ U32.show(count) ++ ",\"projectiles\":" ++ U32.show(projectiles) ++ ",\"tick\":" ++ U32.show(tick) ++ ",\"cooldown\":" ++ U32.show(cooldown) ++ ",\"shotRate\":" ++ F32.show(shot_rate(count)) ++ ",\"bounces\":" ++ U32.show(bounce_budget(count)) ++ ",\"bodies\":[" ++ rows_json(bodies) ++ "]}"}
def started(result: Boot) -> Packet:
  match result:
    case Boot{world,+bodies}: packet(State{W.barrier(~Schema,~Store,~Unit,~Unit,world),400.0,250.0,5,0,0,0,0,0.0,180,360,513,1000000,512,0,bodies})
    case BootRefused{}: Failed{"World creation refused"}
def start() -> Packet: started(setup(W.create(~Schema,~Store,~Unit,~Unit,~empty,W.factory(),Unit{})))
def damage(active: Bool,+hp: U32,+cooldown: U32) -> U32 & U32:
  match active:
    case True{}: ((hp - 1 : U32),60)
    case False{}: (hp,cooldown)
def damaged(world: World(),+px: F32,+py: F32,+score: U32,+kills: U32,+tick: U32,+charge: F32,+pulseClock: U32,+chainClock: U32,+nextEnemy: U32,+nextProjectile: U32,+count: U32,+projectiles: U32,+bodies: List<&2,Body>,result: U32 & U32) -> Packet:
  (hp,cooldown) = result
  packet(State{W.barrier(~Schema,~Store,~Unit,~Unit,world),px,py,hp,score,kills,tick,cooldown,charge,pulseClock,chainClock,nextEnemy,nextProjectile,count,projectiles,bodies})
def totals(world: World(),+px: F32,+py: F32,+hp: U32,+score: U32,+kills: U32,+tick: U32,+cooldown: U32,+charge: F32,+pulseClock: U32,+chainClock: U32,+nextEnemy: U32,+nextProjectile: U32,value: Totals) -> Packet:
  match value:
    case Totals{+hits,+points,+killed,+count,+projectiles,+bodies}:
      damaged(world,px,py,(score + points : U32),(kills + killed : U32),tick,charge,pulseClock,chainClock,nextEnemy,nextProjectile,count,projectiles,bodies,damage(Bool.and(U32.is_lt(0,hits),U32.is_eq(cooldown,0)),hp,cooldown))
def executed(+px: F32,+py: F32,+hp: U32,+score: U32,+kills: U32,+tick: U32,+cooldown: U32,+charge: F32,+pulseClock: U32,+chainClock: U32,+nextEnemy: U32,+nextProjectile: U32,result: Q.Executed<World(),Q.Error<Error>,Row>) -> Packet:
  match result:
    case Q.Executed{world,T.Success{},rows}: totals(world,px,py,hp,score,kills,tick,cooldown,charge,pulseClock,chainClock,nextEnemy,nextProjectile,accumulate(rows,0,0,0,0,0,[]))
    case Q.Executed{_,T.Failure{_},_}: Failed{"ECS query failed"}

type Emission is Type: Emission{world: World(),bodies: List<&2,Body>,nextProjectile: U32}
def emit_bolts(remaining: Nat,world: World(),+bodies: List<&2,Body>,+next: U32,+px: F32,+py: F32,+target: U32) -> Emission:
  match remaining:
    case 0n: Emission{world,bodies,next}
    case 1n+rest: emit_bolts(rest,spawn(world,Body{px,py,3,next,1,7.0,target,[],0}),Body{px,py,3,next,1,7.0,target,[],0} <> bodies,(next + 1 : U32),px,py,target)
def emit_pulse(fired: Bool,emission: Emission,+px: F32,+py: F32) -> Emission:
  match fired emission:
    case False{} emission: emission
    case True{} Emission{world,+bodies,+next}: Emission{spawn(world,Body{px,py,5,next,0,0.0,0,[],0}),Body{px,py,5,next,0,0.0,0,[],0} <> bodies,(next + 1 : U32)}
def emit_chain(fired: Bool,emission: Emission,+px: F32,+py: F32,+count: U32) -> Emission:
  match fired emission:
    case False{} emission: emission
    case True{} Emission{world,+bodies,+next}: Emission{spawn(world,Body{px,py,4,next,(bounce_budget(count) + 1 : U32),12.0,0,[],0}),Body{px,py,4,next,(bounce_budget(count) + 1 : U32),12.0,0,[],0} <> bodies,(next + 1 : U32)}
def emitted(+px: F32,+py: F32,+hp: U32,+score: U32,+kills: U32,+tick: U32,+cooldown: U32,+charge: F32,+pulseClock: U32,+chainClock: U32,+nextEnemy: U32,emission: Emission) -> Packet:
  match emission:
    case Emission{world,+bodies,+nextProjectile}:
      executed(px,py,hp,score,kills,tick,cooled(cooldown),charge,reset_clock(U32.is_le(pulseClock,1),180,pulseClock),reset_clock(U32.is_le(chainClock,1),360,chainClock),nextEnemy,nextProjectile,execute(W.barrier(~Schema,~Store,~Unit,~Unit,world),Args{px,py,hp,tick,U32.is_le(pulseClock,1),impacts(bodies,bodies,[])}))
def armed(world: World(),+px: F32,+py: F32,+hp: U32,+score: U32,+kills: U32,+tick: U32,+cooldown: U32,+charge: F32,+pulseClock: U32,+chainClock: U32,+nextEnemy: U32,+nextProjectile: U32,+count: U32,+bodies: List<&2,Body>) -> Packet:
  emitted(px,py,hp,score,kills,tick,cooldown,(charge + shot_rate(count) / 60.0 - U32.to_f32(F32.to_u32((charge + shot_rate(count) / 60.0 : F32))) : F32),pulseClock,chainClock,nextEnemy,emit_chain(Bool.and(U32.is_le(chainClock,1),U32.is_lt(0,count)),emit_pulse(U32.is_le(pulseClock,1),emit_bolts(U32.to_nat(F32.to_u32((charge + shot_rate(count) / 60.0 : F32))),world,bodies,nextProjectile,px,py,target_seed(nearest(bodies,px,py,0,[],ArenaNoAim{}))),px,py),px,py,count))
def spawn_reinforcement(shouldSpawn: Bool,world: World(),+px: F32,+py: F32,+hp: U32,+score: U32,+kills: U32,+tick: U32,+cooldown: U32,+charge: F32,+pulseClock: U32,+chainClock: U32,+nextEnemy: U32,+nextProjectile: U32,+count: U32,+bodies: List<&2,Body>) -> Packet:
  match shouldSpawn:
    case False{}: armed(world,px,py,hp,score,kills,tick,cooldown,charge,pulseClock,chainClock,nextEnemy,nextProjectile,count,bodies)
    case True{}: armed(spawn(world,new_enemy(nextEnemy,count)),px,py,hp,score,kills,tick,cooldown,charge,pulseClock,chainClock,(nextEnemy + 1 : U32),nextProjectile,(count + 1 : U32),new_enemy(nextEnemy,count) <> bodies)
def step_state(state: State,+dx: F32,+dy: F32) -> Packet:
  match state:
    case State{world,+px,+py,0,+score,+kills,+tick,+cooldown,+charge,+pulseClock,+chainClock,+nextEnemy,+nextProjectile,+count,+projectiles,+bodies}: packet(State{world,px,py,0,score,kills,tick,cooldown,charge,pulseClock,chainClock,nextEnemy,nextProjectile,count,projectiles,bodies})
    case State{world,+px,+py,+hp,+score,+kills,+tick,+cooldown,+charge,+pulseClock,+chainClock,+nextEnemy,+nextProjectile,+count,_,+bodies}:
      spawn_reinforcement(Bool.and(U32.is_eq(((tick + 1) % 2 : U32),0),Bool.and(U32.is_lt(count,1024),U32.is_lt(nextEnemy,8192))),world,F32.clamp((px + dx * 2.8 : F32),8.0,792.0),F32.clamp((py + dy * 2.8 : F32),8.0,492.0),hp,score,kills,(tick + 1 : U32),cooldown,charge,pulseClock,chainClock,nextEnemy,nextProjectile,count,bodies)

# Stay below the existing bounded allocator; never simulate refused spawns.
def within_budget(available: Bool,state: State,dx: F32,dy: F32) -> Packet:
  match available:
    case True{}: step_state(state,dx,dy)
    case False{}: Failed{"Demo allocation budget reached. Restart to play again."}
def advance(state: State,dx: F32,dy: F32) -> Packet:
  match state:
    case State{world,+px,+py,+hp,+score,+kills,+tick,+cooldown,+charge,+pulseClock,+chainClock,+nextEnemy,+nextProjectile,+count,+projectiles,+bodies}: within_budget(U32.is_lt(nextProjectile,1100000),State{world,px,py,hp,score,kills,tick,cooldown,charge,pulseClock,chainClock,nextEnemy,nextProjectile,count,projectiles,bodies},dx,dy)
