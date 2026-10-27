import Base
import ./world.bend as W
import ./system.bend as Sy
import ./event-runtime.bend as Ev

# Ev.Reader registration result. Success returns actual Ev.Runtime, Ev.Reader and registry;
# failure returns Ev.Runtime without dropping World. No callback executes here.
type Registered<S: Data,C: Type,R: Type,E: Data,A: Type,Error: Data,O: Type,-runner: W.World<S,C,R,E> -> Ev.Input<E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>> is Type:
  Registered{runtime: Ev.Runtime<S,C,R,E>,reader: Ev.Reader<S>,registry: Sy.Registry<S,C,R,E,Ev.Input<E,A>,Error,O,runner>}
  RegisterFailed{runtime: Ev.Runtime<S,C,R,E>}

# Every reader run returns actual Ev.Runtime, Ev.Reader and registry with Ev.Completion.
# No duplicate World or runner owner is retained in detached observations.
type RunResult<S: Data,C: Type,R: Type,E: Data,A: Type,Error: Data,O: Type,-runner: W.World<S,C,R,E> -> Ev.Input<E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>> is Type:
  Ran{runtime: Ev.Runtime<S,C,R,E>,reader: Ev.Reader<S>,registry: Sy.Registry<S,C,R,E,Ev.Input<E,A>,Error,O,runner>,completion: Ev.Completion<Error,O,A>}

def registered_identity(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~Error: Data,~O: Type,~runner: W.World<S,C,R,E> -> Ev.Input<E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>,world: W.World<S,C,R,E>,identity: Sy.Registry<S,C,R,E,Ev.Input<E,A>,Error,O,runner> & U32,+namespace: U32,+batches: List<&2,Ev.Batch<E>>,+positions: List<&2,Ev.Position>,+nextReader: U32,+tick: Nat,+frameStart: Nat,+boundary: Nat,+capacity: Nat,+dropped: Nat) -> Registered<S,C,R,E,A,Error,O,runner>:
  (registry,+registryId) = identity
  Registered{Ev.Runtime{world,namespace,batches,positions,(nextReader+1 : U32),tick,frameStart,boundary,capacity,dropped},Ev.Reader{namespace,nextReader,registryId},registry}

def registered_result(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~Error: Data,~O: Type,~runner: W.World<S,C,R,E> -> Ev.Input<E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>,result: Sy.RegistrationResult<S,C,R,E,Ev.Input<E,A>,Error,O,runner>,+namespace: U32,+batches: List<&2,Ev.Batch<E>>,+positions: List<&2,Ev.Position>,+nextReader: U32,+tick: Nat,+frameStart: Nat,+boundary: Nat,+capacity: Nat,+dropped: Nat) -> Registered<S,C,R,E,A,Error,O,runner>:
  match result:
    case Sy.RegistrationFailed{world}: RegisterFailed{Ev.Runtime{world,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped}}
    case Sy.Registered{world,registry}: registered_identity(~S,~C,~R,~E,~A,~Error,~O,~runner,world,Sy.identity(~S,~C,~R,~E,~Ev.Input<E,A>,~Error,~O,~runner,registry),namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped)

# Register a runner with supplied name/access on the actual World, allocate its
# reader token on success and return Ev.Runtime on refusal. This does not run the
# body or activate a reader position; unused registrations do not retain backlog.
# Name/access and runner coherence are trusted lower-level provisioning.
def register(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~Error: Data,~O: Type,~runner: W.World<S,C,R,E> -> Ev.Input<E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>,runtime: Ev.Runtime<S,C,R,E>,+name: String,+access: List<&2,String>) -> Registered<S,C,R,E,A,Error,O,runner>:
  match runtime:
    case Ev.Runtime{world,+namespace,+batches,+positions,+nextReader,+tick,+frameStart,+boundary,+capacity,+dropped}: registered_result(~S,~C,~R,~E,~A,~Error,~O,~runner,Sy.register(~S,~C,~R,~E,~Ev.Input<E,A>,~Error,~O,~runner,world,name,access),namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped)


