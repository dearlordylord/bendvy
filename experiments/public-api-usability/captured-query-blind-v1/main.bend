import Base
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/world-io.bend as WI
import ../../../src/ecs/column.bend as Col
import ../../../src/ecs/component.bend as C
import ../../../src/ecs/ordinary-component-binding.bend as B
import ../../../src/ecs/ordinary-declaration.bend as D
import ../../../src/ecs/ordinary-query-observable.bend as O
import ../../../src/ecs/ordinary-query-declaration.bend as N
import ../../../src/ecs/compose.bend as Q
import ../../../src/ecs/inspector.bend as I
import ../../../src/ecs/capabilities.bend as Cap
import ../../../src/ecs/transaction.bend as T
import ../../../src/ecs/ordinary-app-component.bend as Comp
import ../../../src/ecs/ordinary-app-capture-query.bend as Capture
import ../../../src/ecs/ordinary-capture-query.bend as Owner
import ../../../src/ecs/local.bend as Local
import ../../../src/ecs/ordinary-app-composer.bend as Build
import ../../../src/ecs/ordinary-app-records.bend as Records
import ../../../src/ecs/ordinary-app-registration-fields.bend as Fields
import ../../../src/ecs/ordinary-app-execution-recipe.bend as Exec
import ../../../src/ecs/ordinary-app-run.bend as Entry
import ../../../src/ecs/ordinary-app-schedule.bend as Schedule
import ../../../src/ecs/ordinary-app-schema.bend as SchemaApp
import ../../../src/ecs/ordinary-app-execution.bend as Execution
import ../../../src/ecs/ordinary-schema.bend as Schema
import ../../../src/ecs/schema-fragments.bend as Fragment
import ../../../src/ecs/ordinary-app-observation-data.bend as DTO
import ../../../src/ecs/schedule-provision.bend as SP
import ../../../src/ecs/execution-context.bend as Ctx
import ../../../src/ecs/system.bend as Sys
import ../../../src/ecs/captured-schedule-composition.bend as Choice

type Garden is Data:
  Garden{}
type Plant is Data:
  Plant{height:U32}
def Store() -> Type: Col.Column<Garden,Plant>
def World() -> Type: W.World<Garden,Store,Unit,Unit>
def empty(_:Unit) -> Store: Col.empty(~Garden,~Plant)
def take(store:Store) -> Unit & Store: (Unit{},store)
def put(_:Unit,store:Store) -> Store: store
def view(plant:Plant) -> Plant & U32:
  match plant:
    case Plant{+height}:(Plant{height},height)
def identity() -> D.Declaration<Garden,Plant>: D.component(~Garden,~Plant,"Plant")
def binding() -> B.Binding<Garden,Store,Unit,Plant,U32,Unit,take,put,view>:
  B.bind(~Garden,~Store,~Unit,~Plant,~U32,~Unit,~take,~put,~view,identity)
def WaterOps(H:Type) -> Type: Cap.Write<H,Plant,U32>
def water_query() -> O.Declaration<Garden,Q.Frame<Garden,Store,Unit,Unit>,WaterOps(Q.Frame<Garden,Store,Unit,Unit>),I.Frame<Garden,Store,Unit,Unit>,C.Access<U32>>:
  O.write(~Garden,~Store,~Unit,~Plant,~U32,~Unit,~take,~put,~view,~Unit,~Unit,~binding)
def watered(~H:Type,~caps:WaterOps(H),enabled:Bool,result:H & C.Access<U32>) -> H & (T.Outcome<Unit> & U32):
  match enabled result:
    case True{}, (owner,C.Found{+height}):(Cap.set(~H,~Plant,~U32,~caps,owner,Plant{(height + 1 : U32)}),(T.Success{},(height + 1 : U32)))
    case False{}, (owner,C.Found{height}):(owner,(T.Success{},height))
    case _, (owner,_):(owner,(T.Failure{Unit{}},999))
