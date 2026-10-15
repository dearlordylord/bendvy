import Base
import machine.bend as M
import event-runtime.bend as Ev
import machine-stream-queue.bend as Q

# FIFO metadata: front oldest-first, back newest-first; size counts events.
type Stream<V: Data> is Data:
  Stream{queue: Q.Queue<M.Transition<V>>,positions: List<&2,Ev.Position>,frameStart: Nat}
type Reader<S: Data,M: Data> is Type:
  Reader{namespace: U32,id: U32}

def empty(~V: Data) -> Stream<V>: Stream{Q.empty(~M.Transition<V>),[],0n}
def publish(~V: Data,stream: Stream<V>,tick: Nat,event: M.Transition<V>) -> Stream<V>:
  match stream:
    case Stream{queue,positions,frameStart}: Stream{Q.publish(~M.Transition<V>,queue,tick,[event]),positions,frameStart}
def activate(~V: Data,stream: Stream<V>,id: U32,tick: Nat) -> Stream<V>:
  match stream:
    case Stream{queue,positions,frameStart}: Stream{queue,Ev.activate(positions,id,tick),frameStart}
def complete(~V: Data,stream: Stream<V>,id: U32,tick: Nat,success: Bool) -> Stream<V>:
  match stream success:
    case Stream{queue,positions,frameStart} True{}: Stream{queue,Ev.update(positions,id,tick,False{}),frameStart}
    case stream False{}: stream
# A condition-false system never executes its reader parameter.
def skip(~V: Data,stream: Stream<V>,id: U32,tick: Nat) -> Stream<V>:
  stream

# Bevy insert_state replaces messages while preserving reader positions and loss.
def initial_queue(~V:Data,queue:Q.Queue<M.Transition<V>>,tick:Nat,value:V) -> Q.Queue<M.Transition<V>>:
  match queue:
    case Q.Queue{_,_,_,dropped,_}:Q.Queue{[],[Q.Batch{tick,1n,[M.Initial{value}]}],1n,dropped,1n}
def initial(~V:Data,stream:Stream<V>,tick:Nat,value:V) -> Stream<V>:
  match stream:
    case Stream{queue,positions,frameStart}:Stream{initial_queue(~V,queue,tick,value),positions,frameStart}

def observe_position(~V: Data,position: Maybe<Ev.Position>,batches: List<&2,Ev.Batch<M.Transition<V>>>,dropped: Nat,id: U32,tick: Nat) -> Ev.Reading<M.Transition<V>>:
  match position:
    case None{}: Ev.reading(~M.Transition<V>,Ev.Position{id,0n,tick},batches,dropped)
    case Some{position}: Ev.reading(~M.Transition<V>,position,batches,dropped)

def observe_registered(~V: Data,position: Ev.Position,+queue: Q.Queue<M.Transition<V>>) -> Ev.Reading<M.Transition<V>>:
  match position queue:
    case Ev.Position{_,+cursor,registered} Q.Queue{+front,+back,+size,+dropped,+batches}: Ev.Reading{Q.read(~M.Transition<V>,Q.Queue{front,back,size,dropped,batches},cursor),Nat.is_lt(Nat.max(cursor,registered),dropped)}
def observe_queue_position(~V: Data,position: Maybe<Ev.Position>,queue: Q.Queue<M.Transition<V>>,id: U32,tick: Nat) -> Ev.Reading<M.Transition<V>>:
  match position:
    case None{}: observe_registered(~V,Ev.Position{id,0n,tick},queue)
    case Some{position}: observe_registered(~V,position,queue)
def observe(~V: Data,stream: Stream<V>,+id: U32,tick: Nat) -> Ev.Reading<M.Transition<V>>:
  match stream:
    case Stream{queue,positions,_}: observe_queue_position(~V,Ev.lookup(positions,id),queue,id,tick)
def batches_into_queue(~V:Data,batches:List<&2,Ev.Batch<M.Transition<V>>>,queue:Q.Queue<M.Transition<V>>) -> Q.Queue<M.Transition<V>>:
  match batches:
    case []:queue
    case Ev.Batch{tick,+items} <> rest:batches_into_queue(~V,rest,Q.publish_nonempty(~M.Transition<V>,queue,tick,items,Q.count_loop(~M.Transition<V>,items,0n)))
