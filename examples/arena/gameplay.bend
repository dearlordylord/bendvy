import Base
# player=0, enemy=1, pickup=2, bolt=3, chain=4, pulse=5.
# Enemy hp is quarter-units; projectile hp is remaining impacts.
type Body is Data: Body{x: F32,y: F32,kind: U32,seed: U32,hp: U32,speed: F32,target: U32,visited: List<&2,U32>,age: U32}
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
# 100 enemies => 21 bounces, plus the initial impact. Zero enemies => zero.
def bounce_budget(count: U32) -> U32: (3 * F32.to_u32(F32.ceil(F32.log2(U32.to_f32(U32.max(1,count))))) : U32)
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
type Totals is Data: Totals{hits: U32,points: U32,kills: U32,count: U32,projectiles: U32,bodies: List<&2,Body>}
def accumulate(rows: List<&2,Row>,+hits: U32,+points: U32,+kills: U32,+count: U32,+projectiles: U32,+bodies: List<&2,Body>) -> Totals:
  match rows:
    case []: Totals{hits,points,kills,count,projectiles,List.reverse(&2,Body,bodies)}
    case Row{_,_,_,+killed,1} <> rest: accumulate(rest,hits,points,(kills + killed : U32),count,projectiles,bodies)
    case Row{Body{+x,+y,+kind,+seed,+hp,+speed,+target,+visited,+age},+hit,+point,_,_} <> rest:
      accumulate(rest,(hits + hit : U32),(points + point : U32),kills,(count + Bool.to_u32(U32.is_eq(kind,1)) : U32),(projectiles + Bool.to_u32(U32.is_le(3,kind)) : U32),Body{x,y,kind,seed,hp,speed,target,visited,age} <> bodies)
def body_json(body: Body) -> String:
  match body:
    case Body{x,y,kind,seed,hp,speed,target,visited,age}: "[" ++ F32.show(x) ++ "," ++ F32.show(y) ++ "," ++ U32.show(kind) ++ "," ++ U32.show(hp) ++ "," ++ F32.show(speed) ++ "," ++ U32.show(seed) ++ "," ++ U32.show(age) ++ "," ++ U32.show(target) ++ "," ++ Nat.show(List.length(&2,U32,visited)) ++ "]"
def rows_json(rows: List<&2,Body>) -> String:
  match rows:
    case []: ""
    case body <> []: body_json(body)
    case body <> rest: body_json(body) ++ "," ++ rows_json(rest)