def water(~H:Type,~caps:WaterOps(H),enabled:Bool,owner:H) -> H & (T.Outcome<Unit> & U32):
  watered(~H,~caps,enabled,Cap.get(~H,~Plant,~U32,~caps,owner))
def render(_:C.Access<U32>) -> String: "plant"
type Frost is Data:
  Frost{entered:U32}
type Memory is Type:
  Memory{entered:U32,total:Array<U32>,sealed:Unit -> U32}
def GrowthOps(H:Type) -> Type: Cap.Write<H,Plant,U32> & Unit
def write_cap(~H:Type,caps:GrowthOps(H)) -> Cap.Write<H,Plant,U32>:
  match caps:
    case (write,_):write
def growth_query() -> N.Declaration<Garden,Q.Frame<Garden,Store,Unit,Unit>,GrowthOps(Q.Frame<Garden,Store,Unit,Unit>)>:
  N.pair(~Garden,~Q.Frame<Garden,Store,Unit,Unit>,~Cap.Write<Q.Frame<Garden,Store,Unit,Unit>,Plant,U32>,~Unit,~N.write(~Garden,~Plant,~Store,~Unit,~Unit,~Unit,~U32,~Unit,~identity,~view,~take,~put),~N.changed(~Garden,~Plant,~Store,~Unit,~Unit,~Unit,~U32,~Unit,~identity,~view,~take,~put))
def growth_status(entered:U32) -> T.Outcome<Frost>:
  match entered:
    case 2:T.Failure{Frost{2}}
    case _:T.Success{}
def accumulated(~H:Type,~caps:GrowthOps(H),+height:U32,+entered:U32,sealed:Unit -> U32,owner:H,result:Array<U32> & U32) -> H & (Memory & (T.Outcome<Frost> & U32)):
  match result:
    case (total,sum):(Cap.set(~H,~Plant,~U32,~write_cap(~H,caps),owner,Plant{(height + 10 : U32)}),(Memory{entered,Array.set(U32,total,0,(sum + height : U32)),sealed},(growth_status(entered),(height + 10 : U32))))
def grow_seen(~H:Type,~caps:GrowthOps(H),memory:Memory,result:H & C.Access<U32>) -> H & (Memory & (T.Outcome<Frost> & U32)):
  match memory result:
    case Memory{entered,total,sealed}, (owner,C.Found{height}):accumulated(~H,~caps,height,(entered + 1 : U32),sealed,owner,Array.get(U32,total,0))
    case memory, (owner,_):(owner,(memory,(T.Failure{Frost{999}},999)))
def grow(~H:Type,~caps:GrowthOps(H),memory:Memory,_:Unit,owner:H) -> H & (Memory & (T.Outcome<Frost> & U32)):
  grow_seen(~H,~caps,memory,Cap.get(~H,~Plant,~U32,~write_cap(~H,caps),owner))
