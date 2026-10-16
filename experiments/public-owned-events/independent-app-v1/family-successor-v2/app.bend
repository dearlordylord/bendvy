import Base
import ./model.bend as M
import ./observe.bend as O
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/event-runtime.bend as Ev
import ../../../../src/ecs/owned-event-log.bend as Log
import ../../../../src/ecs/ordinary-owned-event-family-reader.bend as FamilyRead
import ../../../../src/ecs/event-family-routing.bend as Route
import ../../../../src/ecs/owner-product.bend as Product
import ../../../../src/ecs/owned-event-family-catalog.bend as Catalog
import ../../../../src/ecs/ordinary-owned-event-family-write.bend as Write
import ../../../../src/ecs/ordinary-owned-event-binding.bend as Binding
import ../../../../src/ecs/owned-event-key-route.bend as Key
import ../../../../src/ecs/ordinary-event-family.bend as Family
import ../../../../src/ecs/ordinary-event-declaration.bend as Event
import ../../../../src/ecs/event-stream.bend as Stream
import ../../../../src/ecs/ordinary-owned-event-family-publisher.bend as Pub
import ../../../../src/ecs/owned-event-family-reader-runtime.bend as Read
import ../../../../src/ecs/system.bend as Sys
import ../../../../src/ecs/transaction.bend as T

type State is Type:
  State{runtime:M.Runtime(),publisher:M.Publisher(),fast:M.Reader(),fastRegistry:M.ReaderRegistry(),slow:M.Reader(),slowRegistry:M.ReaderRegistry(),fastArgs:M.ReaderArgs,slowArgs:M.ReaderArgs,report:String}
def PubResult() -> Type:
  M.PubResult()
def ReadResult() -> Type:
  M.ReadResult()
def show_reader(r:M.Reader()) -> M.Reader() & String:
  Route.Reader{+ns,+id,+registryId} = r
  (Route.Reader{ns,id,registryId},"reader(" ++ U32.show(ns) ++ "," ++ U32.show(id) ++ "," ++ U32.show(registryId) ++ ")")
def show_registry(~Args:Type,~Error:Data,~Out:Type,~runner:M.World() -> Args -> Sys.Outcome<M.World(),Error,Out>,r:Sys.Registry<M.Schema,Unit,M.Resources(),Nat,Args,Error,Out,runner>) -> Sys.Registry<M.Schema,Unit,M.Resources(),Nat,Args,Error,Out,runner> & String:
  Sys.Registry{+ns,+id,+name,+access,+cursor} = r
  (Sys.Registry{ns,id,name,access,cursor},"registry(" ++ U32.show(ns) ++ "," ++ U32.show(id) ++ "," ++ name ++ "," ++ O.strings(access) ++ "," ++ U32.show(cursor) ++ ")")
