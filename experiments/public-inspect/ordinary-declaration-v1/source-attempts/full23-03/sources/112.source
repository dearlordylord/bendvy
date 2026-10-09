import Base
import internal/relation-failures/domains.bend as D
import internal/relation-failures/readings.bend as Read
import internal/relation-failures/routing.bend as Route
import internal/relation-failures/barrier.bend as B
import world.bend as W
import system.bend as Sy
import event-runtime.bend as Ev

type Runtime<S: Data,C: Type,R: Type,E: Data> is Type:
  Runtime{world: W.World<S,C,R,E>,domains: List<&2,D.Domain<S,E>>,positions: List<&2,Ev.Position>,tick: Nat,frameStart: Nat,boundary: Nat,capacity: Nat}
type Input<S: Data,E: Data,A: Type> is Type:
  Input{readings: List<&2,Read.KeyReading<S,E>>,args: A}
type Reader<S: Data,C: Type,R: Type,E: Data,A: Type,Error: Data,O: Type,-runner: W.World<S,C,R,E> -> Input<S,E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>> is Type:
  Reader{registry: Sy.Registry<S,C,R,E,Input<S,E,A>,Error,O,runner>,keys: List<&2,D.DescriptorKey<S>>}
type Registered<S: Data,C: Type,R: Type,E: Data,A: Type,Error: Data,O: Type,-runner: W.World<S,C,R,E> -> Input<S,E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>> is Type:
  Registered{runtime: Runtime<S,C,R,E>,reader: Reader<S,C,R,E,A,Error,O,runner>}
  RegistrationFailed{runtime: Runtime<S,C,R,E>}
type Completion<Error: Data,O: Type,A: Type> is Type:
  Succeeded{output: O}
  Failed{error: Error}
  Rejected{args: A}
type RunResult<S: Data,C: Type,R: Type,E: Data,A: Type,Error: Data,O: Type,-runner: W.World<S,C,R,E> -> Input<S,E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>> is Type:
  Ran{runtime: Runtime<S,C,R,E>,reader: Reader<S,C,R,E,A,Error,O,runner>,completion: Completion<Error,O,A>}

def started_clocked(~S: Data,~C: Type,~R: Type,~E: Data,clocked: W.World<S,C,R,E> & U32) -> Runtime<S,C,R,E>:
  (world,clock) = clocked
  Runtime{world,[],[],U32.to_nat(clock),0n,0n,65536n}
def start(~S: Data,~C: Type,~R: Type,~E: Data,world: W.World<S,C,R,E>) -> Runtime<S,C,R,E>:
  started_clocked(~S,~C,~R,~E,W.clock(~S,~C,~R,~E,world))

def frame(~S: Data,~C: Type,~R: Type,~E: Data,runtime: Runtime<S,C,R,E>) -> Runtime<S,C,R,E>:
  match runtime:
    case Runtime{world,domains,+positions,+tick,+frameStart,_,+capacity}: Runtime{world,D.trim(~S,~E,domains,positions,frameStart,capacity),positions,tick,tick,frameStart,capacity}

def registered_result(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~Error: Data,~O: Type,~runner: W.World<S,C,R,E> -> Input<S,E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>,result: Sy.RegistrationResult<S,C,R,E,Input<S,E,A>,Error,O,runner>,+keys: List<&2,D.DescriptorKey<S>>,domains: List<&2,D.Domain<S,E>>,positions: List<&2,Ev.Position>,tick: Nat,frameStart: Nat,boundary: Nat,capacity: Nat) -> Registered<S,C,R,E,A,Error,O,runner>:
  match result:
    case Sy.RegistrationFailed{world}: RegistrationFailed{Runtime{world,domains,positions,tick,frameStart,boundary,capacity}}
    case Sy.Registered{world,registry}: Registered{Runtime{world,domains,positions,tick,frameStart,boundary,capacity},Reader{registry,keys}}

