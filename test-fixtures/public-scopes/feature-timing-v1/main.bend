import Base
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/world-io.bend as WI
import ../../../src/ecs/column.bend as Col
import ../../../src/ecs/relation-commands.bend as A
import ../../../src/ecs/relation-types.bend as G
import ../../../src/ecs/relation-failure-reader.bend as Rel
import ../../../src/ecs/lifetime-scope.bend as Sc
import ../../../src/ecs/lifetime-scope-world-spawn.bend as Spawn
import ../../../src/ecs/ordinary-lifetime-scope.bend as Ord
import ../../../src/ecs/ordinary-schema-provision.bend as Prov
import ../../../src/ecs/commands.bend as Cmd
import ../../../src/ecs/transaction.bend as T
import ../../../src/ecs/system.bend as Sys
import ../../../src/ecs/ordinary-component-despawn.bend as Clear
import ./payload-view.bend as V
import ./fixture.bend as F
import ./observer.bend as O
import ../ordinary-v1/fixture.bend as Values

type Alpha is Data:
  Alpha{}
type Beta is Data:
  Beta{}
type Action is Data:
  LinkedSpawn{}
  Cleanup{failed:Bool}
  Barrier{}
  BeforeSpawn{}
  PlainSeed{}
  AbortScoped{}
  AfterSpawn{}
type Step is Data:
  Act{action:Action}
  See{phase:String}
type ScopeTokens<S:Data> is Data:
  ScopeTokens{first:Sc.Scope<S>,same:Sc.Scope<S>}
type CleanupArgs<S:Data> is Data:
  CleanupArgs{scope:Sc.Scope<S>,fail:Bool}
def Tx(~S:Data) -> Type:
  T.Tx<O.World(~S),A.Notice<S,U32>>
def begin(~S:Data,world:O.World(~S)) -> Tx(~S):
  T.begin(~O.World(~S),~A.Notice<S,U32>,world)
def committed(~S:Data,seen:T.Returned<O.World(~S),Unit>) -> O.World(~S):
  match seen:
    case T.Returned{world,_}:world
def finish(~S:Data,tx:Tx(~S),outcome:T.Outcome<Unit>) -> O.World(~S):
  committed(~S,Cmd.tx_finish(~S,~O.Store(~S),~Unit,~A.Notice<S,U32>,~Unit,tx,outcome))
def plain_returned(~S:Data,seen:Tx(~S) & W.Reservation<S>) -> Tx(~S) & W.Handle<S>:
  match seen:
    case (tx,W.Reserved{handle}):(tx,handle)
    case (tx,_):(tx,W.Handle{0,0})
def scoped_returned(~S:Data,seen:Tx(~S) & Sc.SpawnResult<S,Values.Payload>) -> Tx(~S) & W.Handle<S>:
  match seen:
    case (tx,Sc.Spawned{handle}):(tx,handle)
    case (tx,_):(tx,W.Handle{0,0})
def plain(~S:Data,tx:Tx(~S),id:U32) -> Tx(~S) & W.Handle<S>:
  plain_returned(~S,Cmd.tx_spawn(~S,~O.Store(~S),~Unit,~A.Notice<S,U32>,~Values.Payload,~F.populate_world(~S),tx,Values.payload(id)))
def scoped(~S:Data,tx:Tx(~S),scope:Sc.Scope<S>,id:U32) -> Tx(~S) & W.Handle<S>:
  scoped_returned(~S,Spawn.tx_spawn_in(~S,~Col.Column<S,Values.Payload>,~Unit,~U32,~Values.Payload,~F.populate_world(~S),tx,scope,Values.payload(id)))
def related(~S:Data,seen:Tx(~S) & A.QueueStatus) -> Tx(~S):
  match seen:
    case (tx,_):tx
def relate(~S:Data,tx:Tx(~S),descriptor:G.Descriptor<S>,source:W.Handle<S>,target:W.Handle<S>) -> Tx(~S):
  related(~S,A.queue_relate(~S,~Sc.Store<S,Col.Column<S,Values.Payload>>,~Unit,~U32,tx,descriptor,source,target))
