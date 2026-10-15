import Base
import schema.bend as Fixture
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/machine.bend as M
import ../../../src/ecs/machine-stream.bend as St
import ../../../src/ecs/event-runtime.bend as Ev
import ../../../src/ecs/machine-handlers.bend as H
import ../../../src/ecs/machine-handler-bundle.bend as B
import ../../../src/ecs/ordinary-machine-schedule.bend as Ordinary
import ../../../src/ecs/ordinary-machine-initialization-marker.bend as Marker
import ../../../src/ecs/ordinary-machine-condition.bend as Condition
import ../../../src/ecs/system.bend as Sys
import ../../../src/ecs/system-instance.bend as SI
import ../../../src/ecs/system-cleanup.bend as Cleanup
import ../../../src/ecs/schedule.bend as Sch
import ../../../src/ecs/ordinary-machine-initialization.bend as Init

type Case<S:Data> is Type:
  Created{world:W.World<S,Array<U32>,Fixture.Resources<S>,String>}
  Refused{}

type Watchers<S:Data> is Type:
  Watchers{fast:Condition.Instance<S,Fixture.MachineKey<S>,Fixture.MachineState,Array<U32>,Fixture.Resources<S>,String,Fixture.take_machine(~S),Fixture.put_machine(~S)>,slow:Condition.Instance<S,Fixture.MachineKey<S>,Fixture.MachineState,Array<U32>,Fixture.Resources<S>,String,Fixture.take_machine(~S),Fixture.put_machine(~S)>}

type WatchBuild<S:Data> is Type:
  WatchReady{world:W.World<S,Array<U32>,Fixture.Resources<S>,String>,watchers:Watchers<S>}
  WatchRejected{world:W.World<S,Array<U32>,Fixture.Resources<S>,String>}

type WatchView is Data:
  WatchView{namespace:U32,id:U32,name:String,access:List<&2,String>,cursor:U32,lastRevision:Nat}

type UserReader<S:Data> is Type:
  UserReader{instance:SI.Instance<S,Array<U32>,Fixture.Resources<S>,String,Fixture.TransitionReadArgs,String,Fixture.TransitionReadOutput,Fixture.transition_reader_runner(~S),St.Reader<S,Fixture.MachineKey<S>>,Fixture.transition_reader_validate(~S),Fixture.transition_reader_remove(~S)>}
type UserReaders<S:Data> is Type:
  UserReaders{fast:UserReader<S>,slow:UserReader<S>}
type UserReaderView is Data:
  UserReaderView{systemNamespace:U32,systemId:U32,systemName:String,access:List<&2,String>,cursor:U32,streamNamespace:U32,streamId:U32}
type UserOpen<S:Data> is Type:
  UserOpened{world:W.World<S,Array<U32>,Fixture.Resources<S>,String>,reader:UserReader<S>,reading:Ev.Reading<M.Transition<Fixture.MachineState>>,tick:Nat}
  UserRefused{world:W.World<S,Array<U32>,Fixture.Resources<S>,String>,reader:UserReader<S>}
type UserRun<S:Data> is Type:
  UserRan{world:W.World<S,Array<U32>,Fixture.Resources<S>,String>,reader:UserReader<S>,line:String}
type UserReaderBuild<S:Data> is Type:
  UserReadersReady{world:W.World<S,Array<U32>,Fixture.Resources<S>,String>,watchers:Watchers<S>,readers:UserReaders<S>}
  UserFastRejected{world:W.World<S,Array<U32>,Fixture.Resources<S>,String>,watchers:Watchers<S>}
  UserSlowRejected{world:W.World<S,Array<U32>,Fixture.Resources<S>,String>,watchers:Watchers<S>,fast:UserReader<S>}

def condition_instance_view(~S:Data,instance:Condition.Instance<S,Fixture.MachineKey<S>,Fixture.MachineState,Array<U32>,Fixture.Resources<S>,String,Fixture.take_machine(~S),Fixture.put_machine(~S)>) -> Condition.Instance<S,Fixture.MachineKey<S>,Fixture.MachineState,Array<U32>,Fixture.Resources<S>,String,Fixture.take_machine(~S),Fixture.put_machine(~S)> & WatchView:
  match instance:
    case Condition.Instance{registry,+lastRevision}:
      match registry:
        case Sys.Registry{+namespace,+id,+name,+access,+cursor}:
          (Condition.Instance{Sys.Registry{namespace,id,name,access,cursor},lastRevision},WatchView{namespace,id,name,access,cursor,lastRevision})

def watch_view_text(value:WatchView) -> String:
  match value:
    case WatchView{namespace,id,name,access,cursor,lastRevision}:U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,(item => item),access) ++ ":cursor=" ++ U32.show(cursor) ++ ":revision=" ++ Nat.show(lastRevision)

def watchers_view_returned(~S:Data,fast_pair:Condition.Instance<S,Fixture.MachineKey<S>,Fixture.MachineState,Array<U32>,Fixture.Resources<S>,String,Fixture.take_machine(~S),Fixture.put_machine(~S)> & WatchView,slow_pair:Condition.Instance<S,Fixture.MachineKey<S>,Fixture.MachineState,Array<U32>,Fixture.Resources<S>,String,Fixture.take_machine(~S),Fixture.put_machine(~S)> & WatchView) -> Watchers<S> & String:
  match fast_pair:
    case (fast,fast_view):
      match slow_pair:
        case (slow,slow_view):(Watchers{fast,slow},"fast=" ++ watch_view_text(fast_view) ++ ";slow=" ++ watch_view_text(slow_view))

def watchers_view(~S:Data,watchers:Watchers<S>) -> Watchers<S> & String:
  match watchers:
    case Watchers{fast,slow}:watchers_view_returned(~S,condition_instance_view(~S,fast),condition_instance_view(~S,slow))

def empty_store(_:Unit) -> Array<U32>:
  Array.new(U32,0n,0)

def created(~S:Data,result:W.Creation<S,Array<U32>,Fixture.Resources<S>,String>) -> Case<S>:
  match result:
    case W.Created{factory,world}:Created{world}
    case W.CreateRejected{factory,resource}:Refused{}

def create(~S:Data) -> Case<S>:
  created(~S,W.create(~S,~Array<U32>,~Fixture.Resources<S>,~String,~empty_store,W.factory(),Fixture.resources(~S)))

def slow_defined(~S:Data,fast:Condition.Instance<S,Fixture.MachineKey<S>,Fixture.MachineState,Array<U32>,Fixture.Resources<S>,String,Fixture.take_machine(~S),Fixture.put_machine(~S)>,result:Condition.Definition<S,Fixture.MachineKey<S>,Fixture.MachineState,Array<U32>,Fixture.Resources<S>,String,Fixture.take_machine(~S),Fixture.put_machine(~S)>) -> WatchBuild<S>:
  match result:
    case Condition.Defined{world,instance}:WatchReady{world,Watchers{fast,instance}}
    case Condition.DefinitionRejected{world}:WatchRejected{world}

def define_slow(~S:Data,world:W.World<S,Array<U32>,Fixture.Resources<S>,String>,fast:Condition.Instance<S,Fixture.MachineKey<S>,Fixture.MachineState,Array<U32>,Fixture.Resources<S>,String,Fixture.take_machine(~S),Fixture.put_machine(~S)>) -> WatchBuild<S>:
  slow_defined(~S,fast,Condition.define(~S,~Fixture.MachineKey<S>,~Fixture.MachineState,~Fixture.Resources<S>,~Fixture.take_machine(~S),~Fixture.put_machine(~S),~Array<U32>,~String,~Fixture.declaration(~S),world,"machine.changed.slow"))

def fast_defined(~S:Data,result:Condition.Definition<S,Fixture.MachineKey<S>,Fixture.MachineState,Array<U32>,Fixture.Resources<S>,String,Fixture.take_machine(~S),Fixture.put_machine(~S)>) -> WatchBuild<S>:
  match result:
    case Condition.Defined{world,instance}:define_slow(~S,world,instance)
    case Condition.DefinitionRejected{world}:WatchRejected{world}

def define_watchers(~S:Data,world:W.World<S,Array<U32>,Fixture.Resources<S>,String>) -> WatchBuild<S>:
  fast_defined(~S,Condition.define(~S,~Fixture.MachineKey<S>,~Fixture.MachineState,~Fixture.Resources<S>,~Fixture.take_machine(~S),~Fixture.put_machine(~S),~Array<U32>,~String,~Fixture.declaration(~S),world,"machine.changed.fast"))

def reader_create(~S:Data,name:String,world:W.World<S,Array<U32>,Fixture.Resources<S>,String>) -> SI.Registration<S,Array<U32>,Fixture.Resources<S>,String,Fixture.TransitionReadArgs,String,Fixture.TransitionReadOutput,Fixture.transition_reader_runner(~S),St.Reader<S,Fixture.MachineKey<S>>,Fixture.transition_reader_validate(~S),Fixture.transition_reader_remove(~S)>:
  SI.register(~S,~Array<U32>,~Fixture.Resources<S>,~String,~Fixture.TransitionReadArgs,~String,~Fixture.TransitionReadOutput,~Fixture.transition_reader_runner(~S),~St.Reader<S,Fixture.MachineKey<S>>,~Fixture.transition_reader_validate(~S),~Fixture.transition_reader_remove(~S),~Fixture.transition_reader_create(~S),world,name,["machine.machine.state.transition.read"])

