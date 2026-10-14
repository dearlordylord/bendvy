import Base
import ../../../src/ecs/ordinary-schema-provision.bend as Prov
import ../../../src/ecs/ordinary-lifetime-scope.bend as Ord
import ../../../src/ecs/lifetime-scope.bend as Sc
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/world-io.bend as WI
import ../../../src/ecs/column.bend as Col
import ../../../src/ecs/commands.bend as Cmd
import ../../../src/ecs/transaction.bend as T
import ../../../src/ecs/system.bend as Sys
import ../../../src/ecs/relation-commands.bend as A
import ../../../src/ecs/capabilities.bend as Cap
import ../../../src/ecs/component.bend as Cmp
import ../../../src/ecs/ordinary-system.bend as QuerySys
import ../../../src/ecs/ordinary-query-declaration.bend as QueryMeta
import ../../../src/ecs/compose.bend as Compose
import ../../../src/ecs/ordinary-component-despawn.bend as Clear
import ../ordinary-v1/fixture.bend as Values
import ./fixture.bend as F

type Scene is Data:
  Scene{}
type Garden is Data:
  Garden{}
type CleanupArgs<S:Data> is Data:
  CleanupArgs{scope:Sc.Scope<S>,fail:Bool}
def spawn_returned(~H:Type,~S:Data,seen:H & Sc.SpawnResult<S,Values.Payload>) -> H & (T.Outcome<Unit> & Sc.SpawnResult<S,Values.Payload>):
  match seen:
    case (owner,result):(owner,(T.Success{},result))
def spawn_body(~S:Data,~H:Type,~ops:Ord.Ops<H,S,Values.Payload>,args:(Sc.Scope<S> & Values.Payload),owner:H) -> H & (T.Outcome<Unit> & Sc.SpawnResult<S,Values.Payload>):
  match args:
    case (scope,payload):spawn_returned(~H,~S,Ord.spawn(~H,~S,~Values.Payload,~ops,owner,scope,payload))
def cleanup_decided(~H:Type,failed:Bool,owner:H,status:A.QueueStatus) -> H & (T.Outcome<Unit> & A.QueueStatus):
  match failed:
    case False{}:(owner,(T.Success{},status))
    case True{}:(owner,(T.Failure{Unit{}},status))
def cleanup_returned(~H:Type,failed:Bool,seen:H & A.QueueStatus) -> H & (T.Outcome<Unit> & A.QueueStatus):
  match seen:
    case (owner,status):cleanup_decided(~H,failed,owner,status)
def cleanup_body(~S:Data,~H:Type,~ops:Ord.Ops<H,S,Values.Payload>,args:CleanupArgs<S>,owner:H) -> H & (T.Outcome<Unit> & A.QueueStatus):
  match args:
    case CleanupArgs{scope,fail}:cleanup_returned(~H,fail,Ord.cleanup(~H,~S,~Values.Payload,~ops,owner,scope))
def SpawnOwner(~S:Data) -> Type:
  Sys.Registry<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>,(Sc.Scope<S> & Values.Payload),Unit,Sc.SpawnResult<S,Values.Payload>,Ord.runner(~S,~Col.Column<S,Values.Payload>,~Unit,~U32,~Values.Payload,~F.populate_world(~S),~Clear.leaf(~S,~Col.Column<S,Values.Payload>,~Unit,~Values.Payload,~String,~Unit,~F.take(~S),~F.put(~S),~Values.show_payload,~A.Notice<S,U32>,~F.removed(~S),~F.binding(~S)),~F.record(~S),~[],~(Sc.Scope<S> & Values.Payload),~Unit,~Sc.SpawnResult<S,Values.Payload>,~spawn_body(~S))>
def SpawnResult(~S:Data) -> Type:
  Sys.RunResult<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>,(Sc.Scope<S> & Values.Payload),Unit,Sc.SpawnResult<S,Values.Payload>,Ord.runner(~S,~Col.Column<S,Values.Payload>,~Unit,~U32,~Values.Payload,~F.populate_world(~S),~Clear.leaf(~S,~Col.Column<S,Values.Payload>,~Unit,~Values.Payload,~String,~Unit,~F.take(~S),~F.put(~S),~Values.show_payload,~A.Notice<S,U32>,~F.removed(~S),~F.binding(~S)),~F.record(~S),~[],~(Sc.Scope<S> & Values.Payload),~Unit,~Sc.SpawnResult<S,Values.Payload>,~spawn_body(~S))>
def CleanupOwner(~S:Data) -> Type:
  Sys.Registry<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>,CleanupArgs<S>,Unit,A.QueueStatus,Ord.runner(~S,~Col.Column<S,Values.Payload>,~Unit,~U32,~Values.Payload,~F.populate_world(~S),~Clear.leaf(~S,~Col.Column<S,Values.Payload>,~Unit,~Values.Payload,~String,~Unit,~F.take(~S),~F.put(~S),~Values.show_payload,~A.Notice<S,U32>,~F.removed(~S),~F.binding(~S)),~F.record(~S),~[],~CleanupArgs<S>,~Unit,~A.QueueStatus,~cleanup_body(~S))>