def snapshot(label:String,state:State) -> State:
  State{runtime,publisher,fast,fr,slow,sr,fa,sa,report} = state
  M.bind(M.Runtime(),String,State,O.runtime(runtime),runtime => rt => (
  M.bind(M.Publisher(),String,State,show_registry(~M.PublishArgs,~Unit,~Pub.Reply<U32,Unit,List<M.Manifest>>,~Pub.runner(~M.Schema,~Unit,~M.Resources(),~Nat,~List<M.Manifest>,~Write.Ops(~M.Schema,~M.Manifest,~M.identity()),~Write.grant(~M.Schema,~Unit,~M.Resources(),~M.Manifest,~Array<U32> & Unit,~Nat,~Binding.right_path(~Array<U32>,~Log.Log<M.Manifest>,~M.Manifest,~Unit,~Binding.identity_lens(~Log.Log<M.Manifest>)),~Key.inject_leaf,~M.identity()),~M.declaration(),~M.PublishArgs,~U32,~Unit,~M.publish),publisher),publisher => sp => (
  M.bind(M.Reader(),String,State,show_reader(fast),fast => sf => (
  M.bind(M.Reader(),String,State,show_reader(slow),slow => ss => (
  M.bind(M.ReaderRegistry(),String,State,show_registry(~Ev.Input<Nat,M.ReaderArgs>,~Unit,~Read.Reply<U32,M.ReaderArgs>,~Read.runner(~M.Schema,~Unit,~M.Resources(),~M.Manifest,~Array<U32> & Unit,~Nat,~Binding.right_path(~Array<U32>,~Log.Log<M.Manifest>,~M.Manifest,~Unit,~Binding.identity_lens(~Log.Log<M.Manifest>)),~Unit,~List<&2,U32>,~M.ReaderArgs,~U32,~M.at,~M.consume),fr),fr => sfr => (
  M.bind(M.ReaderRegistry(),String,State,show_registry(~Ev.Input<Nat,M.ReaderArgs>,~Unit,~Read.Reply<U32,M.ReaderArgs>,~Read.runner(~M.Schema,~Unit,~M.Resources(),~M.Manifest,~Array<U32> & Unit,~Nat,~Binding.right_path(~Array<U32>,~Log.Log<M.Manifest>,~M.Manifest,~Unit,~Binding.identity_lens(~Log.Log<M.Manifest>)),~Unit,~List<&2,U32>,~M.ReaderArgs,~U32,~M.at,~M.consume),sr),sr => ssr => (
  M.bind(M.ReaderArgs,String,State,O.reader_args(fa),fa => sfa => (
  M.bind(M.ReaderArgs,String,State,O.reader_args(sa),sa => ssa => (
    State{runtime,publisher,fast,fr,slow,sr,fa,sa,report ++ label ++ ":" ++ rt ++ ";" ++ sp ++ ";" ++ sf ++ ";" ++ sfr ++ ";" ++ ss ++ ";" ++ ssr ++ ";fast=" ++ sfa ++ ";slow=" ++ ssa ++ "\n"}
  ))))))))))))))))
def pub_completed(result:PubResult()) -> M.World() & (M.Publisher() & String):
  match result:
    case Sys.Completed{registry,Sys.Succeeded{world,Pub.Reply{outcome,output,recovered}}}:
      M.bind(List<M.Manifest>,String,M.World() & (M.Publisher() & String),O.payloads(recovered),recovered => text => (
        (world,(registry,"publish=" ++ O.outcome(outcome) ++ ";recovered=" ++ text))))
    case Sys.Completed{registry,Sys.Failed{world,error}}:
      (world,(registry,"publish=transport-failure"))
    case Sys.RegistrationRejected{registry,world,args}:
      M.PublishArgs{fail,payload} = args
      M.bind(M.Manifest,String,M.World() & (M.Publisher() & String),O.manifest(payload),payload => text => (
        (world,(registry,"publish=rejected;incoming=" ++ text))))
def pub_effect(registry:M.Publisher(),args:M.PublishArgs,world:M.World()) -> M.World() & (M.Publisher() & String):
  pub_completed(Pub.run(~M.Schema,~Unit,~M.Resources(),~Nat,~List<M.Manifest>,~Write.Ops(~M.Schema,~M.Manifest,~M.identity()),~Write.grant(~M.Schema,~Unit,~M.Resources(),~M.Manifest,~Array<U32> & Unit,~Nat,~Binding.right_path(~Array<U32>,~Log.Log<M.Manifest>,~M.Manifest,~Unit,~Binding.identity_lens(~Log.Log<M.Manifest>)),~Key.inject_leaf,~M.identity()),~M.declaration(),~M.PublishArgs,~U32,~Unit,~M.publish,registry,world,args))
def pub_returned(fast:M.Reader(),fr:M.ReaderRegistry(),slow:M.Reader(),sr:M.ReaderRegistry(),fa:M.ReaderArgs,sa:M.ReaderArgs,report:String,runtime:M.Runtime(),result:M.Publisher() & String) -> State:
  (publisher,text) = result
  State{runtime,publisher,fast,fr,slow,sr,fa,sa,report ++ text ++ "\n"}