def reader_slow_registered(~S:Data,watchers:Watchers<S>,fast:UserReader<S>,result:SI.Registration<S,Array<U32>,Fixture.Resources<S>,String,Fixture.TransitionReadArgs,String,Fixture.TransitionReadOutput,Fixture.transition_reader_runner(~S),St.Reader<S,Fixture.MachineKey<S>>,Fixture.transition_reader_validate(~S),Fixture.transition_reader_remove(~S)>) -> UserReaderBuild<S>:
  match result:
    case SI.Registered{world,instance}:UserReadersReady{world,watchers,UserReaders{fast,UserReader{instance}}}
    case SI.RegistrationFailed{world}:UserSlowRejected{world,watchers,fast}

def register_reader_slow(~S:Data,watchers:Watchers<S>,fast:UserReader<S>,world:W.World<S,Array<U32>,Fixture.Resources<S>,String>) -> UserReaderBuild<S>:
  reader_slow_registered(~S,watchers,fast,reader_create(~S,"machine.transition.slow",world))

def reader_fast_registered(~S:Data,watchers:Watchers<S>,result:SI.Registration<S,Array<U32>,Fixture.Resources<S>,String,Fixture.TransitionReadArgs,String,Fixture.TransitionReadOutput,Fixture.transition_reader_runner(~S),St.Reader<S,Fixture.MachineKey<S>>,Fixture.transition_reader_validate(~S),Fixture.transition_reader_remove(~S)>) -> UserReaderBuild<S>:
  match result:
    case SI.Registered{world,instance}:register_reader_slow(~S,watchers,UserReader{instance},world)
    case SI.RegistrationFailed{world}:UserFastRejected{world,watchers}

def register_reader_fast(~S:Data,watchers:Watchers<S>,world:W.World<S,Array<U32>,Fixture.Resources<S>,String>) -> UserReaderBuild<S>:
  reader_fast_registered(~S,watchers,reader_create(~S,"machine.transition.fast",world))

def user_reader_view(~S:Data,reader:UserReader<S>) -> UserReader<S> & UserReaderView:
  match reader:
    case UserReader{SI.Instance{Cleanup.Instance{registry,ports}}}:
      match registry:
        case Sys.Registry{+namespace,+id,+name,+access,+cursor}:
          match ports:
            case St.Reader{+readerNamespace,+readerId}:
              (UserReader{SI.Instance{Cleanup.Instance{Sys.Registry{namespace,id,name,access,cursor},St.Reader{readerNamespace,readerId}}}},UserReaderView{namespace,id,name,access,cursor,readerNamespace,readerId})

def user_reader_view_text(value:UserReaderView) -> String:
  match value:
    case UserReaderView{systemNamespace,systemId,systemName,access,cursor,streamNamespace,streamId}:"sys=" ++ U32.show(systemNamespace) ++ ":" ++ U32.show(systemId) ++ ":" ++ systemName ++ ":" ++ List.show(&2,String,(item => item),access) ++ ":cursor=" ++ U32.show(cursor) ++ ";stream=" ++ U32.show(streamNamespace) ++ ":" ++ U32.show(streamId)

def user_readers_view_pair(~S:Data,pair:UserReader<S> & UserReaderView,slow:UserReader<S>,slowView:UserReaderView) -> UserReaders<S> & String:
  match pair:
    case (fast,fastView):(UserReaders{fast,slow},"fast{" ++ user_reader_view_text(fastView) ++ "};slow{" ++ user_reader_view_text(slowView) ++ "}")

def user_readers_view_slow(~S:Data,fast:UserReader<S>,pair:UserReader<S> & UserReaderView) -> UserReaders<S> & String:
  match pair:
    case (slow,slowView):user_readers_view_pair(~S,user_reader_view(~S,fast),slow,slowView)

def user_readers_view(~S:Data,readers:UserReaders<S>) -> UserReaders<S> & String:
  match readers:
    case UserReaders{fast,slow}:user_readers_view_slow(~S,fast,user_reader_view(~S,slow))

def state_name(value:Fixture.MachineState) -> String:
  match value:
    case Fixture.A{}:"A"
    case Fixture.B{}:"B"
    case Fixture.C{}:"C"
    case Fixture.D{}:"D"

def bool_text(value:Bool) -> String:
  match value:
    case True{}:"true"
    case False{}:"false"

def reader_transition_text(value:M.Transition<Fixture.MachineState>) -> String:
  match value:
    case M.Initial{to}:"initial:" ++ state_name(to)
    case M.Transition{from,to}:state_name(from) ++ "->" ++ state_name(to)

def transition_values_text(values:List<&2,M.Transition<Fixture.MachineState>>) -> String:
  List.show(&2,M.Transition<Fixture.MachineState>,reader_transition_text,values)

def transition_reading_text(reading:Ev.Reading<M.Transition<Fixture.MachineState>>) -> String:
  match reading:
    case Ev.Reading{values,lagged}:"values=" ++ transition_values_text(values) ++ ";lagged=" ++ bool_text(lagged)

def transition_output_text(output:Fixture.TransitionReadOutput) -> String:
  match output:
    case Fixture.TransitionReadOutput{values,lagged}:"values=" ++ transition_values_text(values) ++ ";lagged=" ++ bool_text(lagged)

def user_open_result(~S:Data,registry:Sys.Registry<S,Array<U32>,Fixture.Resources<S>,String,Fixture.TransitionReadArgs,String,Fixture.TransitionReadOutput,Fixture.transition_reader_runner(~S)>,world:W.World<S,Array<U32>,Fixture.Resources<S>,String>,tick:Nat,result:St.OpenResult<S,Fixture.MachineKey<S>,Fixture.MachineState>) -> UserOpen<S>:
  match result:
    case St.Opened{reader,stream,reading}:UserOpened{Fixture.transition_stream_set_world(~S,world,stream),UserReader{SI.Instance{Cleanup.Instance{registry,reader}}},reading,tick}
    case St.ReaderRefused{reader,stream}:UserRefused{Fixture.transition_stream_set_world(~S,world,stream),UserReader{SI.Instance{Cleanup.Instance{registry,reader}}}}

def user_open_stream(~S:Data,reader:UserReader<S>,namespace:U32,+tick:Nat,pair:W.World<S,Array<U32>,Fixture.Resources<S>,String> & St.Stream<Fixture.MachineState>) -> UserOpen<S>:
  match reader:
    case UserReader{SI.Instance{Cleanup.Instance{registry,ports}}}:
      match pair:
        case (world,stream):
          user_open_result(~S,registry,world,tick,St.open(~S,~Fixture.MachineKey<S>,~Fixture.MachineState,ports,stream,namespace,tick))

def user_open_clocked(~S:Data,reader:UserReader<S>,namespace:U32,pair:W.World<S,Array<U32>,Fixture.Resources<S>,String> & U32) -> UserOpen<S>:
  match pair:
    case (world,clock):user_open_stream(~S,reader,namespace,U32.to_nat(clock),Fixture.transition_stream_world(~S,world))

def user_open_namespaced(~S:Data,reader:UserReader<S>,pair:W.World<S,Array<U32>,Fixture.Resources<S>,String> & U32) -> UserOpen<S>:
  match pair:
    case (world,namespace):user_open_clocked(~S,reader,namespace,W.clock(~S,~Array<U32>,~Fixture.Resources<S>,~String,world))

def user_open(~S:Data,reader:UserReader<S>,world:W.World<S,Array<U32>,Fixture.Resources<S>,String>) -> UserOpen<S>:
  user_open_namespaced(~S,reader,W.namespace(~S,~Array<U32>,~Fixture.Resources<S>,~String,world))

def reader_args(reading:Ev.Reading<M.Transition<Fixture.MachineState>>,fail:Bool) -> Fixture.TransitionReadArgs:
  match reading:
    case Ev.Reading{values,lagged}:Fixture.TransitionReadArgs{values,lagged,fail}

def reader_finish_result(~S:Data,registry:Sys.Registry<S,Array<U32>,Fixture.Resources<S>,String,Fixture.TransitionReadArgs,String,Fixture.TransitionReadOutput,Fixture.transition_reader_runner(~S)>,world:W.World<S,Array<U32>,Fixture.Resources<S>,String>,line:String,result:St.Reader<S,Fixture.MachineKey<S>> & St.Stream<Fixture.MachineState>) -> UserRun<S>:
  match result:
    case (reader,stream):UserRan{Fixture.transition_stream_set_world(~S,world,stream),UserReader{SI.Instance{Cleanup.Instance{registry,reader}}},line}

def reader_finished_stream(~S:Data,reader:UserReader<S>,tick:Nat,success:Bool,line:String,pair:W.World<S,Array<U32>,Fixture.Resources<S>,String> & St.Stream<Fixture.MachineState>) -> UserRun<S>:
  match reader:
    case UserReader{SI.Instance{Cleanup.Instance{registry,ports}}}:
      match pair:
        case (world,stream):
          reader_finish_result(~S,registry,world,line,St.finish(~S,~Fixture.MachineKey<S>,~Fixture.MachineState,ports,stream,tick,success))

def reader_finish(~S:Data,reader:UserReader<S>,tick:Nat,success:Bool,line:String,world:W.World<S,Array<U32>,Fixture.Resources<S>,String>) -> UserRun<S>:
  reader_finished_stream(~S,reader,tick,success,line,Fixture.transition_stream_world(~S,world))

def user_read_result(~S:Data,reading:Ev.Reading<M.Transition<Fixture.MachineState>>,tick:Nat,result:SI.RunResult<S,Array<U32>,Fixture.Resources<S>,String,Fixture.TransitionReadArgs,String,Fixture.TransitionReadOutput,Fixture.transition_reader_runner(~S),St.Reader<S,Fixture.MachineKey<S>>,Fixture.transition_reader_validate(~S),Fixture.transition_reader_remove(~S)>) -> UserRun<S>:
  match result:
    case SI.Completed{instance,outcome}:
      match outcome:
        case Sys.Succeeded{world,output}:reader_finish(~S,UserReader{instance},tick,True{},"callback=success;" ++ transition_output_text(output),world)
        case Sys.Failed{world,error}:reader_finish(~S,UserReader{instance},tick,False{},"callback=failure:" ++ error ++ ";attempt{" ++ transition_reading_text(reading) ++ "}",world)
    case SI.RegistrationRejected{instance,world,args}:reader_finish(~S,UserReader{instance},tick,False{},"callback=registration-rejected;attempt{" ++ transition_reading_text(reading) ++ "}",world)

