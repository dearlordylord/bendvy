# Finite authored application scenarios; all steps use the real public ECS query.
import Base
import game.bend as G
import ../../src/ecs/world.bend as W

def install(rows: List<&2,G.Body>,world: G.World()) -> G.World():
  match rows:
    case []: world
    case +row <> rest: install(rest,G.spawn(world,row))
def begin(rows: List<&2,G.Body>,+count: U32,+charge: F32,+pulseClock: U32,+chainClock: U32,created: W.Creation<G.Schema,G.Store,Unit,Unit>) -> G.Packet:
  match created:
    case W.Created{_,world}: G.packet(G.State{W.barrier(~G.Schema,~G.Store,~Unit,~Unit,install(rows,G.spawn(world,G.Body{400.0,250.0,0,0,5,0.0,0,[],0}))),400.0,250.0,5,0,0,1,0,charge,pulseClock,chainClock,8192,1000000,count,0,[]})
    case _: G.Failed{"Fixture creation refused"}
def prepared(packet: G.Packet,+rows: List<&2,G.Body>) -> G.Packet:
  match packet:
    case G.Packet{G.State{world,+px,+py,+hp,+score,+kills,+tick,+cooldown,+charge,+pulseClock,+chainClock,+nextEnemy,+nextProjectile,+count,+projectiles,_},_}: G.packet(G.State{world,px,py,hp,score,kills,tick,cooldown,charge,pulseClock,chainClock,nextEnemy,nextProjectile,count,projectiles,G.Body{400.0,250.0,0,0,5,0.0,0,[],0} <> rows})
    case G.Failed{error}: G.Failed{error}
def scenario(+rows: List<&2,G.Body>,count: U32,charge: F32,pulseClock: U32,chainClock: U32) -> G.Packet:
  prepared(begin(rows,count,charge,pulseClock,chainClock,W.create(~G.Schema,~G.Store,~Unit,~Unit,~G.empty,W.factory(),Unit{})),rows)
def regular() -> G.Packet: scenario([G.Body{405.0,250.0,1,1,4,0.0,0,[],0},G.Body{420.0,250.0,1,2,4,0.0,0,[],0}],2,0.9,180,60)
def lethal() -> G.Packet: scenario([G.Body{405.0,250.0,1,1,1,0.0,0,[],0},G.Body{420.0,250.0,1,2,4,0.0,0,[],0}],2,0.9,180,60)
def aoe() -> G.Packet: scenario([G.Body{480.0,250.0,1,1,4,0.0,0,[],0},G.Body{491.0,250.0,1,2,4,0.0,0,[],0}],2,0.0,1,60)
def chain() -> G.Packet: scenario([G.Body{405.0,250.0,1,1,4,0.0,0,[],0},G.Body{412.0,250.0,1,2,4,0.0,0,[],0},G.Body{420.0,250.0,1,3,4,0.0,0,[],0}],3,0.0,180,1)
def advance(packet: G.Packet) -> G.Packet:
  match packet:
    case G.Packet{state,_}: G.advance(state,0.0,0.0)
    case G.Failed{error}: G.Failed{error}
def live_handles(result: G.World() & List<&2,W.Handle<G.Schema>>) -> U32:
  (world,handles) = result
  U32.from_nat(List.length(&2,W.Handle<G.Schema>,handles))
def live_state(state: G.State) -> U32:
  match state:
    case G.State{world,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_}: live_handles(W.handles(~G.Schema,~G.Store,~Unit,~Unit,world))
def live_count(packet: G.Packet) -> U32:
  match packet:
    case G.Packet{state,_}: live_state(state)
    case _: 0
