import Base
import ../../../../src/ecs/ordinary-app-schedule.bend as Single
import ../../../../src/ecs/ordinary-app-schema.bend as SchemaApp
import ../../../../src/ecs/world-resource-owner.bend as WR
import ../../../../src/ecs/commands.bend as Cmd
import ../../../../src/ecs/execution-trace.bend as Trace
import ../../../../src/ecs/checked-condition-schedule.bend as Engine
import ../../../../src/ecs/ordinary-app-checked-family-schedule.bend as Checked
import ../../../../src/ecs/ordinary-app-checked-schedule.bend as Check
import ../../../../src/ecs/ordinary-checked-condition.bend as Cond
import ../../../../src/ecs/ordinary-checked-bindings.bend as B
import ../../../../src/ecs/schedule-provision.bend as SP
import ../../../../src/ecs/schedule.bend as Sch
import ../../../../src/ecs/ordinary-app-observation-data.bend as DTO
import ../../../../src/ecs/ordinary-app-recipe.bend as Tree
import ../../../../src/ecs/ordinary-schema.bend as Schema
import ../../../../src/ecs/ordinary-app-registration-fields.bend as Records
import ../../../../src/ecs/ordinary-app-composer.bend as Build
import ../../../../src/ecs/ordinary-app-records.bend as Leaf
import ../../../../src/ecs/schema-fragments.bend as Fragment
import ../../../../src/ecs/ordinary-app-execution.bend as Execution

import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/transaction.bend as T
import ../../../../src/ecs/capabilities.bend as Cap
import ../../../../src/ecs/owner-product.bend as Product
import ../../../../src/ecs/owned-event-log.bend as Log
import ../../../../src/ecs/ordinary-owned-event.bend as Pub
import ../../../../src/ecs/ordinary-owned-event-binding.bend as Binding
import ../../../../src/ecs/owned-event-key-route.bend as Key
import ../../../../src/ecs/ordinary-owned-event-family-reader-binding.bend as Setup
import ../../../../src/ecs/ordinary-event-family.bend as Family
import ../../../../src/ecs/ordinary-event-declaration.bend as Event
import ../../../../src/ecs/event-stream.bend as Stream
import ../../../../src/ecs/event-family-runtime.bend as FR
import ../../../../src/ecs/event-family-routing.bend as Route
import ../../../../src/ecs/ordinary-owned-event-family-reader.bend as O
import ../../../../src/ecs/owned-event-family-reader-runtime.bend as Core
import ../../../../src/ecs/ordinary-app-event-family-reader.bend as AppReader
import ../../../../src/ecs/ordinary-app-event-family-runtime.bend as App
import ../../../../src/ecs/system.bend as Sys
import ../../../../src/ecs/execution-context.bend as Ctx
import ../../../../src/ecs/event-runtime.bend as Ev

type Workshop is Data:Workshop{}
type Garden is Data:Garden{}
type Args is Type:Args{scratch:Array<U32>,values:List<&2,U32>,fail:Bool}
def resources() -> Log.Log<Array<U32>>:Log.empty(~Array<U32>)
def empty(~S:Data) -> Unit:Unit{}
def World(~S:Data) -> Type:W.World<S,Unit,Log.Log<Array<U32>>,Nat>
def identity(~S:Data) -> Pub.Domain<S,Array<U32>>:Pub.domain(~S,~Array<U32>,"Cargo")
def path() -> Product.Lens<Log.Log<Array<U32>>,Log.Log<Array<U32>>,Unit>:Binding.identity_lens(~Log.Log<Array<U32>>)
def FStream(~S:Data) -> Data:Stream.Stream<S,Nat>
def State(~S:Data) -> Type:FR.State<Nat,FStream(~S),Unit>
def Runtime(~S:Data) -> Type:Route.Runtime<S,Unit,Log.Log<Array<U32>>,Nat,State(~S)>
def take(~S:Data) -> State(~S) -> State(~S) & Stream.Stream<S,Nat>:FR.take(~S,~Nat,~Nat,~FStream(~S),~Unit,~Family.selected_leaf(~S,~Nat))
def put(~S:Data) -> State(~S) -> Stream.Stream<S,Nat> -> State(~S):FR.put(~S,~Nat,~Nat,~FStream(~S),~Unit,~Family.replaced_leaf(~S,~Nat))
def at(payload:Array<U32>,request:Unit) -> Array<U32> & U32:Array.get(U32,payload,0)
def outcome(fail:Bool) -> T.Outcome<String>:
  match fail:
    case False{}:T.Success{}
    case True{}:T.Failure{"reader-body-failed"}
