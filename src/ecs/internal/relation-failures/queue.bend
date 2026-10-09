import Base

# Owned descriptor-local FIFO metadata. Back is newest-first, front oldest-first.
# Cached size makes publication and whole-batch capacity trim amortized linear.
type Batch<E: Data> is Data:
  Batch{tick: Nat,count: Nat,values: List<&2,E>}
type Queue<E: Data> is Data:
  Queue{front: List<&2,Batch<E>>,back: List<&2,Batch<E>>,size: Nat,dropped: Nat}

def empty(~E: Data) -> Queue<E>: Queue{[],[],0n,0n}

def count_loop(~E: Data,items: List<&2,E>,acc: Nat) -> Nat:
  match items:
    case []: acc
    case _ <> rest: count_loop(~E,rest,Nat.add(1n,acc))

def publish_nonempty(~E: Data,queue: Queue<E>,+tick: Nat,+items: List<&2,E>,+count: Nat) -> Queue<E>:
  match queue:
    case Queue{front,back,size,dropped}: Queue{front,Batch{tick,count,items} <> back,Nat.add(size,count),dropped}

def publish_checked(~E: Data,nonempty: Bool,queue: Queue<E>,tick: Nat,items: List<&2,E>,count: Nat) -> Queue<E>:
  match nonempty:
    case False{}: queue
    case True{}: publish_nonempty(~E,queue,tick,items,count)

def publish(~E: Data,queue: Queue<E>,tick: Nat,+items: List<&2,E>) -> Queue<E>:
  publish_checked(~E,Nat.is_lt(0n,count_loop(~E,items,0n)),queue,tick,items,count_loop(~E,items,0n))

def normalize(~E: Data,queue: Queue<E>) -> Queue<E>:
  match queue:
    case Queue{Nil{},back,size,dropped}: Queue{List.reverse(&2,Batch<E>,back),[],size,dropped}
    case Queue{front,back,size,dropped}: Queue{front,back,size,dropped}

def trim_step(~E: Data,remove: Bool,+tick: Nat,+count: Nat,+items: List<&2,E>,+rest: List<&2,Batch<E>>,+back: List<&2,Batch<E>>,+size: Nat,+dropped: Nat,ih: Queue<E> -> Queue<E>) -> Queue<E>:
  match remove:
    case False{}: Queue{Batch{tick,count,items} <> rest,back,size,dropped}
    case True{}: ih(Queue{rest,back,Nat.sub(size,count),Nat.max(dropped,tick)})

def trim_normalized(~E: Data,queue: Queue<E>,+boundary: Nat,+capacity: Nat,ih: Queue<E> -> Queue<E>) -> Queue<E>:
  match queue:
    case Queue{Nil{},back,size,dropped}: Queue{[],back,size,dropped}
    case Queue{Batch{+tick,+count,+items} <> +rest,+back,+size,+dropped}: trim_step(~E,Bool.or(Nat.is_le(tick,boundary),Nat.is_lt(capacity,size)),tick,count,items,rest,back,size,dropped,ih)

def trim_loop(~E: Data,fuel: Nat,queue: Queue<E>,+boundary: Nat,+capacity: Nat) -> Queue<E>:
  match fuel:
    case Zero{}: queue
    case Succ{rest}: trim_normalized(~E,normalize(~E,queue),boundary,capacity,next => trim_loop(~E,rest,next,boundary,capacity))

def trim(~E: Data,queue: Queue<E>,boundary: Nat,capacity: Nat) -> Queue<E>:
  match queue:
    case Queue{+front,+back,+size,+dropped}: trim_loop(~E,Nat.add(size,1n),Queue{front,back,size,dropped},boundary,capacity)

# Materialization is tail-safe; no recursive append of a growing retained prefix.
def prepend_items(~E: Data,items: List<&2,E>,acc: List<&2,E>) -> List<&2,E>:
  match items:
    case []: acc
    case item <> rest: prepend_items(~E,rest,item <> acc)

def visible_items(~E: Data,visible: Bool,items: List<&2,E>,acc: List<&2,E>) -> List<&2,E>:
  match visible:
    case False{}: acc
    case True{}: prepend_items(~E,items,acc)

def read_loop(~E: Data,batches: List<&2,Batch<E>>,+cursor: Nat,acc: List<&2,E>) -> List<&2,E>:
  match batches:
    case []: acc
    case Batch{tick,_,items} <> rest: read_loop(~E,rest,cursor,visible_items(~E,Nat.is_lt(cursor,tick),items,acc))

def read_back(~E: Data,+front: List<&2,Batch<E>>,+back: List<&2,Batch<E>>,+cursor: Nat) -> List<&2,E>:
  List.reverse(&2,E,read_loop(~E,List.reverse(&2,Batch<E>,back),cursor,read_loop(~E,front,cursor,[])))

def read(~E: Data,queue: Queue<E>,cursor: Nat) -> List<&2,E>:
  match queue:
    case Queue{front,back,_,_}: read_back(~E,front,back,cursor)