def user_read_opened(~S:Data,opened:UserOpen<S>,fail:Bool) -> UserRun<S>:
  match opened:
    case UserOpened{world,reader,+reading,tick}:
      match reader:
        case UserReader{instance}:user_read_result(~S,reading,tick,SI.run_tracked(~S,~Array<U32>,~Fixture.Resources<S>,~String,~Fixture.TransitionReadArgs,~String,~Fixture.TransitionReadOutput,~Fixture.transition_reader_runner(~S),~St.Reader<S,Fixture.MachineKey<S>>,~Fixture.transition_reader_validate(~S),~Fixture.transition_reader_remove(~S),instance,world,reader_args(reading,fail)))
    case UserRefused{world,reader}:UserRan{world,reader,"reader-refused-before-callback"}

def user_read(~S:Data,reader:UserReader<S>,world:W.World<S,Array<U32>,Fixture.Resources<S>,String>,fail:Bool) -> UserRun<S>:
  user_read_opened(~S,user_open(~S,reader,world),fail)

def initialized(~S:Data,world:W.World<S,Array<U32>,Fixture.Resources<S>,String>) -> W.World<S,Array<U32>,Fixture.Resources<S>,String>:
  Fixture.initialize(~S,Fixture.initialize(~S,world))

def effects_observed(~S:Data,pair:W.World<S,Array<U32>,Fixture.Resources<S>,String> & Nat) -> W.World<S,Array<U32>,Fixture.Resources<S>,String> & String:
  match pair:
    case (world,count):(world,Nat.show(count))

def effects(~S:Data,world:W.World<S,Array<U32>,Fixture.Resources<S>,String>) -> W.World<S,Array<U32>,Fixture.Resources<S>,String> & String:
  effects_observed(~S,W.observe_resource(~S,~Array<U32>,~Fixture.Resources<S>,~String,~Nat,~Fixture.effect_count(~S),world))

def observed_clock(~S:Data,count:String,pair:W.World<S,Array<U32>,Fixture.Resources<S>,String> & U32) -> String:
  match pair:
    case (world,clock):"defaults=" ++ count ++ ";clock=" ++ U32.show(clock)

def observed_effects_pair(~S:Data,pair:W.World<S,Array<U32>,Fixture.Resources<S>,String> & String) -> String:
  match pair:
    case (world,count):observed_clock(~S,count,W.clock(~S,~Array<U32>,~Fixture.Resources<S>,~String,world))

def observed_effects(~S:Data,world:W.World<S,Array<U32>,Fixture.Resources<S>,String>) -> String:
  observed_effects_pair(~S,effects(~S,world))

def maybe_state_text(value:Maybe<&2,Fixture.MachineState>) -> String:
  match value:
    case None{}:"-"
    case Some{value}:state_name(value)

def pending_text(value:M.Pending<Fixture.MachineState>) -> String:
  match value:
    case M.NoPending{}:"-"
    case M.Queued{value,skipSame}:state_name(value) ++ "/skip=" ++ bool_text(skipSame)

def slot_text(~S:Data,value:M.Slot<S,Fixture.MachineKey<S>,Fixture.MachineState>) -> String:
  match value:
    case M.Missing{}:"missing"
    case M.Present{current,pending,previous,changed}:"present:" ++ state_name(current) ++ "/pending=" ++ pending_text(pending) ++ "/previous=" ++ maybe_state_text(previous) ++ "/changed=" ++ bool_text(changed)

def batch_text(value:Ev.Batch<M.Transition<Fixture.MachineState>>) -> String:
  match value:
    case Ev.Batch{tick,values}:Nat.show(tick) ++ ":" ++ List.show(&2,M.Transition<Fixture.MachineState>,reader_transition_text,values)

def position_text(value:Ev.Position) -> String:
  match value:
    case Ev.Position{id,cursor,registeredAt}:U32.show(id) ++ ":" ++ Nat.show(cursor) ++ ":" ++ Nat.show(registeredAt)

def stream_snapshot_text(~S:Data,value:Fixture.StreamSnapshot<S>) -> String:
  match value:
    case Fixture.StreamSnapshot{batches,positions,dropped,frameStart}:"batches=" ++ List.show(&2,Ev.Batch<M.Transition<Fixture.MachineState>>,batch_text,batches) ++ "/positions=" ++ List.show(&2,Ev.Position,position_text,positions) ++ "/dropped=" ++ Nat.show(dropped) ++ "/frameStart=" ++ Nat.show(frameStart)

def resource_snapshot_text(~S:Data,value:Fixture.Snapshot<S>) -> String:
  match value:
    case Fixture.Snapshot{slot,stream,revision,defaultEffects,callbackLog,failEnter}:"slot=" ++ slot_text(~S,slot) ++ ";revision=" ++ Nat.show(revision) ++ ";defaults=" ++ Nat.show(defaultEffects) ++ ";callbackLog=" ++ List.show(&2,String,(entry => entry),callbackLog) ++ ";failEnter=" ++ bool_text(failEnter) ++ ";stream=" ++ stream_snapshot_text(~S,stream)

def resource_value_text(~S:Data,pair:Fixture.Resources<S> & Fixture.Snapshot<S>) -> String:
  match pair:
    case (resource,snapshot):resource_snapshot_text(~S,snapshot)

def registration_text(value:W.RegistrationMeta) -> String:
  match value:
    case W.RegistrationMeta{id,name,access}:U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,(item => item),access)

def physical_world_parts(~S:Data,+namespace:U32,+nextId:U32,+highWater:U32,+capacity:U32,+depth:Nat,+events:List<&2,String>,pending:List<(W.World<S,Array<U32>,Fixture.Resources<S>,String> -> W.World<S,Array<U32>,Fixture.Resources<S>,String>)>,+registrations:List<&2,W.RegistrationMeta>,+nextSystemId:U32,+clock:U32,pendingCount:U32,live_pair:Array<Bool> & Array<Bool>,store_pair:Array<U32> & Array<U32>,resource_pair:Fixture.Resources<S> & Fixture.Snapshot<S>) -> W.World<S,Array<U32>,Fixture.Resources<S>,String> & String:
  match live_pair:
    case (live,live_view):
      match store_pair:
        case (store,store_view):
          match resource_pair:
            case (resource,snapshot):
              (W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock},"world{ns=" ++ U32.show(namespace) ++ ";nextId=" ++ U32.show(nextId) ++ ";highWater=" ++ U32.show(highWater) ++ ";live=" ++ List.show(&1,Bool,bool_text,Array.to_list(~Bool,live_view)) ++ ";capacity=" ++ U32.show(capacity) ++ ";depth=" ++ Nat.show(depth) ++ ";store=" ++ List.show(&1,U32,U32.show,Array.to_list(~U32,store_view)) ++ ";resource={" ++ resource_snapshot_text(~S,snapshot) ++ "};events=" ++ List.show(&2,String,(item => item),events) ++ ";pending=" ++ U32.show(pendingCount) ++ ";registrations=" ++ List.show(&2,W.RegistrationMeta,registration_text,registrations) ++ ";nextSystemId=" ++ U32.show(nextSystemId) ++ ";clock=" ++ U32.show(clock) ++ "}")

def physical_world_count(~S:Data,pair:W.World<S,Array<U32>,Fixture.Resources<S>,String> & U32) -> W.World<S,Array<U32>,Fixture.Resources<S>,String> & String:
  match pair:
    case (W.World{+namespace,+nextId,+highWater,live,+capacity,+depth,store,resource,+events,pending,+registrations,+nextSystemId,+clock},pendingCount):physical_world_parts(~S,namespace,nextId,highWater,capacity,depth,events,pending,registrations,nextSystemId,clock,pendingCount,Array.clone(Bool,live),Array.clone(U32,store),Fixture.snapshot_resource(~S,resource))

def physical_world_text_pair(~S:Data,pair:W.World<S,Array<U32>,Fixture.Resources<S>,String> & String) -> String:
  match pair:
    case (world,text):text

def physical_world_observation(~S:Data,world:W.World<S,Array<U32>,Fixture.Resources<S>,String>) -> W.World<S,Array<U32>,Fixture.Resources<S>,String> & String:
  physical_world_count(~S,W.pending_count(~S,~Array<U32>,~Fixture.Resources<S>,~String,world))

def physical_world_text(~S:Data,world:W.World<S,Array<U32>,Fixture.Resources<S>,String>) -> String:
  physical_world_text_pair(~S,physical_world_observation(~S,world))

def resource_observed(~S:Data,pair:W.World<S,Array<U32>,Fixture.Resources<S>,String> & Fixture.Snapshot<S>) -> String:
  match pair:
    case (world,snapshot):resource_snapshot_text(~S,snapshot)

def world_resource_text(~S:Data,world:W.World<S,Array<U32>,Fixture.Resources<S>,String>) -> String:
  resource_observed(~S,W.observe_resource(~S,~Array<U32>,~Fixture.Resources<S>,~String,~Fixture.Snapshot<S>,~Fixture.snapshot_resource(~S),world))

def phase_name(value:H.Phase) -> String:
  match value:
    case H.Exit{}:"exit"
    case H.Transition{}:"transition"
    case H.Enter{}:"enter"

