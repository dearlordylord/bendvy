import Base
import ./world.bend as W
import ./system.bend as Sy

# One event domain; World owns payloads, this owner owns batch and reader metadata.
type Batch<E: Data> is Data:
  Batch{tick: Nat,values: List<&2,E>}
type Position is Data:
  Position{id: U32,cursor: Nat,registeredAt: Nat}
type Reader<S: Data> is Type:
  Reader{namespace: U32,id: U32,registryId: U32}
type Runtime<S: Data,C: Type,R: Type,E: Data> is Type:
  Runtime{world: W.World<S,C,R,E>,namespace: U32,batches: List<&2,Batch<E>>,positions: List<&2,Position>,nextReader: U32,tick: Nat,frameStart: Nat,boundary: Nat,capacity: Nat,droppedThrough: Nat}
type Input<E: Data,A: Type> is Type:
  Input{values: List<&2,E>,lagged: Bool,args: A}
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

def frame(~S: Data,~C: Type,~R: Type,~E: Data,runtime: Runtime<S,C,R,E>) -> Runtime<S,C,R,E>:
  match runtime:
    case Runtime{world,namespace,batches,positions,nextReader,+tick,+frameStart,_,capacity,dropped}: trim(~S,~C,~R,~E,Runtime{world,namespace,batches,positions,nextReader,tick,tick,frameStart,capacity,dropped})

def start_named(~S: Data,~C: Type,~R: Type,~E: Data,+capacity: Nat,named: W.World<S,C,R,E> & U32) -> Runtime<S,C,R,E>:
  (world,namespace) = named
  Runtime{world,namespace,[],[],1,0n,0n,0n,capacity,0n}

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

def with_world(~S: Data,~C: Type,~R: Type,~E: Data,~O: Type,effect: W.World<S,C,R,E> -> W.World<S,C,R,E> & O,runtime: Runtime<S,C,R,E>) -> Runtime<S,C,R,E> & O:
  match runtime:
    case Runtime{world,+namespace,+batches,+positions,+nextReader,+tick,+frameStart,+boundary,+capacity,+dropped}: with_world_result(~S,~C,~R,~E,~O,effect(world),namespace,batches,positions,nextReader,1n+tick,frameStart,boundary,capacity,dropped)

type Registered<S: Data,C: Type,R: Type,E: Data,A: Type,Error: Data,O: Type,-runner: W.World<S,C,R,E> -> Input<E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>> is Type:
  Registered{runtime: Runtime<S,C,R,E>,reader: Reader<S>,registry: Sy.Registry<S,C,R,E,Input<E,A>,Error,O,runner>}
  RegisterFailed{runtime: Runtime<S,C,R,E>}
type Completion<Error: Data,O: Type,A: Type> is Type:
  Succeeded{output: O}
  Failed{error: Error}
  Rejected{args: A}
type RunResult<S: Data,C: Type,R: Type,E: Data,A: Type,Error: Data,O: Type,-runner: W.World<S,C,R,E> -> Input<E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>> is Type:
  Ran{runtime: Runtime<S,C,R,E>,reader: Reader<S>,registry: Sy.Registry<S,C,R,E,Input<E,A>,Error,O,runner>,completion: Completion<Error,O,A>}

def registered_identity(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~Error: Data,~O: Type,~runner: W.World<S,C,R,E> -> Input<E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>,world: W.World<S,C,R,E>,identity: Sy.Registry<S,C,R,E,Input<E,A>,Error,O,runner> & U32,+namespace: U32,+batches: List<&2,Batch<E>>,+positions: List<&2,Position>,+nextReader: U32,+tick: Nat,+frameStart: Nat,+boundary: Nat,+capacity: Nat,+dropped: Nat) -> Registered<S,C,R,E,A,Error,O,runner>:
  (registry,+registryId) = identity
  Registered{Runtime{world,namespace,batches,positions,(nextReader+1 : U32),tick,frameStart,boundary,capacity,dropped},Reader{namespace,nextReader,registryId},registry}