def clean_tx(~S:Data,tx:Tx(~S),scope:Sc.Scope<S>) -> Tx(~S):
  related(~S,Sc.tx_cleanup(~S,~Col.Column<S,Values.Payload>,~Unit,~U32,~F.clear(~S),~F.record(~S),~Values.descriptors(~S),tx,scope))
def linked6(~S:Data,+h1:W.Handle<S>,+h2:W.Handle<S>,h3:W.Handle<S>,h4:W.Handle<S>,seen:Tx(~S) & W.Handle<S>) -> O.World(~S):
  match seen:
    case (tx,_):finish(~S,relate(~S,relate(~S,relate(~S,tx,Values.parent(~S),h2,h1),Values.parent(~S),h4,h2),Values.link(~S),h3,h1),T.Success{})
def linked5(~S:Data,h1:W.Handle<S>,h2:W.Handle<S>,h3:W.Handle<S>,h4:W.Handle<S>,seen:Tx(~S) & W.Handle<S>) -> O.World(~S):
  match seen:
    case (tx,_):linked6(~S,h1,h2,h3,h4,plain(~S,tx,6))
def linked4(~S:Data,scope:Sc.Scope<S>,h1:W.Handle<S>,h2:W.Handle<S>,h3:W.Handle<S>,seen:Tx(~S) & W.Handle<S>) -> O.World(~S):
  match seen:
    case (tx,h4):linked5(~S,h1,h2,h3,h4,scoped(~S,tx,scope,5))
def linked3(~S:Data,scope:Sc.Scope<S>,h1:W.Handle<S>,h2:W.Handle<S>,seen:Tx(~S) & W.Handle<S>) -> O.World(~S):
  match seen:
    case (tx,h3):linked4(~S,scope,h1,h2,h3,plain(~S,tx,4))
def linked2(~S:Data,scope:Sc.Scope<S>,h1:W.Handle<S>,seen:Tx(~S) & W.Handle<S>) -> O.World(~S):
  match seen:
    case (tx,h2):linked3(~S,scope,h1,h2,plain(~S,tx,3))
def linked1(~S:Data,scope:Sc.Scope<S>,seen:Tx(~S) & W.Handle<S>) -> O.World(~S):
  match seen:
    case (tx,h1):linked2(~S,scope,h1,plain(~S,tx,2))
def linked(~S:Data,world:O.World(~S),scope:Sc.Scope<S>,same:Sc.Scope<S>) -> O.World(~S):
  linked1(~S,same,scoped(~S,begin(~S,world),scope,1))
def cleanup_decided(~H:Type,failed:Bool,owner:H,status:A.QueueStatus) -> H & (T.Outcome<Unit> & A.QueueStatus):
  match failed:
    case False{}:(owner,(T.Success{},status))
    case True{}:(owner,(T.Failure{Unit{}},status))
def cleanup_returned(~H:Type,failed:Bool,seen:H & A.QueueStatus) -> H & (T.Outcome<Unit> & A.QueueStatus):
  match seen:
    case (owner,status):cleanup_decided(~H,failed,owner,status)
def cleanup_body(~S:Data,~H:Type,~ops:Ord.Ops<H,S,Values.Payload>,args:CleanupArgs<S>,owner:H) -> H & (T.Outcome<Unit> & A.QueueStatus):
  match args:
    case CleanupArgs{scope,failed}:cleanup_returned(~H,failed,Ord.cleanup(~H,~S,~Values.Payload,~ops,owner,scope))
def declarations(~S:Data) -> List<&2,Rel.Declaration<S>>:
  [Rel.relation(~S,Values.link(~S)),Rel.relation(~S,Values.parent(~S))]
def cleanup_result(~S:Data,seen:Sys.RunResult<S,O.Store(~S),Unit,A.Notice<S,U32>,CleanupArgs<S>,Unit,A.QueueStatus,Ord.runner(~S,~Col.Column<S,Values.Payload>,~Unit,~U32,~Values.Payload,~F.populate_world(~S),~Clear.leaf(~S,~Col.Column<S,Values.Payload>,~Unit,~Values.Payload,~List<&2,U32>,~Unit,~F.take(~S),~F.put(~S),~V.project,~A.Notice<S,U32>,~F.removed(~S),~F.binding(~S)),~F.record(~S),~declarations(~S),~CleanupArgs<S>,~Unit,~A.QueueStatus,~cleanup_body(~S))>) -> O.World(~S) & String:
  match seen:
    case Sys.Completed{_,Sys.Succeeded{world,_}}:(world,"ok")
    case Sys.Completed{_,Sys.Failed{world,_}}:(world,"Rejected")
    case Sys.RegistrationRejected{_,world,_}:(world,"RegistrationRejected")