def register(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~Error: Data,~O: Type,~runner: W.World<S,C,R,E> -> Input<S,E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>,runtime: Runtime<S,C,R,E>,+keys: List<&2,D.DescriptorKey<S>>,+name: String,+access: List<&2,String>) -> Registered<S,C,R,E,A,Error,O,runner>:
  match runtime:
    case Runtime{world,domains,positions,tick,frameStart,boundary,capacity}: registered_result(~S,~C,~R,~E,~A,~Error,~O,~runner,Sy.register(~S,~C,~R,~E,~Input<S,E,A>,~Error,~O,~runner,world,name,access),keys,domains,positions,tick,frameStart,boundary,capacity)

def position_or(position: Maybe<Ev.Position>,id: U32,tick: Nat) -> Ev.Position:
  match position:
    case None{}: Ev.Position{id,0n,tick}
    case Some{found}: found

def succeeded_collected(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~Error: Data,~O: Type,~runner: W.World<S,C,R,E> -> Input<S,E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>,joined: W.World<S,C,R,E> & List<&2,D.Domain<S,E>>,registry: Sy.Registry<S,C,R,E,Input<S,E,A>,Error,O,runner>,+keys: List<&2,D.DescriptorKey<S>>,positions: List<&2,Ev.Position>,tick: Nat,frameStart: Nat,boundary: Nat,capacity: Nat,output: O) -> RunResult<S,C,R,E,A,Error,O,runner>:
  (world,domains) = joined
  Ran{Runtime{world,domains,positions,tick,frameStart,boundary,capacity},Reader{registry,keys},Succeeded{output}}

def failed_clocked(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~Error: Data,~O: Type,~runner: W.World<S,C,R,E> -> Input<S,E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>,~classify: E -> Maybe<D.DescriptorKey<S>>,clocked: W.World<S,C,R,E> & U32,registry: Sy.Registry<S,C,R,E,Input<S,E,A>,Error,O,runner>,+keys: List<&2,D.DescriptorKey<S>>,+domains: List<&2,D.Domain<S,E>>,+positions: List<&2,Ev.Position>,+id: U32,+previous: Nat,frameStart: Nat,boundary: Nat,capacity: Nat,error: Error) -> RunResult<S,C,R,E,A,Error,O,runner>:
  (world,clock) = clocked
  Ran{Runtime{world,Read.activate(~S,~E,keys,domains,id),Ev.activate(positions,id,previous),U32.to_nat(clock),frameStart,boundary,capacity},Reader{registry,keys},Failed{error}}
def succeeded_clocked(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~Error: Data,~O: Type,~runner: W.World<S,C,R,E> -> Input<S,E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>,~classify: E -> Maybe<D.DescriptorKey<S>>,clocked: W.World<S,C,R,E> & U32,registry: Sy.Registry<S,C,R,E,Input<S,E,A>,Error,O,runner>,+keys: List<&2,D.DescriptorKey<S>>,+domains: List<&2,D.Domain<S,E>>,+positions: List<&2,Ev.Position>,+id: U32,+previous: Nat,frameStart: Nat,boundary: Nat,capacity: Nat,output: O) -> RunResult<S,C,R,E,A,Error,O,runner>:
  (world,+clock) = clocked
  succeeded_collected(~S,~C,~R,~E,~A,~Error,~O,~runner,Route.collect(~S,~C,~R,~E,~classify,world,U32.to_nat(clock),Read.activate(~S,~E,keys,domains,id)),registry,keys,Ev.update(Ev.activate(positions,id,previous),id,U32.to_nat(clock),False{}),U32.to_nat(clock),frameStart,boundary,capacity,output)

