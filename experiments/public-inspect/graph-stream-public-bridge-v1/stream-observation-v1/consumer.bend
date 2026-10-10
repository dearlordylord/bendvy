import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/relation-types.bend as G
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import ../state.bend as State
import ../dump.bend as Dump
import ../public-consumer.bend as Descriptors
import fixture.bend as Fixture
import frame.bend as F
import resources.bend as Resources
import transitions.bend as T
import failures.bend as Fail

type RuntimeView<S:Data> is Data:
  RuntimeView{world:String,namespace:U32,batches:List<&2,Ev.Batch<A.Notice<S,U32>>>,positions:List<&2,Ev.Position>,nextReader:U32,tick:Nat,frameStart:Nat,boundary:Nat,capacity:Nat,dropped:Nat}
type ReaderView is Data:
  ReaderView{namespace:U32,id:U32,registryId:U32}
type RegistryView is Data:
  RegistryView{namespace:U32,id:U32,name:String,access:List<&2,String>,cursor:U32}
type Observation<S:Data> is Data:
  Observation{cursor:U32,transitions:T.TransitionLog<S,State.FlowToken,U32>,failures:Fail.FailureView<S,U32>}
type Report<S:Data> is Data:
  Report{reader:ReaderView,registry:RegistryView,before:RuntimeView<S>,first:Observation<S>,afterFirst:RuntimeView<S>,second:Observation<S>,afterSecond:RuntimeView<S>}
def runner(~S:Data,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,input:Ev.Input<A.Notice<S,U32>,Unit>) -> Sys.Outcome<W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,Bool,Unit>:
  match input:
    case Ev.Input{_,_,args}:Sys.Succeeded{world,args}
def failure_declaration(~S:Data) -> Fail.Declaration<S>:
  Fail.Declaration{Descriptors.parent(~S)}
def runtime_join(~S:Data,+namespace:U32,+batches:List<&2,Ev.Batch<A.Notice<S,U32>>>,+positions:List<&2,Ev.Position>,+nextReader:U32,+tick:Nat,+frameStart:Nat,+boundary:Nat,+capacity:Nat,+dropped:Nat,observed:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String) -> Ev.Runtime<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & RuntimeView<S>:
  (world,text)=observed
  (Ev.Runtime{world,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped},RuntimeView{text,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped})
def runtime_view(~S:Data,runtime:Ev.Runtime<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>) -> Ev.Runtime<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & RuntimeView<S>:
  match runtime:
    case Ev.Runtime{world,+namespace,+batches,+positions,+nextReader,+tick,+frameStart,+boundary,+capacity,+dropped}:runtime_join(~S,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped,Dump.world(~S,world))
type Values<S:Data> is Data:
  Values{transitions:T.TransitionLog<S,State.FlowToken,U32>,failures:Fail.FailureView<S,U32>}
def transition_field(~S:Data,~H:Type,caps:Cap.ValueRead<H,T.TransitionLog<S,State.FlowToken,U32>> & Cap.ValueRead<H,Fail.FailureView<S,U32>>) -> Cap.ValueRead<H,T.TransitionLog<S,State.FlowToken,U32>>:
  (transition,_)=caps
  transition
def failure_field(~S:Data,~H:Type,caps:Cap.ValueRead<H,T.TransitionLog<S,State.FlowToken,U32>> & Cap.ValueRead<H,Fail.FailureView<S,U32>>) -> Cap.ValueRead<H,Fail.FailureView<S,U32>>:
  (_,failure)=caps
  failure
def failure_done(~S:Data,~H:Type,transitions:T.TransitionLog<S,State.FlowToken,U32>,observed:H & Fail.FailureView<S,U32>) -> H & Values<S>:
  (owner,failures)=observed
  (owner,Values{transitions,failures})
def transition_done(~S:Data,~H:Type,~cap:Cap.ValueRead<H,Fail.FailureView<S,U32>>,observed:H & T.TransitionLog<S,State.FlowToken,U32>) -> H & Values<S>:
  (owner,transitions)=observed
  failure_done(~S,~H,transitions,Cap.value_read(~H,~Fail.FailureView<S,U32>,~cap,owner))
def body(~S:Data,~H:Type,~caps:Cap.ValueRead<H,T.TransitionLog<S,State.FlowToken,U32>> & Cap.ValueRead<H,Fail.FailureView<S,U32>>,args:Unit,owner:H) -> H & Values<S>:
  transition_done(~S,~H,~failure_field(~S,~H,caps),Cap.value_read(~H,~T.TransitionLog<S,State.FlowToken,U32>,~transition_field(~S,~H,caps),owner))
def observed(~S:Data,returned:F.Frame<S,A.Store<S,State.Components<S>>,State.Resources<S>,U32> & Values<S>) -> Ev.Runtime<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & Observation<S>:
  match returned:
    case (F.Frame{runtime,cursor},Values{transitions,failures}):(runtime,Observation{cursor,transitions,failures})
def snapshot(~S:Data,runtime:Ev.Runtime<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>) -> Ev.Runtime<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & Observation<S>:
  observed(~S,Cap.invoke(~(H => Cap.ValueRead<H,T.TransitionLog<S,State.FlowToken,U32>> & Cap.ValueRead<H,Fail.FailureView<S,U32>>),~Unit,~Values<S>,~body(~S),~F.Frame<S,A.Store<S,State.Components<S>>,State.Resources<S>,U32>,~(T.inspect(~S,~State.FlowToken,~U32,~A.Store<S,State.Components<S>>,~State.Resources<S>,~U32,~Resources.take(~S),~Resources.declaration(~S)),Fail.inspect(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~U32,~failure_declaration(~S))),Unit{},F.Frame{runtime,19}))