def AError() -> Data: Choice.Choice<Unit,Comp.ExecutionError<Unit>>
def AOwners() -> Type: Comp.execution_owners(~Garden,~Store,~Unit,~Unit,~Unit,~Unit,~Build.empty_observe(~World),~Records.empty(~Garden),~Unit,~Exec.empty_plan(~Garden),~Exec.empty_dispatch(~World),~Exec.empty_provide(~Garden,~World),~WaterOps,~Bool,~Unit,~U32,~C.Access<U32>,~water_query,~water,~render)
def ARows() -> Data: Comp.execution_rows(~Garden,~Store,~Unit,~Unit,~Unit,~Unit,~Build.empty_observe(~World),~Records.empty(~Garden),~Unit,~Exec.empty_plan(~Garden),~Exec.empty_dispatch(~World),~Exec.empty_provide(~Garden,~World),~WaterOps,~Bool,~Unit,~U32,~C.Access<U32>,~water_query,~water,~render)
def AObserve() -> World -> World & DTO.Observation<ARows>: Comp.execution_observe(~Garden,~Store,~Unit,~Unit,~Unit,~Unit,~Build.empty_observe(~World),~Records.empty(~Garden),~Unit,~Exec.empty_plan(~Garden),~Exec.empty_dispatch(~World),~Exec.empty_provide(~Garden,~World),~WaterOps,~Bool,~Unit,~U32,~C.Access<U32>,~water_query,~water,~render)
def AFold() -> AOwners -> AOwners & List<&2,Fields.Fields<Garden>>: Comp.execution_fold(~Garden,~Store,~Unit,~Unit,~Unit,~Unit,~Build.empty_observe(~World),~Records.empty(~Garden),~Unit,~Exec.empty_plan(~Garden),~Exec.empty_dispatch(~World),~Exec.empty_provide(~Garden,~World),~WaterOps,~Bool,~Unit,~U32,~C.Access<U32>,~water_query,~water,~render)
def APlan() -> AOwners -> AOwners & SP.Plan<Garden>: Comp.execution_plan(~Garden,~Store,~Unit,~Unit,~Unit,~Unit,~Build.empty_observe(~World),~Records.empty(~Garden),~Unit,~Exec.empty_plan(~Garden),~Exec.empty_dispatch(~World),~Exec.empty_provide(~Garden,~World),~WaterOps,~Bool,~Unit,~U32,~C.Access<U32>,~water_query,~water,~render)
def ADispatch() -> AOwners -> Ctx.Context<World> -> U32 -> AOwners & Sys.Outcome<Ctx.Context<World>,AError,Unit>: Comp.execution_dispatch(~Garden,~Store,~Unit,~Unit,~Unit,~Unit,~Build.empty_observe(~World),~Records.empty(~Garden),~Unit,~Exec.empty_plan(~Garden),~Exec.empty_dispatch(~World),~Exec.empty_provide(~Garden,~World),~WaterOps,~Bool,~Unit,~U32,~C.Access<U32>,~water_query,~water,~render)
def AProvide() -> World -> World & List<&2,SP.Requirement<Garden>>: Comp.execution_provide(~Garden,~Store,~Unit,~Unit,~Unit,~Unit,~Build.empty_observe(~World),~Records.empty(~Garden),~Unit,~Exec.empty_plan(~Garden),~Exec.empty_dispatch(~World),~Exec.empty_provide(~Garden,~World),~WaterOps,~Bool,~Unit,~U32,~C.Access<U32>,~water_query,~water,~render)
def ARegistered() -> Type: Comp.Application(~Garden,~Store,~Unit,~Unit,~Unit,~Unit,~Build.empty_observe(~World),~Records.empty(~Garden),~Unit,~Exec.empty_plan(~Garden),~Exec.empty_dispatch(~World),~Exec.empty_provide(~Garden,~World),~WaterOps,~Bool,~Unit,~U32,~C.Access<U32>,~water_query,~water,~render)
def GError() -> Data: Choice.Choice<AError,Capture.ExecutionError<Frost>>
def GOwners() -> Type: Capture.execution_owners(~Garden,~Store,~Unit,~Unit,~AOwners,~ARows,~AObserve,~AFold,~AError,~APlan,~ADispatch,~AProvide,~Memory,~GrowthOps,~Unit,~Frost,~U32,~growth_query,~grow)
def GRows() -> Data: Capture.execution_rows(~Garden,~Store,~Unit,~Unit,~AOwners,~ARows,~AObserve,~AFold,~AError,~APlan,~ADispatch,~AProvide,~Memory,~GrowthOps,~Unit,~Frost,~U32,~growth_query,~grow)
def GObserve() -> World -> World & DTO.Observation<GRows>: Capture.execution_observe(~Garden,~Store,~Unit,~Unit,~AOwners,~ARows,~AObserve,~AFold,~AError,~APlan,~ADispatch,~AProvide,~Memory,~GrowthOps,~Unit,~Frost,~U32,~growth_query,~grow)
def GFold() -> GOwners -> GOwners & List<&2,Fields.Fields<Garden>>: Capture.execution_fold(~Garden,~Store,~Unit,~Unit,~AOwners,~ARows,~AObserve,~AFold,~AError,~APlan,~ADispatch,~AProvide,~Memory,~GrowthOps,~Unit,~Frost,~U32,~growth_query,~grow)
def GPlan() -> GOwners -> GOwners & SP.Plan<Garden>: Capture.execution_plan(~Garden,~Store,~Unit,~Unit,~AOwners,~ARows,~AObserve,~AFold,~AError,~APlan,~ADispatch,~AProvide,~Memory,~GrowthOps,~Unit,~Frost,~U32,~growth_query,~grow)
def GDispatch() -> GOwners -> Ctx.Context<World> -> U32 -> GOwners & Sys.Outcome<Ctx.Context<World>,GError,Unit>: Capture.execution_dispatch(~Garden,~Store,~Unit,~Unit,~AOwners,~ARows,~AObserve,~AFold,~AError,~APlan,~ADispatch,~AProvide,~Memory,~GrowthOps,~Unit,~Frost,~U32,~growth_query,~grow)
def GProvide() -> World -> World & List<&2,SP.Requirement<Garden>>: Capture.execution_provide(~Garden,~Store,~Unit,~Unit,~AOwners,~ARows,~AObserve,~AFold,~AError,~APlan,~ADispatch,~AProvide,~Memory,~GrowthOps,~Unit,~Frost,~U32,~growth_query,~grow)
def GRegistered() -> Type: Capture.Application(~Garden,~Store,~Unit,~Unit,~AOwners,~ARows,~AObserve,~AFold,~AError,~APlan,~ADispatch,~AProvide,~Memory,~GrowthOps,~Unit,~Frost,~U32,~growth_query,~grow)
def GardenApp() -> Type: Entry.Application<Garden,Store,Unit,Unit,GOwners,GRows,GObserve,GFold,GError,GPlan,GDispatch,GProvide>
def Invocation() -> Type: Capture.Invocation(~Garden,~Store,~Unit,~Unit,~Memory,~GrowthOps,~Unit,~Frost,~U32,~growth_query,~grow)