def outcome(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~Error: Data,~O: Type,~runner: W.World<S,C,R,E> -> Input<S,E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>,~classify: E -> Maybe<D.DescriptorKey<S>>,outcome: Sy.Outcome<W.World<S,C,R,E>,Error,O>,registry: Sy.Registry<S,C,R,E,Input<S,E,A>,Error,O,runner>,+keys: List<&2,D.DescriptorKey<S>>,+domains: List<&2,D.Domain<S,E>>,+positions: List<&2,Ev.Position>,+id: U32,+tick: Nat,+frameStart: Nat,+boundary: Nat,+capacity: Nat) -> RunResult<S,C,R,E,A,Error,O,runner>:
  match outcome:
    case Sy.Failed{world,error}: failed_clocked(~S,~C,~R,~E,~A,~Error,~O,~runner,~classify,W.clock(~S,~C,~R,~E,world),registry,keys,domains,positions,id,tick,frameStart,boundary,capacity,error)
    case Sy.Succeeded{world,output}: succeeded_clocked(~S,~C,~R,~E,~A,~Error,~O,~runner,~classify,W.clock(~S,~C,~R,~E,world),registry,keys,domains,positions,id,tick,frameStart,boundary,capacity,output)

def run_result(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~Error: Data,~O: Type,~runner: W.World<S,C,R,E> -> Input<S,E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>,~classify: E -> Maybe<D.DescriptorKey<S>>,result: Sy.RunResult<S,C,R,E,Input<S,E,A>,Error,O,runner>,+keys: List<&2,D.DescriptorKey<S>>,domains: List<&2,D.Domain<S,E>>,positions: List<&2,Ev.Position>,id: U32,tick: Nat,frameStart: Nat,boundary: Nat,capacity: Nat) -> RunResult<S,C,R,E,A,Error,O,runner>:
  match result:
    case Sy.RegistrationRejected{registry,world,Input{_,args}}: Ran{Runtime{world,domains,positions,tick,frameStart,boundary,capacity},Reader{registry,keys},Rejected{args}}
    case Sy.Completed{registry,completed}: outcome(~S,~C,~R,~E,~A,~Error,~O,~runner,~classify,completed,registry,keys,domains,positions,id,tick,frameStart,boundary,capacity)

def run_clocked(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~Error: Data,~O: Type,~runner: W.World<S,C,R,E> -> Input<S,E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>,registry: Sy.Registry<S,C,R,E,Input<S,E,A>,Error,O,runner>,advanced: W.World<S,C,R,E> & U32,input: Input<S,E,A>) -> Sy.RunResult<S,C,R,E,Input<S,E,A>,Error,O,runner>:
  (world,_) = advanced
  Sy.run_tracked(~S,~C,~R,~E,~Input<S,E,A>,~Error,~O,~runner,registry,world,input)

def effect_clocked(~S: Data,~C: Type,~R: Type,~E: Data,~O: Type,effect: W.World<S,C,R,E> -> W.World<S,C,R,E> & O,advanced: W.World<S,C,R,E> & U32) -> W.World<S,C,R,E> & O:
  (world,_) = advanced
  effect(world)


def run_identified(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~Error: Data,~O: Type,~runner: W.World<S,C,R,E> -> Input<S,E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>,~classify: E -> Maybe<D.DescriptorKey<S>>,runtime: Runtime<S,C,R,E>,identified: Sy.Registry<S,C,R,E,Input<S,E,A>,Error,O,runner> & U32,+keys: List<&2,D.DescriptorKey<S>>,args: A) -> RunResult<S,C,R,E,A,Error,O,runner>:
  match runtime:
    case Runtime{world,+domains,+positions,+tick,+frameStart,+boundary,+capacity}:
      (registry,+id) = identified
      run_result(~S,~C,~R,~E,~A,~Error,~O,~runner,~classify,run_clocked(~S,~C,~R,~E,~A,~Error,~O,~runner,registry,W.advance_clock(~S,~C,~R,~E,world),Input{Read.all(~S,~E,keys,domains,position_or(Ev.lookup(positions,id),id,tick)),args}),keys,domains,positions,id,tick,frameStart,boundary,capacity)