def CleanupResult(~S:Data) -> Type:
  Sys.RunResult<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>,CleanupArgs<S>,Unit,A.QueueStatus,Ord.runner(~S,~Col.Column<S,Values.Payload>,~Unit,~U32,~Values.Payload,~F.populate_world(~S),~Clear.leaf(~S,~Col.Column<S,Values.Payload>,~Unit,~Values.Payload,~String,~Unit,~F.take(~S),~F.put(~S),~Values.show_payload,~A.Notice<S,U32>,~F.removed(~S),~F.binding(~S)),~F.record(~S),~[],~CleanupArgs<S>,~Unit,~A.QueueStatus,~cleanup_body(~S))>
def cleanup_view(~S:Data,value:CleanupOwner(~S)) -> CleanupOwner(~S) & String:
  match value:
    case Sys.Registry{+ns,+id,+name,+access,+cursor}:(Sys.Registry{ns,id,name,access,cursor},U32.show(ns) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,value => value,access) ++ ":" ++ U32.show(cursor))
def observed(~S:Data,label:String,+owner:String,seen:W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>> & String) -> W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>> & String:
  match seen:
    case (world,text):(world,"{\"label\":\"" ++ label ++ "\",\"world\":\"" ++ text ++ "\",\"owner\":\"" ++ owner ++ "\"}")
def observe(~S:Data,label:String,+owner:String,world:W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>>) -> W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>> & String:
  observed(~S,label,owner,F.observe(~S,world))
def query_observed(~S:Data,snapshots:String,values:List<&2,String>,seen:W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>> & String) -> String:
  match seen:
    case (_,text):"{\"snapshots\":" ++ snapshots ++ ",\"query\":" ++ List.show(&2,String,value => "\"" ++ value ++ "\"",values) ++ ",\"after-query\":" ++ text ++ "}"
def query_returned(~S:Data,snapshots:String,seen:Sys.RunResult<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>,Unit & U32,Compose.Error<Unit>,List<&2,String>,QuerySys.observable_runner(~S,~A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,~Unit,~A.Notice<S,U32>,~h => Cap.Read<h,String>,~Unit,~Unit,~String,~Cmp.Access<String>,~F.query(~S),~F.read_body)> & (String & List<&2,QueryMeta.Clause<S>>)) -> String:
  match seen:
    case (Sys.Completed{Sys.Registry{ns,id,name,access,cursor},Sys.Succeeded{world,values}},_):query_observed(~S,snapshots,values,observe(~S,"after-query",U32.show(ns) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,value => value,access) ++ ":" ++ U32.show(cursor),world))
    case _:"SurvivorQueryFailure"
def query_defined(~S:Data,snapshots:String,seen:QuerySys.Defined<S,W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>>,Sys.Registry<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>,Unit & U32,Compose.Error<Unit>,List<&2,String>,QuerySys.observable_runner(~S,~A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,~Unit,~A.Notice<S,U32>,~h => Cap.Read<h,String>,~Unit,~Unit,~String,~Cmp.Access<String>,~F.query(~S),~F.read_body)>>) -> String:
  match seen:
    case QuerySys.Defined{world,owner}:query_returned(~S,snapshots,QuerySys.observable_run(~S,~A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,~Unit,~A.Notice<S,U32>,~h => Cap.Read<h,String>,~Unit,~Unit,~String,~Cmp.Access<String>,~F.query(~S),~F.read_body,owner,world,Unit{}))
    case _:"QueryRegistrationFailure"
def cleaned_observed(~S:Data,a:String,b:String,c:String,d:String,seen:W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>> & String) -> String:
  match seen:
    case (world,e):query_defined(~S,"[" ++ a ++ "," ++ b ++ "," ++ c ++ "," ++ d ++ "," ++ e ++ "]",QuerySys.observable_define(~S,~A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,~Unit,~A.Notice<S,U32>,~h => Cap.Read<h,String>,~Unit,~Unit,~String,~Cmp.Access<String>,~F.query(~S),~F.read_body,world,"survivors","survivors"))
def retry_observed(~S:Data,+owner:String,a:String,b:String,c:String,seen:W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>> & String) -> String:
  match seen:
    case (world,d):cleaned_observed(~S,a,b,c,d,observe(~S,"cleaned",owner,W.barrier(~S,~A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,~Unit,~A.Notice<S,U32>,world)))