def read_returned(~H:Type,scratch:Array<U32>,values:List<&2,U32>,+fail:Bool,result:H & U32) -> H & (T.Outcome<String> & Args):
  match result:
    case (owner,value):(owner,(outcome(fail),Args{scratch,List.append(&2,U32,values,[value]),fail}))
def body(~H:Type,~read:Cap.Request<H,Unit,U32>,owner:H,args:Args) -> H & (T.Outcome<String> & Args):
  match args:
    case Args{scratch,values,fail}:read_returned(~H,scratch,values,fail,Cap.request(~H,~Unit,~U32,~read,owner,Unit{}))
def runner(~S:Data) -> World(~S) -> Ev.Input<Nat,Args> -> Sys.Outcome<World(~S),Unit,Core.Reply<String,Args>>:Core.runner(~S,~Unit,~Log.Log<Array<U32>>,~Array<U32>,~Unit,~Nat,~path(),~Unit,~U32,~Args,~String,~at,~body)
def Reader(~S:Data) -> Type:Route.Reader<S,Nat,State(~S),take(~S),put(~S)>
def Registry(~S:Data) -> Type:Sys.Registry<S,Unit,Log.Log<Array<U32>>,Nat,Ev.Input<Nat,Args>,Unit,Core.Reply<String,Args>,runner(~S)>
def Owner(~S:Data) -> Type:AppReader.Owner<S,Nat,Reader(~S),Registry(~S)>
def family(~S:Data,world:World(~S)) -> Runtime(~S):O.setup(~S,~Unit,~Log.Log<Array<U32>>,~Array<U32>,~Unit,~Nat,~Event.Domain<S,Nat>,~FStream(~S),~path(),~Key.inject_leaf,~Key.select_leaf,~identity(~S),~Family.leaf_make(~S,~Nat),~Family.leaf_sync(~S,~Nat),~Family.leaf_frame(~S,~Nat),~Family.leaf_retain(~S,~Nat),~Family.leaf_inventory(~S,~Nat),~Family.selected_leaf(~S,~Nat),~Family.replaced_leaf(~S,~Nat),~Unit,Setup.leaf(~S,~Array<U32>,~identity(~S)),world,Unit{},1n)
def register(~S:Data,runtime:Runtime(~S)) -> AppReader.Registration<S,Unit,Log.Log<Array<U32>>,Nat,Nat,State(~S),Args,Unit,Core.Reply<String,Args>,take(~S),put(~S),runner(~S)>:O.register_app(~S,~Unit,~Log.Log<Array<U32>>,~Array<U32>,~Unit,~Nat,~Event.Domain<S,Nat>,~FStream(~S),~path(),~Key.inject_leaf,~Key.select_leaf,~identity(~S),~Family.leaf_make(~S,~Nat),~Family.leaf_sync(~S,~Nat),~Family.leaf_frame(~S,~Nat),~Family.leaf_retain(~S,~Nat),~Family.leaf_inventory(~S,~Nat),~Family.selected_leaf(~S,~Nat),~Family.replaced_leaf(~S,~Nat),~Setup.leaf(~S,~Array<U32>,~identity(~S)),~Unit,~Unit,~U32,~Args,~String,~at,~body,runtime,"owned-reader")
def read(~S:Data,context:Ctx.Context<World(~S)>,state:State(~S),tick:Nat,reader:Reader(~S),registry:Registry(~S),args:Args) -> Route.ContextRunResult<S,Unit,Log.Log<Array<U32>>,Nat,Nat,State(~S),Args,Unit,Core.Reply<String,Args>,take(~S),put(~S),runner(~S)>:O.run_context(~S,~Unit,~Log.Log<Array<U32>>,~Array<U32>,~Unit,~Nat,~Event.Domain<S,Nat>,~FStream(~S),~path(),~Key.inject_leaf,~Key.select_leaf,~identity(~S),~Family.leaf_make(~S,~Nat),~Family.leaf_sync(~S,~Nat),~Family.leaf_frame(~S,~Nat),~Family.leaf_retain(~S,~Nat),~Family.leaf_inventory(~S,~Nat),~Family.selected_leaf(~S,~Nat),~Family.replaced_leaf(~S,~Nat),~Setup.leaf(~S,~Array<U32>,~identity(~S)),~Unit,~Unit,~U32,~Args,~String,~at,~body,context,state,tick,reader,registry,args)