def run(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~Error: Data,~O: Type,~runner: W.World<S,C,R,E> -> Input<S,E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>,~classify: E -> Maybe<D.DescriptorKey<S>>,runtime: Runtime<S,C,R,E>,reader: Reader<S,C,R,E,A,Error,O,runner>,args: A) -> RunResult<S,C,R,E,A,Error,O,runner>:
  match reader:
    case Reader{registry,keys}: run_identified(~S,~C,~R,~E,~A,~Error,~O,~runner,~classify,runtime,Sy.identity(~S,~C,~R,~E,~Input<S,E,A>,~Error,~O,~runner,registry),keys,args)
def skipped_checked(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~Error: Data,~O: Type,~runner: W.World<S,C,R,E> -> Input<S,E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>,allowed: Bool,runtime: Runtime<S,C,R,E>,reader: Reader<S,C,R,E,A,Error,O,runner>,+id: U32) -> Runtime<S,C,R,E> & Reader<S,C,R,E,A,Error,O,runner>:
  match allowed runtime:
    case False{} runtime: (runtime,reader)
    case True{} Runtime{world,domains,positions,+tick,frameStart,boundary,capacity}: (Runtime{world,domains,Ev.update(positions,id,tick,False{}),tick,frameStart,boundary,capacity},reader)

def skip_meta(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~Error: Data,~O: Type,~runner: W.World<S,C,R,E> -> Input<S,E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>,checked: W.World<S,C,R,E> & Bool,registry: Sy.Registry<S,C,R,E,Input<S,E,A>,Error,O,runner>,keys: List<&2,D.DescriptorKey<S>>,domains: List<&2,D.Domain<S,E>>,positions: List<&2,Ev.Position>,tick: Nat,frameStart: Nat,boundary: Nat,capacity: Nat,id: U32) -> Runtime<S,C,R,E> & Reader<S,C,R,E,A,Error,O,runner>:
  (world,allowed) = checked
  skipped_checked(~S,~C,~R,~E,~A,~Error,~O,~runner,allowed,Runtime{world,domains,positions,tick,frameStart,boundary,capacity},Reader{registry,keys},id)

def skip_namespace(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~Error: Data,~O: Type,~runner: W.World<S,C,R,E> -> Input<S,E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>,same: Bool,world: W.World<S,C,R,E>,registry: Sy.Registry<S,C,R,E,Input<S,E,A>,Error,O,runner>,keys: List<&2,D.DescriptorKey<S>>,domains: List<&2,D.Domain<S,E>>,positions: List<&2,Ev.Position>,tick: Nat,frameStart: Nat,boundary: Nat,capacity: Nat) -> Runtime<S,C,R,E> & Reader<S,C,R,E,A,Error,O,runner>:
  match same registry:
    case False{} registry: (Runtime{world,domains,positions,tick,frameStart,boundary,capacity},Reader{registry,keys})
    case True{} Sy.Registry{+namespace,+id,+name,+access,+cursor}: skip_meta(~S,~C,~R,~E,~A,~Error,~O,~runner,W.registration_matches(~S,~C,~R,~E,world,id,name,access),Sy.Registry{namespace,id,name,access,cursor},keys,domains,positions,tick,frameStart,boundary,capacity,id)

def skip_named(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~Error: Data,~O: Type,~runner: W.World<S,C,R,E> -> Input<S,E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>,reader: Reader<S,C,R,E,A,Error,O,runner>,named: W.World<S,C,R,E> & U32,domains: List<&2,D.Domain<S,E>>,positions: List<&2,Ev.Position>,tick: Nat,frameStart: Nat,boundary: Nat,capacity: Nat) -> Runtime<S,C,R,E> & Reader<S,C,R,E,A,Error,O,runner>:
  match reader:
    case Reader{Sy.Registry{+namespace,+id,+name,+access,+cursor},keys}:
      (world,actual) = named
      skip_namespace(~S,~C,~R,~E,~A,~Error,~O,~runner,U32.is_eq(namespace,actual),world,Sy.Registry{namespace,id,name,access,cursor},keys,domains,positions,tick,frameStart,boundary,capacity)

