import Base
import ../../src/ecs/world.bend as W
import ../../src/ecs/column.bend as Col
import ../../src/ecs/component.bend as C
import ../../src/ecs/ordinary-component-binding.bend as B
import ../../src/ecs/ordinary-declaration.bend as D
import ../../src/ecs/ordinary-query-observable.bend as O
import ../../src/ecs/compose.bend as Q
import ../../src/ecs/inspector.bend as I
import ../../src/ecs/inspector-query-projection.bend as P
import ../../src/ecs/capabilities.bend as Cap
import ../../src/ecs/transaction.bend as T
import ../../src/ecs/ordinary-app-component.bend as Comp
import ../../src/ecs/ordinary-app-service-registration.bend as Svc
import ../../src/ecs/ordinary-service-declaration.bend as SD
import ../../src/ecs/ordinary-app-composer.bend as Build
import ../../src/ecs/ordinary-app-records.bend as Records
import ../../src/ecs/ordinary-app-registration-fields.bend as Fields
import ../../src/ecs/ordinary-app-execution-recipe.bend as Exec
import ../../src/ecs/ordinary-app-run.bend as Entry
import ../../src/ecs/ordinary-app-schedule.bend as Schedule
import ../../src/ecs/ordinary-app-execution.bend as Execution
import ../../src/ecs/ordinary-schema.bend as Schema
import ../../src/ecs/schema-fragments.bend as Fragment
import ../../src/ecs/ordinary-app-observation-data.bend as DTO
import ../../src/ecs/schedule-provision.bend as SP
import ../../src/ecs/execution-context.bend as Ctx
import ../../src/ecs/system.bend as Sys
import ../../src/ecs/captured-schedule-composition.bend as Choice

type Game is Data:
  Game{}
type Health is Data:
  Health{points:U32}
type HealthDecay is Data:
  HealthDecay{points:U32}
type Store is Type:
  Store{health:Col.Column<Game,Health>,decay:Col.Column<Game,HealthDecay>}
def Resources() -> Type: SD.Slot<U32>
def World() -> Type: W.World<Game,Store,Resources,Unit>
def empty(_:Unit) -> Store: Store{Col.empty(~Game,~Health),Col.empty(~Game,~HealthDecay)}
def health_take(store:Store) -> Col.Column<Game,HealthDecay> & Col.Column<Game,Health>:
  match store:
    case Store{health,decay}:(decay,health)
def health_put(decay:Col.Column<Game,HealthDecay>,health:Col.Column<Game,Health>) -> Store: Store{health,decay}
def decay_take(store:Store) -> Col.Column<Game,Health> & Col.Column<Game,HealthDecay>:
  match store:
    case Store{health,decay}:(health,decay)
def decay_put(health:Col.Column<Game,Health>,decay:Col.Column<Game,HealthDecay>) -> Store: Store{health,decay}
def health_view(value:Health) -> Health & U32:
  match value:
    case Health{+points}:(Health{points},points)
def decay_view(value:HealthDecay) -> HealthDecay & U32:
  match value:
    case HealthDecay{+points}:(HealthDecay{points},points)
def health_binding() -> B.Binding<Game,Store,Col.Column<Game,HealthDecay>,Health,U32,Unit,health_take,health_put,health_view>:
  B.bind(~Game,~Store,~Col.Column<Game,HealthDecay>,~Health,~U32,~Unit,~health_take,~health_put,~health_view,D.component(~Game,~Health,"Health"))
def health_query() -> O.Declaration<Game,Q.Frame<Game,Store,Resources,Unit>,Cap.Write<Q.Frame<Game,Store,Resources,Unit>,Health,U32>,I.Frame<Game,Store,Resources,Unit>,C.Access<U32>>:
  O.write(~Game,~Store,~Col.Column<Game,HealthDecay>,~Health,~U32,~Unit,~health_take,~health_put,~health_view,~Resources,~Unit,~health_binding)
def decay_binding() -> B.Binding<Game,Store,Col.Column<Game,Health>,HealthDecay,U32,Unit,decay_take,decay_put,decay_view>:
  B.bind(~Game,~Store,~Col.Column<Game,Health>,~HealthDecay,~U32,~Unit,~decay_take,~decay_put,~decay_view,D.component(~Game,~HealthDecay,"HealthDecay"))