type Held is Type:
  Held{args:Args,status:T.Outcome<Core.Failure<String>>,lagged:Bool}
  NoArgs{}
def held() -> Held:Held{Args{ANode{ALeaf{600},ALeaf{601}},[],False{}},T.Success{},False{}}
def observe(~S:Data,world:World(~S)) -> World(~S) & DTO.Observation<Unit>:(world,DTO.Observation{Unit{},[]})
def fold_held(~S:Data,owner:Held) -> Held & List<&2,Records.Fields<S>>:(owner,[])
def Before(~S:Data) -> Type:App.Application<S,Unit,Log.Log<Array<U32>>,Nat,State(~S),Held,Unit,observe(~S),fold_held(~S)>
def Owners(~S:Data) -> Type:Held & Owner(~S)
def Rows() -> Data:DTO.Product<Unit,Unit>
def observation(~S:Data) -> World(~S) -> World(~S) & DTO.Observation<Rows()>:Tree.observe_pair(~World(~S),~Unit,~Unit,~observe(~S),~AppReader.observe(~S,~Unit,~Log.Log<Array<U32>>,~Nat))
def reader_fields(~S:Data) -> Owner(~S) -> Owner(~S) & List<&2,Records.Fields<S>>:AppReader.fields(~S,~Unit,~Log.Log<Array<U32>>,~Nat,~Nat,~Reader(~S),~Args,~Unit,~Core.Reply<String,Args>,~runner(~S))
def fold(~S:Data) -> Owners(~S) -> Owners(~S) & List<&2,Records.Fields<S>>:Leaf.fold_pair(~S,~Held,~Owner(~S),~fold_held(~S),~reader_fields(~S))
def Unscheduled(~S:Data) -> Type:App.Application<S,Unit,Log.Log<Array<U32>>,Nat,State(~S),Owners(~S),Rows(),observation(~S),fold(~S)>
def Guard(~S:Data) -> Type:B.BoundOwner<Bool>
def select(~S:Data) -> Guard(~S) -> World(~S) -> U32 -> B.Selection<World(~S),Guard(~S)>:B.select(~World(~S),~Bool,~Cond.constant_run(~World(~S)))
def Application(~S:Data) -> Type:Checked.Application<S,Unit,Log.Log<Array<U32>>,Nat,State(~S),Owners(~S),Rows(),observation(~S),fold(~S),Guard(~S),select(~S)>
def schema(~S:Data) -> Schema.Schema<S,Unit,Log.Log<Array<U32>>>:Schema.Schema{[Fragment.Entry{Fragment.Event{},Pub.name(~S,~Array<U32>,identity(~S)),Pub.name(~S,~Array<U32>,identity(~S))}]}
def before(~S:Data,result:Runtime(~S)) -> Before(~S):
  match result:
    case Route.Runtime{world,family,tick}:App.Application{schema(~S),Route.Runtime{world,family,tick},held(),Tree.Recipe{},False{}}
type SetupResult<S:Data> is Type:
  Ready{app:Application(~S)}
  RegistrationRejected{app:Before(~S)}
  ScheduleRejected{app:Unscheduled(~S),bindings:B.Bindings<World(~S),Guard(~S),select(~S)>}
def attached(~S:Data,result:Checked.Attachment<Unscheduled(~S),B.Bindings<World(~S),Guard(~S),select(~S)>,Application(~S)>) -> SetupResult<S>:
  match result:
    case Checked.Attached{app}:Ready{app}
    case Checked.Invalid{app,bindings}:ScheduleRejected{app,bindings}
