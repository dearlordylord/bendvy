import Base
import ../../../src/ecs/compose.bend as Compose
import ../../../src/ecs/ordinary-query-declaration.bend as QueryMeta
import ../../../src/ecs/ordinary-system.bend as QuerySys
import ../../../src/ecs/component.bend as Cmp
import ../../../src/ecs/capabilities.bend as Cap
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
import ../ordinary-v1/fixture.bend as Values
import ../frontend-v1/fixture.bend as F
import ../frontend-v1/main.bend as Front

type Scene is Data:
  Scene{}
type Garden is Data:
  Garden{}
def record(label:String,text:String) -> String:
  "{\"label\":\"" ++ label ++ "\",\"world\":\"" ++ text ++ "\"}"
def observed(~S:Data,label:String,seen:W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>> & String) -> W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>> & String:
  match seen:
    case (world,text):(world,record(label,text))
def observe(~S:Data,label:String,world:W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>>) -> W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>> & String:
  observed(~S,label,F.observe(~S,world))
def final_observed(~S:Data,a:String,b:String,c:String,d:String,seen:W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>> & String) -> String:
  match seen:
    case (world,e):Front.query_defined(~S,"[" ++ a ++ "," ++ b ++ "," ++ c ++ "," ++ d ++ "," ++ e ++ "]",QuerySys.observable_define(~S,~A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,~Unit,~A.Notice<S,U32>,~h => Cap.Read<h,String>,~Unit,~Unit,~String,~Cmp.Access<String>,~F.query(~S),~F.read_body,world,"survivors","survivors"))
def cleaned(~S:Data,a:String,b:String,c:String,d:String,seen:T.Returned<W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>>,Unit>) -> String:
  match seen:
    case T.Returned{world,T.Success{}}:final_observed(~S,a,b,c,d,observe(~S,"order-cleaned",W.barrier(~S,~A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,~Unit,~A.Notice<S,U32>,world)))
    case _:"CleanupCommitFailure"
def cleanup_queued(~S:Data,a:String,b:String,c:String,d:String,seen:T.Tx<W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>>,A.Notice<S,U32>> & A.QueueStatus) -> String:
  match seen:
    case (tx,A.Queued{}):cleaned(~S,a,b,c,d,Cmd.tx_finish(~S,~A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,~Unit,~A.Notice<S,U32>,~Unit,tx,T.Success{}))
    case _:"CleanupQueueFailure"
def spawned(~S:Data,+scope:Sc.Scope<S>,a:String,b:String,c:String,seen:W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>> & String) -> String:
  match seen:
    case (world,d):cleanup_queued(~S,a,b,c,d,Sc.tx_cleanup(~S,~Col.Column<S,Values.Payload>,~Unit,~U32,~Clear.leaf(~S,~Col.Column<S,Values.Payload>,~Unit,~Values.Payload,~String,~Unit,~F.take(~S),~F.put(~S),~Values.show_payload,~A.Notice<S,U32>,~F.removed(~S),~F.binding(~S)),~F.record(~S),~[],T.begin(~W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>>,~A.Notice<S,U32>,world),scope))
def pending(~S:Data,+scope:Sc.Scope<S>,a:String,b:String,seen:W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>> & String) -> String:
  match seen:
    case (world,c):spawned(~S,scope,a,b,c,observe(~S,"order-spawned",W.barrier(~S,~A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,~Unit,~A.Notice<S,U32>,world)))
def committed(~S:Data,+scope:Sc.Scope<S>,a:String,b:String,seen:T.Returned<W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>>,Unit>) -> String:
  match seen:
    case T.Returned{world,T.Success{}}:pending(~S,scope,a,b,observe(~S,"order-pending",world))
    case _:"OrderCommitFailure"
def plain_reserved(~S:Data,+scope:Sc.Scope<S>,a:String,b:String,seen:T.Tx<W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>>,A.Notice<S,U32>> & W.Reservation<S>) -> String:
  match seen:
    case (tx,W.Reserved{_}):committed(~S,scope,a,b,Cmd.tx_finish(~S,~A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,~Unit,~A.Notice<S,U32>,~Unit,tx,T.Success{}))
    case _:"PlainReservationFailure"
def scoped_reserved(~S:Data,+scope:Sc.Scope<S>,a:String,b:String,seen:T.Tx<W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>>,A.Notice<S,U32>> & Sc.SpawnResult<S,Values.Payload>) -> String:
  match seen:
    case (tx,Sc.Spawned{_}):plain_reserved(~S,scope,a,b,Cmd.tx_spawn(~S,~A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,~Unit,~A.Notice<S,U32>,~Values.Payload,~F.populate_world(~S),tx,Values.payload(2)))
    case _:"ScopedReservationFailure"
