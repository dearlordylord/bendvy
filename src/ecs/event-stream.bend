import Base
import ./event-runtime.bend as Ev
import ./ordinary-event-declaration.bend as Event

# Detached Data metadata; the containing application retains the sole affine World.
# Detached typed stream metadata: ordered Data batches and activated reader
# positions with retention accounting. It owns no World or affine payload log;
# raw construction/selection belongs to trusted family provisioning.
type Stream<S:Data,E:Data> is Data:
  Stream{domain:Event.Domain<S,E>,batches:List<&2,Ev.Batch<E>>,positions:List<&2,Ev.Position>,nextReader:U32,frameStart:Nat,boundary:Nat,capacity:Nat,dropped:Nat}
# Initialize an empty stream for a declared domain/capacity. No reader is active.
def provision(~S:Data,~E:Data,domain:Event.Domain<S,E>,capacity:Nat) -> Stream<S,E>:
  Stream{domain,[],[],1,0n,0n,capacity,0n}
# Check remaining U32 reader-id space, without allocating or activating a reader.
def can_register(~S:Data,~E:Data,stream:Stream<S,E>) -> Bool:
  match stream:
    case Stream{_,_,_,nextReader,_,_,_,_}:U32.is_lt(nextReader,4294967295)
def increment_reader(~S:Data,~E:Data,stream:Stream<S,E>,+tick:Nat) -> Stream<S,E> & U32:
  match stream:
    case Stream{domain,batches,positions,+nextReader,frameStart,boundary,capacity,dropped}:(Stream{domain,batches,positions,(nextReader+1:U32),frameStart,boundary,capacity,dropped},nextReader)
def registered_checked(~S:Data,~E:Data,available:Bool,stream:Stream<S,E>,+tick:Nat) -> Stream<S,E> & U32:
  match available:
    case False{}:(stream,0)
    case True{}:increment_reader(~S,~E,stream,tick)
# Append nonempty Data publications at the supplied tick using runtime batch rules.
# Does not advance readers or trim capacity; caller supplies ordered publication data.
def append(~S:Data,~E:Data,stream:Stream<S,E>,tick:Nat,+values:List<&2,E>) -> Stream<S,E>:
  match stream:
    case Stream{domain,+batches,positions,nextReader,frameStart,boundary,capacity,dropped}:Stream{domain,Ev.sync_checked(~E,Nat.is_lt(0n,Ev.count(~E,values)),batches,tick,values),positions,nextReader,frameStart,boundary,capacity,dropped}
# Allocate the next reader id, returning zero on exhaustion with stream unchanged.
# Does not activate its position or deliver unread data; routing checks admission
# before using this low-level result.
def registered(~S:Data,~E:Data,+stream:Stream<S,E>,+tick:Nat) -> Stream<S,E> & U32:
  registered_checked(~S,~E,can_register(~S,~E,stream),stream,tick)
def read_position(~S:Data,~E:Data,stream:Stream<S,E>,+id:U32,+tick:Nat,position:Maybe<Ev.Position>) -> Stream<S,E> & Ev.Reading<E>:
  match stream position:
    case Stream{domain,+batches,positions,nextReader,frameStart,boundary,capacity,+dropped} Some{position}:(Stream{domain,batches,positions,nextReader,frameStart,boundary,capacity,dropped},Ev.reading(~E,position,batches,dropped))
    case Stream{domain,+batches,positions,nextReader,frameStart,boundary,capacity,+dropped} None{}:(Stream{domain,batches,positions,nextReader,frameStart,boundary,capacity,dropped},Ev.reading(~E,Ev.Position{id,0n,tick},batches,dropped))