def planned(~S:Data,steps:List<&2,Sch.Step>) -> SP.Plan<S>:
  match steps:
    case []:SP.Empty{}
    case step <> rest:SP.Sequence{SP.Entry{step,[]},planned(~S,rest)}
def plan(~S:Data) -> SP.Plan<S>:planned(~S,[Sch.Phase{"reader"},Sch.System{1,0},Sch.Barrier{}])
def installed(~S:Data,app:Unscheduled(~S)) -> SetupResult<S>:
  attached(~S,Checked.attach(~S,~Unit,~Log.Log<Array<U32>>,~Nat,~State(~S),~Owners(~S),~Rows(),~observation(~S),~fold(~S),~Guard(~S),~select(~S),app,"checked-owned-reader",plan(~S),B.bind(~World(~S),~Bool,~Cond.constant_run(~World(~S)),1,Cond.constant(~World(~S),False{}))))
def registration_failed(~S:Data,app:Before(~S)) -> SetupResult<S>:RegistrationRejected{app}
def clock_advanced(~S:Data,value:World(~S) & U32) -> World(~S):
  match value:
    case (world,_):world
def advance(~S:Data,world:World(~S)) -> World(~S):clock_advanced(~S,W.advance_clock(~S,~Unit,~Log.Log<Array<U32>>,~Nat,world))
def setup(~S:Data,world:World(~S)) -> SetupResult<S>:O.install(~S,~Unit,~Log.Log<Array<U32>>,~Array<U32>,~Unit,~Nat,~Event.Domain<S,Nat>,~FStream(~S),~path(),~Key.inject_leaf,~Key.select_leaf,~identity(~S),~Family.leaf_make(~S,~Nat),~Family.leaf_sync(~S,~Nat),~Family.leaf_frame(~S,~Nat),~Family.leaf_retain(~S,~Nat),~Family.leaf_inventory(~S,~Nat),~Family.selected_leaf(~S,~Nat),~Family.replaced_leaf(~S,~Nat),~Setup.leaf(~S,~Array<U32>,~identity(~S)),~Unit,~Unit,~U32,~Args,~String,~at,~body,~Held,~Unit,~observe(~S),~fold_held(~S),~SetupResult<S>,installed(~S),registration_failed(~S),before(~S,family(~S,W.enqueue(~S,~Unit,~Log.Log<Array<U32>>,~Nat,world,advance(~S)))),"owned-reader")

def completed(~S:Data,declaration:Event.Declaration<S,Nat>,value:Route.ContextRunResult<S,Unit,Log.Log<Array<U32>>,Nat,Nat,State(~S),Args,Unit,Core.Reply<String,Args>,take(~S),put(~S),runner(~S)>) -> (Owners(~S) & (State(~S) & Nat)) & Sys.Outcome<Ctx.Context<World(~S)>,String,Unit>:
  match value:
    case Route.ContextRan{context,family,tick,reader,registry,Ev.Succeeded{Core.Reply{status,args,lagged}}}:(((Held{args,status,lagged},AppReader.Owner{declaration,reader,registry}),(family,tick)),Sys.Succeeded{context,Unit{}})
    case Route.ContextRan{context,family,tick,reader,registry,Ev.Rejected{args}}:(((Held{args,T.Success{},False{}},AppReader.Owner{declaration,reader,registry}),(family,tick)),Sys.Failed{context,"reader-registration-rejected"})
    case Route.ContextRan{context,family,tick,reader,registry,Ev.Failed{_}}:(((NoArgs{},AppReader.Owner{declaration,reader,registry}),(family,tick)),Sys.Failed{context,"reader-transport-failed"})
def dispatch(~S:Data,owners:Owners(~S) & (State(~S) & Nat),context:Ctx.Context<World(~S)>,id:U32) -> (Owners(~S) & (State(~S) & Nat)) & Sys.Outcome<Ctx.Context<World(~S)>,String,Unit>:
  match owners:
    case ((Held{args,_,_},AppReader.Owner{declaration,reader,registry}),(family,tick)):completed(~S,declaration,read(~S,context,family,tick,reader,registry,args))
    case owners:(owners,Sys.Failed{context,"no-reader-args"})
