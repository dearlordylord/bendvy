import Base
import /workspace/formal-proofs/bendvy/src/ecs/schema-fragments.bend as Fragment
import /workspace/formal-proofs/bendvy/src/ecs/persistence-declaration.bend as Persist
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D
import source-provision.bend as Provision
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-component-binding.bend as Binding
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-declaration.bend as Identity
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as Cmp
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema-dump.bend as DumpProvision
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-dump.bend as Dump
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-population.bend as Population
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schema.bend as SchemaApp
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-records.bend as Leaf
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-dump-filter.bend as Filter
import /workspace/formal-proofs/bendvy-worktrees/ordinary-schedule-debug-v1/experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/ordinary-schema-debug-v1/refusal-preservation-v1/public-successor/consumer/owner-observer.bend as O
type S is Data:
  S{}
type First is Data:
  First{}
type Second is Data:
  Second{}
type Store is Type:
  Store{first:Col.Column<S,Array<U32>>,second:Col.Column<S,Array<U32>>,sibling:Array<U32>}
type Rest is Type:
  Rest{column:Col.Column<S,Array<U32>>,sibling:Array<U32>}
def first_take(store:Store) -> Rest & Col.Column<S,Array<U32>>:
  match store:
    case Store{first,second,sibling}:(Rest{second,sibling},first)
def first_put(rest:Rest,column:Col.Column<S,Array<U32>>) -> Store:
  match rest:
    case Rest{second,sibling}:Store{column,second,sibling}
def second_take(store:Store) -> Rest & Col.Column<S,Array<U32>>:
  match store:
    case Store{first,second,sibling}:(Rest{first,sibling},second)
def second_put(rest:Rest,column:Col.Column<S,Array<U32>>) -> Store:
  match rest:
    case Rest{first,sibling}:Store{first,column,sibling}
def view(value:Array<U32>) -> Array<U32> & U32:
  Array.get(U32,value,0)
