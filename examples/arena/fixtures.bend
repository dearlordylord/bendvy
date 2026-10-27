# Preserved authored scenarios now use the same retained application as the game.
import Base
import ./game.bend as G
import ./gameplay.bend as Body
import ./observe.bend as Observe
import ./root.bend as Root

def regular(_:Unit) -> IO(G.Packet):G.scenario([Body.Body{405.0,250.0,1,1,4,0.0,0,[],0},Body.Body{420.0,250.0,1,2,4,0.0,0,[],0}],2,0.9,180,60)
def lethal(_:Unit) -> IO(G.Packet):G.scenario([Body.Body{405.0,250.0,1,1,1,0.0,0,[],0},Body.Body{420.0,250.0,1,2,4,0.0,0,[],0}],2,0.9,180,60)
def aoe(_:Unit) -> IO(G.Packet):G.scenario([Body.Body{480.0,250.0,1,1,4,0.0,0,[],0},Body.Body{491.0,250.0,1,2,4,0.0,0,[],0}],2,0.0,1,60)
def chain(_:Unit) -> IO(G.Packet):G.scenario([Body.Body{405.0,250.0,1,1,4,0.0,0,[],0},Body.Body{412.0,250.0,1,2,4,0.0,0,[],0},Body.Body{420.0,250.0,1,3,4,0.0,0,[],0}],3,0.0,180,1)
def advance(packet:G.Packet) -> IO(G.Packet):
  match packet:
    case G.Packet{state,_}:G.advance(state,0.0,0.0)
    case G.Failed{error}:IO.pure(G.Packet,G.Failed{error})
def live_rows(result:Root.Application() & Result<&2,&2,Unit,List<&2,Body.Body>>) -> U32:
  match result:
    case (_,Done{rows}):U32.from_nat(List.length(&2,Body.Body,rows))
    case _:0
def live_state(state:G.State) -> U32:
  match state:
    case G.State{app,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_}:live_rows(Observe.snapshot(app))
def live_count(packet:G.Packet) -> U32:
  match packet:
    case G.Packet{state,_}:live_state(state)
    case _:0