def registered_result(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~Error: Data,~O: Type,~runner: W.World<S,C,R,E> -> Input<E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>,result: Sy.RegistrationResult<S,C,R,E,Input<E,A>,Error,O,runner>,+namespace: U32,+batches: List<&2,Batch<E>>,+positions: List<&2,Position>,+nextReader: U32,+tick: Nat,+frameStart: Nat,+boundary: Nat,+capacity: Nat,+dropped: Nat) -> Registered<S,C,R,E,A,Error,O,runner>:
  match result:
    case Sy.RegistrationFailed{world}: RegisterFailed{Runtime{world,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped}}
    case Sy.Registered{world,registry}: registered_identity(~S,~C,~R,~E,~A,~Error,~O,~runner,world,Sy.identity(~S,~C,~R,~E,~Input<E,A>,~Error,~O,~runner,registry),namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped)

def register(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~Error: Data,~O: Type,~runner: W.World<S,C,R,E> -> Input<E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>,runtime: Runtime<S,C,R,E>,+name: String,+access: List<&2,String>) -> Registered<S,C,R,E,A,Error,O,runner>:
  match runtime:
    case Runtime{world,+namespace,+batches,+positions,+nextReader,+tick,+frameStart,+boundary,+capacity,+dropped}: registered_result(~S,~C,~R,~E,~A,~Error,~O,~runner,Sy.register(~S,~C,~R,~E,~Input<E,A>,~Error,~O,~runner,world,name,access),namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped)

def activation(position: Maybe<Position>,+positions: List<&2,Position>,+id: U32,+registered: Nat) -> List<&2,Position>:
  match position:
    case None{}: Position{id,0n,registered} <> positions
    case Some{_}: positions

def activate(+positions: List<&2,Position>,+id: U32,+registered: Nat) -> List<&2,Position>:
  activation(lookup(positions,id),positions,id,registered)

def run_outcome(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~Error: Data,~O: Type,~runner: W.World<S,C,R,E> -> Input<E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>,outcome: Sy.Outcome<W.World<S,C,R,E>,Error,O>,reader: Reader<S>,registry: Sy.Registry<S,C,R,E,Input<E,A>,Error,O,runner>,+readerId: U32,+namespace: U32,+batches: List<&2,Batch<E>>,+positions: List<&2,Position>,+nextReader: U32,+tick: Nat,+frameStart: Nat,+boundary: Nat,+capacity: Nat,+dropped: Nat) -> RunResult<S,C,R,E,A,Error,O,runner>:
  match outcome:
    case Sy.Failed{world,error}: Ran{Runtime{world,namespace,batches,activate(positions,readerId,Nat.sub(tick,1n)),nextReader,tick,frameStart,boundary,capacity,dropped},reader,registry,Failed{error}}
    case Sy.Succeeded{world,output}: Ran{sync_values(~S,~C,~R,~E,W.events_view(~S,~C,~R,~E,world),namespace,batches,update(activate(positions,readerId,Nat.sub(tick,1n)),readerId,tick,False{}),nextReader,tick,frameStart,boundary,capacity,dropped),reader,registry,Succeeded{output}}

def reject_input(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~Error: Data,~O: Type,~runner: W.World<S,C,R,E> -> Input<E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>,input: Input<E,A>,runtime: Runtime<S,C,R,E>,reader: Reader<S>,registry: Sy.Registry<S,C,R,E,Input<E,A>,Error,O,runner>) -> RunResult<S,C,R,E,A,Error,O,runner>:
  match input:
    case Input{_,_,args}: Ran{runtime,reader,registry,Rejected{args}}

def run_registered_result(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~Error: Data,~O: Type,~runner: W.World<S,C,R,E> -> Input<E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>,result: Sy.RunResult<S,C,R,E,Input<E,A>,Error,O,runner>,reader: Reader<S>,+readerId: U32,+namespace: U32,+batches: List<&2,Batch<E>>,+positions: List<&2,Position>,+nextReader: U32,+tick: Nat,+frameStart: Nat,+boundary: Nat,+capacity: Nat,+dropped: Nat) -> RunResult<S,C,R,E,A,Error,O,runner>:
  match result:
    case Sy.RegistrationRejected{registry,world,args}: reject_input(~S,~C,~R,~E,~A,~Error,~O,~runner,args,Runtime{world,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped},reader,registry)
    case Sy.Completed{registry,outcome}: run_outcome(~S,~C,~R,~E,~A,~Error,~O,~runner,outcome,reader,registry,readerId,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped)

