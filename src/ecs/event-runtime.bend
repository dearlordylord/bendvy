import Base
import ./world.bend as W

# One event domain; World owns payloads, this owner owns batch and reader metadata.
# Ordered detached Data publications grouped at a runtime tick. This is not an
# affine payload owner or an acknowledgement from a reader.
type Batch<E: Data> is Data:
  Batch{tick: Nat,values: List<&2,E>}
# Activated reader metadata: last consumed cursor and activation tick. Merely
# allocating a Reader token does not add a Position or hold old batches.
type Position is Data:
  Position{id: U32,cursor: Nat,registeredAt: Nat}
# Actual affine token binding runtime namespace and reader id to one registry id.
# Raw construction is trusted setup, not proof of registration/provenance.
type Reader<S: Data> is Type:
  Reader{namespace: U32,id: U32,registryId: U32}
# Sole actual World plus Data batch/reader metadata and retention accounting.
# This lower-level runtime handles Data E; affine Type payload logs use separate
# owned-event APIs. Raw metadata construction and World callbacks remain trusted.
type Runtime<S: Data,C: Type,R: Type,E: Data> is Type:
  Runtime{world: W.World<S,C,R,E>,namespace: U32,batches: List<&2,Batch<E>>,positions: List<&2,Position>,nextReader: U32,tick: Nat,frameStart: Nat,boundary: Nat,capacity: Nat,droppedThrough: Nat}
# Unread Data values and lag flag supplied to a runner with actual possibly-
# affine Args. Callback consumption does not imply Args recovery on failure.
type Input<E: Data,A: Type> is Type:
  Input{values: List<&2,E>,lagged: Bool,args: A}
# Detached unread Data in publication order plus bounded-retention lag status.
# Reading alone does not advance a cursor or protect messages from trimming.
type Reading<E: Data> is Data:
  Reading{values: List<&2,E>,lagged: Bool}
type Trimmed<E: Data> is Data:
  Trimmed{batches: List<&2,Batch<E>>,dropped: Nat}

def count_loop(~E: Data,items: List<&2,E>,+acc: Nat) -> Nat:
  match items:
    case []: acc
    case _ <> rest: count_loop(~E,rest,1n+acc)

def count(~E: Data,items: List<&2,E>) -> Nat: count_loop(~E,items,0n)

def append_loop(~E: Data,reversed: List<&2,E>,+output: List<&2,E>) -> List<&2,E>:
  match reversed:
    case []: output
    case head <> rest: append_loop(~E,rest,head <> output)

def append(~E: Data,+left: List<&2,E>,+right: List<&2,E>) -> List<&2,E>:
  match left right:
    case Nil{} right: right
    case left Nil{}: left
    case left right: append_loop(~E,List.reverse(&2,E,left),right)

def values(~E: Data,batches: List<&2,Batch<E>>) -> List<&2,E>:
  match batches:
    case []: []
    case Batch{_,items} <> rest: append(~E,items,values(~E,rest))

def size_loop(~E: Data,batches: List<&2,Batch<E>>,+acc: Nat) -> Nat:
  match batches:
    case []: acc
    case Batch{_,items} <> rest: size_loop(~E,rest,count_loop(~E,items,acc))

def size(~E: Data,batches: List<&2,Batch<E>>) -> Nat:
  size_loop(~E,batches,0n)

def hold_boundary(positions: List<&2,Position>,+boundary: Nat) -> Nat:
  match positions:
    case []: boundary
    case Position{_,cursor,_} <> rest: hold_boundary(rest,Nat.min(boundary,cursor))

def past_checked(~E: Data,remove: Bool,+tick: Nat,+items: List<&2,E>,+rest: List<&2,Batch<E>>,+dropped: Nat,ih: Nat -> Trimmed<E>) -> Trimmed<E>:
  match remove:
    case False{}: Trimmed{Batch{tick,items} <> rest,dropped}
    case True{}: ih(Nat.max(dropped,tick))

def past_window(~E: Data,batches: List<&2,Batch<E>>,+boundary: Nat,+dropped: Nat) -> Trimmed<E>:
  match batches:
    case []: Trimmed{[],dropped}
    case Batch{+tick,+items} <> +rest: past_checked(~E,Nat.is_le(tick,boundary),tick,items,rest,dropped,gone => past_window(~E,rest,boundary,gone))

def capacity_checked(~E: Data,overflow: Bool,+tick: Nat,+items: List<&2,E>,+rest: List<&2,Batch<E>>,+dropped: Nat,ih: Nat -> Trimmed<E>) -> Trimmed<E>:
  match overflow:
    case False{}: Trimmed{Batch{tick,items} <> rest,dropped}
    case True{}: ih(Nat.max(dropped,tick))