def publish(state:State,+code:U32,seed:U32,fail:Bool) -> State:
  State{runtime,publisher,fast,fr,slow,sr,fa,sa,report} = state
  M.bind(M.Runtime(),M.Publisher() & String,State,FamilyRead.with_world(~M.Schema,~Unit,~M.Resources(),~M.Manifest,~Array<U32> & Unit,~Nat,~Event.Domain<M.Schema,Nat>,~Stream.Stream<M.Schema,Nat>,~Binding.right_path(~Array<U32>,~Log.Log<M.Manifest>,~M.Manifest,~Unit,~Binding.identity_lens(~Log.Log<M.Manifest>)),~Key.inject_leaf,~Key.select_leaf,~M.identity(),~Family.leaf_make(~M.Schema,~Nat),~Family.leaf_sync(~M.Schema,~Nat),~Family.leaf_frame(~M.Schema,~Nat),~Family.leaf_retain(~M.Schema,~Nat),~Family.leaf_inventory(~M.Schema,~Nat),~Family.selected_leaf(~M.Schema,~Nat),~Family.replaced_leaf(~M.Schema,~Nat),~M.setup(),~Unit,~M.Publisher() & String,pub_effect(publisher,M.PublishArgs{fail,M.Manifest{code,M.array(seed)}}),runtime),runtime => result => (
    pub_returned(fast,fr,slow,sr,fa,sa,report,runtime,result)))
def read_completed(result:ReadResult()) -> M.Runtime() & (M.Reader() & (M.ReaderRegistry() & (M.ReaderArgs & String))):
  match result:
    case Route.Ran{runtime,reader,registry,Ev.Succeeded{Read.Reply{outcome,args,lagged}}}:
      (runtime,(reader,(registry,(args,"read=" ++ O.read_outcome(outcome) ++ ";lagged=" ++ O.bool(lagged)))))
    case Route.Ran{runtime,reader,registry,Ev.Failed{error}}:
      (runtime,(reader,(registry,(M.initial_reader(False{},0),"read=transport-failure"))))
    case Route.Ran{runtime,reader,registry,Ev.Rejected{args}}:
      (runtime,(reader,(registry,(args,"read=rejected"))))
def fast_returned(publisher:M.Publisher(),slow:M.Reader(),sr:M.ReaderRegistry(),sa:M.ReaderArgs,report:String,runtime:M.Runtime(),returned:M.Reader() & (M.ReaderRegistry() & (M.ReaderArgs & String))) -> State:
  (fast,(fr,(fa,text))) = returned
  State{runtime,publisher,fast,fr,slow,sr,fa,sa,report ++ "fast:" ++ text ++ "\n"}
def slow_returned(publisher:M.Publisher(),fast:M.Reader(),fr:M.ReaderRegistry(),fa:M.ReaderArgs,report:String,runtime:M.Runtime(),returned:M.Reader() & (M.ReaderRegistry() & (M.ReaderArgs & String))) -> State:
  (slow,(sr,(sa,text))) = returned
  State{runtime,publisher,fast,fr,slow,sr,fa,sa,report ++ "slow:" ++ text ++ "\n"}