def empty(unit:Unit) -> Store:Store{Col.empty(~S,~Array<U32>),Col.empty(~S,~Array<U32>),ANode{ALeaf{91},ALeaf{92}}}
def first_binding() -> Binding.Binding<S,Store,Rest,Array<U32>,U32,First,first_take,first_put,view>:Binding.bind(~S,~Store,~Rest,~Array<U32>,~U32,~First,~first_take,~first_put,~view,Identity.component(~S,~Array<U32>,"First"))
def first_family() -> Cmp.Family<S,Store,Rest,Array<U32>,U32,First,first_take,first_put,view>:Binding.family(~S,~Store,~Rest,~Array<U32>,~U32,~First,~first_take,~first_put,~view,first_binding())
def first_count() -> Store -> List<&2,W.Handle<S>> -> Store & List<&2,Maybe<&2,U32>>:Provision.count(~S,~Store,~Rest,~Array<U32>,~first_take,~first_put)
def first_values() -> Store -> U32 -> Store & List<&2,Maybe<&2,String>>:Provision.values(~S,~Store,~Rest,~Array<U32>,~U32,~first_take,~first_put,~view,~U32.show)
def first_provision() -> DumpProvision.Provision<S,Store,Unit,empty,first_count(),first_values(),Provision.no_resource>:Provision.component_plain(~S,~Store,~Rest,~Array<U32>,~U32,~First,~first_take,~first_put,~view,~U32.show,~empty,~first_binding(),Persist.plain(~S,~Array<U32>,~Binding.identity(~S,~Store,~Rest,~Array<U32>,~U32,~First,~first_take,~first_put,~view,first_binding())))
def second_binding() -> Binding.Binding<S,Store,Rest,Array<U32>,U32,Second,second_take,second_put,view>:Binding.bind(~S,~Store,~Rest,~Array<U32>,~U32,~Second,~second_take,~second_put,~view,Identity.component(~S,~Array<U32>,"Second"))
def second_family() -> Cmp.Family<S,Store,Rest,Array<U32>,U32,Second,second_take,second_put,view>:Binding.family(~S,~Store,~Rest,~Array<U32>,~U32,~Second,~second_take,~second_put,~view,second_binding())
def second_count() -> Store -> List<&2,W.Handle<S>> -> Store & List<&2,Maybe<&2,U32>>:Provision.count(~S,~Store,~Rest,~Array<U32>,~second_take,~second_put)
def second_values() -> Store -> U32 -> Store & List<&2,Maybe<&2,String>>:Provision.values(~S,~Store,~Rest,~Array<U32>,~U32,~second_take,~second_put,~view,~U32.show)
def second_provision() -> DumpProvision.Provision<S,Store,Unit,empty,second_count(),second_values(),Provision.no_resource>:Provision.component_transient(~S,~Store,~Rest,~Array<U32>,~U32,~Second,~second_take,~second_put,~view,~U32.show,~empty,~second_binding(),Persist.transient(~S,~Array<U32>,~Binding.identity(~S,~Store,~Rest,~Array<U32>,~U32,~Second,~second_take,~second_put,~view,second_binding())))
def component_counts() -> Store -> List<&2,W.Handle<S>> -> Store & List<&2,Maybe<&2,U32>>:Provision.append_count(~S,~Store,~first_count(),~second_count())
def component_values() -> Store -> U32 -> Store & List<&2,Maybe<&2,String>>:Provision.append_values(~Store,~first_values(),~second_values())
def resource_prefix() -> Unit -> Unit & List<&2,Maybe<&2,String>>:Provision.append_resources(~Provision.no_resource,~Provision.no_resource)
def component_provision() -> DumpProvision.Provision<S,Store,Unit,empty,component_counts(),component_values(),resource_prefix()>:Provision.append(~S,~Store,~empty,~first_count(),~second_count(),~first_values(),~second_values(),~Provision.no_resource,~Provision.no_resource,first_provision(),second_provision())
def count() -> Store -> List<&2,W.Handle<S>> -> Store & List<&2,Maybe<&2,U32>>:Provision.resource_count(~S,~Store,~component_counts())
def values() -> Store -> U32 -> Store & List<&2,Maybe<&2,String>>:Provision.resource_values(~Store,~component_values())
def resources() -> Array<U32> -> Array<U32> & List<&2,Maybe<&2,String>>:Provision.resources(~Array<U32>,~resource_prefix(),~O.u32_array)
def resource_identity() -> Identity.Declaration<S,Array<U32>>:Identity.component(~S,~Array<U32>,"Inventory")
def resource_projected(result:Array<U32> & U32) -> Array<U32> & D.Raw:
  match result:
    case (owner,value):(owner,D.Number{value})
def resource_project(owner:Array<U32>) -> Array<U32> & D.Raw:resource_projected(view(owner))
def resource_extension() -> Persist.Constructed<S,Array<U32>,resource_identity(),resource_project>:Persist.constructed(~S,~Array<U32>,~resource_identity(),~resource_project,D.Integer{})
def provision() -> DumpProvision.Provision<S,Store,Array<U32>,empty,count(),values(),resources()>:Provision.with_resource_transient(~S,~Store,~Array<U32>,~empty,~component_counts(),~component_values(),~resource_prefix(),~O.u32_array,~resource_identity(),Persist.transient(~S,~Array<U32>,~resource_identity()),component_provision())
def World() -> Type:W.World<S,Store,Array<U32>,U32>
def observe() -> World() -> World() & DTO.Observation<Unit>:Build.empty_observe(~World())
def Application() -> Type:Dump.Application<S,Store,Array<U32>,U32,Unit,Unit,observe(),Leaf.empty(~S),count(),values(),resources()>
def filters() -> Filter.Filter<S>:Filter.Filter{None{},[],None{}}
def field(value:Filter.Value) -> String:
  match value:
    case Filter.Value{key,text}:key ++ "=" ++ text
def row(value:Filter.Row<S>) -> String:
  match value:
    case Filter.Row{W.Handle{ns,id},values}:U32.show(ns) ++ ":" ++ U32.show(id) ++ ":" ++ List.show(&2,Filter.Value,field,values)