def at_capacity(~E: Data,batches: List<&2,Batch<E>>,+capacity: Nat,+dropped: Nat) -> Trimmed<E>:
  match batches:
    case []: Trimmed{[],dropped}
    case Batch{+tick,+items} <> +rest: capacity_checked(~E,Nat.is_lt(capacity,size(~E,Batch{tick,items} <> rest)),tick,items,rest,dropped,gone => at_capacity(~E,rest,capacity,gone))

def trim_capacity(~E: Data,trimmed: Trimmed<E>,+capacity: Nat) -> Trimmed<E>:
  match trimmed:
    case Trimmed{batches,dropped}: at_capacity(~E,batches,capacity,dropped)

def trim_result(~S: Data,~C: Type,~R: Type,~E: Data,world: W.World<S,C,R,E>,+namespace: U32,+positions: List<&2,Position>,+nextReader: U32,+tick: Nat,+frameStart: Nat,+boundary: Nat,+capacity: Nat,trimmed: Trimmed<E>) -> Runtime<S,C,R,E>:
  match trimmed:
    case Trimmed{+batches,dropped}: Runtime{W.events_replace(~S,~C,~R,~E,world,values(~E,batches)),namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped}

def trim(~S: Data,~C: Type,~R: Type,~E: Data,runtime: Runtime<S,C,R,E>) -> Runtime<S,C,R,E>:
  match runtime:
    case Runtime{world,+namespace,+batches,+positions,+nextReader,+tick,+frameStart,+boundary,+capacity,+dropped}: trim_result(~S,~C,~R,~E,world,namespace,positions,nextReader,tick,frameStart,boundary,capacity,trim_capacity(~E,past_window(~E,batches,hold_boundary(positions,boundary),dropped),capacity))

# Advance frame markers and apply trim, returning actual Runtime/World. This
# bounds normal visibility while preserving unread holds only within hard capacity.
# Does not run a system, apply pending structural commands or acknowledge readers.
def frame(~S: Data,~C: Type,~R: Type,~E: Data,runtime: Runtime<S,C,R,E>) -> Runtime<S,C,R,E>:
  match runtime:
    case Runtime{world,namespace,batches,positions,nextReader,+tick,+frameStart,_,capacity,dropped}: trim(~S,~C,~R,~E,Runtime{world,namespace,batches,positions,nextReader,tick,tick,frameStart,capacity,dropped})

def start_named(~S: Data,~C: Type,~R: Type,~E: Data,+capacity: Nat,named: W.World<S,C,R,E> & U32) -> Runtime<S,C,R,E>:
  (world,namespace) = named
  Runtime{world,namespace,[],[],1,0n,0n,0n,capacity,0n}

# Start runtime metadata for the actual World namespace and supplied capacity.
# Initial batches/readers/tick are empty/zero; this does not consume World events
# or automatically synchronize an already populated log.
def start(~S: Data,~C: Type,~R: Type,~E: Data,world: W.World<S,C,R,E>,+capacity: Nat) -> Runtime<S,C,R,E>:
  start_named(~S,~C,~R,~E,capacity,W.namespace(~S,~C,~R,~E,world))


def update_checked(found: Bool,dispose: Bool,+id: U32,+old: Nat,+registered: Nat,+rest: List<&2,Position>,+cursor: Nat) -> List<&2,Position>:
  match found dispose:
    case False{} _: Position{id,old,registered} <> rest
    case True{} False{}: Position{id,cursor,registered} <> rest
    case True{} True{}: rest

def update(positions: List<&2,Position>,+id: U32,+cursor: Nat,+dispose: Bool) -> List<&2,Position>:
  match positions:
    case []: []
    case Position{+actual,+old,+registered} <> rest: update_checked(U32.is_eq(actual,id),dispose,actual,old,registered,update(rest,id,cursor,dispose),cursor)


def choose_position(found: Bool,+position: Position,fallback: Maybe<Position>) -> Maybe<Position>:
  match found:
    case False{}: fallback
    case True{}: Some{position}

def lookup_checked(position: Position,+id: U32,fallback: Maybe<Position>) -> Maybe<Position>:
  match position:
    case Position{+actual,+cursor,+registered}: choose_position(U32.is_eq(actual,id),Position{actual,cursor,registered},fallback)

def lookup(positions: List<&2,Position>,+id: U32) -> Maybe<Position>:
  match positions:
    case []: None{}
    case +position <> rest: lookup_checked(position,id,lookup(rest,id))


def since_checked(~E: Data,visible: Bool,+items: List<&2,E>,+rest: List<&2,E>) -> List<&2,E>:
  match visible:
    case False{}: rest
    case True{}: append(~E,items,rest)