def finish_registry(~S:Data,reader:ReaderView,before:RuntimeView<S>,first:Observation<S>,afterFirst:RuntimeView<S>,second:Observation<S>,afterSecond:RuntimeView<S>,registry:Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Ev.Input<A.Notice<S,U32>,Unit>,Bool,Unit,runner(~S)>) -> Report<S>:
  match registry:
    case Sys.Registry{namespace,id,name,access,cursor}:Report{reader,RegistryView{namespace,id,name,access,cursor},before,first,afterFirst,second,afterSecond}
def finish_reader(~S:Data,registry:Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Ev.Input<A.Notice<S,U32>,Unit>,Bool,Unit,runner(~S)>,before:RuntimeView<S>,first:Observation<S>,afterFirst:RuntimeView<S>,second:Observation<S>,afterSecond:RuntimeView<S>,reader:Ev.Reader<S>) -> Report<S>:
  match reader:
    case Ev.Reader{namespace,id,registryId}:finish_registry(~S,ReaderView{namespace,id,registryId},before,first,afterFirst,second,afterSecond,registry)
def final(~S:Data,reader:Ev.Reader<S>,registry:Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Ev.Input<A.Notice<S,U32>,Unit>,Bool,Unit,runner(~S)>,before:RuntimeView<S>,first:Observation<S>,afterFirst:RuntimeView<S>,second:Observation<S>,observed:Ev.Runtime<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & RuntimeView<S>) -> Report<S>:
  (runtime,afterSecond)=observed
  finish_reader(~S,registry,before,first,afterFirst,second,afterSecond,reader)
def second_done(~S:Data,reader:Ev.Reader<S>,registry:Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Ev.Input<A.Notice<S,U32>,Unit>,Bool,Unit,runner(~S)>,before:RuntimeView<S>,first:Observation<S>,afterFirst:RuntimeView<S>,observed:Ev.Runtime<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & Observation<S>) -> Report<S>:
  (runtime,second)=observed
  final(~S,reader,registry,before,first,afterFirst,second,runtime_view(~S,runtime))
def middle(~S:Data,reader:Ev.Reader<S>,registry:Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Ev.Input<A.Notice<S,U32>,Unit>,Bool,Unit,runner(~S)>,before:RuntimeView<S>,first:Observation<S>,observed:Ev.Runtime<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & RuntimeView<S>) -> Report<S>:
  (runtime,afterFirst)=observed
  second_done(~S,reader,registry,before,first,afterFirst,snapshot(~S,runtime))
def first_done(~S:Data,reader:Ev.Reader<S>,registry:Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Ev.Input<A.Notice<S,U32>,Unit>,Bool,Unit,runner(~S)>,before:RuntimeView<S>,observed:Ev.Runtime<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & Observation<S>) -> Report<S>:
  (runtime,first)=observed
  middle(~S,reader,registry,before,first,runtime_view(~S,runtime))
def initial(~S:Data,reader:Ev.Reader<S>,registry:Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Ev.Input<A.Notice<S,U32>,Unit>,Bool,Unit,runner(~S)>,observed:Ev.Runtime<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & RuntimeView<S>) -> Report<S>:
  (runtime,before)=observed
  first_done(~S,reader,registry,before,snapshot(~S,runtime))
def setup_done(~S:Data,reader:Ev.Reader<S>,registry:Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Ev.Input<A.Notice<S,U32>,Unit>,Bool,Unit,runner(~S)>,observed:Ev.Runtime<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & Unit) -> Report<S>:
  (runtime,_)=observed
  initial(~S,reader,registry,runtime_view(~S,runtime))
def with_namespace(~S:Data,observed:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & U32) -> W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & Unit:
  (world,+namespace)=observed
  (A.apply_relate(~S,~State.Components<S>,~State.Resources<S>,~U32,A.apply_relate(~S,~State.Components<S>,~State.Resources<S>,~U32,A.apply_relate(~S,~State.Components<S>,~State.Resources<S>,~U32,world,Descriptors.parent(~S),W.Handle{namespace,2},W.Handle{namespace,2}),Descriptors.parent(~S),W.Handle{namespace,4},W.Handle{namespace,2}),Descriptors.link(~S),W.Handle{namespace,4},W.Handle{namespace,2}),Unit{})
def failed_commands(~S:Data,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>) -> W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & Unit:
  with_namespace(~S,W.namespace(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,world))

def completed(~S:Data,runtime:Ev.Runtime<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,reader:Ev.Reader<S>,registry:Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Ev.Input<A.Notice<S,U32>,Unit>,Bool,Unit,runner(~S)>,completion:Ev.Completion<Bool,Unit,Unit>) -> Maybe<Report<S>>:
  match completion:
    case Ev.Succeeded{_}:Some{setup_done(~S,reader,registry,Ev.with_world(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,~Unit,failed_commands(~S),runtime))}
    case _:None{}
def ran(~S:Data,result:Ev.RunResult<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Unit,Bool,Unit,runner(~S)>) -> Maybe<Report<S>>:
  match result:
    case Ev.Ran{runtime,reader,registry,completion}:completed(~S,runtime,reader,registry,completion)

def registered(~S:Data,result:Ev.Registered<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Unit,Bool,Unit,runner(~S)>) -> Maybe<Report<S>>:
  match result:
    case Ev.RegisterFailed{_}:None{}
    case Ev.Registered{runtime,reader,registry}:ran(~S,Ev.run(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,~Unit,~Bool,~Unit,~runner(~S),runtime,reader,registry,Unit{}))
def run(~S:Data,namespace:U32,base:U32) -> Maybe<Report<S>>:
  registered(~S,Ev.register(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,~Unit,~Bool,~Unit,~runner(~S),Ev.start(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,Fixture.world(~S,namespace,base),8n),"NoticeReader",["relationFailures","transitionEvents"]))