def first_cleanup(~S:Data,+scope:Sc.Scope<S>,a:String,b:String,seen:T.Tx<W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>>,A.Notice<S,U32>> & A.QueueStatus) -> String:
  match seen:
    case (tx,A.Queued{}):scoped_reserved(~S,scope,a,b,Spawn.tx_spawn_in(~S,~Col.Column<S,Values.Payload>,~Unit,~U32,~Values.Payload,~F.populate_world(~S),tx,scope,Values.payload(1)))
    case _:"FirstCleanupFailure"
def order_scoped(~S:Data,a:String,b:String,seen:W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>> & Sc.Scope<S>) -> String:
  match seen:
    case (world,+scope):first_cleanup(~S,scope,a,b,Sc.tx_cleanup(~S,~Col.Column<S,Values.Payload>,~Unit,~U32,~Clear.leaf(~S,~Col.Column<S,Values.Payload>,~Unit,~Values.Payload,~String,~Unit,~F.take(~S),~F.put(~S),~Values.show_payload,~A.Notice<S,U32>,~F.removed(~S),~F.binding(~S)),~F.record(~S),~[],T.begin(~W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>>,~A.Notice<S,U32>,world),scope))
def garden_created(a:String,b:String,seen:Prov.Provision<Garden,A.Store<Garden,Sc.Store<Garden,Col.Column<Garden,Values.Payload>>>,Unit,Ord.empty_store(~Garden,~Col.Column<Garden,Values.Payload>,~Prov.component_empty(~Garden,~Values.Payload)),Ord.count_store(~Garden,~Col.Column<Garden,Values.Payload>,~Prov.component_count(~Garden,~Values.Payload))> & WI.Creation<Garden,A.Store<Garden,Sc.Store<Garden,Col.Column<Garden,Values.Payload>>>,Unit,A.Notice<Garden,U32>>) -> IO(Unit):
  match seen:
    case (_,WI.Created{world}):IO.print(order_scoped(~Garden,a,b,Sc.scope(~Garden,~Col.Column<Garden,Values.Payload>,~Unit,~U32,world,"scene")))
    case _:IO.print("GardenCreationFailure")
def foreign_observed(a:String,seen:W.World<Scene,A.Store<Scene,Sc.Store<Scene,Col.Column<Scene,Values.Payload>>>,Unit,A.Notice<Scene,U32>> & String) -> IO(Unit):
  match seen:
    case (_,b):IO.bind(Prov.Provision<Garden,A.Store<Garden,Sc.Store<Garden,Col.Column<Garden,Values.Payload>>>,Unit,Ord.empty_store(~Garden,~Col.Column<Garden,Values.Payload>,~Prov.component_empty(~Garden,~Values.Payload)),Ord.count_store(~Garden,~Col.Column<Garden,Values.Payload>,~Prov.component_count(~Garden,~Values.Payload))> & WI.Creation<Garden,A.Store<Garden,Sc.Store<Garden,Col.Column<Garden,Values.Payload>>>,Unit,A.Notice<Garden,U32>>,Unit,F.create(~Garden),value => garden_created(a,b,value))
def foreign_finished(a:String,payload:String,seen:T.Returned<W.World<Scene,A.Store<Scene,Sc.Store<Scene,Col.Column<Scene,Values.Payload>>>,Unit,A.Notice<Scene,U32>>,Unit>) -> IO(Unit):
  match seen:
    case T.Returned{world,T.Success{}}:foreign_observed(a,observed(~Scene,"foreign-refused:" ++ payload,F.observe(~Scene,world)))
    case _:IO.print("ForeignFinishFailure")
def foreign_payload(a:String,tx:T.Tx<W.World<Scene,A.Store<Scene,Sc.Store<Scene,Col.Column<Scene,Values.Payload>>>,Unit,A.Notice<Scene,U32>>,A.Notice<Scene,U32>>,seen:Values.Payload & String) -> IO(Unit):
  match seen:
    case (_,payload):foreign_finished(a,payload,Cmd.tx_finish(~Scene,~A.Store<Scene,Sc.Store<Scene,Col.Column<Scene,Values.Payload>>>,~Unit,~A.Notice<Scene,U32>,~Unit,tx,T.Success{}))
def foreign_cleanup(a:String,payload:Values.Payload,seen:T.Tx<W.World<Scene,A.Store<Scene,Sc.Store<Scene,Col.Column<Scene,Values.Payload>>>,Unit,A.Notice<Scene,U32>>,A.Notice<Scene,U32>> & A.QueueStatus) -> IO(Unit):
  match seen:
    case (tx,A.MissingEntity{}):foreign_payload(a,tx,Values.show_payload(payload))
    case _:IO.print("ForeignCleanupAccepted")