def since(~E: Data,batches: List<&2,Batch<E>>,+cursor: Nat) -> List<&2,E>:
  match batches:
    case []: []
    case Batch{+tick,+items} <> rest: since_checked(~E,Nat.is_lt(cursor,tick),items,since(~E,rest,cursor))


def reading(~E: Data,position: Position,+batches: List<&2,Batch<E>>,+dropped: Nat) -> Reading<E>:
  match position:
    case Position{_,+cursor,+registered}: Reading{since(~E,batches,cursor),Nat.is_lt(Nat.max(cursor,registered),dropped)}

def sync_checked(~E: Data,nonempty: Bool,+batches: List<&2,Batch<E>>,+tick: Nat,+published: List<&2,E>) -> List<&2,Batch<E>>:
  match nonempty:
    case False{}: batches
    case True{}: append(~Batch<E>,batches,[Batch{tick,published}])

def sync_values(~S: Data,~C: Type,~R: Type,~E: Data,observed: W.World<S,C,R,E> & List<&2,E>,+namespace: U32,+batches: List<&2,Batch<E>>,+positions: List<&2,Position>,+nextReader: U32,+tick: Nat,+frameStart: Nat,+boundary: Nat,+capacity: Nat,+dropped: Nat) -> Runtime<S,C,R,E>:
  (world,+all) = observed
  +published = List.drop(&2,E,all,size(~E,batches))
  Runtime{world,namespace,sync_checked(~E,Nat.is_lt(0n,count(~E,published)),batches,tick,published),positions,nextReader,tick,frameStart,boundary,capacity,dropped}

def with_world_result(~S: Data,~C: Type,~R: Type,~E: Data,~O: Type,returned: W.World<S,C,R,E> & O,+namespace: U32,+batches: List<&2,Batch<E>>,+positions: List<&2,Position>,+nextReader: U32,+tick: Nat,+frameStart: Nat,+boundary: Nat,+capacity: Nat,+dropped: Nat) -> Runtime<S,C,R,E> & O:
  (world,output) = returned
  (sync_values(~S,~C,~R,~E,W.events_view(~S,~C,~R,~E,world),namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped),output)

# Advanced action bridge: consume/return actual World and Out, advance runtime
# tick, then synchronize newly appended World events by the existing retained-log
# prefix length. Action must respect that synchronization invariant; this is not
# a read-only guarantee, transaction wrapper or implicit structural barrier.
def with_world(~S: Data,~C: Type,~R: Type,~E: Data,~O: Type,effect: W.World<S,C,R,E> -> W.World<S,C,R,E> & O,runtime: Runtime<S,C,R,E>) -> Runtime<S,C,R,E> & O:
  match runtime:
    case Runtime{world,+namespace,+batches,+positions,+nextReader,+tick,+frameStart,+boundary,+capacity,+dropped}: with_world_result(~S,~C,~R,~E,~O,effect(world),namespace,batches,positions,nextReader,1n+tick,frameStart,boundary,capacity,dropped)

# Succeeded returns actual Out; Failed carries callback Error without consumed
# Args; Rejected returns unconsumed Args. Higher-level semantic errors encoded
# inside Out must be inspected separately from transport success.
type Completion<Error: Data,O: Type,A: Type> is Type:
  Succeeded{output: O}
  Failed{error: Error}
  Rejected{args: A}
def activation(position: Maybe<Position>,+positions: List<&2,Position>,+id: U32,+registered: Nat) -> List<&2,Position>:
  match position:
    case None{}: Position{id,0n,registered} <> positions
    case Some{_}: positions

def activate(+positions: List<&2,Position>,+id: U32,+registered: Nat) -> List<&2,Position>:
  activation(lookup(positions,id),positions,id,registered)

# A condition skip discards stream backlog without invoking gameplay.
def skip_checked(~S: Data,~C: Type,~R: Type,~E: Data,allowed: Bool,runtime: Runtime<S,C,R,E>,reader: Reader<S>,+id: U32) -> Runtime<S,C,R,E> & Reader<S>:
  match allowed runtime:
    case False{} runtime: (runtime,reader)
    case True{} Runtime{world,namespace,batches,positions,nextReader,+tick,frameStart,boundary,capacity,dropped}: (Runtime{world,namespace,batches,update(positions,id,tick,False{}),nextReader,tick,frameStart,boundary,capacity,dropped},reader)

