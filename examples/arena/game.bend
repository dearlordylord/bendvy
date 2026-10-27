import Base
import ./gameplay.bend as G
import ./schema.bend as D
import ./root.bend as Root
import ./registration.bend as Registration
import ./owners.bend as Owners
import ./observe.bend as Observe
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-composer-schema.bend as Setup
import ../../src/ecs/dependency-application.bend as App
import ../../src/ecs/dependency-executor.bend as Exec

type State is Type:State{app:Root.Application(),px:F32,py:F32,hp:U32,score:U32,kills:U32,tick:U32,cooldown:U32,charge:F32,pulseClock:U32,chainClock:U32,nextEnemy:U32,nextProjectile:U32,count:U32,projectiles:U32,bodies:List<&2,G.Body>}
type Packet is Type:Packet{state:State,frame:String}
  Failed{error:String}
type Initial is Data:Initial{count:U32,charge:F32,pulseClock:U32,chainClock:U32,tick:U32,nextEnemy:U32}
def successful(events:List<&2,Exec.Observation<String,Unit>>) -> Bool:
  match events:
    case []:True{}
    case Exec.Ran{_,_} <> rest:successful(rest)
    case _ <> _:False{}
def completed(accepted:Bool,next:Root.Application() -> Packet,app:Root.Application()) -> Packet:
  match accepted:
    case True{}:next(app)
    case False{}:Failed{"ECS admission refused"}
def packet(state:State) -> Packet:
  match state:
    case State{app,+px,+py,+hp,+score,+kills,+tick,+cooldown,+charge,+pulseClock,+chainClock,+nextEnemy,+nextProjectile,+count,+projectiles,+bodies}:
      Packet{State{app,px,py,hp,score,kills,tick,cooldown,charge,pulseClock,chainClock,nextEnemy,nextProjectile,count,projectiles,bodies},"{\"hp\":" ++ U32.show(hp) ++ ",\"score\":" ++ U32.show(score) ++ ",\"kills\":" ++ U32.show(kills) ++ ",\"enemies\":" ++ U32.show(count) ++ ",\"projectiles\":" ++ U32.show(projectiles) ++ ",\"tick\":" ++ U32.show(tick) ++ ",\"cooldown\":" ++ U32.show(cooldown) ++ ",\"shotRate\":" ++ F32.show(G.shot_rate(count)) ++ ",\"bounces\":" ++ U32.show(G.bounce_budget(count)) ++ ",\"bodies\":[" ++ G.rows_json(bodies) ++ "]}"}
def enemies(remaining:Nat,+seed:U32,rows:List<&2,G.Body>) -> List<&2,G.Body>:
  match remaining:
    case 0n:List.reverse(&2,G.Body,rows)
    case 1n+rest:enemies(rest,U32.add(seed,1),G.new_enemy(seed,U32.sub(seed,1)) <> rows)
def pickups(remaining:Nat,+seed:U32,rows:List<&2,G.Body>) -> List<&2,G.Body>:
  match remaining:
    case 0n:List.reverse(&2,G.Body,rows)
    case 1n+rest:pickups(rest,U32.add(seed,1),G.new_pickup(seed) <> rows)
def seeds() -> List<&2,G.Body>:
  G.Body{400.0,250.0,0,0,5,0.0,0,[],0} <> List.append(&2,G.Body,enemies(512n,1,[]),pickups(10n,10000,[]))
def initial(settings:Initial,result:Root.Application() & Result<&2,&2,Unit,List<&2,G.Body>>) -> Packet:
  match settings result:
    case Initial{count,charge,pulseClock,chainClock,tick,nextEnemy}, (app,Done{bodies}):packet(State{app,400.0,250.0,5,0,0,tick,0,charge,pulseClock,chainClock,nextEnemy,1000000,count,0,bodies})
    case _ _:Failed{"Initial observation refused"}
def started(settings:Initial,result:Root.Application() & App.Report<String,Unit>) -> Packet:
  match result:
    case (app,App.Finished{events}):completed(successful(events),app => initial(settings,Observe.snapshot(app)),app)
    case _:Failed{"Initial ECS execution refused"}
def registered(settings:Initial,result:Maybe<Root.Application()>) -> IO(Packet):
  match result:
    case Some{app}:IO.bind(Root.Application() & App.Report<String,Unit>,Packet,Root.run(app),result => IO.pure(Packet,started(settings,result)))
    case None{}:IO.pure(Packet,Failed{"System registration refused"})
def created(settings:Initial,bodies:List<&2,G.Body>,result:Setup.Initialized<D.Schema,D.components(),D.resources(),Unit>) -> IO(Packet):
  match result:
    case Setup.SchemaCreated{_,world}:registered(settings,Registration.attach(world,bodies))
    case _:IO.pure(Packet,Failed{"World creation refused"})
