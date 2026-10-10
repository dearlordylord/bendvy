import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/relation-types.bend as G
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy-worktrees/graph-stream-public-bridge-v1/experiments/public-inspect/graph-stream-public-bridge-v1/state.bend as State
import /workspace/formal-proofs/bendvy-worktrees/graph-stream-public-bridge-v1/experiments/public-inspect/graph-stream-public-bridge-v1/dump.bend as Dump
import /workspace/formal-proofs/bendvy-worktrees/graph-stream-public-bridge-v1/experiments/public-inspect/graph-stream-public-bridge-v1/public-consumer.bend as Descriptors
import fixture.bend as Fixture
import stream-app.bend as App
import resources.bend as Resources
import /workspace/formal-proofs/bendvy/src/ecs/inspector-transition-projection.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/inspector-failure-projection.bend as Fail

type RuntimeView<S:Data> is Data:
  RuntimeView{world:String,namespace:U32,batches:List<&2,Ev.Batch<A.Notice<S,U32>>>,positions:List<&2,Ev.Position>,nextReader:U32,tick:Nat,frameStart:Nat,boundary:Nat,capacity:Nat,dropped:Nat}
type ReaderView is Data:
  ReaderView{namespace:U32,id:U32,registryId:U32}
type RegistryView is Data:
  RegistryView{namespace:U32,id:U32,name:String,access:List<&2,String>,cursor:U32}
type Observation<S:Data> is Data:
  Observation{cursor:U32,debug:Bool,values:Maybe<&2,App.Description<S,State.FlowToken,U32,U32>>}
type Report<S:Data> is Data:
  Report{reader:ReaderView,registry:RegistryView,setup:RuntimeView<S>,disabled:Observation<S>,operational:App.Values<S,State.FlowToken,U32,U32>,before:RuntimeView<S>,first:Observation<S>,afterFirst:RuntimeView<S>,second:Observation<S>,afterSecond:RuntimeView<S>}
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
def Application(~S:Data) -> Type:
  App.Application<S,State.FlowToken,U32,A.Store<S,State.Components<S>>,State.Resources<S>,U32,Unit,Resources.take(~S),Resources.declaration(~S),failure_declaration(~S)>
def app_view(~S:Data,app:Application(~S)) -> Application(~S) & RuntimeView<S>:
  App.with_runtime(~S,~State.FlowToken,~U32,~A.Store<S,State.Components<S>>,~State.Resources<S>,~U32,~Unit,~Resources.take(~S),~Resources.declaration(~S),~failure_declaration(~S),~RuntimeView<S>,runtime_view(~S),app)
def observed(~S:Data,returned:Application(~S) & Maybe<&2,App.Description<S,State.FlowToken,U32,U32>>) -> Application(~S) & Observation<S>:
  match returned:
    case (App.Application{runtime,owners,+cursor,+debug},values):(App.Application{runtime,owners,cursor,debug},Observation{cursor,debug,values})
def snapshot(~S:Data,app:Application(~S),flag:Bool) -> Application(~S) & Observation<S>:
  observed(~S,App.snapshot(~S,~State.FlowToken,~U32,~A.Store<S,State.Components<S>>,~State.Resources<S>,~U32,~Unit,~Resources.take(~S),~Resources.declaration(~S),~failure_declaration(~S),App.enabled(~S,~State.FlowToken,~U32,~A.Store<S,State.Components<S>>,~State.Resources<S>,~U32,~Unit,~Resources.take(~S),~Resources.declaration(~S),~failure_declaration(~S),app,flag)))
def finish_registry(~S:Data,setup:RuntimeView<S>,disabled:Observation<S>,operational:App.Values<S,State.FlowToken,U32,U32>,reader:ReaderView,before:RuntimeView<S>,first:Observation<S>,afterFirst:RuntimeView<S>,second:Observation<S>,afterSecond:RuntimeView<S>,registry:Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Ev.Input<A.Notice<S,U32>,Unit>,Bool,Unit,runner(~S)>) -> Report<S>:
  match registry:
    case Sys.Registry{namespace,id,name,access,cursor}:Report{reader,RegistryView{namespace,id,name,access,cursor},setup,disabled,operational,before,first,afterFirst,second,afterSecond}
def finish_reader(~S:Data,setup:RuntimeView<S>,disabled:Observation<S>,operational:App.Values<S,State.FlowToken,U32,U32>,registry:Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Ev.Input<A.Notice<S,U32>,Unit>,Bool,Unit,runner(~S)>,before:RuntimeView<S>,first:Observation<S>,afterFirst:RuntimeView<S>,second:Observation<S>,afterSecond:RuntimeView<S>,reader:Ev.Reader<S>) -> Report<S>:
  match reader:
    case Ev.Reader{namespace,id,registryId}:finish_registry(~S,setup,disabled,operational,ReaderView{namespace,id,registryId},before,first,afterFirst,second,afterSecond,registry)