def step_text(value:Sch.Step) -> String:
  match value:
    case Sch.System{id,condition}:"system:" ++ U32.show(id) ++ ":" ++ U32.show(condition)
    case Sch.Phase{name}:"phase:" ++ name
    case Sch.Barrier{}:"barrier"

def observation_text(value:Sch.Observation) -> String:
  match value:
    case Sch.Entered{name}:"entered:" ++ name
    case Sch.Ran{id}:"ran:" ++ U32.show(id)
    case Sch.Skipped{id}:"skipped:" ++ U32.show(id)
    case Sch.Applied{}:"applied"

def invocation_name(invocation:H.Invocation<Fixture.MachineState>) -> String:
  match invocation:
    case H.InitialEnter{ordinal,to}:"initial-enter#" ++ U32.show(ordinal) ++ ":" ++ state_name(to)
    case H.Invocation{phase,ordinal,from,to}:phase_name(phase) ++ "#" ++ U32.show(ordinal) ++ ":" ++ state_name(from) ++ "->" ++ state_name(to)

def handler_checked(~S:Data,world:W.World<S,Array<U32>,Fixture.Resources<S>,String>,invocation:H.Invocation<Fixture.MachineState>,failure:Bool) -> Sys.Outcome<W.World<S,Array<U32>,Fixture.Resources<S>,String>,String,Unit>:
  match invocation failure:
    case H.InitialEnter{_,_} True{}:Sys.Failed{world,"injected-enter-failure"}
    case _,True{}:Sys.Succeeded{W.event_publish(~S,~Array<U32>,~Fixture.Resources<S>,~String,world,[invocation_name(invocation)]),Unit{}}
    case _,False{}:Sys.Succeeded{W.event_publish(~S,~Array<U32>,~Fixture.Resources<S>,~String,world,[invocation_name(invocation)]),Unit{}}

def handler_failure_read(~S:Data,invocation:H.Invocation<Fixture.MachineState>,observed:W.World<S,Array<U32>,Fixture.Resources<S>,String> & Bool) -> Sys.Outcome<W.World<S,Array<U32>,Fixture.Resources<S>,String>,String,Unit>:
  match observed:
    case (world,failure):handler_checked(~S,world,invocation,failure)

def handler_runner(~S:Data,world:W.World<S,Array<U32>,Fixture.Resources<S>,String>,invocation:H.Invocation<Fixture.MachineState>) -> Sys.Outcome<W.World<S,Array<U32>,Fixture.Resources<S>,String>,String,Unit>:
  handler_failure_read(~S,invocation,W.observe_resource(~S,~Array<U32>,~Fixture.Resources<S>,~String,~Bool,~Fixture.failure_mode(~S),world))

def unit_same(_:Unit,_:Unit) -> Bool:True{}
def has_unit(~S:Data,world:W.World<S,Array<U32>,Fixture.Resources<S>,String>,_:Unit) -> W.World<S,Array<U32>,Fixture.Resources<S>,String> & Bool:(world,True{})
def frame_returned(~S:Data,pair:W.World<S,Array<U32>,Fixture.Resources<S>,String> & U32) -> W.World<S,Array<U32>,Fixture.Resources<S>,String>:
  match pair:
    case (world,_):world
def marker_frame(~S:Data,world:W.World<S,Array<U32>,Fixture.Resources<S>,String>) -> W.World<S,Array<U32>,Fixture.Resources<S>,String>:
  frame_returned(~S,W.advance_clock(~S,~Array<U32>,~Fixture.Resources<S>,~String,world))

type Scheduled<S:Data> is Type:
  ScheduledItem{value:B.Scheduled<S,Fixture.MachineKey<S>,Fixture.MachineState,Unit,Array<U32>,Fixture.Resources<S>,String,handler_runner(~S)>}

type Run<S:Data> is Type:
  Running{scenario:Scenario<S>}
  Stopped{line:String}
type Scenario<S:Data> is Type:
  Scenario{app:Marker.Application<S,Fixture.MachineKey<S>,Fixture.MachineState,Unit,Array<U32>,Fixture.Resources<S>,String,handler_runner(~S)>,watchers:Watchers<S>,readers:UserReaders<S>,trace:List<&2,String>}

type BundleBuild<S:Data> is Type:
  BundleReady{world:W.World<S,Array<U32>,Fixture.Resources<S>,String>,bundle:B.Bundle<S,Fixture.MachineKey<S>,Fixture.MachineState,Unit,Array<U32>,Fixture.Resources<S>,String,handler_runner(~S)>}
  BundleFailed{world:W.World<S,Array<U32>,Fixture.Resources<S>,String>}

def add_scheduled_result(~S:Data,selector:B.Selector<S,Fixture.MachineKey<S>,Fixture.MachineState>,prior:List<&1,B.Scheduled<S,Fixture.MachineKey<S>,Fixture.MachineState,Unit,Array<U32>,Fixture.Resources<S>,String,handler_runner(~S)>>,result:Sys.RegistrationResult<S,Array<U32>,Fixture.Resources<S>,String,H.Invocation<Fixture.MachineState>,String,Unit,handler_runner(~S)>) -> BundleBuild<S>:
  match result:
    case Sys.Registered{world,Sys.Registry{+namespace,+id,+name,+access,+cursor}}:
      BundleReady{world,B.Bundle{namespace,List.append(&1,B.Scheduled<S,Fixture.MachineKey<S>,Fixture.MachineState,Unit,Array<U32>,Fixture.Resources<S>,String,handler_runner(~S)>,prior,[B.Scheduled{selector,[],H.Entry{id,Sys.Registry{namespace,id,name,access,cursor}}}])}}
    case Sys.RegistrationFailed{world}:BundleFailed{world}

def register_scheduled(~S:Data,world:W.World<S,Array<U32>,Fixture.Resources<S>,String>,selector:B.Selector<S,Fixture.MachineKey<S>,Fixture.MachineState>,name:String,prior:List<&1,B.Scheduled<S,Fixture.MachineKey<S>,Fixture.MachineState,Unit,Array<U32>,Fixture.Resources<S>,String,handler_runner(~S)>>) -> BundleBuild<S>:
  add_scheduled_result(~S,selector,prior,Sys.register(~S,~Array<U32>,~Fixture.Resources<S>,~String,~H.Invocation<Fixture.MachineState>,~String,~Unit,~handler_runner(~S),world,name,["machine.state:read"]))

def bundle_namespaced(~S:Data,entries:List<&1,B.Scheduled<S,Fixture.MachineKey<S>,Fixture.MachineState,Unit,Array<U32>,Fixture.Resources<S>,String,handler_runner(~S)>>,pair:W.World<S,Array<U32>,Fixture.Resources<S>,String> & U32) -> BundleBuild<S>:
  match pair:
    case (world,namespace):BundleReady{world,B.Bundle{namespace,entries}}

def bundle_built(~S:Data,world:W.World<S,Array<U32>,Fixture.Resources<S>,String>,entries:List<&1,B.Scheduled<S,Fixture.MachineKey<S>,Fixture.MachineState,Unit,Array<U32>,Fixture.Resources<S>,String,handler_runner(~S)>>) -> BundleBuild<S>:
  bundle_namespaced(~S,entries,W.namespace(~S,~Array<U32>,~Fixture.Resources<S>,~String,world))

def scheduled_items(~S:Data,bundle:B.Bundle<S,Fixture.MachineKey<S>,Fixture.MachineState,Unit,Array<U32>,Fixture.Resources<S>,String,handler_runner(~S)>) -> List<&1,B.Scheduled<S,Fixture.MachineKey<S>,Fixture.MachineState,Unit,Array<U32>,Fixture.Resources<S>,String,handler_runner(~S)>>:
  match bundle:
    case B.Bundle{namespace,entries}:entries

def bundle_third(~S:Data,result:BundleBuild<S>) -> BundleBuild<S>:
  match result:
    case BundleReady{world,bundle}:register_scheduled(~S,world,B.EnterTo{Fixture.C{}},"on-enter-C",scheduled_items(~S,bundle))
    case BundleFailed{world}:BundleFailed{world}

def bundle_second(~S:Data,result:BundleBuild<S>) -> BundleBuild<S>:
  match result:
    case BundleReady{world,bundle}:register_scheduled(~S,world,B.EnterTo{Fixture.B{}},"on-enter-B",scheduled_items(~S,bundle))
    case BundleFailed{world}:BundleFailed{world}

def bundle_initial(~S:Data,world:W.World<S,Array<U32>,Fixture.Resources<S>,String>) -> BundleBuild<S>:
  bundle_third(~S,bundle_second(~S,register_scheduled(~S,world,B.EnterTo{Fixture.A{}},"on-enter-A",[])))

type AppBuild<S:Data> is Type:
  AppReady{app:Marker.Application<S,Fixture.MachineKey<S>,Fixture.MachineState,Unit,Array<U32>,Fixture.Resources<S>,String,handler_runner(~S)>}
  AppRejected{world:W.World<S,Array<U32>,Fixture.Resources<S>,String>,bundle:B.Bundle<S,Fixture.MachineKey<S>,Fixture.MachineState,Unit,Array<U32>,Fixture.Resources<S>,String,handler_runner(~S)>,declaration:Ordinary.Declaration<S>}
  SystemRejected{world:W.World<S,Array<U32>,Fixture.Resources<S>,String>}

def definition_ready(~S:Data,result:Marker.Definition<S,Fixture.MachineKey<S>,Fixture.MachineState,Unit,Array<U32>,Fixture.Resources<S>,String,handler_runner(~S)>) -> AppBuild<S>:
  match result:
    case Marker.Bound{app}:AppReady{app}
    case Marker.BindRejected{world,bundle,declaration}:AppRejected{world,bundle,declaration}