# Condition-false lifecycle operation: for a matching namespace, advance an
# existing position to current tick without invoking gameplay. Does not activate
# an absent reader; foreign namespace leaves Runtime/Reader unchanged. No trim
# or registry disposal is performed.
def skip(~S: Data,~C: Type,~R: Type,~E: Data,runtime: Runtime<S,C,R,E>,reader: Reader<S>) -> Runtime<S,C,R,E> & Reader<S>:
  match runtime reader:
    case Runtime{world,+namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped} Reader{+readerNamespace,+id,+expected}: skip_checked(~S,~C,~R,~E,U32.is_eq(namespace,readerNamespace),Runtime{world,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped},Reader{readerNamespace,id,expected},id)

# Detached active-reader id/cursor/activation tick with unread count and lag flag.
# Registry ids are separate; statuses do not grant reading or mutation authority.
type ReaderStatus is Data:
  ReaderStatus{id: U32,cursor: Nat,registeredAt: Nat,unread: Nat,lagged: Bool}
# Detached visible batch values, retained World log and activated-reader statuses
# with tick/boundary. This is observation, not a restorable runtime checkpoint.
type Snapshot<E: Data> is Data:
  Snapshot{visible: List<&2,E>,retained: List<&2,E>,readers: List<&2,ReaderStatus>,tick: Nat,boundary: Nat}

def reader_status(~E: Data,position: Position,+batches: List<&2,Batch<E>>,+dropped: Nat) -> ReaderStatus:
  match position:
    case Position{+id,+cursor,+registered}: ReaderStatus{id,cursor,registered,count(~E,since(~E,batches,cursor)),Nat.is_lt(Nat.max(cursor,registered),dropped)}

def reader_statuses(~E: Data,positions: List<&2,Position>,+batches: List<&2,Batch<E>>,+dropped: Nat) -> List<&2,ReaderStatus>:
  match positions:
    case []: []
    case position <> rest: reader_status(~E,position,batches,dropped) <> reader_statuses(~E,rest,batches,dropped)

def inspect_values(~S: Data,~C: Type,~R: Type,~E: Data,observed: W.World<S,C,R,E> & List<&2,E>,+namespace: U32,+batches: List<&2,Batch<E>>,+positions: List<&2,Position>,+nextReader: U32,+tick: Nat,+frameStart: Nat,+boundary: Nat,+capacity: Nat,+dropped: Nat) -> Runtime<S,C,R,E> & Snapshot<E>:
  (world,retained) = observed
  (Runtime{world,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped},Snapshot{since(~E,batches,boundary),retained,reader_statuses(~E,List.reverse(&2,Position,positions),batches,dropped),tick,boundary})

# Return Runtime and detached Snapshot without synchronization, trimming, frame
# advance or reader acknowledgement. visible derives from batches after boundary;
# retained is the actual World event log, so unsynchronized publications may differ.
# Reader statuses follow reversed position order, not an inferred registry catalog.
def inspect(~S: Data,~C: Type,~R: Type,~E: Data,runtime: Runtime<S,C,R,E>) -> Runtime<S,C,R,E> & Snapshot<E>:
  match runtime:
    case Runtime{world,+namespace,+batches,+positions,+nextReader,+tick,+frameStart,+boundary,+capacity,+dropped}: inspect_values(~S,~C,~R,~E,W.events_view(~S,~C,~R,~E,world),namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped)

# Gameplay receives only a closed capability over an abstract affine owner.
# Closed read capability over opaque H returning detached Reading<E>. The bound
# operation defines lifecycle behavior; raw adapters remain trusted setup.
type ReadAccess<H: Type,E: Data,-observe: H -> H & Reading<E>> is Data:
  ReadAccess{}
# Closed Data-publication capability threading opaque H. This type alone does
# not promise transaction staging or rollback of arbitrary host side effects.
type WriteAccess<H: Type,E: Data,-publish: H -> E -> H> is Data:
  WriteAccess{}

# Invoke the declared closed observation, returning actual H plus Reading.
# Adds no validation or acknowledgement beyond the supplied operation.
def all(~H: Type,~E: Data,~observe: H -> H & Reading<E>,_: ReadAccess<H,E,observe>,owner: H) -> H & Reading<E>:
  observe(owner)

# Invoke the declared publication operation with Data event and return H.
# Publication timing/transaction behavior belongs to that bound provider.
def emit(~H: Type,~E: Data,~publish: H -> E -> H,_: WriteAccess<H,E,publish>,owner: H,event: E) -> H:
  publish(owner,event)

# Project copied unread values and lag from Input while retaining actual Args
# inside the returned Input owner. Does not rerun or advance the reader.
def input_read(~E: Data,~A: Type,input: Input<E,A>) -> Input<E,A> & Reading<E>:
  match input:
    case Input{+items,+lagged,args}: (Input{items,lagged,args},Reading{items,lagged})