def trimmed(~V:Data,frameStart:Nat,positions:List<&2,Ev.Position>,result:Ev.Trimmed<M.Transition<V>>) -> Stream<V>:
  match result:
    case Ev.Trimmed{batches,dropped}:Stream{batches_into_queue(~V,batches,Q.Queue{[],[],0n,dropped,0n}),positions,frameStart}

def frame(~V: Data,stream: Stream<V>,tick: Nat) -> Stream<V>:
  match stream:
    case Stream{queue,+positions,frameStart}: Stream{Q.trim(~M.Transition<V>,queue,Ev.hold_boundary(positions,frameStart),65536n),positions,tick}
def dispose(~V: Data,stream: Stream<V>,id: U32) -> Stream<V>:
  match stream:
    case Stream{queue,positions,frameStart}: Stream{queue,Ev.update(positions,id,0n,True{}),frameStart}

# Canonical snapshot includes every retained batch/payload, without changing cursor.
def batches_loop(~V: Data,batches: List<&2,Q.Batch<M.Transition<V>>>,acc: List<&2,Ev.Batch<M.Transition<V>>>) -> List<&2,Ev.Batch<M.Transition<V>>>:
  match batches:
    case []: List.reverse(&2,Ev.Batch<M.Transition<V>>,acc)
    case Q.Batch{tick,_,items} <> rest: batches_loop(~V,rest,Ev.Batch{tick,items} <> acc)
def snapshot_queue(~V: Data,queue: Q.Queue<M.Transition<V>>,positions: List<&2,Ev.Position>,frameStart: Nat) -> List<&2,Ev.Batch<M.Transition<V>>> & (List<&2,Ev.Position> & (Nat & Nat)):
  match queue:
    case Q.Queue{front,back,_,dropped,_}: (batches_loop(~V,Ev.append(~Q.Batch<M.Transition<V>>,front,List.reverse(&2,Q.Batch<M.Transition<V>>,back)),[]),(positions,(dropped,frameStart)))
def snapshot(~V: Data,stream: Stream<V>) -> List<&2,Ev.Batch<M.Transition<V>>> & (List<&2,Ev.Position> & (Nat & Nat)):
  match stream:
    case Stream{queue,positions,frameStart}: snapshot_queue(~V,queue,positions,frameStart)

# Engine entry points consume and return the real affine reader capability.
# A foreign-world refusal preserves both owners and never activates a cursor.
type OpenResult<S: Data,M: Data,V: Data> is Type:
  Opened{reader: Reader<S,M>,stream: Stream<V>,reading: Ev.Reading<M.Transition<V>>}
  ReaderRefused{reader: Reader<S,M>,stream: Stream<V>}

def open_checked(~S: Data,~M: Data,~V: Data,allowed: Bool,reader: Reader<S,M>,+stream: Stream<V>,+tick: Nat) -> OpenResult<S,M,V>:
  match allowed reader:
    case False{}, reader: ReaderRefused{reader,stream}
    case True{}, Reader{namespace,+id}:
      Opened{Reader{namespace,id},activate(~V,stream,id,tick),observe(~V,stream,id,tick)}

def open(~S: Data,~M: Data,~V: Data,reader: Reader<S,M>,stream: Stream<V>,namespace: U32,tick: Nat) -> OpenResult<S,M,V>:
  match reader:
    case Reader{+owner,id}: open_checked(~S,~M,~V,U32.is_eq(owner,namespace),Reader{owner,id},stream,tick)

def finish(~S: Data,~M: Data,~V: Data,reader: Reader<S,M>,stream: Stream<V>,tick: Nat,success: Bool) -> Reader<S,M> & Stream<V>:
  match reader:
    case Reader{namespace,+id}: (Reader{namespace,id},complete(~V,stream,id,tick,success))

def skip_owned(~S: Data,~M: Data,~V: Data,reader: Reader<S,M>,stream: Stream<V>,tick: Nat) -> Reader<S,M> & Stream<V>:
  match reader:
    case Reader{namespace,+id}: (Reader{namespace,id},skip(~V,stream,id,tick))