def decay_query() -> O.Declaration<Game,Q.Frame<Game,Store,Resources,Unit>,Cap.Read<Q.Frame<Game,Store,Resources,Unit>,U32>,I.Frame<Game,Store,Resources,Unit>,C.Access<U32>>:
  O.read(~Game,~Store,~Col.Column<Game,Health>,~HealthDecay,~U32,~Unit,~decay_take,~decay_put,~decay_view,~Resources,~Unit,~decay_binding)
def Ops(H:Type) -> Type: Cap.Write<H,Health,U32> & Cap.Read<H,U32>
def Values() -> Data: P.Product<C.Access<U32>,C.Access<U32>>
def query() -> O.Declaration<Game,Q.Frame<Game,Store,Resources,Unit>,Ops(Q.Frame<Game,Store,Resources,Unit>),I.Frame<Game,Store,Resources,Unit>,Values>:
  O.pair(~Game,~Q.Frame<Game,Store,Resources,Unit>,~Cap.Write<Q.Frame<Game,Store,Resources,Unit>,Health,U32>,~Cap.Read<Q.Frame<Game,Store,Resources,Unit>,U32>,~I.Frame<Game,Store,Resources,Unit>,~C.Access<U32>,~C.Access<U32>,~health_query,~decay_query)
def write_cap(~H:Type,caps:Ops(H)) -> Cap.Write<H,Health,U32>:
  match caps:
    case (health,_):health
def read_cap(~H:Type,caps:Ops(H)) -> Cap.Read<H,U32>:
  match caps:
    case (_,decay):decay
def changed(~H:Type,~caps:Ops(H),health:C.Access<U32>,decay:C.Access<U32>,owner:H) -> H & (T.Outcome<Unit> & Unit):
  match health decay:
    case C.Found{health} C.Found{decay}:(Cap.set(~H,~Health,~U32,~write_cap(~H,caps),owner,Health{(health - decay : U32)}),(T.Success{},Unit{}))
    case _ _:(owner,(T.Failure{Unit{}},Unit{}))
def damage_decay(~H:Type,~caps:Ops(H),health:C.Access<U32>,result:H & C.Access<U32>) -> H & (T.Outcome<Unit> & Unit):
  match result:
    case (owner,decay):changed(~H,~caps,health,decay,owner)
def damage_health(~H:Type,~caps:Ops(H),result:H & C.Access<U32>) -> H & (T.Outcome<Unit> & Unit):
  match result:
    case (owner,health):damage_decay(~H,~caps,health,Cap.read(~H,~U32,~read_cap(~H,caps),owner))
def damage(~H:Type,~caps:Ops(H),_:Unit,owner:H) -> H & (T.Outcome<Unit> & Unit):
  damage_health(~H,~caps,Cap.get(~H,~Health,~U32,~write_cap(~H,caps),owner))
def render(_:Values) -> String: "health/decay"
def service_take(value:Resources) -> Unit & SD.Slot<U32>: (Unit{},value)
def service_put(_:Unit,value:SD.Slot<U32>) -> Resources: value
def count_tick(value:U32) -> U32: (value + 1 : U32)
def service() -> SD.Declaration<Game,Resources,U32,Unit,service_take,service_put,count_tick>:
  SD.declare(~Game,~Resources,~U32,~Unit,~service_take,~service_put,~count_tick,17,"TickCounter")
def scan() -> World -> World & List<&2,SD.Status<Game>>:
  SD.world_observed(~Game,~Store,~Resources,~Unit,~U32,~Unit,~service_take,~service_put,~count_tick,service)
def setup() -> SD.Setup<Game,Store,Resources,Unit,scan>:
  SD.single(~Game,~Store,~Resources,~Unit,~U32,~Unit,~service_take,~service_put,~count_tick,~service)