def provision(~S:Data,world:World(~S)) -> World(~S) & List<&2,SP.Requirement<S>>:(world,[])
def run(~S:Data,app:Application(~S)) -> Execution.Run<Application(~S),S,Engine.Error<String>>:Checked.run(~S,~Unit,~Log.Log<Array<U32>>,~Nat,~State(~S),~Owners(~S),~Rows(),~observation(~S),~fold(~S),~Guard(~S),~select(~S),~String,~dispatch(~S),~provision(~S),app)

type RunStatus<S:Data> is Data:
  Finished{observations:List<&2,Sch.Observation>}
  Failed{error:Engine.Error<String>,observations:List<&2,Sch.Observation>}
  Rejected{}
  Missing{requirements:List<&2,SP.Requirement<S>>}
def resumed(~S:Data,batch:Trace.Batch<Engine.Error<String>>,value:Single.RunResult<Application(~S),S,Engine.Error<String>>) -> Application(~S) & (RunStatus<S> & Trace.Batch<Engine.Error<String>>):
  match value:
    case Single.Finished{app,observations}:(app,(Finished{observations},batch))
    case Single.Failed{app,error,observations}:(app,(Failed{error,observations},batch))
    case Single.Rejected{app}:(app,(Rejected{},batch))
    case Single.Missing{app,requirements}:(app,(Missing{requirements},batch))
def resume(~S:Data,value:Execution.Run<Application(~S),S,Engine.Error<String>>) -> Application(~S) & (RunStatus<S> & Trace.Batch<Engine.Error<String>>):
  match value:
    case Execution.Run{result,batch}:resumed(~S,batch,result)
type Collector is Type:Collector{calls:Nat,events:List<&2,Trace.TraceEvent<Engine.Error<String>>>,owned:Array<U32>}
def collector(first:U32,second:U32) -> Collector:Collector{0n,[],ANode{ALeaf{first},ALeaf{second}}}
def collected(+event:Trace.TraceEvent<Engine.Error<String>>,calls:Nat,events:List<&2,Trace.TraceEvent<Engine.Error<String>>>,result:Array<U32> & U32) -> Collector:
  match result:
    case (owner,value):Collector{1n+calls,List.append(&2,Trace.TraceEvent<Engine.Error<String>>,events,[event]),Array.set(U32,owner,0,U32.add(value,1))}
def step(owner:Collector,event:Trace.TraceEvent<Engine.Error<String>>) -> Collector:
  match owner:
    case Collector{calls,events,owned}:collected(event,calls,events,Array.get(U32,owned,0))
def Subscriber() -> Type:Trace.Subscriber<Collector,Engine.Error<String>,step>
def runtime_returned(~S:Data,~Out:Type,schema:Schema.Schema<S,Unit,Log.Log<Array<U32>>>,owners:Owners(~S),recipe:Tree.Recipe<World(~S),Rows(),observation(~S)>,debug:Bool,plan:SP.Plan<S>,namespace:U32,name:String,steps:List<&2,Sch.Step>,needs:List<&2,SP.Requirement<S>>,bindings:B.Bindings<World(~S),Guard(~S),select(~S)>,result:Runtime(~S) & Out) -> Application(~S) & Out:
  match result:
    case (Route.Runtime{world,family,tick},out):(Checked.Application{Check.Application{Single.Application{SchemaApp.Application{schema,Build.Registered{world,(owners,(family,tick)),recipe,debug}},plan,namespace,name,steps,needs},bindings}},out)
def with_runtime(~S:Data,~Out:Type,app:Application(~S),action:Runtime(~S) -> Runtime(~S) & Out) -> Application(~S) & Out:
  match app:
    case Checked.Application{Check.Application{Single.Application{SchemaApp.Application{schema,Build.Registered{world,(owners,(family,tick)),recipe,debug}},plan,namespace,name,steps,needs},bindings}}:runtime_returned(~S,~Out,schema,owners,recipe,debug,plan,namespace,name,steps,needs,bindings,action(Route.Runtime{world,family,tick}))