def read_fast(state:State) -> State:
  State{runtime,publisher,fast,fr,slow,sr,fa,sa,report} = state
  M.bind(M.Runtime(),M.Reader() & (M.ReaderRegistry() & (M.ReaderArgs & String)),State,read_completed(FamilyRead.run(~M.Schema,~Unit,~M.Resources(),~M.Manifest,~Array<U32> & Unit,~Nat,~Event.Domain<M.Schema,Nat>,~Stream.Stream<M.Schema,Nat>,~Binding.right_path(~Array<U32>,~Log.Log<M.Manifest>,~M.Manifest,~Unit,~Binding.identity_lens(~Log.Log<M.Manifest>)),~Key.inject_leaf,~Key.select_leaf,~M.identity(),~Family.leaf_make(~M.Schema,~Nat),~Family.leaf_sync(~M.Schema,~Nat),~Family.leaf_frame(~M.Schema,~Nat),~Family.leaf_retain(~M.Schema,~Nat),~Family.leaf_inventory(~M.Schema,~Nat),~Family.selected_leaf(~M.Schema,~Nat),~Family.replaced_leaf(~M.Schema,~Nat),~M.setup(),~Unit,~Unit,~List<&2,U32>,~M.ReaderArgs,~U32,~M.at,~M.consume,runtime,fast,fr,fa)),runtime => returned => (
    fast_returned(publisher,slow,sr,sa,report,runtime,returned)))
def read_slow(state:State) -> State:
  State{runtime,publisher,fast,fr,slow,sr,fa,sa,report} = state
  M.bind(M.Runtime(),M.Reader() & (M.ReaderRegistry() & (M.ReaderArgs & String)),State,read_completed(FamilyRead.run(~M.Schema,~Unit,~M.Resources(),~M.Manifest,~Array<U32> & Unit,~Nat,~Event.Domain<M.Schema,Nat>,~Stream.Stream<M.Schema,Nat>,~Binding.right_path(~Array<U32>,~Log.Log<M.Manifest>,~M.Manifest,~Unit,~Binding.identity_lens(~Log.Log<M.Manifest>)),~Key.inject_leaf,~Key.select_leaf,~M.identity(),~Family.leaf_make(~M.Schema,~Nat),~Family.leaf_sync(~M.Schema,~Nat),~Family.leaf_frame(~M.Schema,~Nat),~Family.leaf_retain(~M.Schema,~Nat),~Family.leaf_inventory(~M.Schema,~Nat),~Family.selected_leaf(~M.Schema,~Nat),~Family.replaced_leaf(~M.Schema,~Nat),~M.setup(),~Unit,~Unit,~List<&2,U32>,~M.ReaderArgs,~U32,~M.at,~M.consume,runtime,slow,sr,sa)),runtime => returned => (
    slow_returned(publisher,fast,fr,fa,report,runtime,returned)))
def retry_fast(state:State) -> State:
  State{runtime,publisher,fast,fr,slow,sr,fa,sa,report} = state
  State{runtime,publisher,fast,fr,slow,sr,M.retry(fa),sa,report}
def frame_returned(state:State,receipt:List<Log.Row<M.Manifest>>) -> State:
  State{runtime,publisher,fast,fr,slow,sr,fa,sa,report} = state
  M.bind(List<Log.Row<M.Manifest>>,String,State,O.rows(receipt),receipt => text => (
    State{runtime,publisher,fast,fr,slow,sr,fa,sa,report ++ "retired=" ++ text ++ "\n"}))
def frame(state:State) -> State:
  State{runtime,publisher,fast,fr,slow,sr,fa,sa,report} = state
  M.bind(M.Runtime(),List<Log.Row<M.Manifest>>,State,FamilyRead.frame(~M.Schema,~Unit,~Array<U32>,~Log.Log<M.Manifest>,~M.Manifest,~Array<U32> & Unit,~Nat,~Event.Domain<M.Schema,Nat>,~Stream.Stream<M.Schema,Nat>,~Binding.right_path(~Array<U32>,~Log.Log<M.Manifest>,~M.Manifest,~Unit,~Binding.identity_lens(~Log.Log<M.Manifest>)),~Key.inject_leaf,~Key.select_leaf,~M.identity(),~Family.leaf_make(~M.Schema,~Nat),~Family.leaf_sync(~M.Schema,~Nat),~Family.leaf_frame(~M.Schema,~Nat),~Family.leaf_retain(~M.Schema,~Nat),~Family.leaf_inventory(~M.Schema,~Nat),~Family.selected_leaf(~M.Schema,~Nat),~Family.replaced_leaf(~M.Schema,~Nat),~M.setup(),~Unit,~List<Log.Row<M.Manifest>>,~Log.retain(~M.Manifest),~Log.drain(~M.Manifest),~Catalog.leaf_clear(~M.Schema),~M.catalog(),runtime),runtime => retired => (
    frame_returned(State{runtime,publisher,fast,fr,slow,sr,fa,sa,report},retired)))