def bind_marker(~S:Data,world:W.World<S,Array<U32>,Fixture.Resources<S>,String>,bundle:B.Bundle<S,Fixture.MachineKey<S>,Fixture.MachineState,Unit,Array<U32>,Fixture.Resources<S>,String,handler_runner(~S)>) -> AppBuild<S>:
  definition_ready(~S,Marker.bind(~S,~Fixture.MachineKey<S>,~Fixture.MachineState,~Fixture.Resources<S>,~Fixture.take_machine(~S),~Fixture.put_machine(~S),~Array<U32>,~String,~Unit,~handler_runner(~S),~Fixture.same_state,~unit_same,~has_unit(~S),~marker_frame(~S),~Fixture.declaration(~S),Ordinary.declare(~S,"ordinary-machine-marker"),bundle,world))

def bind_bundle(~S:Data,result:BundleBuild<S>) -> AppBuild<S>:
  match result:
    case BundleReady{world,bundle}:bind_marker(~S,world,bundle)
    case BundleFailed{world}:SystemRejected{world}

def scenario_user_readers_built(~S:Data,bundle:B.Bundle<S,Fixture.MachineKey<S>,Fixture.MachineState,Unit,Array<U32>,Fixture.Resources<S>,String,handler_runner(~S)>,reader:St.Reader<S,Fixture.MachineKey<S>>,declaration:Ordinary.Declaration<S>,result:UserReaderBuild<S>) -> Run<S>:
  match result:
    case UserReadersReady{world,watchers,readers}:Running{Scenario{Marker.Application{world,bundle,reader,declaration},watchers,readers,[]}}
    case UserFastRejected{world,watchers}:Stopped{"fast-transition-reader-registration-rejected;" ++ physical_world_text(~S,world)}
    case UserSlowRejected{world,watchers,fast}:Stopped{"slow-transition-reader-registration-rejected;" ++ physical_world_text(~S,world)}

def scenario_watch_result(~S:Data,bundle:B.Bundle<S,Fixture.MachineKey<S>,Fixture.MachineState,Unit,Array<U32>,Fixture.Resources<S>,String,handler_runner(~S)>,reader:St.Reader<S,Fixture.MachineKey<S>>,declaration:Ordinary.Declaration<S>,result:WatchBuild<S>) -> Run<S>:
  match result:
    case WatchReady{world,watchers}:scenario_user_readers_built(~S,bundle,reader,declaration,register_reader_fast(~S,watchers,world))
    case WatchRejected{world}:Stopped{"condition-registration-rejected;" ++ physical_world_text(~S,world)}

def scenario_watch_app(~S:Data,bundle:B.Bundle<S,Fixture.MachineKey<S>,Fixture.MachineState,Unit,Array<U32>,Fixture.Resources<S>,String,handler_runner(~S)>,reader:St.Reader<S,Fixture.MachineKey<S>>,declaration:Ordinary.Declaration<S>,world:W.World<S,Array<U32>,Fixture.Resources<S>,String>) -> Run<S>:
  scenario_watch_result(~S,bundle,reader,declaration,define_watchers(~S,world))

def scenario_app_build(~S:Data,result:AppBuild<S>) -> Run<S>:
  match result:
    case AppReady{app}:
      match app:
        case Marker.Application{world,bundle,reader,declaration}:scenario_watch_app(~S,bundle,reader,declaration,world)
    case AppRejected{world,bundle,declaration}:Stopped{"marker-bind-rejected;" ++ physical_world_text(~S,world)}
    case SystemRejected{world}:Stopped{"handler-registration-rejected;" ++ physical_world_text(~S,world)}

def scenario_bind(~S:Data,world:W.World<S,Array<U32>,Fixture.Resources<S>,String>) -> Run<S>:
  scenario_app_build(~S,bind_bundle(~S,bundle_initial(~S,world)))

def maybe_bool_text(value:Maybe<&2,Bool>) -> String:
  match value:
    case None{}:"skipped-or-failed"
    case Some{value}:bool_text(value)

def condition_finish_readers(~S:Data,label:String,bundle:B.Bundle<S,Fixture.MachineKey<S>,Fixture.MachineState,Unit,Array<U32>,Fixture.Resources<S>,String,handler_runner(~S)>,reader:St.Reader<S,Fixture.MachineKey<S>>,declaration:Ordinary.Declaration<S>,trace:List<&2,String>,fastResult:String,slowResult:String,world:W.World<S,Array<U32>,Fixture.Resources<S>,String>,worldText:String,watchers:Watchers<S>,watchText:String,pair:UserReaders<S> & String) -> Run<S>:
  match pair:
    case (readers,readerText):Running{Scenario{Marker.Application{world,bundle,reader,declaration},watchers,readers,List.append(&2,String,trace,[label ++ ";fast=" ++ fastResult ++ ";slow=" ++ slowResult ++ ";" ++ worldText ++ ";watchers{" ++ watchText ++ "};readers{" ++ readerText ++ "}"])} }

def condition_finish_pairs(~S:Data,label:String,bundle:B.Bundle<S,Fixture.MachineKey<S>,Fixture.MachineState,Unit,Array<U32>,Fixture.Resources<S>,String,handler_runner(~S)>,reader:St.Reader<S,Fixture.MachineKey<S>>,declaration:Ordinary.Declaration<S>,trace:List<&2,String>,fastResult:String,slowResult:String,readers:UserReaders<S>,world_pair:W.World<S,Array<U32>,Fixture.Resources<S>,String> & String,watch_pair:Watchers<S> & String) -> Run<S>:
  match world_pair:
    case (world,world_text):
      match watch_pair:
        case (watchers,watch_text):condition_finish_readers(~S,label,bundle,reader,declaration,trace,fastResult,slowResult,world,world_text,watchers,watch_text,user_readers_view(~S,readers))

def condition_finish(~S:Data,label:String,bundle:B.Bundle<S,Fixture.MachineKey<S>,Fixture.MachineState,Unit,Array<U32>,Fixture.Resources<S>,String,handler_runner(~S)>,reader:St.Reader<S,Fixture.MachineKey<S>>,declaration:Ordinary.Declaration<S>,trace:List<&2,String>,fastResult:String,slowResult:String,watchers:Watchers<S>,readers:UserReaders<S>,world:W.World<S,Array<U32>,Fixture.Resources<S>,String>) -> Run<S>:
  condition_finish_pairs(~S,label,bundle,reader,declaration,trace,fastResult,slowResult,readers,physical_world_observation(~S,world),watchers_view(~S,watchers))

def conditions_after_slow(~S:Data,label:String,bundle:B.Bundle<S,Fixture.MachineKey<S>,Fixture.MachineState,Unit,Array<U32>,Fixture.Resources<S>,String,handler_runner(~S)>,reader:St.Reader<S,Fixture.MachineKey<S>>,declaration:Ordinary.Declaration<S>,trace:List<&2,String>,readers:UserReaders<S>,fastResult:String,result:Condition.Observed<S,Fixture.MachineKey<S>,Fixture.MachineState,Array<U32>,Fixture.Resources<S>,String,Fixture.take_machine(~S),Fixture.put_machine(~S)>,fast:Condition.Instance<S,Fixture.MachineKey<S>,Fixture.MachineState,Array<U32>,Fixture.Resources<S>,String,Fixture.take_machine(~S),Fixture.put_machine(~S)>) -> Run<S>:
  match result:
    case Condition.Observed{world,instance,value}:
      condition_finish(~S,label,bundle,reader,declaration,trace,fastResult,maybe_bool_text(value),Watchers{fast,instance},readers,world)
    case Condition.RegistrationRejected{world,instance}:
      condition_finish(~S,label,bundle,reader,declaration,trace,fastResult,"registration-rejected",Watchers{fast,instance},readers,world)

def conditions_after_fast(~S:Data,label:String,bundle:B.Bundle<S,Fixture.MachineKey<S>,Fixture.MachineState,Unit,Array<U32>,Fixture.Resources<S>,String,handler_runner(~S)>,reader:St.Reader<S,Fixture.MachineKey<S>>,declaration:Ordinary.Declaration<S>,trace:List<&2,String>,readers:UserReaders<S>,slow:Condition.Instance<S,Fixture.MachineKey<S>,Fixture.MachineState,Array<U32>,Fixture.Resources<S>,String,Fixture.take_machine(~S),Fixture.put_machine(~S)>,result:Condition.Observed<S,Fixture.MachineKey<S>,Fixture.MachineState,Array<U32>,Fixture.Resources<S>,String,Fixture.take_machine(~S),Fixture.put_machine(~S)>) -> Run<S>:
  match result:
    case Condition.Observed{world,instance,value}:
      conditions_after_slow(~S,label,bundle,reader,declaration,trace,readers,maybe_bool_text(value),Condition.run(~S,~Fixture.MachineKey<S>,~Fixture.MachineState,~Fixture.Resources<S>,~Fixture.take_machine(~S),~Fixture.put_machine(~S),~Array<U32>,~String,slow,world),instance)
    case Condition.RegistrationRejected{world,instance}:
      conditions_after_slow(~S,label,bundle,reader,declaration,trace,readers,"registration-rejected",Condition.run(~S,~Fixture.MachineKey<S>,~Fixture.MachineState,~Fixture.Resources<S>,~Fixture.take_machine(~S),~Fixture.put_machine(~S),~Array<U32>,~String,slow,world),instance)

def scenario_conditions(~S:Data,label:String,scenario:Scenario<S>) -> Run<S>:
  match scenario:
    case Scenario{app,watchers,readers,trace}:
      match app:
        case Marker.Application{world,bundle,reader,declaration}:
          match watchers:
            case Watchers{fast,slow}:conditions_after_fast(~S,label,bundle,reader,declaration,trace,readers,slow,Condition.run(~S,~Fixture.MachineKey<S>,~Fixture.MachineState,~Fixture.Resources<S>,~Fixture.take_machine(~S),~Fixture.put_machine(~S),~Array<U32>,~String,fast,world))