def AError() -> Data: Choice.Choice<Unit,Comp.ExecutionError<Unit>>
def AOwners() -> Type: Comp.execution_owners(~Game,~Store,~Resources,~Unit,~Unit,~Unit,~Build.empty_observe(~World),~Records.empty(~Game),~Unit,~Exec.empty_plan(~Game),~Exec.empty_dispatch(~World),~Exec.empty_provide(~Game,~World),~Ops,~Unit,~Unit,~Unit,~Values,~query,~damage,~render)
def ARows() -> Data: Comp.execution_rows(~Game,~Store,~Resources,~Unit,~Unit,~Unit,~Build.empty_observe(~World),~Records.empty(~Game),~Unit,~Exec.empty_plan(~Game),~Exec.empty_dispatch(~World),~Exec.empty_provide(~Game,~World),~Ops,~Unit,~Unit,~Unit,~Values,~query,~damage,~render)
def AObserve() -> World -> World & DTO.Observation<ARows>: Comp.execution_observe(~Game,~Store,~Resources,~Unit,~Unit,~Unit,~Build.empty_observe(~World),~Records.empty(~Game),~Unit,~Exec.empty_plan(~Game),~Exec.empty_dispatch(~World),~Exec.empty_provide(~Game,~World),~Ops,~Unit,~Unit,~Unit,~Values,~query,~damage,~render)
def AFold() -> AOwners -> AOwners & List<&2,Fields.Fields<Game>>: Comp.execution_fold(~Game,~Store,~Resources,~Unit,~Unit,~Unit,~Build.empty_observe(~World),~Records.empty(~Game),~Unit,~Exec.empty_plan(~Game),~Exec.empty_dispatch(~World),~Exec.empty_provide(~Game,~World),~Ops,~Unit,~Unit,~Unit,~Values,~query,~damage,~render)
def APlan() -> AOwners -> AOwners & SP.Plan<Game>: Comp.execution_plan(~Game,~Store,~Resources,~Unit,~Unit,~Unit,~Build.empty_observe(~World),~Records.empty(~Game),~Unit,~Exec.empty_plan(~Game),~Exec.empty_dispatch(~World),~Exec.empty_provide(~Game,~World),~Ops,~Unit,~Unit,~Unit,~Values,~query,~damage,~render)
def ADispatch() -> AOwners -> Ctx.Context<World> -> U32 -> AOwners & Sys.Outcome<Ctx.Context<World>,AError,Unit>: Comp.execution_dispatch(~Game,~Store,~Resources,~Unit,~Unit,~Unit,~Build.empty_observe(~World),~Records.empty(~Game),~Unit,~Exec.empty_plan(~Game),~Exec.empty_dispatch(~World),~Exec.empty_provide(~Game,~World),~Ops,~Unit,~Unit,~Unit,~Values,~query,~damage,~render)
def AProvide() -> World -> World & List<&2,SP.Requirement<Game>>: Comp.execution_provide(~Game,~Store,~Resources,~Unit,~Unit,~Unit,~Build.empty_observe(~World),~Records.empty(~Game),~Unit,~Exec.empty_plan(~Game),~Exec.empty_dispatch(~World),~Exec.empty_provide(~Game,~World),~Ops,~Unit,~Unit,~Unit,~Values,~query,~damage,~render)
def A() -> Type: Comp.Application(~Game,~Store,~Resources,~Unit,~Unit,~Unit,~Build.empty_observe(~World),~Records.empty(~Game),~Unit,~Exec.empty_plan(~Game),~Exec.empty_dispatch(~World),~Exec.empty_provide(~Game,~World),~Ops,~Unit,~Unit,~Unit,~Values,~query,~damage,~render)
def BError() -> Data: Choice.Choice<AError,Unit>
def BOwners() -> Type: Svc.execution_owners(~Game,~Store,~Resources,~Unit,~U32,~Unit,~service_take,~service_put,~count_tick,~service,~scan,~AOwners,~ARows,~AObserve,~AFold,~AError,~APlan,~ADispatch,~AProvide)
def BRows() -> Data: Svc.execution_rows(~Game,~Store,~Resources,~Unit,~U32,~Unit,~service_take,~service_put,~count_tick,~service,~scan,~AOwners,~ARows,~AObserve,~AFold,~AError,~APlan,~ADispatch,~AProvide)
def BObserve() -> World -> World & DTO.Observation<BRows>: Svc.execution_observe(~Game,~Store,~Resources,~Unit,~U32,~Unit,~service_take,~service_put,~count_tick,~service,~scan,~AOwners,~ARows,~AObserve,~AFold,~AError,~APlan,~ADispatch,~AProvide)
def BFold() -> BOwners -> BOwners & List<&2,Fields.Fields<Game>>: Svc.execution_fold(~Game,~Store,~Resources,~Unit,~U32,~Unit,~service_take,~service_put,~count_tick,~service,~scan,~AOwners,~ARows,~AObserve,~AFold,~AError,~APlan,~ADispatch,~AProvide)
def BPlan() -> BOwners -> BOwners & SP.Plan<Game>: Svc.composed_plan(~Game,~Store,~Resources,~Unit,~U32,~Unit,~service_take,~service_put,~count_tick,~service,~scan,~AOwners,~ARows,~AObserve,~AFold,~AError,~APlan,~ADispatch,~AProvide)
def BDispatch() -> BOwners -> Ctx.Context<World> -> U32 -> BOwners & Sys.Outcome<Ctx.Context<World>,BError,Unit>: Svc.execution_dispatch(~Game,~Store,~Resources,~Unit,~U32,~Unit,~service_take,~service_put,~count_tick,~service,~scan,~AOwners,~ARows,~AObserve,~AFold,~AError,~APlan,~ADispatch,~AProvide)
def BProvide() -> World -> World & List<&2,SP.Requirement<Game>>: Svc.execution_provide(~Game,~Store,~Resources,~Unit,~U32,~Unit,~service_take,~service_put,~count_tick,~service,~scan,~AOwners,~ARows,~AObserve,~AFold,~AError,~APlan,~ADispatch,~AProvide)
def BApp() -> Type: Svc.Executable(~Game,~Store,~Resources,~Unit,~U32,~Unit,~service_take,~service_put,~count_tick,~service,~scan,~AOwners,~ARows,~AObserve,~AFold,~AError,~APlan,~ADispatch,~AProvide)
def GameApp() -> Type: Entry.Application<Game,Store,Resources,Unit,BOwners,BRows,BObserve,BFold,BError,BPlan,BDispatch,BProvide>
def observed_resource(slot:Resources) -> Resources & U32:
  match slot:
    case SD.Ready{+count}:(SD.Ready{count},count)
    case SD.Missing{}:(SD.Missing{},999)