def drain(state:State) -> State:
  State{runtime,publisher,fast,fr,slow,sr,fa,sa,report} = state
  M.bind(M.Runtime(),List<Log.Row<M.Manifest>>,State,FamilyRead.shutdown(~M.Schema,~Unit,~Array<U32>,~Log.Log<M.Manifest>,~M.Manifest,~Array<U32> & Unit,~Nat,~Event.Domain<M.Schema,Nat>,~Stream.Stream<M.Schema,Nat>,~Binding.right_path(~Array<U32>,~Log.Log<M.Manifest>,~M.Manifest,~Unit,~Binding.identity_lens(~Log.Log<M.Manifest>)),~Key.inject_leaf,~Key.select_leaf,~M.identity(),~Family.leaf_make(~M.Schema,~Nat),~Family.leaf_sync(~M.Schema,~Nat),~Family.leaf_frame(~M.Schema,~Nat),~Family.leaf_retain(~M.Schema,~Nat),~Family.leaf_inventory(~M.Schema,~Nat),~Family.selected_leaf(~M.Schema,~Nat),~Family.replaced_leaf(~M.Schema,~Nat),~M.setup(),~Unit,~List<Log.Row<M.Manifest>>,~Log.retain(~M.Manifest),~Log.drain(~M.Manifest),~Catalog.leaf_clear(~M.Schema),~M.catalog(),runtime),runtime => retired => (
    frame_returned(State{runtime,publisher,fast,fr,slow,sr,fa,sa,report ++ "shutdown:"},retired)))
def finish(state:State) -> String:
  State{runtime,publisher,fast,fr,slow,sr,fa,sa,report} = state
  report

def scenario(state:State) -> String:
  state = snapshot("created",state)
  state = snapshot("commit-a",publish(state,11,101,False{}))
  state = snapshot("abort-b",publish(state,22,202,True{}))
  state = snapshot("fast-failed",read_fast(state))
  state = snapshot("fast-retry",read_fast(retry_fast(state)))
  state = snapshot("frame-one",frame(state))
  state = snapshot("commit-c",publish(state,33,303,False{}))
  state = snapshot("fast-c",read_fast(state))
  state = snapshot("slow-a-c",read_slow(state))
  state = snapshot("frame-two",frame(state))
  state = snapshot("frame-three",frame(state))
  state = snapshot("commit-d",publish(state,44,404,False{}))
  state = snapshot("shutdown",drain(state))
  finish(state)

def registered_slow(publisher:M.Publisher(),fast:M.Reader(),fr:M.ReaderRegistry(),result:M.RegisteredReader()) -> String:
  match result:
    case Route.Registered{runtime,reader,registry}:
      scenario(State{runtime,publisher,fast,fr,reader,registry,M.initial_reader(True{},701),M.initial_reader(False{},801),"cargo-manifests-family-v2\n"})
    case Route.RegistrationFailed{runtime}: "fatal:slow-registration"
