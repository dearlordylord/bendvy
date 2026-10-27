import Base
import ./machine.bend as Machine
import ./deferred-command.bend as Deferred
import ./trace-facts.bend as TraceFacts
import ./transaction.bend as Tx

# Historical transactional operations over the shared machine state types.
# Journal the complete old slot before replacing it. Aliases see the current
# world through the same affine transaction; no independent machine owner copy.
def write_taken(~S: Data,~M: Data,~V: Data,~W: Type,~E: Data,
  ~put: W -> Machine.Slot<S,M,V> -> W,
  pair: W & Machine.Slot<S,M,V>,undo: List<&1,(W -> W)>,commands:List<&1,Deferred.Command<W>>,events: List<&2,E>,trace:TraceFacts.State,value: V,skipSame: Bool) -> Tx.Tx<W,E>:
  match pair:
    case (world,+old):
      Tx.Tx{put(world,Machine.queue(~S,~M,~V,old,value,skipSame)),(world => put(world,old)) <> undo,commands,events,trace}

def write(~S: Data,~M: Data,~V: Data,~W: Type,~E: Data,
  ~take: W -> W & Machine.Slot<S,M,V>,~put: W -> Machine.Slot<S,M,V> -> W,
  tx: Tx.Tx<W,E>,value: V,skipSame: Bool) -> Tx.Tx<W,E>:
  match tx:
    case Tx.Tx{world,undo,commands,events,trace}:
      write_taken(~S,~M,~V,~W,~E,~put,take(world),undo,commands,events,trace,value,skipSame)

def reset_taken(~S: Data,~M: Data,~V: Data,~W: Type,~E: Data,
  ~put: W -> Machine.Slot<S,M,V> -> W,
  pair: W & Machine.Slot<S,M,V>,undo: List<&1,(W -> W)>,commands:List<&1,Deferred.Command<W>>,events: List<&2,E>,trace:TraceFacts.State) -> Tx.Tx<W,E>:
  match pair:
    case (world,+old):
      Tx.Tx{put(world,Machine.reset(~S,~M,~V,old)),(world => put(world,old)) <> undo,commands,events,trace}

def reset_tx(~S: Data,~M: Data,~V: Data,~W: Type,~E: Data,
  ~take: W -> W & Machine.Slot<S,M,V>,~put: W -> Machine.Slot<S,M,V> -> W,
  tx: Tx.Tx<W,E>) -> Tx.Tx<W,E>:
  match tx:
    case Tx.Tx{world,undo,commands,events,trace}:
      reset_taken(~S,~M,~V,~W,~E,~put,take(world),undo,commands,events,trace)

def next(~S: Data,~M: Data,~V: Data,~W: Type,~E: Data,
  ~take: W -> W & Machine.Slot<S,M,V>,~put: W -> Machine.Slot<S,M,V> -> W,
  tx: Tx.Tx<W,E>,request: Machine.QueueInput<V>) -> Tx.Tx<W,E>:
  match request:
    case Machine.Set{value,skipSame}: write(~S,~M,~V,~W,~E,~take,~put,tx,value,skipSame)
    case Machine.Reset{}: reset_tx(~S,~M,~V,~W,~E,~take,~put,tx)

def read_taken(~S: Data,~M: Data,~V: Data,~W: Type,~E: Data,
  pair: W & Machine.Slot<S,M,V>,undo: List<&1,(W -> W)>,commands:List<&1,Deferred.Command<W>>,events: List<&2,E>,trace:TraceFacts.State) -> Tx.Tx<W,E> & Machine.Slot<S,M,V>:
  match pair:
    case (world,slot): (Tx.Tx{world,undo,commands,events,trace},slot)

def read(~S: Data,~M: Data,~V: Data,~W: Type,~E: Data,
  ~take: W -> W & Machine.Slot<S,M,V>,tx: Tx.Tx<W,E>) -> Tx.Tx<W,E> & Machine.Slot<S,M,V>:
  match tx:
    case Tx.Tx{world,undo,commands,events,trace}: read_taken(~S,~M,~V,~W,~E,take(world),undo,commands,events,trace)

def read_declared(~S: Data,~M: Data,~V: Data,~W: Type,~E: Data,
  ~take: W -> W & Machine.Slot<S,M,V>,~put: W -> Machine.Slot<S,M,V> -> W,
  _: Machine.Family<S,M,V,W,take,put>,tx: Tx.Tx<W,E>) -> Tx.Tx<W,E> & Machine.Slot<S,M,V>:
  read(~S,~M,~V,~W,~E,~take,tx)

def next_declared(~S: Data,~M: Data,~V: Data,~W: Type,~E: Data,
  ~take: W -> W & Machine.Slot<S,M,V>,~put: W -> Machine.Slot<S,M,V> -> W,
  _: Machine.Family<S,M,V,W,take,put>,tx: Tx.Tx<W,E>,request: Machine.QueueInput<V>) -> Tx.Tx<W,E>:
  next(~S,~M,~V,~W,~E,~take,~put,tx,request)