def dump(value:Maybe<&2,Dump.Dump<S>>) -> String:
  match value:
    case None{}:"dump=None"
    case Some{Dump.Dump{alive,rows,resources}}:"alive=" ++ U32.show(alive) ++ ";rows=" ++ List.show(&2,Filter.Row<S>,row,rows) ++ ";resources=" ++ List.show(&2,Filter.Value,field,resources)
def stores_join(a:Col.Column<S,Array<U32>> & String,b:Col.Column<S,Array<U32>> & String,c:Array<U32> & String) -> Store & String:
  match a b c:
    case (a,x),(b,y),(c,z):(Store{a,b,c},"store{" ++ x ++ ";" ++ y ++ ";sibling=" ++ z ++ "}")
def store_text(store:Store) -> Store & String:
  match store:
    case Store{a,b,c}:stores_join(O.column(~S,~Array<U32>,~O.u32_array,a),O.column(~S,~Array<U32>,~O.u32_array,b),O.u32_array(c))
def pending_join(head:World() -> World(),result:List<(World() -> World())> & Nat) -> List<(World() -> World())> & Nat:
  match result:
    case (rest,n):(head <> rest,1n+n)
def pending(values:List<(World() -> World())>) -> List<(World() -> World())> & Nat:
  match values:
    case []:([],0n)
    case head <> rest:pending_join(head,pending(rest))
def world_join(+namespace:U32,+nextId:U32,+highWater:U32,+capacity:U32,+depth:Nat,resource:Array<U32> & String,+events:List<&2,U32>,+registrations:List<&2,W.RegistrationMeta>,+nextSystemId:U32,+clock:U32,live:Array<Bool> & String,store:Store & String,queue:List<(World() -> World())> & Nat) -> World() & String:
  match resource live store queue:
    case (resource,r),(live,a),(store,b),(queue,n):(W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,queue,registrations,nextSystemId,clock},"world{" ++ U32.show(namespace) ++ ";next=" ++ U32.show(nextId) ++ ";high=" ++ U32.show(highWater) ++ ";live=" ++ a ++ ";capacity=" ++ U32.show(capacity) ++ ";depth=" ++ Nat.show(depth) ++ ";" ++ b ++ ";resource=" ++ r ++ ";events=" ++ List.show(&2,U32,U32.show,events) ++ ";pending=" ++ Nat.show(n) ++ ";registrations=" ++ List.show(&2,W.RegistrationMeta,O.registration,registrations) ++ ";nextSystem=" ++ U32.show(nextSystemId) ++ ";clock=" ++ U32.show(clock) ++ "}")
def physical(world:World()) -> World() & String:
  match world:
    case W.World{ns,next,high,live,cap,depth,store,resource,events,queue,regs,system,clock}:world_join(ns,next,high,cap,depth,O.u32_array(resource),events,regs,system,clock,O.bool_array(live),store_text(store),pending(queue))
def returned(schema:Schema.Schema<S,Store,Array<U32>>,flag:Bool,text:String,result:World() & String) -> Application() & String:
  match result:
    case (world,physical):(Dump.Application{schema,Build.enabled(~S,~World(),~Unit,~Unit,~observe(),~Leaf.empty(~S),Build.empty(~S,~World(),world),flag)},text ++ "|" ++ physical)
def snap_returned(result:Application() & Maybe<&2,Dump.Dump<S>>) -> Application() & String:
  match result:
    case (Dump.Application{schema,Build.Registered{world,_,_,flag}},result):returned(schema,flag,dump(result),physical(world))
def population_count(value:Population.ComponentCount) -> String:
  match value:
    case Population.ComponentCount{key,count}:key ++ "=" ++ U32.show(count)
def population_text(value:Maybe<&2,Population.Population>) -> String:
  match value:
    case None{}:"population=None"
    case Some{Population.Population{alive,components}}:"population=" ++ U32.show(alive) ++ ":" ++ List.show(&2,Population.ComponentCount,population_count,components)
def population_dumped(text:String,result:Application() & String) -> Application() & String:
  match result:
    case (app,view):(app,text ++ "|" ++ view)