def registered_fast(publisher:M.Publisher(),result:M.RegisteredReader()) -> String:
  match result:
    case Route.Registered{runtime,reader,registry}:
      registered_slow(publisher,reader,registry,FamilyRead.register(~M.Schema,~Unit,~M.Resources(),~M.Manifest,~Array<U32> & Unit,~Nat,~Event.Domain<M.Schema,Nat>,~Stream.Stream<M.Schema,Nat>,~Binding.right_path(~Array<U32>,~Log.Log<M.Manifest>,~M.Manifest,~Unit,~Binding.identity_lens(~Log.Log<M.Manifest>)),~Key.inject_leaf,~Key.select_leaf,~M.identity(),~Family.leaf_make(~M.Schema,~Nat),~Family.leaf_sync(~M.Schema,~Nat),~Family.leaf_frame(~M.Schema,~Nat),~Family.leaf_retain(~M.Schema,~Nat),~Family.leaf_inventory(~M.Schema,~Nat),~Family.selected_leaf(~M.Schema,~Nat),~Family.replaced_leaf(~M.Schema,~Nat),~M.setup(),~Unit,~Unit,~List<&2,U32>,~M.ReaderArgs,~U32,~M.at,~M.consume,runtime,"warehouse"))
    case Route.RegistrationFailed{runtime}: "fatal:fast-registration"
def registered_publisher(result:M.RegisteredPublisher()) -> String:
  match result:
    case Sys.Registered{world,registry}:
      registered_fast(registry,FamilyRead.register(~M.Schema,~Unit,~M.Resources(),~M.Manifest,~Array<U32> & Unit,~Nat,~Event.Domain<M.Schema,Nat>,~Stream.Stream<M.Schema,Nat>,~Binding.right_path(~Array<U32>,~Log.Log<M.Manifest>,~M.Manifest,~Unit,~Binding.identity_lens(~Log.Log<M.Manifest>)),~Key.inject_leaf,~Key.select_leaf,~M.identity(),~Family.leaf_make(~M.Schema,~Nat),~Family.leaf_sync(~M.Schema,~Nat),~Family.leaf_frame(~M.Schema,~Nat),~Family.leaf_retain(~M.Schema,~Nat),~Family.leaf_inventory(~M.Schema,~Nat),~Family.selected_leaf(~M.Schema,~Nat),~Family.replaced_leaf(~M.Schema,~Nat),~M.setup(),~Unit,~Unit,~List<&2,U32>,~M.ReaderArgs,~U32,~M.at,~M.consume,FamilyRead.setup(~M.Schema,~Unit,~M.Resources(),~M.Manifest,~Array<U32> & Unit,~Nat,~Event.Domain<M.Schema,Nat>,~Stream.Stream<M.Schema,Nat>,~Binding.right_path(~Array<U32>,~Log.Log<M.Manifest>,~M.Manifest,~Unit,~Binding.identity_lens(~Log.Log<M.Manifest>)),~Key.inject_leaf,~Key.select_leaf,~M.identity(),~Family.leaf_make(~M.Schema,~Nat),~Family.leaf_sync(~M.Schema,~Nat),~Family.leaf_frame(~M.Schema,~Nat),~Family.leaf_retain(~M.Schema,~Nat),~Family.leaf_inventory(~M.Schema,~Nat),~Family.selected_leaf(~M.Schema,~Nat),~Family.replaced_leaf(~M.Schema,~Nat),~Unit,M.setup(),world,Unit{},8n),"dock"))
    case Sys.RegistrationFailed{world}: "fatal:publisher-registration"
def created(world:M.World()) -> String:
  registered_publisher(Pub.define(~M.Schema,~Unit,~M.Resources(),~Nat,~List<M.Manifest>,~Write.Ops(~M.Schema,~M.Manifest,~M.identity()),~Write.grant(~M.Schema,~Unit,~M.Resources(),~M.Manifest,~Array<U32> & Unit,~Nat,~Binding.right_path(~Array<U32>,~Log.Log<M.Manifest>,~M.Manifest,~Unit,~Binding.identity_lens(~Log.Log<M.Manifest>)),~Key.inject_leaf,~M.identity()),~M.declaration(),~M.PublishArgs,~U32,~Unit,~M.publish,world,"dispatch"))
