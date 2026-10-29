import Base

# Owned descriptor-local FIFO metadata. Back is newest-first, front oldest-first.
# Cached event size and batch count retain empty-batch compatibility without scans.
type Batch<E: Data> is Data:
  Batch{tick: Nat,count: Nat,values: List<&2,E>}
type Queue<E: Data> is Data:
  Queue{front: List<&2,Batch<E>>,back: List<&2,Batch<E>>,size: Nat,dropped: Nat,batchCount: Nat}

def empty_generic(-E: Data) -> Queue<E>: Queue{[],[],0n,0n,0n}

def count_loop_generic(-E: Data,items: List<&2,E>,acc: Nat) -> Nat:
  match items:
    case []: acc
    case _ <> rest: count_loop_generic(E,rest,Nat.add(1n,acc))

# The compatibility batch-list lowering also uses count zero for empty batches.
def publish_nonempty_generic(-E: Data,queue: Queue<E>,+tick: Nat,+items: List<&2,E>,+count: Nat) -> Queue<E>:
  match queue:
    case Queue{front,back,size,dropped,batches}: Queue{front,Batch{tick,count,items} <> back,Nat.add(size,count),dropped,1n+batches}

def publish_checked_generic(-E: Data,nonempty: Bool,queue: Queue<E>,tick: Nat,items: List<&2,E>,count: Nat) -> Queue<E>:
  match nonempty:
    case False{}: queue
    case True{}: publish_nonempty_generic(E,queue,tick,items,count)

def publish_generic(-E: Data,queue: Queue<E>,tick: Nat,+items: List<&2,E>) -> Queue<E>:
  publish_checked_generic(E,Nat.is_lt(0n,count_loop_generic(E,items,0n)),queue,tick,items,count_loop_generic(E,items,0n))

def normalize_generic(-E: Data,queue: Queue<E>) -> Queue<E>:
  match queue:
    case Queue{Nil{},back,size,dropped,batches}: Queue{List.reverse(&2,Batch<E>,back),[],size,dropped,batches}
    case Queue{front,back,size,dropped,batches}: Queue{front,back,size,dropped,batches}

def trim_step_generic(-E: Data,remove: Bool,+tick: Nat,+count: Nat,+items: List<&2,E>,+rest: List<&2,Batch<E>>,+back: List<&2,Batch<E>>,+size: Nat,+dropped: Nat,+batches:Nat,ih: Queue<E> -> Queue<E>) -> Queue<E>:
  match remove:
    case False{}: Queue{Batch{tick,count,items} <> rest,back,size,dropped,batches}
    case True{}: ih(Queue{rest,back,Nat.sub(size,count),Nat.max(dropped,tick),Nat.sub(batches,1n)})

# Match the canonical two-pass policy even for non-monotonic supplied ticks:
# first remove the expired prefix, then evict whole batches for capacity only.
def past_normalized_generic(-E:Data,queue:Queue<E>,+boundary:Nat,ih:Queue<E> -> Queue<E>) -> Queue<E>:
  match queue:
    case Queue{Nil{},back,size,dropped,batches}:Queue{[],back,size,dropped,batches}
    case Queue{Batch{+tick,+count,+items} <> +rest,+back,+size,+dropped,+batches}:trim_step_generic(E,Nat.is_le(tick,boundary),tick,count,items,rest,back,size,dropped,batches,ih)
def past_loop_generic(-E:Data,fuel:Nat,queue:Queue<E>,+boundary:Nat) -> Queue<E>:
  match fuel:
    case Zero{}:queue
    case Succ{rest}:past_normalized_generic(E,normalize_generic(E,queue),boundary,next => past_loop_generic(E,rest,next,boundary))
def capacity_normalized_generic(-E:Data,queue:Queue<E>,+capacity:Nat,ih:Queue<E> -> Queue<E>) -> Queue<E>:
  match queue:
    case Queue{Nil{},back,size,dropped,batches}:Queue{[],back,size,dropped,batches}
    case Queue{Batch{+tick,+count,+items} <> +rest,+back,+size,+dropped,+batches}:trim_step_generic(E,Nat.is_lt(capacity,size),tick,count,items,rest,back,size,dropped,batches,ih)
def capacity_loop_generic(-E:Data,fuel:Nat,queue:Queue<E>,+capacity:Nat) -> Queue<E>:
  match fuel:
    case Zero{}:queue
    case Succ{rest}:capacity_normalized_generic(E,normalize_generic(E,queue),capacity,next => capacity_loop_generic(E,rest,next,capacity))
def capacity_pass_generic(-E:Data,queue:Queue<E>,capacity:Nat) -> Queue<E>:
  match queue:
    case Queue{front,back,size,dropped,+batches}:capacity_loop_generic(E,Nat.add(batches,1n),Queue{front,back,size,dropped,batches},capacity)
def trim_generic(-E:Data,queue:Queue<E>,boundary:Nat,capacity:Nat) -> Queue<E>:
  match queue:
    case Queue{front,back,size,dropped,+batches}:capacity_pass_generic(E,past_loop_generic(E,Nat.add(batches,1n),Queue{front,back,size,dropped,batches},boundary),capacity)