def nums(values:List<&2,U32>) -> String:
  match values:
    case []:""
    case n <> rest:String.append(U32.show(n),String.append(",",nums(rest)))
def point(value:Maybe<&2,U32>) -> U32:
  match value:
    case Some{n}:n
    case None{}:999
def heights_join(value:U32,result:Store & List<&2,U32>) -> Store & List<&2,U32>:
  match result:
    case (store,tail):(store,value <> tail)
def heights_read(next:Store -> Store & List<&2,U32>,result:Store & Maybe<&2,U32>) -> Store & List<&2,U32>:
  match result:
    case (store,value):heights_join(point(value),next(store))
def heights(handles:List<&2,W.Handle<Garden>>,store:Store) -> Store & List<&2,U32>:
  match handles:
    case []:(store,[])
    case handle <> rest:heights_read(store=>heights(rest,store),Col.view(~Garden,~Plant,~U32,~view,store,W.handle_index(~Garden,handle)))
def projected(rebuild:Store -> World,result:Store & List<&2,U32>) -> World & List<&2,U32>:
  match result:
    case (store,values):(rebuild(store),values)
def world_values(handles:List<&2,W.Handle<Garden>>,world:World) -> World & List<&2,U32>:
  match world:
    case W.World{ns,allocator,store,r,e,p,regs,next,clock}:projected(store=>W.World{ns,allocator,store,r,e,p,regs,next,clock},heights(handles,store))
def got_handles(result:World & List<&2,W.Handle<Garden>>) -> World & List<&2,U32>:
  match result:
    case (world,handles):world_values(handles,world)
def report(world:World) -> World & List<&2,U32>: got_handles(W.handles(~Garden,~Store,~Unit,~Unit,world))
def with_water(owners:GOwners,enabled:Bool) -> GOwners:
  match owners:
    case ((base,Exec.Invocation{record,_,outputs}),growth):((base,Exec.Invocation{record,enabled,outputs}),growth)