def skip(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~Error: Data,~O: Type,~runner: W.World<S,C,R,E> -> Input<S,E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>,runtime: Runtime<S,C,R,E>,reader: Reader<S,C,R,E,A,Error,O,runner>) -> Runtime<S,C,R,E> & Reader<S,C,R,E,A,Error,O,runner>:
  match runtime:
    case Runtime{world,domains,positions,tick,frameStart,boundary,capacity}: skip_named(~S,~C,~R,~E,~A,~Error,~O,~runner,reader,W.namespace(~S,~C,~R,~E,world),domains,positions,tick,frameStart,boundary,capacity)

def barrier_join(~S: Data,~C: Type,~R: Type,~E: Data,state: B.BarrierState<S,C,R,E>,positions: List<&2,Ev.Position>,frameStart: Nat,boundary: Nat,capacity: Nat) -> Runtime<S,C,R,E>:
  match state:
    case B.BarrierState{world,domains,tick}: Runtime{world,domains,positions,tick,frameStart,boundary,capacity}

def barrier(~S: Data,~C: Type,~R: Type,~E: Data,~classify: E -> Maybe<D.DescriptorKey<S>>,runtime: Runtime<S,C,R,E>) -> Runtime<S,C,R,E>:
  match runtime:
    case Runtime{world,domains,positions,tick,frameStart,boundary,capacity}: barrier_join(~S,~C,~R,~E,B.barrier(~S,~C,~R,~E,~classify,world,domains),positions,frameStart,boundary,capacity)

def with_world_collected(~S: Data,~C: Type,~R: Type,~E: Data,~O: Type,collected: W.World<S,C,R,E> & List<&2,D.Domain<S,E>>,output: O,positions: List<&2,Ev.Position>,tick: Nat,frameStart: Nat,boundary: Nat,capacity: Nat) -> Runtime<S,C,R,E> & O:
  (world,domains) = collected
  (Runtime{world,domains,positions,tick,frameStart,boundary,capacity},output)

def with_world_clocked(~S: Data,~C: Type,~R: Type,~E: Data,~O: Type,~classify: E -> Maybe<D.DescriptorKey<S>>,clocked: W.World<S,C,R,E> & U32,output: O,domains: List<&2,D.Domain<S,E>>,positions: List<&2,Ev.Position>,frameStart: Nat,boundary: Nat,capacity: Nat) -> Runtime<S,C,R,E> & O:
  (world,+clock) = clocked
  with_world_collected(~S,~C,~R,~E,~O,Route.collect(~S,~C,~R,~E,~classify,world,U32.to_nat(clock),domains),output,positions,U32.to_nat(clock),frameStart,boundary,capacity)
def with_world_result(~S: Data,~C: Type,~R: Type,~E: Data,~O: Type,~classify: E -> Maybe<D.DescriptorKey<S>>,result: W.World<S,C,R,E> & O,domains: List<&2,D.Domain<S,E>>,positions: List<&2,Ev.Position>,_: Nat,frameStart: Nat,boundary: Nat,capacity: Nat) -> Runtime<S,C,R,E> & O:
  (world,output) = result
  with_world_clocked(~S,~C,~R,~E,~O,~classify,W.clock(~S,~C,~R,~E,world),output,domains,positions,frameStart,boundary,capacity)

def with_world(~S: Data,~C: Type,~R: Type,~E: Data,~O: Type,~classify: E -> Maybe<D.DescriptorKey<S>>,effect: W.World<S,C,R,E> -> W.World<S,C,R,E> & O,runtime: Runtime<S,C,R,E>) -> Runtime<S,C,R,E> & O:
  match runtime:
    case Runtime{world,domains,positions,tick,frameStart,boundary,capacity}: with_world_result(~S,~C,~R,~E,~O,~classify,effect_clocked(~S,~C,~R,~E,~O,effect,W.advance_clock(~S,~C,~R,~E,world)),domains,positions,tick,frameStart,boundary,capacity)