def run_reading(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~Error: Data,~O: Type,~runner: W.World<S,C,R,E> -> Input<E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>,reading: Reading<E>,world: W.World<S,C,R,E>,reader: Reader<S>,registry: Sy.Registry<S,C,R,E,Input<E,A>,Error,O,runner>,args: A,+readerId: U32,+namespace: U32,+batches: List<&2,Batch<E>>,+positions: List<&2,Position>,+nextReader: U32,+tick: Nat,+frameStart: Nat,+boundary: Nat,+capacity: Nat,+dropped: Nat) -> RunResult<S,C,R,E,A,Error,O,runner>:
  match reading:
    case Reading{items,lagged}: run_registered_result(~S,~C,~R,~E,~A,~Error,~O,~runner,Sy.run(~S,~C,~R,~E,~Input<E,A>,~Error,~O,~runner,registry,world,Input{items,lagged,args}),reader,readerId,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped)

def run_position(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~Error: Data,~O: Type,~runner: W.World<S,C,R,E> -> Input<E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>,position: Maybe<Position>,world: W.World<S,C,R,E>,reader: Reader<S>,registry: Sy.Registry<S,C,R,E,Input<E,A>,Error,O,runner>,args: A,+readerId: U32,+namespace: U32,+batches: List<&2,Batch<E>>,+positions: List<&2,Position>,+nextReader: U32,+tick: Nat,+frameStart: Nat,+boundary: Nat,+capacity: Nat,+dropped: Nat) -> RunResult<S,C,R,E,A,Error,O,runner>:
  match position:
    case None{}: run_reading(~S,~C,~R,~E,~A,~Error,~O,~runner,reading(~E,Position{readerId,0n,tick},batches,dropped),world,reader,registry,args,readerId,namespace,batches,positions,nextReader,1n+tick,frameStart,boundary,capacity,dropped)
    case Some{position}: run_reading(~S,~C,~R,~E,~A,~Error,~O,~runner,reading(~E,position,batches,dropped),world,reader,registry,args,readerId,namespace,batches,positions,nextReader,1n+tick,frameStart,boundary,capacity,dropped)

def run_checked(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~Error: Data,~O: Type,~runner: W.World<S,C,R,E> -> Input<E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>,allowed: Bool,world: W.World<S,C,R,E>,reader: Reader<S>,registry: Sy.Registry<S,C,R,E,Input<E,A>,Error,O,runner>,args: A,+readerId: U32,+namespace: U32,+batches: List<&2,Batch<E>>,+positions: List<&2,Position>,+nextReader: U32,+tick: Nat,+frameStart: Nat,+boundary: Nat,+capacity: Nat,+dropped: Nat) -> RunResult<S,C,R,E,A,Error,O,runner>:
  match allowed:
    case False{}: Ran{Runtime{world,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped},reader,registry,Rejected{args}}
    case True{}: run_position(~S,~C,~R,~E,~A,~Error,~O,~runner,lookup(positions,readerId),world,reader,registry,args,readerId,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped)

def run_identity(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~Error: Data,~O: Type,~runner: W.World<S,C,R,E> -> Input<E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>,runtime: Runtime<S,C,R,E>,reader: Reader<S>,registry: Sy.Registry<S,C,R,E,Input<E,A>,Error,O,runner>,actual: U32,args: A) -> RunResult<S,C,R,E,A,Error,O,runner>:
  match runtime reader:
    case Runtime{world,+namespace,+batches,+positions,+nextReader,+tick,+frameStart,+boundary,+capacity,+dropped} Reader{+readerNamespace,+readerId,+expected}: run_checked(~S,~C,~R,~E,~A,~Error,~O,~runner,Bool.and(U32.is_eq(namespace,readerNamespace),U32.is_eq(expected,actual)),world,Reader{readerNamespace,readerId,expected},registry,args,readerId,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped)

