import Base
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-event-declaration.bend as Event

# Detached Data metadata; the containing application retains the sole affine World.
type Stream<S:Data,E:Data> is Data:
  Stream{domain:Event.Domain<S,E>,batches:List<&2,Ev.Batch<E>>,positions:List<&2,Ev.Position>,nextReader:U32,frameStart:Nat,boundary:Nat,capacity:Nat,dropped:Nat}
def provision(~S:Data,~E:Data,domain:Event.Domain<S,E>,capacity:Nat) -> Stream<S,E>:
  Stream{domain,[],[],1,0n,0n,capacity,0n}
def append(~S:Data,~E:Data,stream:Stream<S,E>,tick:Nat,+values:List<&2,E>) -> Stream<S,E>:
  match stream:
    case Stream{domain,+batches,positions,nextReader,frameStart,boundary,capacity,dropped}:Stream{domain,Ev.sync_checked(~E,Nat.is_lt(0n,Ev.count(~E,values)),batches,tick,values),positions,nextReader,frameStart,boundary,capacity,dropped}
def registered(~S:Data,~E:Data,stream:Stream<S,E>,+tick:Nat) -> Stream<S,E> & U32:
  match stream:
    case Stream{domain,batches,positions,+nextReader,frameStart,boundary,capacity,dropped}:(Stream{domain,batches,positions,(nextReader+1:U32),frameStart,boundary,capacity,dropped},nextReader)
def read_position(~S:Data,~E:Data,stream:Stream<S,E>,+id:U32,+tick:Nat,position:Maybe<Ev.Position>) -> Stream<S,E> & Ev.Reading<E>:
  match stream position:
    case Stream{domain,+batches,positions,nextReader,frameStart,boundary,capacity,+dropped} Some{position}:(Stream{domain,batches,positions,nextReader,frameStart,boundary,capacity,dropped},Ev.reading(~E,position,batches,dropped))
    case Stream{domain,+batches,positions,nextReader,frameStart,boundary,capacity,+dropped} None{}:(Stream{domain,batches,positions,nextReader,frameStart,boundary,capacity,dropped},Ev.reading(~E,Ev.Position{id,0n,tick},batches,dropped))
def reading(~S:Data,~E:Data,+stream:Stream<S,E>,+id:U32,+tick:Nat) -> Stream<S,E> & Ev.Reading<E>:
  match stream:
    case Stream{+domain,+batches,+positions,+nextReader,+frameStart,+boundary,+capacity,+dropped}:read_position(~S,~E,Stream{domain,batches,positions,nextReader,frameStart,boundary,capacity,dropped},id,tick,Ev.lookup(positions,id))
def advance(~S:Data,~E:Data,stream:Stream<S,E>,+id:U32,+tick:Nat) -> Stream<S,E>:
  match stream:
    case Stream{domain,batches,positions,nextReader,frameStart,boundary,capacity,dropped}:Stream{domain,batches,Ev.update(Ev.activate(positions,id,Nat.sub(tick,1n)),id,tick,False{}),nextReader,frameStart,boundary,capacity,dropped}
def trimmed(~S:Data,~E:Data,domain:Event.Domain<S,E>,positions:List<&2,Ev.Position>,nextReader:U32,frameStart:Nat,boundary:Nat,capacity:Nat,trimmed:Ev.Trimmed<E>) -> Stream<S,E>:
  match trimmed:
    case Ev.Trimmed{batches,dropped}:Stream{domain,batches,positions,nextReader,frameStart,boundary,capacity,dropped}
def frame(~S:Data,~E:Data,stream:Stream<S,E>,+tick:Nat) -> Stream<S,E>:
  match stream:
    case Stream{domain,batches,+positions,nextReader,+frameStart,_,+capacity,dropped}:trimmed(~S,~E,domain,positions,nextReader,tick,frameStart,capacity,Ev.trim_capacity(~E,Ev.past_window(~E,batches,Ev.hold_boundary(positions,frameStart),dropped),capacity))
def inventory(~S:Data,~E:Data,stream:Stream<S,E>) -> String:
  match stream:
    case Stream{Event.Domain{key},_,_,_,_,_,_,_}:key