def point(value:Maybe<&2,U32>) -> U32:
  match value:
    case Some{n}:n
    case None{}:999
def values_join(value:Maybe<&2,U32>,result:Col.Column<Game,Health> & List<&2,U32>) -> Col.Column<Game,Health> & List<&2,U32>:
  match result:
    case (column,tail):(column,point(value) <> tail)
def values(handles:List<&2,W.Handle<Game>>,result:Col.Column<Game,Health> & Maybe<&2,U32>) -> Col.Column<Game,Health> & List<&2,U32>:
  match handles result:
    case [], (column,value):(column,[point(value)])
    case (handle <> rest), (column,value):values_join(value,values(rest,Col.view(~Game,~Health,~U32,~health_view,column,W.handle_index(~Game,handle))))
def values_start(handles:List<&2,W.Handle<Game>>,column:Col.Column<Game,Health>) -> Col.Column<Game,Health> & List<&2,U32>:
  match handles:
    case []:(column,[])
    case handle <> rest:values(rest,Col.view(~Game,~Health,~U32,~health_view,column,W.handle_index(~Game,handle)))
def report_resource(rebuild:Resources -> World,points:List<&2,U32>,result:Resources & U32) -> World & List<&2,U32>:
  match result:
    case (resource,count):(rebuild(resource),count <> points)
def report_columns(rebuild:Col.Column<Game,Health> -> Resources -> World,resource:Resources,result:Col.Column<Game,Health> & List<&2,U32>) -> World & List<&2,U32>:
  match result:
    case (health,points):report_resource(rebuild(health),points,observed_resource(resource))
def report_values(world:World,handles:List<&2,W.Handle<Game>>) -> World & List<&2,U32>:
  match world:
    case W.World{ns,allocator,Store{health,decay},resource,events,pending,registrations,next,clock}:
      report_columns(health=>resource=>W.World{ns,allocator,Store{health,decay},resource,events,pending,registrations,next,clock},resource,values_start(handles,health))
def report_handles(result:World & List<&2,W.Handle<Game>>) -> World & List<&2,U32>:
  match result:
    case (world,handles):report_values(world,handles)
def report(world:World) -> World & List<&2,U32>:
  report_handles(W.handles(~Game,~Store,~Resources,~Unit,world))
def observe(app:GameApp) -> GameApp & List<&2,U32>:
  Entry.inspect(~Game,~Store,~Resources,~Unit,~BOwners,~BRows,~BObserve,~BFold,~BError,~BPlan,~BDispatch,~BProvide,~List<&2,U32>,~report,app)
def step(result:Execution.Run<GameApp,Game,BError>) -> GameApp & Bool:
  match result:
    case Execution.Run{Schedule.Finished{app,_},_}:(app,True{})
    case Execution.Run{Schedule.Failed{app,_,_},_}:(app,False{})
    case Execution.Run{Schedule.Rejected{app},_}:(app,False{})
    case Execution.Run{Schedule.Missing{app,_},_}:(app,False{})
def next(result:GameApp & Bool) -> GameApp:
  match result:
    case (app,_):app