def run_identified(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~Error: Data,~O: Type,~runner: W.World<S,C,R,E> -> Input<E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>,runtime: Runtime<S,C,R,E>,reader: Reader<S>,identified: Sy.Registry<S,C,R,E,Input<E,A>,Error,O,runner> & U32,args: A) -> RunResult<S,C,R,E,A,Error,O,runner>:
  (registry,actual) = identified
  run_identity(~S,~C,~R,~E,~A,~Error,~O,~runner,runtime,reader,registry,actual,args)

def run(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~Error: Data,~O: Type,~runner: W.World<S,C,R,E> -> Input<E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>,runtime: Runtime<S,C,R,E>,reader: Reader<S>,registry: Sy.Registry<S,C,R,E,Input<E,A>,Error,O,runner>,args: A) -> RunResult<S,C,R,E,A,Error,O,runner>:
  run_identified(~S,~C,~R,~E,~A,~Error,~O,~runner,runtime,reader,Sy.identity(~S,~C,~R,~E,~Input<E,A>,~Error,~O,~runner,registry),args)

# A condition skip discards stream backlog without invoking gameplay.
def skip_checked(~S: Data,~C: Type,~R: Type,~E: Data,allowed: Bool,runtime: Runtime<S,C,R,E>,reader: Reader<S>,+id: U32) -> Runtime<S,C,R,E> & Reader<S>:
  match allowed runtime:
    case False{} runtime: (runtime,reader)
    case True{} Runtime{world,namespace,batches,positions,nextReader,+tick,frameStart,boundary,capacity,dropped}: (Runtime{world,namespace,batches,update(positions,id,tick,False{}),nextReader,tick,frameStart,boundary,capacity,dropped},reader)

def skip(~S: Data,~C: Type,~R: Type,~E: Data,runtime: Runtime<S,C,R,E>,reader: Reader<S>) -> Runtime<S,C,R,E> & Reader<S>:
  match runtime reader:
    case Runtime{world,+namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped} Reader{+readerNamespace,+id,+expected}: skip_checked(~S,~C,~R,~E,U32.is_eq(namespace,readerNamespace),Runtime{world,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped},Reader{readerNamespace,id,expected},id)

type ReaderStatus is Data:
  ReaderStatus{id: U32,cursor: Nat,registeredAt: Nat,unread: Nat,lagged: Bool}
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

def inspect(~S: Data,~C: Type,~R: Type,~E: Data,runtime: Runtime<S,C,R,E>) -> Runtime<S,C,R,E> & Snapshot<E>:
  match runtime:
    case Runtime{world,+namespace,+batches,+positions,+nextReader,+tick,+frameStart,+boundary,+capacity,+dropped}: inspect_values(~S,~C,~R,~E,W.events_view(~S,~C,~R,~E,world),namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped)

type Disposal<S: Data,C: Type,R: Type,E: Data,A: Type,Error: Data,O: Type,-runner: W.World<S,C,R,E> -> Input<E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>> is Type:
  Disposed{runtime: Runtime<S,C,R,E>}
  DisposalRejected{runtime: Runtime<S,C,R,E>,reader: Reader<S>,registry: Sy.Registry<S,C,R,E,Input<E,A>,Error,O,runner>}

def disposal_result(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~Error: Data,~O: Type,~runner: W.World<S,C,R,E> -> Input<E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>,result: Sy.Disposal<S,C,R,E,Input<E,A>,Error,O,runner>,reader: Reader<S>,+id: U32,+namespace: U32,+batches: List<&2,Batch<E>>,+positions: List<&2,Position>,+nextReader: U32,+tick: Nat,+frameStart: Nat,+boundary: Nat,+capacity: Nat,+dropped: Nat) -> Disposal<S,C,R,E,A,Error,O,runner>:
  match result:
    case Sy.Disposed{world}: Disposed{Runtime{world,namespace,batches,update(positions,id,tick,True{}),nextReader,tick,frameStart,boundary,capacity,dropped}}
    case Sy.DisposalRejected{world,registry}: DisposalRejected{Runtime{world,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped},reader,registry}

