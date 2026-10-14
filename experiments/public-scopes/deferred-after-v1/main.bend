import Base
import ../../../src/ecs/ordinary-schema-provision.bend as Prov
import ../../../src/ecs/ordinary-lifetime-scope.bend as Ord
import ../../../src/ecs/lifetime-scope.bend as Sc
import ../../../src/ecs/lifetime-scope-world-spawn.bend as Spawn
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/world-io.bend as WI
import ../../../src/ecs/column.bend as Col
import ../../../src/ecs/commands.bend as Cmd
import ../../../src/ecs/transaction.bend as T
import ../../../src/ecs/relation-commands.bend as A
import ../../../src/ecs/ordinary-component-despawn.bend as Clear
import ../../../src/ecs/capabilities.bend as Cap
import ../../../src/ecs/component.bend as Cmp
import ../../../src/ecs/ordinary-system.bend as QuerySys
import ../ordinary-v1/fixture.bend as Values
import ../frontend-v1/fixture.bend as F
import ../frontend-v1/main.bend as Front

type Scene is Data:
  Scene{}
def observed(~S:Data,label:String,seen:W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>> & String) -> W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>> & String:
  match seen:
    case (world,text):(world,"{\"label\":\"" ++ label ++ "\",\"world\":\"" ++ text ++ "\"}")
def observe(~S:Data,label:String,world:W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>>) -> W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>> & String:
  observed(~S,label,F.observe(~S,world))
def cleaned(~S:Data,a:String,b:String,c:String,seen:W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>> & String) -> String:
  match seen:
    case (world,d):Front.query_defined(~S,"[" ++ a ++ "," ++ b ++ "," ++ c ++ "," ++ d ++ "]",QuerySys.observable_define(~S,~A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,~Unit,~A.Notice<S,U32>,~h => Cap.Read<h,String>,~Unit,~Unit,~String,~Cmp.Access<String>,~F.query(~S),~F.read_body,world,"survivors","survivors"))
def pending(~S:Data,a:String,b:String,seen:W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>> & String) -> String:
  match seen:
    case (world,c):cleaned(~S,a,b,c,observe(~S,"after-cleaned",W.barrier(~S,~A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,~Unit,~A.Notice<S,U32>,world)))
def committed(~S:Data,a:String,b:String,seen:T.Returned<W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>>,Unit>) -> String:
  match seen:
    case T.Returned{world,T.Success{}}:pending(~S,a,b,observe(~S,"after-pending",world))
    case _:"AfterCommitFailure"
def cleanup_queued(~S:Data,a:String,b:String,seen:T.Tx<W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>>,A.Notice<S,U32>> & A.QueueStatus) -> String:
  match seen:
    case (tx,A.Queued{}):committed(~S,a,b,Cmd.tx_finish(~S,~A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,~Unit,~A.Notice<S,U32>,~Unit,tx,T.Success{}))
    case _:"AfterCleanupFailure"
def after_reserved(~S:Data,scope:Sc.Scope<S>,a:String,b:String,seen:T.Tx<W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>>,A.Notice<S,U32>> & Sc.SpawnResult<S,Values.Payload>) -> String:
  match seen:
    case (tx,Sc.Spawned{_}):cleanup_queued(~S,a,b,Sc.tx_cleanup(~S,~Col.Column<S,Values.Payload>,~Unit,~U32,~Clear.leaf(~S,~Col.Column<S,Values.Payload>,~Unit,~Values.Payload,~String,~Unit,~F.take(~S),~F.put(~S),~Values.show_payload,~A.Notice<S,U32>,~F.removed(~S),~F.binding(~S)),~F.record(~S),~[],tx,scope))
    case _:"AfterReservationFailure"
def aborted_observed(~S:Data,+scope:Sc.Scope<S>,a:String,seen:W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>> & String) -> String:
  match seen:
    case (world,b):after_reserved(~S,scope,a,b,Spawn.tx_spawn_in(~S,~Col.Column<S,Values.Payload>,~Unit,~U32,~Values.Payload,~F.populate_world(~S),T.begin(~W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>>,~A.Notice<S,U32>,world),scope,Values.payload(3)))