def run_outcome(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~Error: Data,~O: Type,~runner: W.World<S,C,R,E> -> Ev.Input<E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>,outcome: Sy.Outcome<W.World<S,C,R,E>,Error,O>,reader: Ev.Reader<S>,registry: Sy.Registry<S,C,R,E,Ev.Input<E,A>,Error,O,runner>,+readerId: U32,+namespace: U32,+batches: List<&2,Ev.Batch<E>>,+positions: List<&2,Ev.Position>,+nextReader: U32,+tick: Nat,+frameStart: Nat,+boundary: Nat,+capacity: Nat,+dropped: Nat) -> RunResult<S,C,R,E,A,Error,O,runner>:
  match outcome:
    case Sy.Failed{world,error}: Ran{Ev.Runtime{world,namespace,batches,Ev.activate(positions,readerId,Nat.sub(tick,1n)),nextReader,tick,frameStart,boundary,capacity,dropped},reader,registry,Ev.Failed{error}}
    case Sy.Succeeded{world,output}: Ran{Ev.sync_values(~S,~C,~R,~E,W.events_view(~S,~C,~R,~E,world),namespace,batches,Ev.update(Ev.activate(positions,readerId,Nat.sub(tick,1n)),readerId,tick,False{}),nextReader,tick,frameStart,boundary,capacity,dropped),reader,registry,Ev.Succeeded{output}}

def reject_input(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~Error: Data,~O: Type,~runner: W.World<S,C,R,E> -> Ev.Input<E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>,input: Ev.Input<E,A>,runtime: Ev.Runtime<S,C,R,E>,reader: Ev.Reader<S>,registry: Sy.Registry<S,C,R,E,Ev.Input<E,A>,Error,O,runner>) -> RunResult<S,C,R,E,A,Error,O,runner>:
  match input:
    case Ev.Input{_,_,args}: Ran{runtime,reader,registry,Ev.Rejected{args}}

def run_registered_result(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~Error: Data,~O: Type,~runner: W.World<S,C,R,E> -> Ev.Input<E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>,result: Sy.RunResult<S,C,R,E,Ev.Input<E,A>,Error,O,runner>,reader: Ev.Reader<S>,+readerId: U32,+namespace: U32,+batches: List<&2,Ev.Batch<E>>,+positions: List<&2,Ev.Position>,+nextReader: U32,+tick: Nat,+frameStart: Nat,+boundary: Nat,+capacity: Nat,+dropped: Nat) -> RunResult<S,C,R,E,A,Error,O,runner>:
  match result:
    case Sy.RegistrationRejected{registry,world,args}: reject_input(~S,~C,~R,~E,~A,~Error,~O,~runner,args,Ev.Runtime{world,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped},reader,registry)
    case Sy.Completed{registry,outcome}: run_outcome(~S,~C,~R,~E,~A,~Error,~O,~runner,outcome,reader,registry,readerId,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped)

def run_reading(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~Error: Data,~O: Type,~runner: W.World<S,C,R,E> -> Ev.Input<E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>,reading: Ev.Reading<E>,world: W.World<S,C,R,E>,reader: Ev.Reader<S>,registry: Sy.Registry<S,C,R,E,Ev.Input<E,A>,Error,O,runner>,args: A,+readerId: U32,+namespace: U32,+batches: List<&2,Ev.Batch<E>>,+positions: List<&2,Ev.Position>,+nextReader: U32,+tick: Nat,+frameStart: Nat,+boundary: Nat,+capacity: Nat,+dropped: Nat) -> RunResult<S,C,R,E,A,Error,O,runner>:
  match reading:
    case Ev.Reading{items,lagged}: run_registered_result(~S,~C,~R,~E,~A,~Error,~O,~runner,Sy.run(~S,~C,~R,~E,~Ev.Input<E,A>,~Error,~O,~runner,registry,world,Ev.Input{items,lagged,args}),reader,readerId,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped)

def run_position(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~Error: Data,~O: Type,~runner: W.World<S,C,R,E> -> Ev.Input<E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>,position: Maybe<Ev.Position>,world: W.World<S,C,R,E>,reader: Ev.Reader<S>,registry: Sy.Registry<S,C,R,E,Ev.Input<E,A>,Error,O,runner>,args: A,+readerId: U32,+namespace: U32,+batches: List<&2,Ev.Batch<E>>,+positions: List<&2,Ev.Position>,+nextReader: U32,+tick: Nat,+frameStart: Nat,+boundary: Nat,+capacity: Nat,+dropped: Nat) -> RunResult<S,C,R,E,A,Error,O,runner>:
  match position:
    case None{}: run_reading(~S,~C,~R,~E,~A,~Error,~O,~runner,Ev.reading(~E,Ev.Position{readerId,0n,tick},batches,dropped),world,reader,registry,args,readerId,namespace,batches,positions,nextReader,1n+tick,frameStart,boundary,capacity,dropped)
    case Some{position}: run_reading(~S,~C,~R,~E,~A,~Error,~O,~runner,Ev.reading(~E,position,batches,dropped),world,reader,registry,args,readerId,namespace,batches,positions,nextReader,1n+tick,frameStart,boundary,capacity,dropped)