def skipped_fast_finish(~S:Data,label:String,bundle:B.Bundle<S,Fixture.MachineKey<S>,Fixture.MachineState,Unit,Array<U32>,Fixture.Resources<S>,String,handler_runner(~S)>,reader:St.Reader<S,Fixture.MachineKey<S>>,declaration:Ordinary.Declaration<S>,trace:List<&2,String>,readers:UserReaders<S>,slow:Condition.Instance<S,Fixture.MachineKey<S>,Fixture.MachineState,Array<U32>,Fixture.Resources<S>,String,Fixture.take_machine(~S),Fixture.put_machine(~S)>,result:Condition.Observed<S,Fixture.MachineKey<S>,Fixture.MachineState,Array<U32>,Fixture.Resources<S>,String,Fixture.take_machine(~S),Fixture.put_machine(~S)>) -> Run<S>:
  match result:
    case Condition.Observed{world,instance,value}:condition_finish(~S,label,bundle,reader,declaration,trace,"run_if(false);active-transition-fast=not-invoked",maybe_bool_text(value),Watchers{instance,slow},readers,world)
    case Condition.RegistrationRejected{world,instance}:condition_finish(~S,label,bundle,reader,declaration,trace,"run_if-rejected","not-run",Watchers{instance,slow},readers,world)

def scenario_skip_fast(~S:Data,label:String,scenario:Scenario<S>) -> Run<S>:
  match scenario:
    case Scenario{app,watchers,readers,trace}:
      match app:
        case Marker.Application{world,bundle,reader,declaration}:
          match watchers:
            case Watchers{fast,slow}:skipped_fast_finish(~S,label,bundle,reader,declaration,trace,readers,slow,Condition.run_if(~S,~Fixture.MachineKey<S>,~Fixture.MachineState,~Fixture.Resources<S>,~Fixture.take_machine(~S),~Fixture.put_machine(~S),~Array<U32>,~String,False{},fast,world))

def queue_app(~S:Data,app:Marker.Application<S,Fixture.MachineKey<S>,Fixture.MachineState,Unit,Array<U32>,Fixture.Resources<S>,String,handler_runner(~S)>,value:Fixture.MachineState) -> Marker.Application<S,Fixture.MachineKey<S>,Fixture.MachineState,Unit,Array<U32>,Fixture.Resources<S>,String,handler_runner(~S)>:
  match app:
    case Marker.Application{world,bundle,reader,declaration}:Marker.Application{Fixture.queue_world(~S,world,value),bundle,reader,declaration}

def insert_app_value(~S:Data,app:Marker.Application<S,Fixture.MachineKey<S>,Fixture.MachineState,Unit,Array<U32>,Fixture.Resources<S>,String,handler_runner(~S)>,value:Fixture.MachineState) -> Marker.Application<S,Fixture.MachineKey<S>,Fixture.MachineState,Unit,Array<U32>,Fixture.Resources<S>,String,handler_runner(~S)>:
  Marker.insert_app(~S,~Fixture.MachineKey<S>,~Fixture.MachineState,~Fixture.Resources<S>,~Fixture.take_machine(~S),~Fixture.put_machine(~S),~Array<U32>,~String,~Unit,~handler_runner(~S),~Fixture.same_state,~unit_same,~has_unit(~S),~marker_frame(~S),~Fixture.declaration(~S),app,value)

def failure_app(~S:Data,app:Marker.Application<S,Fixture.MachineKey<S>,Fixture.MachineState,Unit,Array<U32>,Fixture.Resources<S>,String,handler_runner(~S)>,enabled:Bool) -> Marker.Application<S,Fixture.MachineKey<S>,Fixture.MachineState,Unit,Array<U32>,Fixture.Resources<S>,String,handler_runner(~S)>:
  match app:
    case Marker.Application{world,bundle,reader,declaration}:Marker.Application{Fixture.failure_world(~S,world,enabled),bundle,reader,declaration}

def remove_app_slot(~S:Data,app:Marker.Application<S,Fixture.MachineKey<S>,Fixture.MachineState,Unit,Array<U32>,Fixture.Resources<S>,String,handler_runner(~S)>) -> Marker.Application<S,Fixture.MachineKey<S>,Fixture.MachineState,Unit,Array<U32>,Fixture.Resources<S>,String,handler_runner(~S)>:
  match app:
    case Marker.Application{world,bundle,reader,declaration}:Marker.Application{Fixture.remove_slot(~S,world),bundle,reader,declaration}

def queue_scenario(~S:Data,value:Fixture.MachineState,scenario:Scenario<S>) -> Scenario<S>:
  match scenario:
    case Scenario{app,watchers,readers,trace}:Scenario{queue_app(~S,app,value),watchers,readers,trace}

def insert_scenario(~S:Data,value:Fixture.MachineState,scenario:Scenario<S>) -> Scenario<S>:
  match scenario:
    case Scenario{app,watchers,readers,trace}:Scenario{insert_app_value(~S,app,value),watchers,readers,trace}

def failure_scenario(~S:Data,enabled:Bool,scenario:Scenario<S>) -> Scenario<S>:
  match scenario:
    case Scenario{app,watchers,readers,trace}:Scenario{failure_app(~S,app,enabled),watchers,readers,trace}

def remove_scenario_slot(~S:Data,scenario:Scenario<S>) -> Scenario<S>:
  match scenario:
    case Scenario{app,watchers,readers,trace}:Scenario{remove_app_slot(~S,app),watchers,readers,trace}

def init_app_once(~S:Data,app:Marker.Application<S,Fixture.MachineKey<S>,Fixture.MachineState,Unit,Array<U32>,Fixture.Resources<S>,String,handler_runner(~S)>) -> Marker.Application<S,Fixture.MachineKey<S>,Fixture.MachineState,Unit,Array<U32>,Fixture.Resources<S>,String,handler_runner(~S)>:
  Marker.init_app(~S,~Fixture.MachineKey<S>,~Fixture.MachineState,~Fixture.Resources<S>,~Fixture.take_machine(~S),~Fixture.put_machine(~S),~Array<U32>,~String,~Unit,~handler_runner(~S),~Fixture.same_state,~unit_same,~has_unit(~S),~marker_frame(~S),~Fixture.declaration(~S),~Fixture.make_default(~S),app)

def init_scenario_once(~S:Data,scenario:Scenario<S>) -> Scenario<S>:
  match scenario:
    case Scenario{app,watchers,readers,trace}:Scenario{init_app_once(~S,app),watchers,readers,trace}

def duplicate_init_scenario(~S:Data,scenario:Scenario<S>) -> Scenario<S>:
  match scenario:
    case Scenario{app,watchers,readers,trace}:Scenario{init_app_once(~S,app),watchers,readers,trace}

def ready_bundle(~S:Data,result:BundleBuild<S>) -> AppBuild<S>:
  match result:
    case BundleReady{world,bundle}:bind_marker(~S,world,bundle)
    case BundleFailed{world}:SystemRejected{world}

def app_status_text(status:B.Status<Unit>) -> String:
  match status:
    case B.Completed{}:"Completed"
    case B.HandlerFailed{phase,error}:"HandlerFailed:" ++ phase_name(phase) ++ ":" ++ error
    case B.ForeignBundle{}:"ForeignBundle"
    case B.MachineUnavailable{}:"MachineUnavailable"
    case B.MissingRequirements{_}:"MissingRequirements"

def events_text(~S:Data,pair:W.World<S,Array<U32>,Fixture.Resources<S>,String> & List<&2,String>) -> W.World<S,Array<U32>,Fixture.Resources<S>,String> & String:
  match pair:
    case (world,events):(world,List.show(&2,String,(value => value),events))

def clock_text(~S:Data,status:String,pair:W.World<S,Array<U32>,Fixture.Resources<S>,String> & U32) -> String:
  match pair:
    case (world,clock):status ++ ";clock=" ++ U32.show(clock)

def app_events_observed(~S:Data,status:String,pair:W.World<S,Array<U32>,Fixture.Resources<S>,String> & List<&2,String>) -> String:
  match pair:
    case (world,events):clock_text(~S,status ++ ";events=" ++ List.show(&2,String,(value => value),events),W.clock(~S,~Array<U32>,~Fixture.Resources<S>,~String,world))

def app_events_text(~S:Data,status:String,world:W.World<S,Array<U32>,Fixture.Resources<S>,String>) -> String:
  app_events_observed(~S,status,W.events_view(~S,~Array<U32>,~Fixture.Resources<S>,~String,world))

def app_run_text(~S:Data,result:Marker.AppRun<S,Fixture.MachineKey<S>,Fixture.MachineState,Unit,Array<U32>,Fixture.Resources<S>,String,handler_runner(~S)>) -> String:
  match result:
    case Marker.Applied{app,status,steps,observations}:
      match app:
        case Marker.Application{world,bundle,reader,declaration}:
          app_status_text(status) ++ ";steps=" ++ List.show(&2,Sch.Step,step_text,steps) ++ ";observations=" ++ List.show(&2,Sch.Observation,observation_text,observations) ++ ";" ++ physical_world_text(~S,world)
    case Marker.RecoveryRequired{declaration,result}:"RecoveryRequired"

type Capture<S:Data> is Type:
  Captured{app:Marker.Application<S,Fixture.MachineKey<S>,Fixture.MachineState,Unit,Array<U32>,Fixture.Resources<S>,String,handler_runner(~S)>,line:String}
  Interrupted{result:Marker.MarkerRun<S,Fixture.MachineKey<S>,Fixture.MachineState,Unit,Array<U32>,Fixture.Resources<S>,String,handler_runner(~S)>,line:String}