def start(_:Unit) -> IO(Packet):created(Initial{512,0.0,180,60,0,513},seeds(),D.create(W.factory()))
def scenario(rows:List<&2,G.Body>,count:U32,charge:F32,pulseClock:U32,chainClock:U32) -> IO(Packet):created(Initial{count,charge,pulseClock,chainClock,1,8192},G.Body{400.0,250.0,0,0,5,0.0,0,[],0} <> rows,D.create(W.factory()))
def damage(active:Bool,+hp:U32,+cooldown:U32) -> U32 & U32:
  match active:
    case True{}:(U32.sub(hp,1),60)
    case False{}:(hp,cooldown)
def damaged(app:Root.Application(),+px:F32,+py:F32,+score:U32,+kills:U32,+tick:U32,+charge:F32,+pulseClock:U32,+chainClock:U32,+nextEnemy:U32,+nextProjectile:U32,+count:U32,+projectiles:U32,+bodies:List<&2,G.Body>,result:U32 & U32) -> Packet:
  (hp,cooldown) = result
  packet(State{app,px,py,hp,score,kills,tick,cooldown,charge,pulseClock,chainClock,nextEnemy,nextProjectile,count,projectiles,bodies})
def totals(app:Root.Application(),+px:F32,+py:F32,+hp:U32,+score:U32,+kills:U32,+tick:U32,+cooldown:U32,+charge:F32,+pulseClock:U32,+chainClock:U32,+nextEnemy:U32,+nextProjectile:U32,value:G.Totals) -> Packet:
  match value:
    case G.Totals{+hits,+points,+killed,+count,+projectiles,+bodies}:damaged(app,px,py,U32.add(score,points),U32.add(kills,killed),tick,charge,pulseClock,chainClock,nextEnemy,nextProjectile,count,projectiles,bodies,damage(Bool.and(U32.is_lt(0,hits),U32.is_eq(cooldown,0)),hp,cooldown))
def observed(+px:F32,+py:F32,+hp:U32,+score:U32,+kills:U32,+tick:U32,+cooldown:U32,+charge:F32,+pulseClock:U32,+chainClock:U32,+nextEnemy:U32,+nextProjectile:U32,result:Root.Application() & List<&2,G.Row>) -> Packet:
  match result:
    case (app,rows):totals(app,px,py,hp,score,kills,tick,cooldown,charge,pulseClock,chainClock,nextEnemy,nextProjectile,G.accumulate(rows,0,0,0,0,0,[]))
def executed(+px:F32,+py:F32,+hp:U32,+score:U32,+kills:U32,+tick:U32,+cooldown:U32,+charge:F32,+pulseClock:U32,+chainClock:U32,+nextEnemy:U32,+nextProjectile:U32,result:Root.Application() & App.Report<String,Unit>) -> Packet:
  match result:
    case (app,App.Finished{events}):completed(successful(events),app => observed(px,py,hp,score,kills,tick,cooldown,charge,pulseClock,chainClock,nextEnemy,nextProjectile,Owners.rows(app)),app)
    case _:Failed{"ECS execution refused"}
type Emission is Type:Emission{app:Root.Application(),bodies:List<&2,G.Body>,seeds:List<&2,G.Body>,nextProjectile:U32}
def emit_bolts(remaining:Nat,app:Root.Application(),+bodies:List<&2,G.Body>,+seeds:List<&2,G.Body>,+next:U32,+px:F32,+py:F32,+target:U32) -> Emission:
  match remaining:
    case 0n:Emission{app,bodies,seeds,next}
    case 1n+rest:emit_bolts(rest,app,G.Body{px,py,3,next,1,7.0,target,[],0} <> bodies,List.append(&2,G.Body,seeds,[G.Body{px,py,3,next,1,7.0,target,[],0}]),U32.add(next,1),px,py,target)
def emit_pulse(fired:Bool,emission:Emission,+px:F32,+py:F32) -> Emission:
  match fired emission:
    case False{} emission:emission
    case True{} Emission{app,+bodies,+seeds,+next}:Emission{app,G.Body{px,py,5,next,0,0.0,0,[],0} <> bodies,List.append(&2,G.Body,seeds,[G.Body{px,py,5,next,0,0.0,0,[],0}]),U32.add(next,1)}
def emit_chain(fired:Bool,emission:Emission,+px:F32,+py:F32,+count:U32) -> Emission:
  match fired emission:
    case False{} emission:emission
    case True{} Emission{app,+bodies,+seeds,+next}:Emission{app,G.Body{px,py,4,next,U32.add(G.bounce_budget(count),1),12.0,0,[],0} <> bodies,List.append(&2,G.Body,seeds,[G.Body{px,py,4,next,U32.add(G.bounce_budget(count),1),12.0,0,[],0}]),U32.add(next,1)}