def cleanup_registered(~S:Data,scope:Sc.Scope<S>,failed:Bool,seen:Sys.RegistrationResult<S,O.Store(~S),Unit,A.Notice<S,U32>,CleanupArgs<S>,Unit,A.QueueStatus,Ord.runner(~S,~Col.Column<S,Values.Payload>,~Unit,~U32,~Values.Payload,~F.populate_world(~S),~Clear.leaf(~S,~Col.Column<S,Values.Payload>,~Unit,~Values.Payload,~List<&2,U32>,~Unit,~F.take(~S),~F.put(~S),~V.project,~A.Notice<S,U32>,~F.removed(~S),~F.binding(~S)),~F.record(~S),~declarations(~S),~CleanupArgs<S>,~Unit,~A.QueueStatus,~cleanup_body(~S))>) -> O.World(~S) & String:
  match seen:
    case Sys.Registered{world,owner}:cleanup_result(~S,Ord.run(~S,~Col.Column<S,Values.Payload>,~Unit,~U32,~Values.Payload,~F.populate_world(~S),~Clear.leaf(~S,~Col.Column<S,Values.Payload>,~Unit,~Values.Payload,~List<&2,U32>,~Unit,~F.take(~S),~F.put(~S),~V.project,~A.Notice<S,U32>,~F.removed(~S),~F.binding(~S)),~F.record(~S),~declarations(~S),~CleanupArgs<S>,~Unit,~A.QueueStatus,~cleanup_body(~S),owner,world,CleanupArgs{scope,failed}))
    case Sys.RegistrationFailed{world}:(world,"RegistrationFailed")
def cleanup(~S:Data,world:O.World(~S),scope:Sc.Scope<S>,failed:Bool) -> O.World(~S) & String:
  cleanup_registered(~S,scope,failed,Ord.register(~S,~Col.Column<S,Values.Payload>,~Unit,~U32,~Values.Payload,~F.populate_world(~S),~Clear.leaf(~S,~Col.Column<S,Values.Payload>,~Unit,~Values.Payload,~List<&2,U32>,~Unit,~F.take(~S),~F.put(~S),~V.project,~A.Notice<S,U32>,~F.removed(~S),~F.binding(~S)),~F.record(~S),~declarations(~S),~CleanupArgs<S>,~Unit,~A.QueueStatus,~cleanup_body(~S),~F.clear_declaration(~S),world,"scope/matched-cleanup"))
def before_plain(~S:Data,seen:Tx(~S) & W.Handle<S>) -> O.World(~S):
  match seen:
    case (tx,_):finish(~S,tx,T.Success{})
def before_scoped(~S:Data,seen:Tx(~S) & W.Handle<S>) -> O.World(~S):
  match seen:
    case (tx,_):before_plain(~S,plain(~S,tx,2))
def before(~S:Data,world:O.World(~S),+scope:Sc.Scope<S>) -> O.World(~S):
  before_scoped(~S,scoped(~S,clean_tx(~S,begin(~S,world),scope),scope,1))
def plain_seed(~S:Data,world:O.World(~S)) -> O.World(~S):
  before_plain(~S,plain(~S,begin(~S,world),2))
def abort_finished(~S:Data,seen:T.Returned<O.World(~S),Unit>) -> O.World(~S) & String:
  match seen:
    case T.Returned{world,T.Failure{_}}:(world,"Rejected")
    case T.Returned{world,T.Success{}}:(world,"UnexpectedAbortSuccess")
def aborted(~S:Data,seen:Tx(~S) & W.Handle<S>) -> O.World(~S) & String:
  match seen:
    case (tx,_):abort_finished(~S,Cmd.tx_finish(~S,~O.Store(~S),~Unit,~A.Notice<S,U32>,~Unit,tx,T.Failure{Unit{}}))