def appended(~S:Data,rest:WR.Rest<S,Unit,Log.Log<Array<U32>>,Nat>,result:Log.Log<Array<U32>> & Nat) -> World(~S) & Nat:
  match result:
    case (log,+id):(Cmd.publish(~S,~Unit,~Log.Log<Array<U32>>,~Nat,WR.put(~S,~Unit,~Log.Log<Array<U32>>,~Nat,rest,log),[id]),id)
def resource_taken(~S:Data,payload:Array<U32>,result:WR.Rest<S,Unit,Log.Log<Array<U32>>,Nat> & Log.Log<Array<U32>>) -> World(~S) & Nat:
  match result:
    case (rest,log):appended(~S,rest,Log.append(~Array<U32>,log,payload))
def append(~S:Data,world:World(~S),payload:Array<U32>) -> World(~S) & Nat:resource_taken(~S,payload,WR.take(~S,~Unit,~Log.Log<Array<U32>>,~Nat,world))
def publish(~S:Data,app:Application(~S),payload:Array<U32>) -> Application(~S) & Nat:with_runtime(~S,~Nat,app,runtime => O.with_world(~S,~Unit,~Log.Log<Array<U32>>,~Array<U32>,~Unit,~Nat,~Event.Domain<S,Nat>,~FStream(~S),~path(),~Key.inject_leaf,~Key.select_leaf,~identity(~S),~Family.leaf_make(~S,~Nat),~Family.leaf_sync(~S,~Nat),~Family.leaf_frame(~S,~Nat),~Family.leaf_retain(~S,~Nat),~Family.leaf_inventory(~S,~Nat),~Family.selected_leaf(~S,~Nat),~Family.replaced_leaf(~S,~Nat),~Setup.leaf(~S,~Array<U32>,~identity(~S)),~Unit,~Nat,(world => append(~S,world,payload)),runtime))
def framed(~S:Data,runtime:Runtime(~S)) -> Runtime(~S) & Unit:(FR.frame(~S,~Unit,~Log.Log<Array<U32>>,~Nat,~FStream(~S),~Unit,~Family.leaf_frame(~S,~Nat),~Family.leaf_retain(~S,~Nat),runtime),Unit{})
def frame(~S:Data,app:Application(~S)) -> Application(~S) & Unit:with_runtime(~S,~Unit,app,framed(~S))
def guard(~S:Data,app:Application(~S),flag:Bool) -> Application(~S):
  match app:
    case Checked.Application{Check.Application{app,B.Bindings{B.BoundOwner{id,_},_}}}:Checked.Application{Check.Application{app,B.bind(~World(~S),~Bool,~Cond.constant_run(~World(~S)),id,Cond.constant(~World(~S),flag))}}
def held_flag(held:Held,flag:Bool) -> Held:
  match held:
    case Held{Args{scratch,values,_},status,lagged}:Held{Args{scratch,values,flag},status,lagged}
    case NoArgs{}:NoArgs{}
def failure(~S:Data,app:Application(~S),flag:Bool) -> Application(~S):
  match app:
    case Checked.Application{Check.Application{Single.Application{SchemaApp.Application{schema,Build.Registered{world,((held,reader),rest),recipe,debug}},plan,namespace,name,steps,needs},bindings}}:Checked.Application{Check.Application{Single.Application{SchemaApp.Application{schema,Build.Registered{world,((held_flag(held,flag),reader),rest),recipe,debug}},plan,namespace,name,steps,needs},bindings}}
def enabled(~S:Data,app:Application(~S),flag:Bool) -> Application(~S):Checked.enabled(~S,~Unit,~Log.Log<Array<U32>>,~Nat,~State(~S),~Owners(~S),~Rows(),~observation(~S),~fold(~S),~Guard(~S),~select(~S),app,flag)
def snapshot(~S:Data,app:Application(~S)) -> Application(~S) & Maybe<&2,Check.Description<S,Rows()>>:Checked.snapshot(~S,~Unit,~Log.Log<Array<U32>>,~Nat,~State(~S),~Owners(~S),~Rows(),~observation(~S),~fold(~S),~Guard(~S),~select(~S),app)