# Materialization is tail-safe; no recursive append of a growing retained prefix.
def prepend_items_generic(-E: Data,items: List<&2,E>,acc: List<&2,E>) -> List<&2,E>:
  match items:
    case []: acc
    case item <> rest: prepend_items_generic(E,rest,item <> acc)

def visible_items_generic(-E: Data,visible: Bool,items: List<&2,E>,acc: List<&2,E>) -> List<&2,E>:
  match visible:
    case False{}: acc
    case True{}: prepend_items_generic(E,items,acc)

def read_loop_generic(-E: Data,batches: List<&2,Batch<E>>,+cursor: Nat,acc: List<&2,E>) -> List<&2,E>:
  match batches:
    case []: acc
    case Batch{tick,_,items} <> rest: read_loop_generic(E,rest,cursor,visible_items_generic(E,Nat.is_lt(cursor,tick),items,acc))

def read_back_generic(-E: Data,+front: List<&2,Batch<E>>,+back: List<&2,Batch<E>>,+cursor: Nat) -> List<&2,E>:
  List.reverse(&2,E,read_loop_generic(E,List.reverse(&2,Batch<E>,back),cursor,read_loop_generic(E,front,cursor,[])))

def read_generic(-E: Data,queue: Queue<E>,cursor: Nat) -> List<&2,E>:
  match queue:
    case Queue{front,back,_,_,_}: read_back_generic(E,front,back,cursor)

# Public template entry points retain the historical API. Pure queue policy
# uses erased generic types internally, avoiding caller-dependent staging depth.
def empty(~E: Data) -> Queue<E>:
  empty_generic(E)

def count_loop(~E: Data,items: List<&2,E>,acc: Nat) -> Nat:
  count_loop_generic(E,items,acc)

def publish_nonempty(~E: Data,queue: Queue<E>,+tick: Nat,+items: List<&2,E>,+count: Nat) -> Queue<E>:
  publish_nonempty_generic(E,queue,tick,items,count)

def publish_checked(~E: Data,nonempty: Bool,queue: Queue<E>,tick: Nat,items: List<&2,E>,count: Nat) -> Queue<E>:
  publish_checked_generic(E,nonempty,queue,tick,items,count)

def publish(~E: Data,queue: Queue<E>,tick: Nat,+items: List<&2,E>) -> Queue<E>:
  publish_generic(E,queue,tick,items)

def normalize(~E: Data,queue: Queue<E>) -> Queue<E>:
  normalize_generic(E,queue)

def trim_step(~E: Data,remove: Bool,+tick: Nat,+count: Nat,+items: List<&2,E>,+rest: List<&2,Batch<E>>,+back: List<&2,Batch<E>>,+size: Nat,+dropped: Nat,+batches:Nat,ih: Queue<E> -> Queue<E>) -> Queue<E>:
  trim_step_generic(E,remove,tick,count,items,rest,back,size,dropped,batches,ih)

def past_normalized(~E:Data,queue:Queue<E>,+boundary:Nat,ih:Queue<E> -> Queue<E>) -> Queue<E>:
  past_normalized_generic(E,queue,boundary,ih)

def past_loop(~E:Data,fuel:Nat,queue:Queue<E>,+boundary:Nat) -> Queue<E>:
  past_loop_generic(E,fuel,queue,boundary)

def capacity_normalized(~E:Data,queue:Queue<E>,+capacity:Nat,ih:Queue<E> -> Queue<E>) -> Queue<E>:
  capacity_normalized_generic(E,queue,capacity,ih)

def capacity_loop(~E:Data,fuel:Nat,queue:Queue<E>,+capacity:Nat) -> Queue<E>:
  capacity_loop_generic(E,fuel,queue,capacity)

def capacity_pass(~E:Data,queue:Queue<E>,capacity:Nat) -> Queue<E>:
  capacity_pass_generic(E,queue,capacity)

def trim(~E:Data,queue:Queue<E>,boundary:Nat,capacity:Nat) -> Queue<E>:
  trim_generic(E,queue,boundary,capacity)

def prepend_items(~E: Data,items: List<&2,E>,acc: List<&2,E>) -> List<&2,E>:
  prepend_items_generic(E,items,acc)

def visible_items(~E: Data,visible: Bool,items: List<&2,E>,acc: List<&2,E>) -> List<&2,E>:
  visible_items_generic(E,visible,items,acc)

def read_loop(~E: Data,batches: List<&2,Batch<E>>,+cursor: Nat,acc: List<&2,E>) -> List<&2,E>:
  read_loop_generic(E,batches,cursor,acc)

def read_back(~E: Data,+front: List<&2,Batch<E>>,+back: List<&2,Batch<E>>,+cursor: Nat) -> List<&2,E>:
  read_back_generic(E,front,back,cursor)

def read(~E: Data,queue: Queue<E>,cursor: Nat) -> List<&2,E>:
  read_generic(E,queue,cursor)