def emitted(+px:F32,+py:F32,+hp:U32,+score:U32,+kills:U32,+tick:U32,+cooldown:U32,+charge:F32,+pulseClock:U32,+chainClock:U32,+nextEnemy:U32,emission:Emission) -> IO(Packet):
  match emission:
    case Emission{app,+bodies,seeds,+nextProjectile}:
      IO.bind(Root.Application() & App.Report<String,Unit>,Packet,Root.run(Owners.configure(seeds,G.Args{px,py,hp,tick,U32.is_le(pulseClock,1),G.impacts(bodies,bodies,[])},app)),result => IO.pure(Packet,executed(px,py,hp,score,kills,tick,G.cooled(cooldown),charge,G.reset_clock(U32.is_le(pulseClock,1),180,pulseClock),G.reset_clock(U32.is_le(chainClock,1),60,chainClock),nextEnemy,nextProjectile,result)))
def armed(app:Root.Application(),+px:F32,+py:F32,+hp:U32,+score:U32,+kills:U32,+tick:U32,+cooldown:U32,+charge:F32,+pulseClock:U32,+chainClock:U32,+nextEnemy:U32,+nextProjectile:U32,+count:U32,+bodies:List<&2,G.Body>,seeds:List<&2,G.Body>) -> IO(Packet):
  emitted(px,py,hp,score,kills,tick,cooldown,(charge + G.shot_rate(count) / 60.0 - U32.to_f32(F32.to_u32((charge + G.shot_rate(count) / 60.0 : F32))) : F32),pulseClock,chainClock,nextEnemy,emit_chain(Bool.and(U32.is_le(chainClock,1),U32.is_lt(0,count)),emit_pulse(U32.is_le(pulseClock,1),emit_bolts(U32.to_nat(F32.to_u32((charge + G.shot_rate(count) / 60.0 : F32))),app,bodies,seeds,nextProjectile,px,py,G.target_seed(G.nearest(bodies,px,py,0,[],G.ArenaNoAim{}))),px,py),px,py,count))
def reinforced(shouldSpawn:Bool,app:Root.Application(),+px:F32,+py:F32,+hp:U32,+score:U32,+kills:U32,+tick:U32,+cooldown:U32,+charge:F32,+pulseClock:U32,+chainClock:U32,+nextEnemy:U32,+nextProjectile:U32,+count:U32,+bodies:List<&2,G.Body>) -> IO(Packet):
  match shouldSpawn:
    case False{}:armed(app,px,py,hp,score,kills,tick,cooldown,charge,pulseClock,chainClock,nextEnemy,nextProjectile,count,bodies,[])
    case True{}:armed(app,px,py,hp,score,kills,tick,cooldown,charge,pulseClock,chainClock,U32.add(nextEnemy,1),nextProjectile,U32.add(count,1),G.new_enemy(nextEnemy,count) <> bodies,[G.new_enemy(nextEnemy,count)])
def step_state(state:State,+dx:F32,+dy:F32) -> IO(Packet):
  match state:
    case State{app,+px,+py,0,+score,+kills,+tick,+cooldown,+charge,+pulseClock,+chainClock,+nextEnemy,+nextProjectile,+count,+projectiles,+bodies}:IO.pure(Packet,packet(State{app,px,py,0,score,kills,tick,cooldown,charge,pulseClock,chainClock,nextEnemy,nextProjectile,count,projectiles,bodies}))
    case State{app,+px,+py,+hp,+score,+kills,+tick,+cooldown,+charge,+pulseClock,+chainClock,+nextEnemy,+nextProjectile,+count,_,+bodies}:reinforced(Bool.and(U32.is_eq(((tick + 1) % 2 : U32),0),Bool.and(U32.is_lt(count,1024),U32.is_lt(nextEnemy,8192))),app,F32.clamp((px + dx * 2.8 : F32),8.0,792.0),F32.clamp((py + dy * 2.8 : F32),8.0,492.0),hp,score,kills,U32.add(tick,1),cooldown,charge,pulseClock,chainClock,nextEnemy,nextProjectile,count,bodies)
def within_budget(available:Bool,state:State,dx:F32,dy:F32) -> IO(Packet):
  match available:
    case True{}:step_state(state,dx,dy)
    case False{}:IO.pure(Packet,Failed{"Demo allocation budget reached. Restart to play again."})
def advance(state:State,dx:F32,dy:F32) -> IO(Packet):
  match state:
    case State{app,+px,+py,+hp,+score,+kills,+tick,+cooldown,+charge,+pulseClock,+chainClock,+nextEnemy,+nextProjectile,+count,+projectiles,+bodies}:within_budget(U32.is_lt(nextProjectile,1100000),State{app,px,py,hp,score,kills,tick,cooldown,charge,pulseClock,chainClock,nextEnemy,nextProjectile,count,projectiles,bodies},dx,dy)