def disposal_checked(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~Error: Data,~O: Type,~runner: W.World<S,C,R,E> -> Input<E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>,allowed: Bool,world: W.World<S,C,R,E>,reader: Reader<S>,registry: Sy.Registry<S,C,R,E,Input<E,A>,Error,O,runner>,+id: U32,+namespace: U32,+batches: List<&2,Batch<E>>,+positions: List<&2,Position>,+nextReader: U32,+tick: Nat,+frameStart: Nat,+boundary: Nat,+capacity: Nat,+dropped: Nat) -> Disposal<S,C,R,E,A,Error,O,runner>:
  match allowed:
    case False{}: DisposalRejected{Runtime{world,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped},reader,registry}
    case True{}: disposal_result(~S,~C,~R,~E,~A,~Error,~O,~runner,Sy.dispose(~S,~C,~R,~E,~Input<E,A>,~Error,~O,~runner,registry,world),reader,id,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped)

def disposal_identity(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~Error: Data,~O: Type,~runner: W.World<S,C,R,E> -> Input<E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>,runtime: Runtime<S,C,R,E>,reader: Reader<S>,registry: Sy.Registry<S,C,R,E,Input<E,A>,Error,O,runner>,actual: U32) -> Disposal<S,C,R,E,A,Error,O,runner>:
  match runtime reader:
    case Runtime{world,+namespace,+batches,+positions,+nextReader,+tick,+frameStart,+boundary,+capacity,+dropped} Reader{+readerNamespace,+id,+expected}: disposal_checked(~S,~C,~R,~E,~A,~Error,~O,~runner,Bool.and(U32.is_eq(namespace,readerNamespace),U32.is_eq(actual,expected)),world,Reader{readerNamespace,id,expected},registry,id,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped)

def disposal_identified(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~Error: Data,~O: Type,~runner: W.World<S,C,R,E> -> Input<E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>,runtime: Runtime<S,C,R,E>,reader: Reader<S>,identified: Sy.Registry<S,C,R,E,Input<E,A>,Error,O,runner> & U32) -> Disposal<S,C,R,E,A,Error,O,runner>:
  (registry,actual) = identified
  disposal_identity(~S,~C,~R,~E,~A,~Error,~O,~runner,runtime,reader,registry,actual)

def dispose(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~Error: Data,~O: Type,~runner: W.World<S,C,R,E> -> Input<E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>,runtime: Runtime<S,C,R,E>,reader: Reader<S>,registry: Sy.Registry<S,C,R,E,Input<E,A>,Error,O,runner>) -> Disposal<S,C,R,E,A,Error,O,runner>:
  disposal_identified(~S,~C,~R,~E,~A,~Error,~O,~runner,runtime,reader,Sy.identity(~S,~C,~R,~E,~Input<E,A>,~Error,~O,~runner,registry))

# Gameplay receives only a closed capability over an abstract affine owner.
type ReadAccess<H: Type,E: Data,-observe: H -> H & Reading<E>> is Data:
  ReadAccess{}
type WriteAccess<H: Type,E: Data,-publish: H -> E -> H> is Data:
  WriteAccess{}

def all(~H: Type,~E: Data,~observe: H -> H & Reading<E>,_: ReadAccess<H,E,observe>,owner: H) -> H & Reading<E>:
  observe(owner)

def emit(~H: Type,~E: Data,~publish: H -> E -> H,_: WriteAccess<H,E,publish>,owner: H,event: E) -> H:
  publish(owner,event)

def input_read(~E: Data,~A: Type,input: Input<E,A>) -> Input<E,A> & Reading<E>:
  match input:
    case Input{+items,+lagged,args}: (Input{items,lagged,args},Reading{items,lagged})