def run_result(result:Execution.Run<GardenApp,Garden,GError>) -> GardenApp & U32:
  match result:
    case Execution.Run{Schedule.Finished{app,_},_}:(app,1)
    case Execution.Run{Schedule.Failed{app,Choice.RightError{Capture.CallbackFailure{Q.UserError{Frost{2}}}},_},_}:(app,2)
    case Execution.Run{Schedule.Failed{app,_,_},_}:(app,998)
    case Execution.Run{Schedule.Rejected{app},_}:(app,997)
    case Execution.Run{Schedule.Missing{app,_},_}:(app,996)

def memory_seen(rebuild:Memory -> GardenApp,status:U32,points:List<&2,U32>,water:List<&2,U32>,growth:List<&2,U32>,cursor:U32,+entered:U32,sealed:Unit -> U32,result:Array<U32> & U32) -> GardenApp & String:
  match result:
    case (total,+sum):(rebuild(Memory{entered,total,sealed}),String.append(nums([status,cursor,entered,sum]),String.append("|",String.append(nums(points),String.append("|",String.append(nums(water),String.append("|",nums(growth))))))))
def observe_owners(rebuild:GOwners -> GardenApp,status:U32,points:List<&2,U32>,owners:GOwners) -> GardenApp & String:
  match owners:
    case ((base,Exec.Invocation{waterRecord,waterArgs,+water}),Exec.Invocation{Records.Record{Owner.Owner{Local.Instance{ns,id,name,access,Memory{entered,total,sealed}},+cursor},fields},args,+growth}):
      memory_seen(memory=>rebuild(((base,Exec.Invocation{waterRecord,waterArgs,water}),Exec.Invocation{Records.Record{Owner.Owner{Local.Instance{ns,id,name,access,memory},cursor},fields},args,growth})),status,points,water,growth,cursor,entered,sealed,Array.get(U32,total,0))
def observe_values(status:U32,result:GardenApp & List<&2,U32>) -> GardenApp & String:
  match result:
    case (Entry.Application{Schedule.Application{SchemaApp.Application{schema,Build.Registered{world,owners,recipe,debug}},selected,ns,name,steps,needs},execution},points):
      observe_owners(owners=>Entry.Application{Schedule.Application{SchemaApp.Application{schema,Build.Registered{world,owners,recipe,debug}},selected,ns,name,steps,needs},execution},status,points,owners)
def observe(result:GardenApp & U32) -> GardenApp & String:
  match result:
    case (app,status):observe_values(status,Entry.inspect(~Garden,~Store,~Unit,~Unit,~GOwners,~GRows,~GObserve,~GFold,~GError,~GPlan,~GDispatch,~GProvide,~List<&2,U32>,~report,app))

def finish(owners:GOwners) -> U32:
  match owners:
    case (_,Exec.Invocation{Records.Record{Owner.Owner{Local.Instance{_,_,_,_,Memory{_,_,sealed}},_},_},_,_}):sealed(Unit{})
def finish_app(app:GardenApp) -> U32:
  match app:
    case Entry.Application{Schedule.Application{SchemaApp.Application{_,Build.Registered{_,owners,_,_}},_,_,_,_,_},_}:finish(owners)
def joined(prefix:String,result:GardenApp & String) -> String:
  match result:
    case (app,row):String.append(prefix,String.append(row,String.append("\nsealed=",U32.show(finish_app(app)))))
def fourth(prefix:String,result:GardenApp & String) -> String:
  match result:
    case (app,row):joined(String.append(prefix,String.append(row,"\n")),observe(run_result(Entry.run(~Garden,~Store,~Unit,~Unit,~GOwners,~GRows,~GObserve,~GFold,~GError,~GPlan,~GDispatch,~GProvide,Entry.update_owners(~Garden,~Store,~Unit,~Unit,~GOwners,~GRows,~GObserve,~GFold,~GError,~GPlan,~GDispatch,~GProvide,~Bool,~with_water,app,True{})))))