def aborted(~S:Data,+scope:Sc.Scope<S>,a:String,seen:T.Returned<W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>>,Unit>) -> String:
  match seen:
    case T.Returned{world,T.Failure{_}}:aborted_observed(~S,scope,a,observe(~S,"aborted",world))
    case _:"ExpectedAbort"
def abort_reserved(~S:Data,+scope:Sc.Scope<S>,a:String,seen:T.Tx<W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>>,A.Notice<S,U32>> & Sc.SpawnResult<S,Values.Payload>) -> String:
  match seen:
    case (tx,Sc.Spawned{_}):aborted(~S,scope,a,Cmd.tx_finish(~S,~A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,~Unit,~A.Notice<S,U32>,~Unit,tx,T.Failure{Unit{}}))
    case _:"AbortReservationFailure"
def baseline_observed(~S:Data,+scope:Sc.Scope<S>,seen:W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>> & String) -> String:
  match seen:
    case (world,a):abort_reserved(~S,scope,a,Spawn.tx_spawn_in(~S,~Col.Column<S,Values.Payload>,~Unit,~U32,~Values.Payload,~F.populate_world(~S),T.begin(~W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>>,~A.Notice<S,U32>,world),scope,Values.payload(99)))
def baseline_committed(~S:Data,+scope:Sc.Scope<S>,seen:T.Returned<W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>>,Unit>) -> String:
  match seen:
    case T.Returned{world,T.Success{}}:baseline_observed(~S,scope,observe(~S,"baseline",W.barrier(~S,~A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,~Unit,~A.Notice<S,U32>,world)))
    case _:"BaselineCommitFailure"
def plain_reserved(~S:Data,+scope:Sc.Scope<S>,seen:T.Tx<W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>>,A.Notice<S,U32>> & W.Reservation<S>) -> String:
  match seen:
    case (tx,W.Reserved{_}):baseline_committed(~S,scope,Cmd.tx_finish(~S,~A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,~Unit,~A.Notice<S,U32>,~Unit,tx,T.Success{}))
    case _:"BaselineReservationFailure"
def scoped(~S:Data,seen:W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>> & Sc.Scope<S>) -> String:
  match seen:
    case (world,scope):plain_reserved(~S,scope,Cmd.tx_spawn(~S,~A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,~Unit,~A.Notice<S,U32>,~Values.Payload,~F.populate_world(~S),T.begin(~W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>>,~A.Notice<S,U32>,world),Values.payload(2)))
def created(~S:Data,seen:Prov.Provision<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,Ord.empty_store(~S,~Col.Column<S,Values.Payload>,~Prov.component_empty(~S,~Values.Payload)),Ord.count_store(~S,~Col.Column<S,Values.Payload>,~Prov.component_count(~S,~Values.Payload))> & WI.Creation<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>>) -> IO(Unit):
  match seen:
    case (_,WI.Created{world}):IO.print(scoped(~S,Sc.scope(~S,~Col.Column<S,Values.Payload>,~Unit,~U32,world,"scene")))
    case _:IO.print("CreationRefused")
def main() -> IO(Unit):
  IO.bind(Prov.Provision<Scene,A.Store<Scene,Sc.Store<Scene,Col.Column<Scene,Values.Payload>>>,Unit,Ord.empty_store(~Scene,~Col.Column<Scene,Values.Payload>,~Prov.component_empty(~Scene,~Values.Payload)),Ord.count_store(~Scene,~Col.Column<Scene,Values.Payload>,~Prov.component_count(~Scene,~Values.Payload))> & WI.Creation<Scene,A.Store<Scene,Sc.Store<Scene,Col.Column<Scene,Values.Payload>>>,Unit,A.Notice<Scene,U32>>,Unit,F.create(~Scene),value => created(~Scene,value))