def abort_scoped(~S:Data,world:O.World(~S),scope:Sc.Scope<S>) -> O.World(~S) & String:
  aborted(~S,scoped(~S,begin(~S,world),scope,99))
def after_scoped(~S:Data,scope:Sc.Scope<S>,seen:Tx(~S) & W.Handle<S>) -> O.World(~S):
  match seen:
    case (tx,_):finish(~S,clean_tx(~S,tx,scope),T.Success{})
def after(~S:Data,world:O.World(~S),+scope:Sc.Scope<S>) -> O.World(~S):
  after_scoped(~S,scope,scoped(~S,begin(~S,world),scope,3))
def acted(~S:Data,action:Action,scope:Sc.Scope<S>,same:Sc.Scope<S>,world:O.World(~S)) -> O.World(~S) & String:
  match action:
    case LinkedSpawn{}:(linked(~S,world,scope,same),"ok")
    case Cleanup{failed}:cleanup(~S,world,scope,failed)
    case Barrier{}:(W.barrier(~S,~O.Store(~S),~Unit,~A.Notice<S,U32>,world),"ok")
    case BeforeSpawn{}:(before(~S,world,scope),"ok")
    case PlainSeed{}:(plain_seed(~S,world),"ok")
    case AbortScoped{}:abort_scoped(~S,world,scope)
    case AfterSpawn{}:(after(~S,world,scope),"ok")
def act_result(~S:Data,cursor:Nat,seen:O.World(~S) & String) -> O.State<S>:
  match seen:
    case (world,status):O.State{world,cursor,status}
def act(~S:Data,action:Action,tokens:ScopeTokens<S>,state:O.State<S>) -> O.State<S>:
  match tokens state:
    case ScopeTokens{scope,same} O.State{world,cursor,_}:act_result(~S,cursor,acted(~S,action,scope,same,world))
def record_join(~S:Data,text:String,seen:O.State<S> & List<&2,String>) -> O.State<S> & List<&2,String>:
  match seen:
    case (state,rest):(state,text <> rest)
def record_next(~S:Data,next:O.State<S> -> O.State<S> & List<&2,String>,seen:O.State<S> & String) -> O.State<S> & List<&2,String>:
  match seen:
    case (state,text):record_join(~S,text,next(state))
def steps(~S:Data,+repeat:U32,+schema:String,+scenario:String,+tokens:ScopeTokens<S>,ops:List<&2,Step>,state:O.State<S>) -> O.State<S> & List<&2,String>:
  match ops:
    case []:(state,[])
    case Act{action} <> rest:steps(~S,repeat,schema,scenario,tokens,rest,act(~S,action,tokens,state))
    case See{phase} <> rest:record_next(~S,state => steps(~S,repeat,schema,scenario,tokens,rest,state),O.observe(~S,repeat,schema,scenario,phase,state))
def linked_steps(unit:Unit) -> List<&2,Step>:
  [Act{LinkedSpawn{}},See{"pending-spawn"},Act{Cleanup{True{}}},See{"failed-cleanup"},Act{Barrier{}},See{"spawned"},Act{Cleanup{False{}}},See{"pending-cleanup"},Act{Barrier{}},See{"cleaned"},Act{Cleanup{False{}}},Act{Barrier{}},See{"repeated-cleanup"}]
def before_steps(unit:Unit) -> List<&2,Step>:
  [Act{BeforeSpawn{}},See{"pending"},Act{Barrier{}},See{"spawned"},Act{Cleanup{False{}}},Act{Barrier{}},See{"cleaned"}]
def after_steps(unit:Unit) -> List<&2,Step>:
  [Act{PlainSeed{}},Act{Barrier{}},See{"seeded"},Act{AbortScoped{}},See{"aborted"},Act{AfterSpawn{}},See{"pending"},Act{Barrier{}},See{"cleaned"}]
def selected_steps(id:U32) -> String & List<&2,Step>:
  match id:
    case 0:("linked-failure",linked_steps(Unit{}))
    case 1:("cleanup-before-spawn",before_steps(Unit{}))
    case _:("abort-and-cleanup-after",after_steps(Unit{}))
def completed(~S:Data,seen:O.State<S> & List<&2,String>) -> List<&2,String>:
  match seen:
    case (_,texts):texts