def third(prefix:String,result:GardenApp & String) -> String:
  match result:
    case (app,row):fourth(String.append(prefix,String.append(row,"\n")),observe(run_result(Entry.run(~Garden,~Store,~Unit,~Unit,~GOwners,~GRows,~GObserve,~GFold,~GError,~GPlan,~GDispatch,~GProvide,Entry.update_owners(~Garden,~Store,~Unit,~Unit,~GOwners,~GRows,~GObserve,~GFold,~GError,~GPlan,~GDispatch,~GProvide,~Bool,~with_water,app,False{})))))
def second(result:GardenApp & String) -> String:
  match result:
    case (app,row):third(String.append(row,"\n"),observe(run_result(Entry.run(~Garden,~Store,~Unit,~Unit,~GOwners,~GRows,~GObserve,~GFold,~GError,~GPlan,~GDispatch,~GProvide,app))))
def attached(result:Schedule.Attachment<GRegistered,GardenApp>) -> String:
  match result:
    case Schedule.Attached{app}:second(observe(run_result(Entry.run(~Garden,~Store,~Unit,~Unit,~GOwners,~GRows,~GObserve,~GFold,~GError,~GPlan,~GDispatch,~GProvide,app))))
    case _:"attachment failed"
def schema() -> Schema.Schema<Garden,Store,Unit>: Schema.Schema{[Fragment.Entry{Fragment.Component{},"Plant","Plant"}]}
def attach(app:GRegistered) -> String: attached(Entry.attach(~Garden,~Store,~Unit,~Unit,~GOwners,~GRows,~GObserve,~GFold,~GError,~GPlan,~GDispatch,~GProvide,schema,app,"Greenhouse",False{}))
def sealed_value(result:Array<U32> & U32) -> U32:
  match result:
    case (_,value):value
def seal(array:Array<U32>) -> Unit -> U32: _=>sealed_value(Array.get(U32,array,0))
def add_growth(app:ARegistered) -> String:
  Capture.add(~Garden,~Store,~Unit,~Unit,~AOwners,~ARows,~AObserve,~AFold,~AError,~APlan,~ADispatch,~AProvide,~Memory,~GrowthOps,~Unit,~Frost,~U32,~growth_query,~grow,~String,attach,_=>_=>"capture rejected",app,Unit{},"grow",Memory{0,[0:U32*1n],seal([77:U32*1n])})
def register(world:World) -> String:
  Comp.add(~Garden,~Store,~Unit,~Unit,~Unit,~Unit,~Build.empty_observe(~World),~Records.empty(~Garden),~Unit,~Exec.empty_plan(~Garden),~Exec.empty_dispatch(~World),~Exec.empty_provide(~Garden,~World),~WaterOps,~Bool,~Unit,~U32,~C.Access<U32>,~water_query,~water,~render,~String,add_growth,_=>"water rejected",Exec.empty(~Garden,~World,world),True{},"water","garden")

def replaced(result:C.Replacement<World,Plant>) -> World:
  match result:
    case C.Replaced{world,_}:world
    case C.ReplaceRejected{world,_,_}:world
def spawned(height:U32,result:World & W.Reservation<Garden>) -> World:
  match result:
    case (world,W.Reserved{+handle}):replaced(C.replace(~Garden,~Store,~Unit,~Unit,~Unit,~Plant,~U32,~Unit,~take,~put,~view,B.family(~Garden,~Store,~Unit,~Plant,~U32,~Unit,~take,~put,~view,binding),W.discard_status(~Garden,~Store,~Unit,~Unit,W.activate(~Garden,~Store,~Unit,~Unit,world,handle)),handle,Some{Plant{height}}))
    case (world,_):world
def spawn(world:World,height:U32) -> World: spawned(height,W.reserve_id(~Garden,~Store,~Unit,~Unit,world))
def created(result:WI.Creation<Garden,Store,Unit,Unit>) -> IO(Unit):
  match result:
    case WI.Created{world}:IO.print(register(spawn(spawn(world,10),20)))
    case _:IO.die(Unit,1,"world creation failed")
def main() -> IO(Unit): IO.bind(WI.Creation<Garden,Store,Unit,Unit>,Unit,WI.create(~Garden,~Store,~Unit,~Unit,~empty,Unit{}),created)