def ticks(n:Nat,result:GameApp & List<&2,U32>) -> List<&2,List<&2,U32>>:
  match n result:
    case 0n, (app,row):[row]
    case 1n+p, (app,row):row <> ticks(p,observe(next(step(Entry.run(~Game,~Store,~Resources,~Unit,~BOwners,~BRows,~BObserve,~BFold,~BError,~BPlan,~BDispatch,~BProvide,app)))))
def attached(result:Schedule.Attachment<BApp,GameApp>) -> List<&2,List<&2,U32>>:
  match result:
    case Schedule.Invalid{_}:[[997]]
    case Schedule.Attached{app}:ticks(3n,observe(app))
def schema() -> Schema.Schema<Game,Store,Resources>:
  Schema.Schema{[Fragment.Entry{Fragment.Component{},"Health","Health"},Fragment.Entry{Fragment.Component{},"HealthDecay","HealthDecay"},SD.entry(~Game,~Resources,~U32,~Unit,~service_take,~service_put,~count_tick,service)]}
def attach(app:BApp) -> List<&2,List<&2,U32>>:
  attached(Entry.attach(~Game,~Store,~Resources,~Unit,~BOwners,~BRows,~BObserve,~BFold,~BError,~BPlan,~BDispatch,~BProvide,schema,app,"Update",False{}))
def add_service(app:A) -> List<&2,List<&2,U32>>:
  Svc.add(~Game,~Store,~Resources,~Unit,~U32,~Unit,~service_take,~service_put,~count_tick,~service,~scan,~AOwners,~ARows,~AObserve,~AFold,~AError,~APlan,~ADispatch,~AProvide,~List<&2,List<&2,U32>>,attach,_=>[[996]],setup,"count ticks",app)
def register(world:World) -> List<&2,List<&2,U32>>:
  Comp.add(~Game,~Store,~Resources,~Unit,~Unit,~Unit,~Build.empty_observe(~World),~Records.empty(~Game),~Unit,~Exec.empty_plan(~Game),~Exec.empty_dispatch(~World),~Exec.empty_provide(~Game,~World),~Ops,~Unit,~Unit,~Unit,~Values,~query,~damage,~render,~List<&2,List<&2,U32>>,add_service,_=>[[995]],Exec.empty(~Game,~World,world),Unit{},"health decay","gameplay")
def health_replaced(value:C.Replacement<World,Health>) -> World:
  match value:
    case C.Replaced{world,_}:world
    case C.ReplaceRejected{world,_,_}:world
def put_health(world:World,handle:W.Handle<Game>,value:Health) -> World:
  health_replaced(C.replace(~Game,~Store,~Resources,~Unit,~Col.Column<Game,HealthDecay>,~Health,~U32,~Unit,~health_take,~health_put,~health_view,B.family(~Game,~Store,~Col.Column<Game,HealthDecay>,~Health,~U32,~Unit,~health_take,~health_put,~health_view,health_binding),world,handle,Some{value}))
def decay_replaced(value:C.Replacement<World,HealthDecay>) -> World:
  match value:
    case C.Replaced{world,_}:world
    case C.ReplaceRejected{world,_,_}:world
def put_decay(world:World,handle:W.Handle<Game>,value:HealthDecay) -> World:
  decay_replaced(C.replace(~Game,~Store,~Resources,~Unit,~Col.Column<Game,Health>,~HealthDecay,~U32,~Unit,~decay_take,~decay_put,~decay_view,B.family(~Game,~Store,~Col.Column<Game,Health>,~HealthDecay,~U32,~Unit,~decay_take,~decay_put,~decay_view,decay_binding),world,handle,Some{value}))
def optional_decay(value:Maybe<&2,U32>,world:World,handle:W.Handle<Game>) -> World:
  match value:
    case None{}:world
    case Some{amount}:put_decay(world,handle,HealthDecay{amount})
def spawned(health:U32,decay:Maybe<&2,U32>,result:World & W.Reservation<Game>) -> World:
  match result:
    case (world,W.ReservationRejected{_}):world
    case (world,W.Reserved{+handle}):
      world=W.discard_status(~Game,~Store,~Resources,~Unit,W.activate(~Game,~Store,~Resources,~Unit,world,handle))
      optional_decay(decay,put_health(world,handle,Health{health}),handle)
def spawn(world:World,health:U32,decay:Maybe<&2,U32>) -> World:
  spawned(health,decay,W.reserve_id(~Game,~Store,~Resources,~Unit,world))
def start(world:World) -> List<&2,List<&2,U32>>:
  world=spawn(world,40,Some{3})
  world=spawn(world,70,Some{5})
  world=spawn(world,90,None{})
  register(world)