def foreign_spawn(+scope:Sc.Scope<Scene>,a:String,seen:T.Tx<W.World<Scene,A.Store<Scene,Sc.Store<Scene,Col.Column<Scene,Values.Payload>>>,Unit,A.Notice<Scene,U32>>,A.Notice<Scene,U32>> & Sc.SpawnResult<Scene,Values.Payload>) -> IO(Unit):
  match seen:
    case (tx,Sc.SpawnRejected{payload,W.MissingEntity{}}):foreign_cleanup(a,payload,Sc.tx_cleanup(~Scene,~Col.Column<Scene,Values.Payload>,~Unit,~U32,~Clear.leaf(~Scene,~Col.Column<Scene,Values.Payload>,~Unit,~Values.Payload,~String,~Unit,~F.take(~Scene),~F.put(~Scene),~Values.show_payload,~A.Notice<Scene,U32>,~F.removed(~Scene),~F.binding(~Scene)),~F.record(~Scene),~[],tx,scope))
    case _:IO.print("ForeignSpawnAccepted")
def second_created(+scope:Sc.Scope<Scene>,a:String,seen:Prov.Provision<Scene,A.Store<Scene,Sc.Store<Scene,Col.Column<Scene,Values.Payload>>>,Unit,Ord.empty_store(~Scene,~Col.Column<Scene,Values.Payload>,~Prov.component_empty(~Scene,~Values.Payload)),Ord.count_store(~Scene,~Col.Column<Scene,Values.Payload>,~Prov.component_count(~Scene,~Values.Payload))> & WI.Creation<Scene,A.Store<Scene,Sc.Store<Scene,Col.Column<Scene,Values.Payload>>>,Unit,A.Notice<Scene,U32>>) -> IO(Unit):
  match seen:
    case (_,WI.Created{world}):foreign_spawn(scope,a,Spawn.tx_spawn_in(~Scene,~Col.Column<Scene,Values.Payload>,~Unit,~U32,~Values.Payload,~F.populate_world(~Scene),T.begin(~W.World<Scene,A.Store<Scene,Sc.Store<Scene,Col.Column<Scene,Values.Payload>>>,Unit,A.Notice<Scene,U32>>,~A.Notice<Scene,U32>,world),scope,Values.payload(99)))
    case _:IO.print("SecondCreationFailure")
def first_observed(+scope:Sc.Scope<Scene>,seen:W.World<Scene,A.Store<Scene,Sc.Store<Scene,Col.Column<Scene,Values.Payload>>>,Unit,A.Notice<Scene,U32>> & String) -> IO(Unit):
  match seen:
    case (_,a):IO.bind(Prov.Provision<Scene,A.Store<Scene,Sc.Store<Scene,Col.Column<Scene,Values.Payload>>>,Unit,Ord.empty_store(~Scene,~Col.Column<Scene,Values.Payload>,~Prov.component_empty(~Scene,~Values.Payload)),Ord.count_store(~Scene,~Col.Column<Scene,Values.Payload>,~Prov.component_count(~Scene,~Values.Payload))> & WI.Creation<Scene,A.Store<Scene,Sc.Store<Scene,Col.Column<Scene,Values.Payload>>>,Unit,A.Notice<Scene,U32>>,Unit,F.create(~Scene),value => second_created(scope,a,value))
def first_scoped(seen:W.World<Scene,A.Store<Scene,Sc.Store<Scene,Col.Column<Scene,Values.Payload>>>,Unit,A.Notice<Scene,U32>> & Sc.Scope<Scene>) -> IO(Unit):
  match seen:
    case (world,scope):first_observed(scope,observe(~Scene,"first-world",world))
def first_created(seen:Prov.Provision<Scene,A.Store<Scene,Sc.Store<Scene,Col.Column<Scene,Values.Payload>>>,Unit,Ord.empty_store(~Scene,~Col.Column<Scene,Values.Payload>,~Prov.component_empty(~Scene,~Values.Payload)),Ord.count_store(~Scene,~Col.Column<Scene,Values.Payload>,~Prov.component_count(~Scene,~Values.Payload))> & WI.Creation<Scene,A.Store<Scene,Sc.Store<Scene,Col.Column<Scene,Values.Payload>>>,Unit,A.Notice<Scene,U32>>) -> IO(Unit):
  match seen:
    case (_,WI.Created{world}):first_scoped(Sc.scope(~Scene,~Col.Column<Scene,Values.Payload>,~Unit,~U32,world,"scene"))
    case _:IO.print("FirstCreationFailure")
def main() -> IO(Unit):
  IO.bind(Prov.Provision<Scene,A.Store<Scene,Sc.Store<Scene,Col.Column<Scene,Values.Payload>>>,Unit,Ord.empty_store(~Scene,~Col.Column<Scene,Values.Payload>,~Prov.component_empty(~Scene,~Values.Payload)),Ord.count_store(~Scene,~Col.Column<Scene,Values.Payload>,~Prov.component_count(~Scene,~Values.Payload))> & WI.Creation<Scene,A.Store<Scene,Sc.Store<Scene,Col.Column<Scene,Values.Payload>>>,Unit,A.Notice<Scene,U32>>,Unit,F.create(~Scene),first_created)