def final(~S:Data,setup:RuntimeView<S>,disabled:Observation<S>,operational:App.Values<S,State.FlowToken,U32,U32>,reader:Ev.Reader<S>,registry:Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Ev.Input<A.Notice<S,U32>,Unit>,Bool,Unit,runner(~S)>,before:RuntimeView<S>,first:Observation<S>,afterFirst:RuntimeView<S>,second:Observation<S>,observed:Application(~S) & RuntimeView<S>) -> Report<S>:
  (runtime,afterSecond)=observed
  finish_reader(~S,setup,disabled,operational,registry,before,first,afterFirst,second,afterSecond,reader)
def second_done(~S:Data,setup:RuntimeView<S>,disabled:Observation<S>,operational:App.Values<S,State.FlowToken,U32,U32>,reader:Ev.Reader<S>,registry:Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Ev.Input<A.Notice<S,U32>,Unit>,Bool,Unit,runner(~S)>,before:RuntimeView<S>,first:Observation<S>,afterFirst:RuntimeView<S>,observed:Application(~S) & Observation<S>) -> Report<S>:
  (runtime,second)=observed
  final(~S,setup,disabled,operational,reader,registry,before,first,afterFirst,second,app_view(~S,runtime))
def middle(~S:Data,setup:RuntimeView<S>,disabled:Observation<S>,operational:App.Values<S,State.FlowToken,U32,U32>,reader:Ev.Reader<S>,registry:Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Ev.Input<A.Notice<S,U32>,Unit>,Bool,Unit,runner(~S)>,before:RuntimeView<S>,first:Observation<S>,observed:Application(~S) & RuntimeView<S>) -> Report<S>:
  (runtime,afterFirst)=observed
  second_done(~S,setup,disabled,operational,reader,registry,before,first,afterFirst,snapshot(~S,runtime,True{}))
def first_done(~S:Data,setup:RuntimeView<S>,disabled:Observation<S>,operational:App.Values<S,State.FlowToken,U32,U32>,reader:Ev.Reader<S>,registry:Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Ev.Input<A.Notice<S,U32>,Unit>,Bool,Unit,runner(~S)>,before:RuntimeView<S>,observed:Application(~S) & Observation<S>) -> Report<S>:
  (runtime,first)=observed
  middle(~S,setup,disabled,operational,reader,registry,before,first,app_view(~S,runtime))
def initial(~S:Data,setup:RuntimeView<S>,disabled:Observation<S>,operational:App.Values<S,State.FlowToken,U32,U32>,reader:Ev.Reader<S>,registry:Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Ev.Input<A.Notice<S,U32>,Unit>,Bool,Unit,runner(~S)>,observed:Application(~S) & RuntimeView<S>) -> Report<S>:
  (runtime,before)=observed
  first_done(~S,setup,disabled,operational,reader,registry,before,snapshot(~S,runtime,True{}))
def selected_done(~S:Data,setup:RuntimeView<S>,disabled:Observation<S>,reader:Ev.Reader<S>,registry:Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Ev.Input<A.Notice<S,U32>,Unit>,Bool,Unit,runner(~S)>,returned:Application(~S) & App.Values<S,State.FlowToken,U32,U32>) -> Report<S>:
  (app,operational)=returned
  initial(~S,setup,disabled,operational,reader,registry,app_view(~S,app))
def disabled_done(~S:Data,setup:RuntimeView<S>,reader:Ev.Reader<S>,registry:Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Ev.Input<A.Notice<S,U32>,Unit>,Bool,Unit,runner(~S)>,returned:Application(~S) & Observation<S>) -> Report<S>:
  (app,disabled)=returned
  selected_done(~S,setup,disabled,reader,registry,App.read_app(~S,~State.FlowToken,~U32,~A.Store<S,State.Components<S>>,~State.Resources<S>,~U32,~Unit,~Resources.take(~S),~Resources.declaration(~S),~failure_declaration(~S),app))
def setup_view(~S:Data,reader:Ev.Reader<S>,registry:Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Ev.Input<A.Notice<S,U32>,Unit>,Bool,Unit,runner(~S)>,returned:Ev.Runtime<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & RuntimeView<S>) -> Report<S>:
  (runtime,setup)=returned
  disabled_done(~S,setup,reader,registry,snapshot(~S,App.bind(~S,~State.FlowToken,~U32,~A.Store<S,State.Components<S>>,~State.Resources<S>,~U32,~Unit,~Resources.take(~S),~Resources.declaration(~S),~failure_declaration(~S),runtime,Unit{},19),False{}))
def setup_done(~S:Data,reader:Ev.Reader<S>,registry:Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Ev.Input<A.Notice<S,U32>,Unit>,Bool,Unit,runner(~S)>,observed:Ev.Runtime<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & Unit) -> Report<S>:
  (runtime,_)=observed
  setup_view(~S,reader,registry,runtime_view(~S,runtime))
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