def retry_owner(~S:Data,world:W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>>,a:String,b:String,c:String,seen:CleanupOwner(~S) & String) -> String:
  match seen:
    case (_,+owner):retry_observed(~S,owner,a,b,c,observe(~S,"pending-cleanup",owner,world))
def cleanup_retried(~S:Data,a:String,b:String,c:String,seen:CleanupResult(~S)) -> String:
  match seen:
    case Sys.Completed{owner,Sys.Succeeded{world,_}}:retry_owner(~S,world,a,b,c,cleanup_view(~S,owner))
    case _:"ExpectedRetrySuccess"
def failed_observed(~S:Data,owner:CleanupOwner(~S),+scope:Sc.Scope<S>,a:String,b:String,seen:W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>> & String) -> String:
  match seen:
    case (world,c):cleanup_retried(~S,a,b,c,Ord.run(~S,~Col.Column<S,Values.Payload>,~Unit,~U32,~Values.Payload,~F.populate_world(~S),~Clear.leaf(~S,~Col.Column<S,Values.Payload>,~Unit,~Values.Payload,~String,~Unit,~F.take(~S),~F.put(~S),~Values.show_payload,~A.Notice<S,U32>,~F.removed(~S),~F.binding(~S)),~F.record(~S),~[],~CleanupArgs<S>,~Unit,~A.QueueStatus,~cleanup_body(~S),owner,W.barrier(~S,~A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,~Unit,~A.Notice<S,U32>,world),CleanupArgs{scope,False{}}))
def failed_owner(~S:Data,world:W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>>,+scope:Sc.Scope<S>,a:String,b:String,seen:CleanupOwner(~S) & String) -> String:
  match seen:
    case (owner,text):failed_observed(~S,owner,scope,a,b,observe(~S,"failed-cleanup",text,world))
def cleanup_failed(~S:Data,+scope:Sc.Scope<S>,a:String,b:String,seen:CleanupResult(~S)) -> String:
  match seen:
    case Sys.Completed{owner,Sys.Failed{world,_}}:failed_owner(~S,world,scope,a,b,cleanup_view(~S,owner))
    case _:"ExpectedRegisteredFailure"
def cleanup_registered(~S:Data,+scope:Sc.Scope<S>,a:String,b:String,seen:Sys.RegistrationResult<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>,CleanupArgs<S>,Unit,A.QueueStatus,Ord.runner(~S,~Col.Column<S,Values.Payload>,~Unit,~U32,~Values.Payload,~F.populate_world(~S),~Clear.leaf(~S,~Col.Column<S,Values.Payload>,~Unit,~Values.Payload,~String,~Unit,~F.take(~S),~F.put(~S),~Values.show_payload,~A.Notice<S,U32>,~F.removed(~S),~F.binding(~S)),~F.record(~S),~[],~CleanupArgs<S>,~Unit,~A.QueueStatus,~cleanup_body(~S))>) -> String:
  match seen:
    case Sys.Registered{world,owner}:cleanup_failed(~S,scope,a,b,Ord.run(~S,~Col.Column<S,Values.Payload>,~Unit,~U32,~Values.Payload,~F.populate_world(~S),~Clear.leaf(~S,~Col.Column<S,Values.Payload>,~Unit,~Values.Payload,~String,~Unit,~F.take(~S),~F.put(~S),~Values.show_payload,~A.Notice<S,U32>,~F.removed(~S),~F.binding(~S)),~F.record(~S),~[],~CleanupArgs<S>,~Unit,~A.QueueStatus,~cleanup_body(~S),owner,world,CleanupArgs{scope,True{}}))
    case _:"RegistrationFailure"
def spawn_observed(~S:Data,+scope:Sc.Scope<S>,a:String,seen:W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>> & String) -> String:
  match seen:
    case (world,b):cleanup_registered(~S,scope,a,b,Ord.register(~S,~Col.Column<S,Values.Payload>,~Unit,~U32,~Values.Payload,~F.populate_world(~S),~Clear.leaf(~S,~Col.Column<S,Values.Payload>,~Unit,~Values.Payload,~String,~Unit,~F.take(~S),~F.put(~S),~Values.show_payload,~A.Notice<S,U32>,~F.removed(~S),~F.binding(~S)),~F.record(~S),~[],~CleanupArgs<S>,~Unit,~A.QueueStatus,~cleanup_body(~S),~F.clear_declaration(~S),world,"cleanup"))
def pending_observed(~S:Data,+scope:Sc.Scope<S>,seen:W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>> & String) -> String:
  match seen:
    case (world,a):spawn_observed(~S,scope,a,observe(~S,"spawned","spawn-owner-not-retained",W.barrier(~S,~A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,~Unit,~A.Notice<S,U32>,world)))
def plain_committed(~S:Data,+scope:Sc.Scope<S>,seen:T.Returned<W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>>,Unit>) -> String:
  match seen:
    case T.Returned{world,T.Success{}}:pending_observed(~S,scope,observe(~S,"pending-spawn","spawn-owner-not-retained",world))
    case _:"PlainCommitFailure"