def capture_application_world(~S:Data,label:String,status:B.Status<Unit>,steps:List<&2,Sch.Step>,observations:List<&2,Sch.Observation>,bundle:B.Bundle<S,Fixture.MachineKey<S>,Fixture.MachineState,Unit,Array<U32>,Fixture.Resources<S>,String,handler_runner(~S)>,reader:St.Reader<S,Fixture.MachineKey<S>>,declaration:Ordinary.Declaration<S>,pair:W.World<S,Array<U32>,Fixture.Resources<S>,String> & String) -> Capture<S>:
  match pair:
    case (world,text):Captured{Marker.Application{world,bundle,reader,declaration},label ++ ":" ++ app_status_text(status) ++ ";steps=" ++ List.show(&2,Sch.Step,step_text,steps) ++ ";observations=" ++ List.show(&2,Sch.Observation,observation_text,observations) ++ ";" ++ text}

def capture_application(~S:Data,label:String,status:B.Status<Unit>,steps:List<&2,Sch.Step>,observations:List<&2,Sch.Observation>,app:Marker.Application<S,Fixture.MachineKey<S>,Fixture.MachineState,Unit,Array<U32>,Fixture.Resources<S>,String,handler_runner(~S)>) -> Capture<S>:
  match app:
    case Marker.Application{world,bundle,reader,declaration}:capture_application_world(~S,label,status,steps,observations,bundle,reader,declaration,physical_world_count(~S,W.pending_count(~S,~Array<U32>,~Fixture.Resources<S>,~String,world)))

def captured_result(~S:Data,label:String,result:Marker.AppRun<S,Fixture.MachineKey<S>,Fixture.MachineState,Unit,Array<U32>,Fixture.Resources<S>,String,handler_runner(~S)>) -> Capture<S>:
  match result:
    case Marker.Applied{app,status,steps,observations}:capture_application(~S,label,status,steps,observations,app)
    case Marker.RecoveryRequired{declaration,result}:Interrupted{result,label ++ ":RecoveryRequired"}

def capture_run(~S:Data,label:String,app:Marker.Application<S,Fixture.MachineKey<S>,Fixture.MachineState,Unit,Array<U32>,Fixture.Resources<S>,String,handler_runner(~S)>) -> Capture<S>:
  captured_result(~S,label,Marker.run_app(~S,~Fixture.MachineKey<S>,~Fixture.MachineState,~Fixture.Resources<S>,~Fixture.take_machine(~S),~Fixture.put_machine(~S),~Array<U32>,~String,~Unit,~handler_runner(~S),~Fixture.same_state,~unit_same,~has_unit(~S),~marker_frame(~S),app))

def trace_with_reader_view(~S:Data,app:Marker.Application<S,Fixture.MachineKey<S>,Fixture.MachineState,Unit,Array<U32>,Fixture.Resources<S>,String,handler_runner(~S)>,trace:List<&2,String>,line:String,watchers:Watchers<S>,watchText:String,pair:UserReaders<S> & String) -> Run<S>:
  match pair:
    case (readers,readerText):Running{Scenario{app,watchers,readers,List.append(&2,String,trace,[line ++ ";watchers{" ++ watchText ++ "};readers{" ++ readerText ++ "}"])}}

def trace_with_watchers(~S:Data,app:Marker.Application<S,Fixture.MachineKey<S>,Fixture.MachineState,Unit,Array<U32>,Fixture.Resources<S>,String,handler_runner(~S)>,readers:UserReaders<S>,trace:List<&2,String>,line:String,pair:Watchers<S> & String) -> Run<S>:
  match pair:
    case (watchers,watch_text):trace_with_reader_view(~S,app,trace,line,watchers,watch_text,user_readers_view(~S,readers))

def trace_capture(~S:Data,watchers:Watchers<S>,readers:UserReaders<S>,trace:List<&2,String>,capture:Capture<S>) -> Run<S>:
  match capture:
    case Captured{app,line}:trace_with_watchers(~S,app,readers,trace,line,watchers_view(~S,watchers))
    case Interrupted{result,line}:Stopped{line}

def scenario_snapshot(~S:Data,label:String,scenario:Scenario<S>) -> Run<S>:
  match scenario:
    case Scenario{app,watchers,readers,trace}:trace_capture(~S,watchers,readers,trace,capture_application(~S,label,B.Completed{},[],[],app))

def scenario_marker(~S:Data,label:String,scenario:Scenario<S>) -> Run<S>:
  match scenario:
    case Scenario{app,watchers,readers,trace}:trace_capture(~S,watchers,readers,trace,capture_run(~S,label,app))

def reader_fast_finished(~S:Data,label:String,bundle:B.Bundle<S,Fixture.MachineKey<S>,Fixture.MachineState,Unit,Array<U32>,Fixture.Resources<S>,String,handler_runner(~S)>,markerReader:St.Reader<S,Fixture.MachineKey<S>>,declaration:Ordinary.Declaration<S>,watchers:Watchers<S>,slow:UserReader<S>,trace:List<&2,String>,result:UserRun<S>) -> Run<S>:
  match result:
    case UserRan{world,reader,line}:scenario_snapshot(~S,label,Scenario{Marker.Application{world,bundle,markerReader,declaration},watchers,UserReaders{reader,slow},List.append(&2,String,trace,[line])})

def reader_slow_finished(~S:Data,label:String,bundle:B.Bundle<S,Fixture.MachineKey<S>,Fixture.MachineState,Unit,Array<U32>,Fixture.Resources<S>,String,handler_runner(~S)>,markerReader:St.Reader<S,Fixture.MachineKey<S>>,declaration:Ordinary.Declaration<S>,watchers:Watchers<S>,fast:UserReader<S>,trace:List<&2,String>,result:UserRun<S>) -> Run<S>:
  match result:
    case UserRan{world,reader,line}:scenario_snapshot(~S,label,Scenario{Marker.Application{world,bundle,markerReader,declaration},watchers,UserReaders{fast,reader},List.append(&2,String,trace,[line])})

def scenario_read_fast(~S:Data,label:String,fail:Bool,scenario:Scenario<S>) -> Run<S>:
  match scenario:
    case Scenario{app,watchers,readers,trace}:
      match app:
        case Marker.Application{world,bundle,reader,declaration}:
          match readers:
            case UserReaders{fast,slow}:reader_fast_finished(~S,label,bundle,reader,declaration,watchers,slow,trace,user_read(~S,fast,world,fail))

def scenario_read_slow(~S:Data,label:String,fail:Bool,scenario:Scenario<S>) -> Run<S>:
  match scenario:
    case Scenario{app,watchers,readers,trace}:
      match app:
        case Marker.Application{world,bundle,reader,declaration}:
          match readers:
            case UserReaders{fast,slow}:reader_slow_finished(~S,label,bundle,reader,declaration,watchers,fast,trace,user_read(~S,slow,world,fail))

def init_app_twice(~S:Data,app:Marker.Application<S,Fixture.MachineKey<S>,Fixture.MachineState,Unit,Array<U32>,Fixture.Resources<S>,String,handler_runner(~S)>) -> Marker.Application<S,Fixture.MachineKey<S>,Fixture.MachineState,Unit,Array<U32>,Fixture.Resources<S>,String,handler_runner(~S)>:
  Marker.init_app(~S,~Fixture.MachineKey<S>,~Fixture.MachineState,~Fixture.Resources<S>,~Fixture.take_machine(~S),~Fixture.put_machine(~S),~Array<U32>,~String,~Unit,~handler_runner(~S),~Fixture.same_state,~unit_same,~has_unit(~S),~marker_frame(~S),~Fixture.declaration(~S),~Fixture.make_default(~S),Marker.init_app(~S,~Fixture.MachineKey<S>,~Fixture.MachineState,~Fixture.Resources<S>,~Fixture.take_machine(~S),~Fixture.put_machine(~S),~Array<U32>,~String,~Unit,~handler_runner(~S),~Fixture.same_state,~unit_same,~has_unit(~S),~marker_frame(~S),~Fixture.declaration(~S),~Fixture.make_default(~S),app))

def scenario_initialized(~S:Data,scenario:Scenario<S>) -> Run<S>:
  match scenario:
    case Scenario{app,watchers,readers,trace}:scenario_snapshot(~S,"init-duplicate",Scenario{init_app_twice(~S,app),watchers,readers,trace})

def marker_after_snapshot(~S:Data,run:Run<S>) -> Run<S>:
  match run:
    case Running{scenario}:scenario_marker(~S,"initial-marker",scenario)
    case Stopped{line}:Stopped{line}

def initialized_and_marked(~S:Data,scenario:Scenario<S>) -> Run<S>:
  marker_after_snapshot(~S,scenario_initialized(~S,scenario))

def run_app_build(~S:Data,build:AppBuild<S>) -> String:
  match build:
    case AppReady{app}:app_run_text(~S,Marker.run_app(~S,~Fixture.MachineKey<S>,~Fixture.MachineState,~Fixture.Resources<S>,~Fixture.take_machine(~S),~Fixture.put_machine(~S),~Array<U32>,~String,~Unit,~handler_runner(~S),~Fixture.same_state,~unit_same,~has_unit(~S),~marker_frame(~S),app))
    case AppRejected{world,bundle,declaration}:"MarkerRejected"
    case SystemRejected{world}:"HandlerRegistrationRejected"