def second_scope(~S:Data,repeat:U32,schema:String,scenario:String,ops:List<&2,Step>,first:Sc.Scope<S>,seen:O.World(~S) & Sc.Scope<S>) -> List<&2,String>:
  match seen:
    case (world,same):completed(~S,steps(~S,repeat,schema,scenario,ScopeTokens{first,same},ops,O.State{world,0n,"ok"}))
def scoped_case(~S:Data,repeat:U32,schema:String,scenario:String,ops:List<&2,Step>,seen:O.World(~S) & Sc.Scope<S>) -> List<&2,String>:
  match seen:
    case (world,first):second_scope(~S,repeat,schema,scenario,ops,first,Sc.scope(~S,~Col.Column<S,Values.Payload>,~Unit,~U32,world,"scene"))
def case_selected(~S:Data,repeat:U32,schema:String,world:O.World(~S),seen:String & List<&2,Step>) -> List<&2,String>:
  match seen:
    case (scenario,ops):scoped_case(~S,repeat,schema,scenario,ops,Sc.scope(~S,~Col.Column<S,Values.Payload>,~Unit,~U32,world,"scene"))
def Creation(~S:Data) -> Type:
  Prov.Provision<S,O.Store(~S),Unit,Ord.empty_store(~S,~Col.Column<S,Values.Payload>,~Prov.component_empty(~S,~Values.Payload)),Ord.count_store(~S,~Col.Column<S,Values.Payload>,~Prov.component_count(~S,~Values.Payload))> & WI.Creation<S,O.Store(~S),Unit,A.Notice<S,U32>>
def created(~S:Data,repeat:U32,schema:String,scenario:U32,seen:Creation(~S)) -> IO(List<&2,String>):
  match seen:
    case (_,WI.Created{world}):IO.pure(List<&2,String>,case_selected(~S,repeat,schema,world,selected_steps(scenario)))
    case _:IO.pure(List<&2,String>,["CreationRefused"])
def run_case(~S:Data,repeat:U32,schema:String,scenario:U32) -> IO(List<&2,String>):
  IO.bind(Creation(~S),List<&2,String>,F.create(~S),value => created(~S,repeat,schema,scenario,value))
def lists_join(left:List<&2,String>,right:List<&2,String>) -> List<&2,String>:
  List.append(&2,String,left,right)
def schema_cases(~S:Data,+repeat:U32,+schema:String) -> IO(List<&2,String>):
  IO.bind(List<&2,String>,List<&2,String>,run_case(~S,repeat,schema,0),a => IO.bind(List<&2,String>,List<&2,String>,run_case(~S,repeat,schema,1),b => IO.bind(List<&2,String>,List<&2,String>,run_case(~S,repeat,schema,2),c => IO.pure(List<&2,String>,lists_join(a,lists_join(b,c))))))
def one(+repeat:U32) -> IO(List<&2,String>):
  IO.bind(List<&2,String>,List<&2,String>,schema_cases(~Alpha,repeat,"ScopeTimingAlpha"),a => IO.bind(List<&2,String>,List<&2,String>,schema_cases(~Beta,repeat,"ScopeTimingBeta"),b => IO.pure(List<&2,String>,lists_join(a,b))))
def repeat_next(next:List<&2,String> -> IO(List<&2,String>),seen:List<&2,String>) -> IO(List<&2,String>):
  next(seen)
def loops(remaining:Nat,+repeat:U32) -> IO(List<&2,String>):
  match remaining:
    case 0n:IO.pure(List<&2,String>,[])
    case 1n+p:IO.bind(List<&2,String>,List<&2,String>,one(repeat),head => IO.bind(List<&2,String>,List<&2,String>,loops(p,U32.add(repeat,1)),tail => IO.pure(List<&2,String>,lists_join(head,tail))))
def rendered(texts:List<&2,String>) -> String:
  O.compact(~String,~text => text,texts)
def run(lifecycles:Nat) -> IO(String):
  IO.bind(List<&2,String>,String,loops(lifecycles,0),texts => IO.pure(String,rendered(texts)))
def main() -> IO(Unit):
  IO.bind(String,Unit,run(1n),IO.print)