def plain_reserved(~S:Data,+scope:Sc.Scope<S>,seen:T.Tx<W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>>,A.Notice<S,U32>> & W.Reservation<S>) -> String:
  match seen:
    case (tx,W.Reserved{_}):plain_committed(~S,scope,Cmd.tx_finish(~S,~A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,~Unit,~A.Notice<S,U32>,~Unit,tx,T.Success{}))
    case _:"PlainReservationFailure"
def spawn_executed(~S:Data,+scope:Sc.Scope<S>,seen:SpawnResult(~S)) -> String:
  match seen:
    case Sys.Completed{_,Sys.Succeeded{world,Sc.Spawned{_}}}:plain_reserved(~S,scope,Cmd.tx_spawn(~S,~A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,~Unit,~A.Notice<S,U32>,~Values.Payload,~F.populate_world(~S),T.begin(~W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>>,~A.Notice<S,U32>,world),Values.payload(2)))
    case _:"SpawnRegistrationFailure"
def spawn_registered(~S:Data,+scope:Sc.Scope<S>,seen:Sys.RegistrationResult<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>,(Sc.Scope<S> & Values.Payload),Unit,Sc.SpawnResult<S,Values.Payload>,Ord.runner(~S,~Col.Column<S,Values.Payload>,~Unit,~U32,~Values.Payload,~F.populate_world(~S),~Clear.leaf(~S,~Col.Column<S,Values.Payload>,~Unit,~Values.Payload,~String,~Unit,~F.take(~S),~F.put(~S),~Values.show_payload,~A.Notice<S,U32>,~F.removed(~S),~F.binding(~S)),~F.record(~S),~[],~(Sc.Scope<S> & Values.Payload),~Unit,~Sc.SpawnResult<S,Values.Payload>,~spawn_body(~S))>) -> String:
  match seen:
    case Sys.Registered{world,owner}:spawn_executed(~S,scope,Ord.run(~S,~Col.Column<S,Values.Payload>,~Unit,~U32,~Values.Payload,~F.populate_world(~S),~Clear.leaf(~S,~Col.Column<S,Values.Payload>,~Unit,~Values.Payload,~String,~Unit,~F.take(~S),~F.put(~S),~Values.show_payload,~A.Notice<S,U32>,~F.removed(~S),~F.binding(~S)),~F.record(~S),~[],~(Sc.Scope<S> & Values.Payload),~Unit,~Sc.SpawnResult<S,Values.Payload>,~spawn_body(~S),owner,world,(scope,Values.payload(1))))
    case _:"RegistrationFailure"
def scoped(~S:Data,seen:W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>> & Sc.Scope<S>) -> String:
  match seen:
    case (world,+scope):spawn_registered(~S,scope,Ord.register(~S,~Col.Column<S,Values.Payload>,~Unit,~U32,~Values.Payload,~F.populate_world(~S),~Clear.leaf(~S,~Col.Column<S,Values.Payload>,~Unit,~Values.Payload,~String,~Unit,~F.take(~S),~F.put(~S),~Values.show_payload,~A.Notice<S,U32>,~F.removed(~S),~F.binding(~S)),~F.record(~S),~[],~(Sc.Scope<S> & Values.Payload),~Unit,~Sc.SpawnResult<S,Values.Payload>,~spawn_body(~S),~F.clear_declaration(~S),world,"spawn"))
def created(~S:Data,seen:Prov.Provision<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,Ord.empty_store(~S,~Col.Column<S,Values.Payload>,~Prov.component_empty(~S,~Values.Payload)),Ord.count_store(~S,~Col.Column<S,Values.Payload>,~Prov.component_count(~S,~Values.Payload))> & WI.Creation<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>>) -> IO(Unit):
  match seen:
    case (_,WI.Created{world}):IO.print(scoped(~S,Sc.scope(~S,~Col.Column<S,Values.Payload>,~Unit,~U32,world,"scene")))
    case (_,WI.Refused{_}):IO.print("CreationRefused")
def main() -> IO(Unit):
  IO.bind(Prov.Provision<Scene,A.Store<Scene,Sc.Store<Scene,Col.Column<Scene,Values.Payload>>>,Unit,Ord.empty_store(~Scene,~Col.Column<Scene,Values.Payload>,~Prov.component_empty(~Scene,~Values.Payload)),Ord.count_store(~Scene,~Col.Column<Scene,Values.Payload>,~Prov.component_count(~Scene,~Values.Payload))> & WI.Creation<Scene,A.Store<Scene,Sc.Store<Scene,Col.Column<Scene,Values.Payload>>>,Unit,A.Notice<Scene,U32>>,Unit,F.create(~Scene),value => created(~Scene,value))