def population_returned(filter:Filter.Filter<S>,result:Population.Application<S,Store,Array<U32>,U32,Unit,Unit,observe(),Leaf.empty(~S),count()> & Maybe<&2,Population.Population>) -> Application() & String:
  match result:
    case (Population.Application{SchemaApp.Application{schema,app}},view):population_dumped(population_text(view),snap_returned(Dump.snapshot(~S,~Store,~Array<U32>,~U32,~Unit,~Unit,~observe(),~Leaf.empty(~S),~count(),~values(),~resources(),filter,Dump.Application{schema,app})))
def population_first(filter:Filter.Filter<S>,app:Application()) -> Application() & String:
  match app:
    case Dump.Application{schema,app}:population_returned(filter,Population.population(~S,~Store,~Array<U32>,~U32,~Unit,~Unit,~observe(),~Leaf.empty(~S),~count(),Population.Application{SchemaApp.Application{schema,app}}))
def kind(value:Fragment.RegistryKind) -> String:
  match value:
    case Fragment.Component{}:"Component"
    case Fragment.Resource{}:"Resource"
    case Fragment.Event{}:"Event"
    case Fragment.Relation{}:"Relation"
    case Fragment.Service{}:"Service"
def persistence(value:Fragment.PersistenceKind) -> String:
  match value:
    case Fragment.Plain{}:"Plain"
    case Fragment.Transient{}:"Transient"
    case Fragment.Constructed{}:"Constructed"
def entry(value:Fragment.Entry<S>) -> String:
  match value:
    case Fragment.Entry{k,key,name}:kind(k) ++ ":" ++ key ++ ":" ++ name ++ ":Bare"
    case Fragment.Classified{k,key,name,p}:kind(k) ++ ":" ++ key ++ ":" ++ name ++ ":" ++ persistence(p)
def description(value:Maybe<&2,SchemaApp.Description<S,Unit>>) -> String:
  match value:
    case None{}:"schema=None"
    case Some{SchemaApp.Description{entries,_}}:"schema=" ++ List.show(&2,Fragment.Entry<S>,entry,entries)
def described(filter:Filter.Filter<S>,result:SchemaApp.Application<S,Store,Array<U32>,U32,Unit,Unit,observe(),Leaf.empty(~S)> & Maybe<&2,SchemaApp.Description<S,Unit>>) -> Application() & String:
  match result:
    case (SchemaApp.Application{schema,app},view):population_dumped(description(view),population_first(filter,Dump.Application{schema,app}))
def describing(filter:Filter.Filter<S>,value:Application()) -> Application() & String:
  match value:
    case Dump.Application{schema,app}:described(filter,SchemaApp.snapshot(~S,~Store,~Array<U32>,~U32,~Unit,~Unit,~observe(),~Leaf.empty(~S),SchemaApp.Application{schema,app}))
def snapshot(app:Application(),flag:Bool,filter:Filter.Filter<S>) -> Application() & String:describing(filter,Dump.enabled(~S,~Store,~Array<U32>,~U32,~Unit,~Unit,~observe(),~Leaf.empty(~S),~count(),~values(),~resources(),app,flag))

def snapshot_last(before:List<&2,String>,result:Application() & String) -> List<&2,String>:
  match result:
    case (_,text):List.append(&2,String,before,[text])
def snapshot_limit(before:List<&2,String>,result:Application() & String) -> List<&2,String>:
  match result:
    case (app,text):snapshot_last(List.append(&2,String,before,[text]),snapshot(app,True{},Filter.Filter{None{},[],Some{1n}}))
def snapshot_filter(before:List<&2,String>,result:Application() & String) -> List<&2,String>:
  match result:
    case (app,text):snapshot_limit(List.append(&2,String,before,[text]),snapshot(app,True{},Filter.Filter{None{},[Filter.Component{"Second"}],None{}}))
def snapshot_repeat(before:List<&2,String>,result:Application() & String) -> List<&2,String>:
  match result:
    case (app,text):snapshot_filter(List.append(&2,String,before,[text]),snapshot(app,True{},filters()))
def snapshot_enabled(before:List<&2,String>,result:Application() & String) -> List<&2,String>:
  match result:
    case (app,text):snapshot_repeat(List.append(&2,String,before,[text]),snapshot(app,True{},filters()))
