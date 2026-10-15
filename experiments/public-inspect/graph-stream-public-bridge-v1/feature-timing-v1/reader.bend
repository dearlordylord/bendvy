import Base
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/system.bend as Sys
import ../../../../src/ecs/relation-commands.bend as A
import ../../../../src/ecs/relation-types.bend as G
import ../../../../src/ecs/machine.bend as M
import ../../../../src/ecs/machine-stream.bend as St
import ../../../../src/ecs/event-runtime.bend as Ev
import ../../../../src/ecs/inspector-failure-projection.bend as Failure
import ./state.bend as State
import ./declarations.bend as D
import ./reader-types.bend as MT

def World(~S:Data) -> Type: W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>
def Runtime(~S:Data) -> Type: Ev.Runtime<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>
type ReaderArgs is Data: ReaderArgs{id:U32}
def streams(~S:Data,+id:U32,+tick:Nat,parent:List<&2,G.Failure<S>>,parentLagged:Bool,resources:State.Resources<S>) -> State.Resources<S> & MT.Streams<S>:
  match resources:
    case State.Resources{owned,siblingOwned,+flowSlot,+levelSlot,ran,flowStream,levelStream}:
      +fs=St.activate(~U32,flowStream,id,tick)
      +ls=St.activate(~U32,levelStream,id,tick)
      (State.Resources{owned,siblingOwned,flowSlot,levelSlot,ran,St.complete(~U32,fs,id,tick,True{}),St.complete(~U32,ls,id,tick,True{})},MT.Streams{M.current_view(~S,~State.FlowToken,~U32,flowSlot),M.current_view(~S,~State.LevelToken,~U32,levelSlot),St.observe(~U32,fs,id,tick),St.observe(~U32,ls,id,tick),parent,parentLagged})
def resources_done(~S:Data,+namespace:U32,+nextId:U32,+highWater:U32,live:Array<Bool>,+capacity:U32,+depth:Nat,store:A.Store<S,State.Components<S>>,+events:List<&2,A.Notice<S,U32>>,pending:List<(World(~S) -> World(~S))>,+registrations:List<&2,W.RegistrationMeta>,+nextSystemId:U32,+clock:U32,observed:State.Resources<S> & MT.Streams<S>) -> World(~S) & MT.Streams<S>:
  (resources,output)=observed
  (W.World{namespace,nextId,highWater,live,capacity,depth,store,resources,events,pending,registrations,nextSystemId,clock},output)
def read_tick(~S:Data,id:U32,tick:Nat,parent:List<&2,G.Failure<S>>,lagged:Bool,world:World(~S)) -> World(~S) & MT.Streams<S>:
  match world:
    case W.World{+namespace,+nextId,+highWater,live,+capacity,+depth,store,resource,+events,pending,+registrations,+nextSystemId,+clock}:resources_done(~S,namespace,nextId,highWater,live,capacity,depth,store,events,pending,registrations,nextSystemId,clock,streams(~S,id,tick,parent,lagged,resource))
def read_clocked(~S:Data,id:U32,parent:List<&2,G.Failure<S>>,lagged:Bool,clocked:World(~S) & U32) -> World(~S) & MT.Streams<S>:
  (world,tick)=clocked
  read_tick(~S,id,U32.to_nat(tick),parent,lagged,world)
def outcome(~S:Data,observed:World(~S) & MT.Streams<S>) -> Sys.Outcome<World(~S),Unit,MT.Streams<S>>:
  (world,output)=observed
  Sys.Succeeded{world,output}
# Trusted descriptor-scoped input adapter. The gameplay projection receives only
# Parent failures; the original notice owner retains every unselected notice.
def runner(~S:Data,world:World(~S),input:Ev.Input<A.Notice<S,U32>,ReaderArgs>) -> Sys.Outcome<World(~S),Unit,MT.Streams<S>>:
  match input:
    case Ev.Input{values,lagged,ReaderArgs{id}}:outcome(~S,read_clocked(~S,id,Failure.failures(~S,~U32,D.parent(~S),values),lagged,W.clock(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,world)))
def Registry(~S:Data) -> Type: Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Ev.Input<A.Notice<S,U32>,ReaderArgs>,Unit,MT.Streams<S>,runner(~S)>
type RuntimeState<S:Data> is Data:
  RuntimeState{namespace:U32,batches:List<&2,Ev.Batch<A.Notice<S,U32>>>,positions:List<&2,Ev.Position>,nextReader:U32,tick:Nat,frameStart:Nat,boundary:Nat,capacity:Nat,dropped:Nat}
type Owner<S:Data> is Type: Owner{state:RuntimeState<S>,reader:Ev.Reader<S>,registry:Registry(~S),warm:MT.Streams<S>}
def ReaderRegistry(~S:Data) -> Type: Owner<S>
type ReaderRegistration<S:Data> is Type:
  StreamReaderRegistered{world:World(~S),registry:Owner<S>}
  StreamReaderRegistrationFailed{world:World(~S)}