def run_checked(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~Error: Data,~O: Type,~runner: W.World<S,C,R,E> -> Ev.Input<E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>,allowed: Bool,world: W.World<S,C,R,E>,reader: Ev.Reader<S>,registry: Sy.Registry<S,C,R,E,Ev.Input<E,A>,Error,O,runner>,args: A,+readerId: U32,+namespace: U32,+batches: List<&2,Ev.Batch<E>>,+positions: List<&2,Ev.Position>,+nextReader: U32,+tick: Nat,+frameStart: Nat,+boundary: Nat,+capacity: Nat,+dropped: Nat) -> RunResult<S,C,R,E,A,Error,O,runner>:
  match allowed:
    case False{}: Ran{Ev.Runtime{world,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped},reader,registry,Ev.Rejected{args}}
    case True{}: run_position(~S,~C,~R,~E,~A,~Error,~O,~runner,Ev.lookup(positions,readerId),world,reader,registry,args,readerId,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped)

def run_identity(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~Error: Data,~O: Type,~runner: W.World<S,C,R,E> -> Ev.Input<E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>,runtime: Ev.Runtime<S,C,R,E>,reader: Ev.Reader<S>,registry: Sy.Registry<S,C,R,E,Ev.Input<E,A>,Error,O,runner>,actual: U32,args: A) -> RunResult<S,C,R,E,A,Error,O,runner>:
  match runtime reader:
    case Ev.Runtime{world,+namespace,+batches,+positions,+nextReader,+tick,+frameStart,+boundary,+capacity,+dropped} Ev.Reader{+readerNamespace,+readerId,+expected}: run_checked(~S,~C,~R,~E,~A,~Error,~O,~runner,Bool.and(U32.is_eq(namespace,readerNamespace),U32.is_eq(expected,actual)),world,Ev.Reader{readerNamespace,readerId,expected},registry,args,readerId,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped)

def run_identified(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~Error: Data,~O: Type,~runner: W.World<S,C,R,E> -> Ev.Input<E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>,runtime: Ev.Runtime<S,C,R,E>,reader: Ev.Reader<S>,identified: Sy.Registry<S,C,R,E,Ev.Input<E,A>,Error,O,runner> & U32,args: A) -> RunResult<S,C,R,E,A,Error,O,runner>:
  (registry,actual) = identified
  run_identity(~S,~C,~R,~E,~A,~Error,~O,~runner,runtime,reader,registry,actual,args)

# Validate token namespace/registry identity, then invoke the actual registered
# runner with ordered unread Data, lag flag and Args. Admission rejection returns
# Args without body execution; registry checks remain authoritative in Sy.run.
# Success advances reader cursor and synchronizes returned publications. Callback
# failure preserves unread position, activating an absent reader under the failed-
# reader rule; returned World is whatever the callback returned, not automatically
# rolled back by this runtime. Actual transaction behavior belongs to the runner.
# Ev.Runtime ticks and reader cursors are distinct from system lifecycle cursors.
def run(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~Error: Data,~O: Type,~runner: W.World<S,C,R,E> -> Ev.Input<E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>,runtime: Ev.Runtime<S,C,R,E>,reader: Ev.Reader<S>,registry: Sy.Registry<S,C,R,E,Ev.Input<E,A>,Error,O,runner>,args: A) -> RunResult<S,C,R,E,A,Error,O,runner>:
  run_identified(~S,~C,~R,~E,~A,~Error,~O,~runner,runtime,reader,Sy.identity(~S,~C,~R,~E,~Ev.Input<E,A>,~Error,~O,~runner,registry),args)


# Success returns Ev.Runtime after registration/position removal. Rejection returns
# Ev.Runtime plus actual Ev.Reader and registry; no payload destructor is invented.
type Disposal<S: Data,C: Type,R: Type,E: Data,A: Type,Error: Data,O: Type,-runner: W.World<S,C,R,E> -> Ev.Input<E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>> is Type:
  Disposed{runtime: Ev.Runtime<S,C,R,E>}
  DisposalRejected{runtime: Ev.Runtime<S,C,R,E>,reader: Ev.Reader<S>,registry: Sy.Registry<S,C,R,E,Ev.Input<E,A>,Error,O,runner>}