def snapshots(schema:Schema.Schema<S,Store,Array<U32>>,world:World()) -> List<&2,String>:snapshot_enabled([],snapshot(Dump.attached(~S,~Store,~Array<U32>,~U32,~Unit,~Unit,~observe(),~Leaf.empty(~S),~count(),~values(),~resources(),schema,Build.empty(~S,~World(),world)),False{},filters()))
def swapped_first(rest:Rest,result:Col.SwapOutcome<S,Array<U32>>) -> Store:
  match result:
    case Col.Accepted{column,_}:first_put(rest,column)
    case Col.Rejected{column,_}:first_put(rest,column)
def seed_first(store:Store,id:U32,value:U32) -> Store:
  match store:
    case Store{a,b,c}:
      +id=id
      swapped_first(Rest{b,c},Col.swap(~S,~Array<U32>,Col.ensure(~S,~Array<U32>,a,id),id,Some{ALeaf{value}}))
def swapped_second(rest:Rest,result:Col.SwapOutcome<S,Array<U32>>) -> Store:
  match result:
    case Col.Accepted{column,_}:second_put(rest,column)
    case Col.Rejected{column,_}:second_put(rest,column)
def seed_second(store:Store,id:U32,value:U32) -> Store:
  match store:
    case Store{a,b,c}:
      +id=id
      swapped_second(Rest{a,c},Col.swap(~S,~Array<U32>,Col.ensure(~S,~Array<U32>,b,id),id,Some{ALeaf{value}}))
def seed(store:Store) -> Store:seed_second(seed_second(seed_first(seed_first(store,1,11),3,33),2,22),4,44)
def queued(world:World()) -> World():world
def second_read_result(schema:Schema.Schema<S,Store,Array<U32>>,result:World() & Cmp.Access<U32>) -> List<&2,String>:
  match result:
    case (world,Cmp.Found{value}):("actual-second-read=" ++ U32.show(value)) <> snapshots(schema,W.enqueue(~S,~Store,~Array<U32>,~U32,world,queued))
    case (world,Cmp.ComponentAbsent{}):"actual-second-read=Absent" <> snapshots(schema,world)
    case (world,Cmp.MissingEntity{}):"actual-second-read=MissingEntity" <> snapshots(schema,world)
def written(schema:Schema.Schema<S,Store,Array<U32>>,result:Cmp.Replacement<World(),Array<U32>>) -> List<&2,String>:
  match result:
    case Cmp.Replaced{world,None{}}:"write=Accepted;previous=None" <> second_read_result(schema,Cmp.get(~S,~Store,~Array<U32>,~U32,~Rest,~Array<U32>,~U32,~Second,~second_take,~second_put,~view,second_family(),world,W.Handle{1,1}))
    case Cmp.Replaced{world,Some{previous}}:"write=UnexpectedPrevious" <> snapshots(schema,world)
    case Cmp.ReplaceRejected{world,_,_}:"write=Rejected" <> snapshots(schema,world)
def write_second(schema:Schema.Schema<S,Store,Array<U32>>,world:World()) -> List<&2,String>:written(schema,Cmp.replace(~S,~Store,~Array<U32>,~U32,~Rest,~Array<U32>,~U32,~Second,~second_take,~second_put,~view,second_family(),world,W.Handle{1,1},Some{ALeaf{24}}))
def read_result(schema:Schema.Schema<S,Store,Array<U32>>,result:World() & Cmp.Access<U32>) -> List<&2,String>:
  match result:
    case (world,Cmp.Found{value}):("actual-read=" ++ U32.show(value)) <> write_second(schema,world)
    case (world,Cmp.ComponentAbsent{}):"actual-read=Absent" <> snapshots(schema,world)
    case (world,Cmp.MissingEntity{}):"actual-read=MissingEntity" <> snapshots(schema,world)
def seeded(schema:Schema.Schema<S,Store,Array<U32>>,result:World() & Unit) -> List<&2,String>:
  match result:
    case (world,_):read_result(schema,Cmp.get(~S,~Store,~Array<U32>,~U32,~Rest,~Array<U32>,~U32,~First,~first_take,~first_put,~view,first_family(),world,W.Handle{1,1}))
