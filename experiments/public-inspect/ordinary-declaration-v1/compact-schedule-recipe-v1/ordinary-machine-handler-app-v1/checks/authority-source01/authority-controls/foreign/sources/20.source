import Base
import machine.bend as M
import event-runtime.bend as Ev

# Transition metadata is Data; the schema/machine reader capability is affine.
# The stream is installed in the real world resource owner, never a shadow world.
type Stream<V: Data> is Data:
  Stream{batches: List<&2,Ev.Batch<M.Transition<V>>>,positions: List<&2,Ev.Position>,droppedThrough: Nat,frameStart: Nat}
type Reader<S: Data,M: Data> is Type:
  Reader{namespace: U32,id: U32}

def empty(~V: Data) -> Stream<V>:
  Stream{[],[],0n,0n}

def publish(~V: Data,stream: Stream<V>,tick: Nat,event: M.Transition<V>) -> Stream<V>:
  match stream:
    case Stream{batches,positions,dropped,frameStart}: Stream{Ev.append(~Ev.Batch<M.Transition<V>>,batches,[Ev.Batch{tick,[event]}]),positions,dropped,frameStart}

def activate(~V: Data,stream: Stream<V>,id: U32,tick: Nat) -> Stream<V>:
  match stream:
    case Stream{batches,positions,dropped,frameStart}: Stream{batches,Ev.activate(positions,id,tick),dropped,frameStart}

def complete(~V: Data,stream: Stream<V>,id: U32,tick: Nat,success: Bool) -> Stream<V>:
  match stream success:
    case Stream{batches,positions,dropped,frameStart} True{}: Stream{batches,Ev.update(positions,id,tick,False{}),dropped,frameStart}
    case stream False{}: stream

# Registered skips advance; a never-activated skipped reader remains absent.
def skip(~V: Data,stream: Stream<V>,id: U32,tick: Nat) -> Stream<V>:
  match stream:
    case Stream{batches,positions,dropped,frameStart}: Stream{batches,Ev.update(positions,id,tick,False{}),dropped,frameStart}

def observe_position(~V: Data,position: Maybe<Ev.Position>,batches: List<&2,Ev.Batch<M.Transition<V>>>,dropped: Nat,id: U32,tick: Nat) -> Ev.Reading<M.Transition<V>>:
  match position:
    case None{}: Ev.reading(~M.Transition<V>,Ev.Position{id,0n,tick},batches,dropped)
    case Some{position}: Ev.reading(~M.Transition<V>,position,batches,dropped)

def observe(~V: Data,stream: Stream<V>,+id: U32,tick: Nat) -> Ev.Reading<M.Transition<V>>:
  match stream:
    case Stream{batches,positions,dropped,frameStart}: observe_position(~V,Ev.lookup(positions,id),batches,dropped,id,tick)

def trimmed(~V: Data,frameStart: Nat,positions: List<&2,Ev.Position>,result: Ev.Trimmed<M.Transition<V>>) -> Stream<V>:
  match result:
    case Ev.Trimmed{batches,dropped}: Stream{batches,positions,dropped,frameStart}

# Machine.STREAM_CAPACITY is exactly 65,536 in the pinned reference. Every
# transition publication forms one batch, so whole-batch eviction is exact.
def frame(~V: Data,stream: Stream<V>,tick: Nat) -> Stream<V>:
  match stream:
    case Stream{batches,+positions,dropped,frameStart}:
      trimmed(~V,tick,positions,Ev.trim_capacity(~M.Transition<V>,Ev.past_window(~M.Transition<V>,batches,Ev.hold_boundary(positions,frameStart),dropped),65536n))

def dispose(~V: Data,stream: Stream<V>,id: U32) -> Stream<V>:
  match stream:
    case Stream{batches,positions,dropped,frameStart}: Stream{batches,Ev.update(positions,id,0n,True{}),dropped,frameStart}

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