def disposal_result(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~Error: Data,~O: Type,~runner: W.World<S,C,R,E> -> Ev.Input<E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>,result: Sy.Disposal<S,C,R,E,Ev.Input<E,A>,Error,O,runner>,reader: Ev.Reader<S>,+id: U32,+namespace: U32,+batches: List<&2,Ev.Batch<E>>,+positions: List<&2,Ev.Position>,+nextReader: U32,+tick: Nat,+frameStart: Nat,+boundary: Nat,+capacity: Nat,+dropped: Nat) -> Disposal<S,C,R,E,A,Error,O,runner>:
  match result:
    case Sy.Disposed{world}: Disposed{Ev.Runtime{world,namespace,batches,Ev.update(positions,id,tick,True{}),nextReader,tick,frameStart,boundary,capacity,dropped}}
    case Sy.DisposalRejected{world,registry}: DisposalRejected{Ev.Runtime{world,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped},reader,registry}

def disposal_checked(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~Error: Data,~O: Type,~runner: W.World<S,C,R,E> -> Ev.Input<E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>,allowed: Bool,world: W.World<S,C,R,E>,reader: Ev.Reader<S>,registry: Sy.Registry<S,C,R,E,Ev.Input<E,A>,Error,O,runner>,+id: U32,+namespace: U32,+batches: List<&2,Ev.Batch<E>>,+positions: List<&2,Ev.Position>,+nextReader: U32,+tick: Nat,+frameStart: Nat,+boundary: Nat,+capacity: Nat,+dropped: Nat) -> Disposal<S,C,R,E,A,Error,O,runner>:
  match allowed:
    case False{}: DisposalRejected{Ev.Runtime{world,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped},reader,registry}
    case True{}: disposal_result(~S,~C,~R,~E,~A,~Error,~O,~runner,Sy.dispose(~S,~C,~R,~E,~Ev.Input<E,A>,~Error,~O,~runner,registry,world),reader,id,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped)

def disposal_identity(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~Error: Data,~O: Type,~runner: W.World<S,C,R,E> -> Ev.Input<E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>,runtime: Ev.Runtime<S,C,R,E>,reader: Ev.Reader<S>,registry: Sy.Registry<S,C,R,E,Ev.Input<E,A>,Error,O,runner>,actual: U32) -> Disposal<S,C,R,E,A,Error,O,runner>:
  match runtime reader:
    case Ev.Runtime{world,+namespace,+batches,+positions,+nextReader,+tick,+frameStart,+boundary,+capacity,+dropped} Ev.Reader{+readerNamespace,+id,+expected}: disposal_checked(~S,~C,~R,~E,~A,~Error,~O,~runner,Bool.and(U32.is_eq(namespace,readerNamespace),U32.is_eq(actual,expected)),world,Ev.Reader{readerNamespace,id,expected},registry,id,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped)

def disposal_identified(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~Error: Data,~O: Type,~runner: W.World<S,C,R,E> -> Ev.Input<E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>,runtime: Ev.Runtime<S,C,R,E>,reader: Ev.Reader<S>,identified: Sy.Registry<S,C,R,E,Ev.Input<E,A>,Error,O,runner> & U32) -> Disposal<S,C,R,E,A,Error,O,runner>:
  (registry,actual) = identified
  disposal_identity(~S,~C,~R,~E,~A,~Error,~O,~runner,runtime,reader,registry,actual)

# Validate token/registry identity and dispose through Sy.dispose, removing the
# reader position only after success. Return actual owners on refusal. Does not
# immediately trim retained batches or dispose unrelated readers/log domains.
def dispose(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~Error: Data,~O: Type,~runner: W.World<S,C,R,E> -> Ev.Input<E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>,runtime: Ev.Runtime<S,C,R,E>,reader: Ev.Reader<S>,registry: Sy.Registry<S,C,R,E,Ev.Input<E,A>,Error,O,runner>) -> Disposal<S,C,R,E,A,Error,O,runner>:
  disposal_identified(~S,~C,~R,~E,~A,~Error,~O,~runner,runtime,reader,Sy.identity(~S,~C,~R,~E,~Ev.Input<E,A>,~Error,~O,~runner,registry))