def seeded_store(store:Store) -> Store & Unit:(seed(store),Unit{})
def finish_setup(schema:Schema.Schema<S,Store,Array<U32>>,result:World() & W.Status) -> List<&2,String>:
  match result:
    case (world,_):seeded(schema,W.with_store(~S,~Store,~Array<U32>,~U32,~Unit,seeded_store,world))
def reserved_fourth(schema:Schema.Schema<S,Store,Array<U32>>,result:World() & W.Reservation<S>) -> List<&2,String>:
  match result:
    case (world,_):finish_setup(schema,W.deactivate(~S,~Store,~Array<U32>,~U32,world,W.Handle{1,3}))
def activated_third(schema:Schema.Schema<S,Store,Array<U32>>,result:World() & W.Status) -> List<&2,String>:
  match result:
    case (world,_):reserved_fourth(schema,W.reserve_id(~S,~Store,~Array<U32>,~U32,world))
def reserved_third(schema:Schema.Schema<S,Store,Array<U32>>,result:World() & W.Reservation<S>) -> List<&2,String>:
  match result:
    case (world,W.Reserved{handle}):activated_third(schema,W.activate(~S,~Store,~Array<U32>,~U32,world,handle))
    case (_,_):["reserve-rejected"]
def activated_second(schema:Schema.Schema<S,Store,Array<U32>>,result:World() & W.Status) -> List<&2,String>:
  match result:
    case (world,_):reserved_third(schema,W.reserve_id(~S,~Store,~Array<U32>,~U32,world))
def reserved_second(schema:Schema.Schema<S,Store,Array<U32>>,result:World() & W.Reservation<S>) -> List<&2,String>:
  match result:
    case (world,W.Reserved{handle}):activated_second(schema,W.activate(~S,~Store,~Array<U32>,~U32,world,handle))
    case (_,_):["reserve-rejected"]
def activated_first(schema:Schema.Schema<S,Store,Array<U32>>,result:World() & W.Status) -> List<&2,String>:
  match result:
    case (world,_):reserved_second(schema,W.reserve_id(~S,~Store,~Array<U32>,~U32,world))
def reserved_first(schema:Schema.Schema<S,Store,Array<U32>>,result:World() & W.Reservation<S>) -> List<&2,String>:
  match result:
    case (world,W.Reserved{handle}):activated_first(schema,W.activate(~S,~Store,~Array<U32>,~U32,world,handle))
    case (_,_):["reserve-rejected"]
def created(schema:Schema.Schema<S,Store,Array<U32>>,result:W.Creation<S,Store,Array<U32>,U32>) -> List<&2,String>:
  match result:
    case W.Created{_,world}:reserved_first(schema,W.reserve_id(~S,~Store,~Array<U32>,~U32,world))
    case _:["create-rejected"]
def resource_admitted(schema:Schema.Schema<S,Store,Array<U32>>,receipt:D.Receipt<Array<U32>>) -> List<&2,String>:
  match receipt:
    case D.Receipt{owner,D.Accepted{D.Number{value}}}:("constructed-admission=" ++ U32.show(value)) <> created(schema,W.create(~S,~Store,~Array<U32>,~U32,~empty,W.factory(),owner))
    case D.Receipt{owner,_}:"constructed-admission=Unexpected" <> created(schema,W.create(~S,~Store,~Array<U32>,~U32,~empty,W.factory(),owner))
def prepared(result:Schema.Schema<S,Store,Array<U32>> & DumpProvision.Recipe<S,Store,Array<U32>,count(),values(),resources()>) -> List<&2,String>:
  match result:
    case (schema,_):"resource-extension=transient" <> created(schema,W.create(~S,~Store,~Array<U32>,~U32,~empty,W.factory(),ANode{ALeaf{81},ALeaf{82}}))
def main() -> List<&2,String>:prepared(DumpProvision.prepared(~S,~Store,~Array<U32>,~empty,~count(),~values(),~resources(),provision()))