# Read ordered unread Data plus lag status using an existing position, or a
# not-yet-activated position for id/tick. Returns stream metadata without advancing
# its cursor. This helper does not validate an external reader token or World.
def reading(~S:Data,~E:Data,+stream:Stream<S,E>,+id:U32,+tick:Nat) -> Stream<S,E> & Ev.Reading<E>:
  match stream:
    case Stream{+domain,+batches,+positions,+nextReader,+frameStart,+boundary,+capacity,+dropped}:read_position(~S,~E,Stream{domain,batches,positions,nextReader,frameStart,boundary,capacity,dropped},id,tick,Ev.lookup(positions,id))
# Activate id if needed then advance its cursor to tick. Trusted completion
# operation, not an independent registration/provenance validation.
def advance(~S:Data,~E:Data,stream:Stream<S,E>,+id:U32,+tick:Nat) -> Stream<S,E>:
  match stream:
    case Stream{domain,batches,positions,nextReader,frameStart,boundary,capacity,dropped}:Stream{domain,batches,Ev.update(Ev.activate(positions,id,Nat.sub(tick,1n)),id,tick,False{}),nextReader,frameStart,boundary,capacity,dropped}
def trimmed(~S:Data,~E:Data,domain:Event.Domain<S,E>,positions:List<&2,Ev.Position>,nextReader:U32,frameStart:Nat,boundary:Nat,capacity:Nat,trimmed:Ev.Trimmed<E>) -> Stream<S,E>:
  match trimmed:
    case Ev.Trimmed{batches,dropped}:Stream{domain,batches,positions,nextReader,frameStart,boundary,capacity,dropped}
# Apply frame-window and capacity trimming with current active-reader holds.
# Return metadata with updated boundaries/dropped history; hard capacity can cause
# lag, so active readers do not promise indefinite retention.
def frame(~S:Data,~E:Data,stream:Stream<S,E>,+tick:Nat) -> Stream<S,E>:
  match stream:
    case Stream{domain,batches,+positions,nextReader,+frameStart,_,+capacity,dropped}:trimmed(~S,~E,domain,positions,nextReader,tick,frameStart,capacity,Ev.trim_capacity(~E,Ev.past_window(~E,batches,Ev.hold_boundary(positions,frameStart),dropped),capacity))
# Return the detached authored domain key without reading message payloads.
def inventory(~S:Data,~E:Data,stream:Stream<S,E>) -> String:
  match stream:
    case Stream{Event.Domain{key},_,_,_,_,_,_,_}:key
# Return the dropped-through history marker, not a message count.
def dropped(~S:Data,~E:Data,stream:Stream<S,E>) -> Nat:
  match stream:
    case Stream{_,_,_,_,_,_,_,value}:value
def completed_positions(success:Bool,+positions:List<&2,Ev.Position>,+id:U32,+tick:Nat) -> List<&2,Ev.Position>:
  match success:
    case False{}:Ev.activate(positions,id,Nat.sub(tick,1n))
    case True{}:Ev.update(Ev.activate(positions,id,Nat.sub(tick,1n)),id,tick,False{})
# Update one reader after execution: success advances to tick; failure preserves
# unread position while activating absent position under failed-reader rules.
# Caller supplies actual id/outcome; this does not execute or validate a callback.
def completed(~S:Data,~E:Data,stream:Stream<S,E>,id:U32,tick:Nat,success:Bool) -> Stream<S,E>:
  match stream:
    case Stream{domain,batches,positions,nextReader,frameStart,boundary,capacity,dropped}:Stream{domain,batches,completed_positions(success,positions,id,tick),nextReader,frameStart,boundary,capacity,dropped}
# Derive read-mode declaration from the retained stream domain, not a new writer grant.
def read_declaration(~S:Data,~E:Data,stream:Stream<S,E>) -> Event.Declaration<S,E>:
  match stream:
    case Stream{domain,_,_,_,_,_,_,_}:Event.read(~S,~E,domain)
# Project the retained typed domain; metadata alone is not reader ownership.
def domain(~S:Data,~E:Data,stream:Stream<S,E>) -> Event.Domain<S,E>:
  match stream:
    case Stream{domain,_,_,_,_,_,_,_}:domain
