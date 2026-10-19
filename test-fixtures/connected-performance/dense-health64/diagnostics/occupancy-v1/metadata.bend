import Base
import private/occupancy.bend as O
import private/src/ecs/column.bend as Col
import private/src/ecs/world.bend as W
import private/src/ecs/owner-product.bend as Product
import private/test-fixtures/connected-performance/dense-motion64/consumer/s-perf/canonical-api-v1/dense-runtime-v1/types.bend as T
import private/src/ecs/entity-allocator.bend as A
import private/src/ecs/deferred-command.bend as Deferred
def shape(value:O.Shape) -> String:
  match value:
    case O.Shape{leaves,nodes}:"[" ++ Nat.show(leaves) ++ "," ++ Nat.show(nodes) ++ "]"
def array(value:O.ArrayStats) -> String:
  match value:
    case O.ArrayStats{leaves,nodes,nonzero}:"[" ++ Nat.show(leaves) ++ "," ++ Nat.show(nodes) ++ "," ++ Nat.show(nonzero) ++ "]"
def entries(value:O.EntryStats) -> String:
  match value:
    case O.EntryStats{physical,added,changed,populated}:"[" ++ Nat.show(physical) ++ "," ++ Nat.show(added) ++ "," ++ Nat.show(changed) ++ "," ++ Nat.show(populated) ++ "]"
def metadata(value:O.MetadataStats) -> String:
  match value:
    case O.MetadataStats{added,changed,capacity,depth,exceptional,populated}:"{\"added\":" ++ array(added) ++ ",\"changed\":" ++ array(changed) ++ ",\"capacity\":" ++ U32.show(capacity) ++ ",\"depth\":" ++ Nat.show(depth) ++ ",\"exceptional\":" ++ entries(exceptional) ++ ",\"populated\":" ++ Nat.show(populated) ++ "}"
def snapshot(value:O.Snapshot) -> String:
  match value:
    case O.Plain{values,stamps}:"{\"kind\":\"plain\",\"values\":" ++ shape(values) ++ ",\"entries\":" ++ entries(stamps) ++ "}"
    case O.Indexed{values,marks}:"{\"kind\":\"indexed\",\"values\":" ++ shape(values) ++ ",\"metadata\":" ++ metadata(marks) ++ "}"

def Store() -> Type:Product.Owner<Col.Column<T.HealthSchema,T.Vitals>,Product.Owner<Col.Column<T.HealthSchema,T.Armor>,Col.Column<T.HealthSchema,T.Tracked>>>
def Resources() -> Type:Product.Owner<T.HealthLedger,Unit>
def World() -> Type:W.World<T.HealthSchema,Store(),Resources(),Nat>
def populated(value:O.Snapshot) -> Nat:
  match value:
    case O.Plain{_,O.EntryStats{_,_,_,populated}}:populated
    case O.Indexed{_,O.MetadataStats{_,_,_,_,O.EntryStats{_,_,_,exceptional},populated}}:Nat.add(populated,exceptional)
def joined(main:Col.Column<T.HealthSchema,T.Vitals> & O.Snapshot,aux:Col.Column<T.HealthSchema,T.Armor> & O.Snapshot,flag:Col.Column<T.HealthSchema,T.Tracked> & O.Snapshot) -> Store() & String:
  match main aux flag:
    case (main,+a), (aux,+b), (flag,+c):(Product.Owner{main,Product.Owner{aux,flag}},"{\"populatedTotal\":" ++ Nat.show(Nat.add(populated(a),Nat.add(populated(b),populated(c)))) ++ ",\"main\":" ++ snapshot(a) ++ ",\"aux\":" ++ snapshot(b) ++ ",\"flag\":" ++ snapshot(c) ++ "}")
def observe_store(value:Store()) -> Store() & String:
  match value:
    case Product.Owner{main,Product.Owner{aux,flag}}:joined(Col.occupancy_observe(~T.HealthSchema,~T.Vitals,main),Col.occupancy_observe(~T.HealthSchema,~T.Armor,aux),Col.occupancy_observe(~T.HealthSchema,~T.Tracked,flag))
def world_join(+namespace:U32,allocator:A.Allocator,resource:Resources(),events:List<&2,Nat>,pending:List<Deferred.Command<World()>>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,+clock:U32,result:Store() & String) -> World() & String:
  match result:
    case (store,text):(W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock},"{\"namespace\":" ++ U32.show(namespace) ++ ",\"tick\":" ++ U32.show(clock) ++ ",\"columns\":" ++ text ++ "}")
def world(value:World()) -> World() & String:
  match value:
    case W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock}:world_join(namespace,allocator,resource,events,pending,registrations,nextSystemId,clock,observe_store(store))

def sample(value:O.Sample) -> String:
  match value:
    case O.Sample{site,value}:"{\"site\":\"" ++ site ++ "\",\"snapshot\":" ++ snapshot(value) ++ "}"
type History is Data:
  Unmonitored{}
  Recorded{values:List<&2,O.Sample>}
type ColumnHistories is Data:
  ColumnHistories{main:History,aux:History,flag:History}
type WorldHistory is Data:
  WorldHistory{namespace:U32,tick:U32,columns:ColumnHistories}
def history_column(~C:Type,value:Col.Column<T.HealthSchema,C>) -> Col.Column<T.HealthSchema,C> & History:
  match value:
    case Col.Monitored{inner,+history}:(Col.Monitored{inner,history},Recorded{List.reverse(&2,O.Sample,history)})
    case other:(other,Unmonitored{})
def history_join(main:Col.Column<T.HealthSchema,T.Vitals> & History,aux:Col.Column<T.HealthSchema,T.Armor> & History,flag:Col.Column<T.HealthSchema,T.Tracked> & History) -> Store() & ColumnHistories:
  match main aux flag:
    case (main,a), (aux,b), (flag,c):(Product.Owner{main,Product.Owner{aux,flag}},ColumnHistories{a,b,c})
def history_store(value:Store()) -> Store() & ColumnHistories:
  match value:
    case Product.Owner{main,Product.Owner{aux,flag}}:history_join(history_column(~T.Vitals,main),history_column(~T.Armor,aux),history_column(~T.Tracked,flag))
def history_world_join(+namespace:U32,allocator:A.Allocator,resource:Resources(),events:List<&2,Nat>,pending:List<Deferred.Command<World()>>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,+clock:U32,result:Store() & ColumnHistories) -> World() & WorldHistory:
  match result:
    case (store,columns):(W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock},WorldHistory{namespace,clock,columns})
def history_world(value:World()) -> World() & WorldHistory:
  match value:
    case W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock}:history_world_join(namespace,allocator,resource,events,pending,registrations,nextSystemId,clock,history_store(store))