def initialized_app_text(~S:Data,app:Marker.Application<S,Fixture.MachineKey<S>,Fixture.MachineState,Unit,Array<U32>,Fixture.Resources<S>,String,handler_runner(~S)>) -> String:
  app_run_text(~S,Marker.run_app(~S,~Fixture.MachineKey<S>,~Fixture.MachineState,~Fixture.Resources<S>,~Fixture.take_machine(~S),~Fixture.put_machine(~S),~Array<U32>,~String,~Unit,~handler_runner(~S),~Fixture.same_state,~unit_same,~has_unit(~S),~marker_frame(~S),Marker.init_app(~S,~Fixture.MachineKey<S>,~Fixture.MachineState,~Fixture.Resources<S>,~Fixture.take_machine(~S),~Fixture.put_machine(~S),~Array<U32>,~String,~Unit,~handler_runner(~S),~Fixture.same_state,~unit_same,~has_unit(~S),~marker_frame(~S),~Fixture.declaration(~S),~Fixture.make_default(~S),Marker.init_app(~S,~Fixture.MachineKey<S>,~Fixture.MachineState,~Fixture.Resources<S>,~Fixture.take_machine(~S),~Fixture.put_machine(~S),~Array<U32>,~String,~Unit,~handler_runner(~S),~Fixture.same_state,~unit_same,~has_unit(~S),~marker_frame(~S),~Fixture.declaration(~S),~Fixture.make_default(~S),app))))

def initialized_build_text(~S:Data,build:AppBuild<S>) -> String:
  match build:
    case AppReady{app}:initialized_app_text(~S,app)
    case AppRejected{world,bundle,declaration}:"MarkerRejected"
    case SystemRejected{world}:"HandlerRegistrationRejected"

def initialized_bundle_text(~S:Data,world:W.World<S,Array<U32>,Fixture.Resources<S>,String>) -> String:
  initialized_build_text(~S,bind_bundle(~S,bundle_initial(~S,world)))

def init_marker_text(~S:Data,world:W.World<S,Array<U32>,Fixture.Resources<S>,String>) -> String:
  initialized_bundle_text(~S,world)

def result_text(~S:Data,result:Case<S>) -> String:
  match result:
    case Refused{}:"create-refused"
    case Created{world}:init_marker_text(~S,world)

type Action is Data:
  SnapshotAction{label:String}
  InitializeAction{label:String}
  InsertAction{label:String,value:Fixture.MachineState}
  QueueAction{label:String,value:Fixture.MachineState}
  RemoveAction{label:String}
  MarkerAction{label:String}
  ConditionsAction{label:String}
  SkipFastAction{label:String}
  ReadFastAction{label:String,fail:Bool}
  ReadSlowAction{label:String,fail:Bool}
  FailureAction{label:String,enabled:Bool}

def snapshot_action(~S:Data,label:String,run:Run<S>) -> Run<S>:
  match run:
    case Stopped{line}:Stopped{line}
    case Running{scenario}:scenario_snapshot(~S,label,scenario)

def initialize_action(~S:Data,label:String,run:Run<S>) -> Run<S>:
  match run:
    case Stopped{line}:Stopped{line}
    case Running{scenario}:scenario_snapshot(~S,label,init_scenario_once(~S,scenario))

def insert_action(~S:Data,label:String,value:Fixture.MachineState,run:Run<S>) -> Run<S>:
  match run:
    case Stopped{line}:Stopped{line}
    case Running{scenario}:scenario_snapshot(~S,label,insert_scenario(~S,value,scenario))

def queue_action(~S:Data,label:String,value:Fixture.MachineState,run:Run<S>) -> Run<S>:
  match run:
    case Stopped{line}:Stopped{line}
    case Running{scenario}:scenario_snapshot(~S,label,queue_scenario(~S,value,scenario))

def remove_action(~S:Data,label:String,run:Run<S>) -> Run<S>:
  match run:
    case Stopped{line}:Stopped{line}
    case Running{scenario}:scenario_snapshot(~S,label,remove_scenario_slot(~S,scenario))

def marker_action(~S:Data,label:String,run:Run<S>) -> Run<S>:
  match run:
    case Stopped{line}:Stopped{line}
    case Running{scenario}:scenario_marker(~S,label,scenario)

def conditions_action(~S:Data,label:String,run:Run<S>) -> Run<S>:
  match run:
    case Stopped{line}:Stopped{line}
    case Running{scenario}:scenario_conditions(~S,label,scenario)

def skip_action(~S:Data,label:String,run:Run<S>) -> Run<S>:
  match run:
    case Stopped{line}:Stopped{line}
    case Running{scenario}:scenario_skip_fast(~S,label,scenario)

def read_fast_action(~S:Data,label:String,fail:Bool,run:Run<S>) -> Run<S>:
  match run:
    case Stopped{line}:Stopped{line}
    case Running{scenario}:scenario_read_fast(~S,label,fail,scenario)

def read_slow_action(~S:Data,label:String,fail:Bool,run:Run<S>) -> Run<S>:
  match run:
    case Stopped{line}:Stopped{line}
    case Running{scenario}:scenario_read_slow(~S,label,fail,scenario)

def failure_action(~S:Data,label:String,enabled:Bool,run:Run<S>) -> Run<S>:
  match run:
    case Stopped{line}:Stopped{line}
    case Running{scenario}:scenario_snapshot(~S,label,failure_scenario(~S,enabled,scenario))

def execute_action(~S:Data,run:Run<S>,action:Action) -> Run<S>:
  match action:
    case SnapshotAction{label}:snapshot_action(~S,label,run)
    case InitializeAction{label}:initialize_action(~S,label,run)
    case InsertAction{label,value}:insert_action(~S,label,value,run)
    case QueueAction{label,value}:queue_action(~S,label,value,run)
    case RemoveAction{label}:remove_action(~S,label,run)
    case MarkerAction{label}:marker_action(~S,label,run)
    case ConditionsAction{label}:conditions_action(~S,label,run)
    case SkipFastAction{label}:skip_action(~S,label,run)
    case ReadFastAction{label,fail}:read_fast_action(~S,label,fail,run)
    case ReadSlowAction{label,fail}:read_slow_action(~S,label,fail,run)
    case FailureAction{label,enabled}:failure_action(~S,label,enabled,run)

def run_actions(~S:Data,actions:List<&2,Action>,run:Run<S>) -> Run<S>:
  match actions:
    case []:run
    case action <> rest:run_actions(~S,rest,execute_action(~S,run,action))

def scenario_program(~S:Data,run:Run<S>) -> String:
  match run:
    case Stopped{line}:line
    case Running{Scenario{app,watchers,readers,trace}}:List.show(&2,String,(line => line),trace)

def start_scenario(~S:Data,world:W.World<S,Array<U32>,Fixture.Resources<S>,String>) -> String:
  scenario_program(~S,run_actions(~S,[
    SnapshotAction{"missing/default-zero"},
    InitializeAction{"init/default-A"},
    MarkerAction{"initial-marker"},
    ReadFastAction{"fast-reader-warm-initial-A",False{}},
    ReadSlowAction{"slow-reader-warm-initial-A",False{}},
    InitializeAction{"duplicate-init-still-A"},
    ConditionsAction{"initial-change-fast-and-slow"},
    QueueAction{"queue-B" ,Fixture.B{}},
    InsertAction{"occupied-insert-C-preserves-pending-B" ,Fixture.C{}},
    MarkerAction{"initial-C-marker"},
    MarkerAction{"queued-C-to-B-transition"},
    MarkerAction{"quiet-marker-after-queued-transition"},
    ConditionsAction{"changed-after-C-to-B"},
    InsertAction{"repeated-insert-A" ,Fixture.A{}},
    InsertAction{"repeated-insert-C-latest-only" ,Fixture.C{}},
    MarkerAction{"latest-initial-C"},
    SkipFastAction{"active-fast-condition-false"},
    ReadSlowAction{"slow-reader-fails-on-unread-initial-C",True{}},
    ReadSlowAction{"slow-reader-retries-same-initial-C",False{}},
    ReadFastAction{"fast-reader-reads-initial-C-after-skip",False{}},
    ConditionsAction{"condition-read-after-fast-skip"},
    InsertAction{"equal-insert-C-is-new-change" ,Fixture.C{}},
    ConditionsAction{"equal-insert-change-read"},
    InitializeAction{"init-occupied-no-change"},
    ConditionsAction{"occupied-init-no-change"},
    RemoveAction{"remove-slot"},
    ConditionsAction{"missing-slot-condition-false"},
    InitializeAction{"reinitialize-missing-default-A"},
    MarkerAction{"reinitialized-initial-A"},
    ReadFastAction{"fast-reader-reads-appended-initial-after-prior-cursor",False{}},
    ReadSlowAction{"slow-reader-reads-appended-initial-after-prior-cursor",False{}},
    ConditionsAction{"reinitialized-change-read"},
    FailureAction{"enable-initial-enter-failure",True{}},
    InsertAction{"republish-initial-C-for-failure",Fixture.C{}},
    MarkerAction{"failed-initial-enter"},
    FailureAction{"disable-initial-enter-failure",False{}},
    MarkerAction{"quiet-retry-does-not-replay"},
    InsertAction{"republish-initial-C-for-retry",Fixture.C{}},
    MarkerAction{"retry-same-owners-after-republish"},
    ConditionsAction{"final-condition-read"}
  ],scenario_bind(~S,world)))

def run_created(~S:Data,result:Case<S>) -> String:
  match result:
    case Refused{}:"create-refused"
    case Created{world}:start_scenario(~S,world)
def scenario_a() -> String:run_created(~Fixture.SchemaA,create(~Fixture.SchemaA))
def scenario_b() -> String:run_created(~Fixture.SchemaB,create(~Fixture.SchemaB))

def main() -> IO(Unit):
  IO.print("SCHEMA=A\n" ++ scenario_a() ++ "\nSCHEMA=B\n" ++ scenario_b())