def runtime_fields(~S:Data,runtime:Runtime(~S)) -> World(~S) & RuntimeState<S>:
  match runtime:
    case Ev.Runtime{world,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped}:(world,RuntimeState{namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped})
def state_runtime(~S:Data,world:World(~S),state:RuntimeState<S>) -> Runtime(~S):
  match state:
    case RuntimeState{namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped}:Ev.Runtime{world,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped}
def identity_world(~S:Data,world:World(~S)) -> World(~S) & Unit: (world,Unit{})
def updated(~S:Data,observed:Runtime(~S) & Unit) -> Runtime(~S):
  (runtime,_)=observed
  runtime

def RunResult(~S:Data) -> Type: Ev.RunResult<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,ReaderArgs,Unit,MT.Streams<S>,runner(~S)>
def invoke(~S:Data,+id:U32,runtime:Runtime(~S),reader:Ev.Reader<S>,registry:Registry(~S)) -> RunResult(~S):
  Ev.run(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,~ReaderArgs,~Unit,~MT.Streams<S>,~runner(~S),runtime,reader,registry,ReaderArgs{id})
def actual_reader_run(~S:Data,world:World(~S),owner:Owner<S>) -> RunResult(~S):
  match owner:
    case Owner{state,Ev.Reader{+ns,+id,+registryId},registry,_}:invoke(~S,id,updated(~S,Ev.with_world(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,~Unit,identity_world(~S),state_runtime(~S,world,state))),Ev.Reader{ns,id,registryId},registry)
def registered_fields(~S:Data,reader:Ev.Reader<S>,registry:Registry(~S),warm:MT.Streams<S>,fields:World(~S) & RuntimeState<S>) -> ReaderRegistration<S>:
  (world,state)=fields
  StreamReaderRegistered{world,Owner{state,reader,registry,warm}}
def warm_failed(~S:Data,fields:World(~S) & RuntimeState<S>) -> ReaderRegistration<S>:
  (world,_)=fields
  StreamReaderRegistrationFailed{world}
def warmed(~S:Data,result:RunResult(~S)) -> ReaderRegistration<S>:
  match result:
    case Ev.Ran{runtime,reader,registry,Ev.Succeeded{output}}:registered_fields(~S,reader,registry,output,runtime_fields(~S,runtime))
    case Ev.Ran{runtime,_,_,_}:warm_failed(~S,runtime_fields(~S,runtime))
def registered(~S:Data,result:Ev.Registered<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,ReaderArgs,Unit,MT.Streams<S>,runner(~S)>) -> ReaderRegistration<S>:
  match result:
    case Ev.Registered{runtime,Ev.Reader{+ns,+id,+registryId},registry}:warmed(~S,invoke(~S,id,runtime,Ev.Reader{ns,id,registryId},registry))
    case Ev.RegisterFailed{runtime}:warm_failed(~S,runtime_fields(~S,runtime))
def register_reader(~S:Data,world:World(~S)) -> ReaderRegistration<S>:
  registered(~S,Ev.register(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,~ReaderArgs,~Unit,~MT.Streams<S>,~runner(~S),Ev.start(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,world,65536n),"Reader",["FlowStream","LevelStream","ParentFailures"]))
def identify_reader(~S:Data,owner:Owner<S>) -> Owner<S> & U32:
  match owner:
    case Owner{state,Ev.Reader{+ns,+id,+registryId},registry,warm}:(Owner{state,Ev.Reader{ns,id,registryId},registry,warm},id)

type RuntimeOwner<S:Data> is Type: RuntimeOwner{runtime:Runtime(~S),reader:Ev.Reader<S>,registry:Registry(~S),warm:MT.Streams<S>}
def attach(~S:Data,world:World(~S),owner:ReaderRegistry(~S)) -> RuntimeOwner<S>:
  match owner:
    case Owner{state,reader,registry,warm}:RuntimeOwner{state_runtime(~S,world,state),reader,registry,warm}
def mapped(~S:Data,~O:Type,reader:Ev.Reader<S>,registry:Registry(~S),warm:MT.Streams<S>,returned:Runtime(~S) & O) -> RuntimeOwner<S> & O:
  (runtime,output)=returned
  (RuntimeOwner{runtime,reader,registry,warm},output)
def map_world(~S:Data,~O:Type,effect:World(~S) -> World(~S) & O,owner:RuntimeOwner<S>) -> RuntimeOwner<S> & O:
  match owner:
    case RuntimeOwner{runtime,reader,registry,warm}:mapped(~S,~O,reader,registry,warm,Ev.with_world(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,~O,effect,runtime))
def run_owned(~S:Data,owner:RuntimeOwner<S>) -> RunResult(~S):
  match owner:
    case RuntimeOwner{runtime,Ev.Reader{+ns,+id,+registryId},registry,_}:invoke(~S,id,runtime,Ev.Reader{ns,id,registryId},registry)
