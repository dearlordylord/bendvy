import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-optional-resource.bend as Slot
import /workspace/formal-proofs/bendvy/experiments/public-conditions/component-query-v1/fixture.bend as Source
import /workspace/formal-proofs/bendvy/experiments/public-conditions/component-query-v1/schema.bend as Model
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev
import /workspace/formal-proofs/bendvy/src/ecs/event-stream.bend as Stream
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-event-declaration.bend as Event
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-event-family.bend as Family
import /workspace/formal-proofs/bendvy/src/ecs/event-family-routing.bend as Route
import /workspace/formal-proofs/bendvy/src/ecs/owner-product.bend as Product
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-event-family-reader.bend as Reader
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-event-family-runtime.bend as App
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schema.bend as SchemaApp
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/resource-field-binding.bend as Binding
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-records.bend as Leaf
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-recipe.bend as Tree
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-registration-fields.bend as Records
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-check-declaration.bend as CD
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-checked-condition.bend as Cond
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-checked-bindings.bend as B
import /workspace/formal-proofs/bendvy/src/ecs/check.bend as K
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as SP
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schedule.bend as Single
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-checked-schedule.bend as Old
import /workspace/formal-proofs/bendvy/src/ecs/checked-condition-schedule.bend as Error
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import ./ordinary-app-checked-family-schedule.bend as Checked

def Resources(~S:Data) -> Type:Source.Resources(~S)
def World(~S:Data) -> Type:W.World<S,Array<U32>,Resources(~S),U32>
type Callback is Type:Callback{owned:Array<U32>,reading:Ev.Reading<U32>}
type Receipt is Type:Receipt{reader:U32,completion:Ev.Completion<Unit,Callback,Unit>}
type Held is Type:Held{owned:Array<U32>,receipts:List<Receipt>,syncCalls:U32}
def FamilyState(~S:Data) -> Type:Product.Owner<Stream.Stream<S,U32>,Held>
def take(~S:Data) -> FamilyState(~S) -> FamilyState(~S) & Stream.Stream<S,U32>:Family.left_take(~S,~U32,~Stream.Stream<S,U32>,~Held,~Family.selected_leaf(~S,~U32))
def put(~S:Data) -> FamilyState(~S) -> Stream.Stream<S,U32> -> FamilyState(~S):Family.left_put(~S,~U32,~Stream.Stream<S,U32>,~Held,~Family.replaced_leaf(~S,~U32))
def domain(~S:Data) -> Event.Domain<S,U32>:Event.domain(~S,~U32,"Signal")
def body(value:Ev.Input<U32,Unit>) -> Callback:
  match value:
    case Ev.Input{values,lagged,_}:Callback{ANode{ALeaf{70},ALeaf{71}},Ev.Reading{values,lagged}}
# Trusted transport only: gameplay body receives the typed input, never World.
def runner(~S:Data,world:World(~S),input:Ev.Input<U32,Unit>) -> Sys.Outcome<World(~S),Unit,Callback>:Sys.Succeeded{world,body(input)}
def sync_held(worldCount:U32,value:Held) -> Held:
  match value:
    case Held{owned,receipts,count}:Held{owned,receipts,(count+1:U32)}
def synchronize(~S:Data,world:World(~S),family:FamilyState(~S),tick:Nat) -> World(~S) & FamilyState(~S):
  match family:
    case Product.Owner{stream,held}:(world,Product.Owner{stream,sync_held(0,held)})
def Owner(~S:Data) -> Type:Reader.OwnerType(~S,~Array<U32>,~Resources(~S),~U32,~U32,~FamilyState(~S),~Unit,~Unit,~Callback,~take(~S),~put(~S),~runner(~S))
def Owner1(~S:Data) -> Type:Unit & Owner(~S)
def Owners(~S:Data) -> Type:Owner1(~S) & Owner(~S)
def Rows1() -> Data:DTO.Product<Unit,Unit>
def Rows() -> Data:DTO.Product<Rows1(),Unit>
def observe1(~S:Data) -> World(~S) -> World(~S) & DTO.Observation<Rows1()>:Tree.observe_pair(~World(~S),~Unit,~Unit,~Build.empty_observe(~World(~S)),~Reader.observe(~S,~Array<U32>,~Resources(~S),~U32))
def observe(~S:Data) -> World(~S) -> World(~S) & DTO.Observation<Rows()>:Tree.observe_pair(~World(~S),~Rows1(),~Unit,~observe1(~S),~Reader.observe(~S,~Array<U32>,~Resources(~S),~U32))
def owner_fields(~S:Data) -> Owner(~S) -> Owner(~S) & List<&2,Records.Fields<S>>:Reader.fields(~S,~Array<U32>,~Resources(~S),~U32,~U32,~Route.Reader<S,U32,FamilyState(~S),take(~S),put(~S)>,~Unit,~Unit,~Callback,~runner(~S))
def fold1(~S:Data) -> Owner1(~S) -> Owner1(~S) & List<&2,Records.Fields<S>>:Leaf.fold_pair(~S,~Unit,~Owner(~S),~Leaf.empty(~S),~owner_fields(~S))
def fold(~S:Data) -> Owners(~S) -> Owners(~S) & List<&2,Records.Fields<S>>:Leaf.fold_pair(~S,~Owner1(~S),~Owner(~S),~fold1(~S),~owner_fields(~S))
def Before(~S:Data) -> Type:App.Application<S,Array<U32>,Resources(~S),U32,FamilyState(~S),Unit,Unit,Build.empty_observe(~World(~S)),Leaf.empty(~S)>
def First(~S:Data) -> Type:App.Application<S,Array<U32>,Resources(~S),U32,FamilyState(~S),Owner1(~S),Rows1(),observe1(~S),fold1(~S)>
def Registered(~S:Data) -> Type:App.Application<S,Array<U32>,Resources(~S),U32,FamilyState(~S),Owners(~S),Rows(),observe(~S),fold(~S)>
def GateOps(~S:Data) -> Type -> Type:CD.Ops(~S,~Array<U32>,~Source.input_identity(~S),~U32)
def gate_declaration(~S:Data) -> CD.Declaration<S,Array<U32>,Resources(~S),U32,GateOps(~S)>:CD.required_resource(~S,~Array<U32>,~Resources(~S),~U32,~Array<U32>,~((Unit & Array<U32>) & Array<U32>),~U32,~Source.input_identity(~S),~Source.input_lens(~S),~Source.input_binding(~S),~Source.view)
def positive_returned(~H:Type,value:H & Maybe<&2,U32>) -> H & Bool:
  match value:
    case (owner,None{}):(owner,False{})
    case (owner,Some{value}):(owner,U32.is_lt(0,value))
def positive(~S:Data,~H:Type,~caps:GateOps(~S)(H),_:Unit,owner:H) -> H & Bool:positive_returned(~H,CD.read(~S,~Array<U32>,~Source.input_identity(~S),~H,~U32,~caps,owner))
def left_run(~S:Data) -> Bool -> World(~S) -> Cond.Evaluation<World(~S),Bool>:Cond.constant_run(~World(~S))
def right_run(~S:Data) -> Unit -> World(~S) -> Cond.Evaluation<World(~S),Unit>:Cond.check_run(~S,~Array<U32>,~Resources(~S),~U32,~GateOps(~S),~Unit,~positive(~S),~gate_declaration(~S))
def guard_run(~S:Data) -> (Bool & Unit) -> World(~S) -> Cond.Evaluation<World(~S),Bool & Unit>:Cond.combined_run(~World(~S),~Bool,~Unit,~left_run(~S),~right_run(~S),~True{})
def guard(~S:Data) -> Cond.Condition<World(~S),Bool & Unit,guard_run(~S)>:Cond.and_then(~World(~S),~Bool,~Unit,~left_run(~S),~right_run(~S),Cond.constant(~World(~S),True{}),Cond.check(~S,~Array<U32>,~Resources(~S),~U32,~GateOps(~S),~Unit,~positive(~S),~gate_declaration(~S),"Threshold-positive",Unit{}))
def Bound(~S:Data) -> Type:B.BoundOwner<(Bool & Unit)>
def leaf_select(~S:Data) -> Bound(~S) -> World(~S) -> U32 -> B.Selection<World(~S),Bound(~S)>:B.select(~World(~S),~(Bool & Unit),~guard_run(~S))
def Guards(~S:Data) -> Type:Bound(~S) & Bound(~S)
def select(~S:Data) -> Guards(~S) -> World(~S) -> U32 -> B.Selection<World(~S),Guards(~S)>:B.pair_select(~World(~S),~Bound(~S),~Bound(~S),~leaf_select(~S),~leaf_select(~S))
def Application(~S:Data) -> Type:Checked.Application<S,Array<U32>,Resources(~S),U32,FamilyState(~S),Owners(~S),Rows(),observe(~S),fold(~S),Guards(~S),select(~S)>
def bindings(~S:Data) -> B.Bindings<World(~S),Guards(~S),select(~S)>:B.pair(~World(~S),~Bound(~S),~Bound(~S),~leaf_select(~S),~leaf_select(~S),B.bind(~World(~S),~(Bool & Unit),~guard_run(~S),1,guard(~S)),B.bind(~World(~S),~(Bool & Unit),~guard_run(~S),2,guard(~S)))
def plan(~S:Data) -> SP.Plan<S>:SP.Sequence{SP.Entry{Sch.Phase{"readers"},[]},SP.Sequence{SP.Entry{Sch.System{1,0},[]},SP.Sequence{SP.Entry{Sch.System{2,0},[]},SP.Entry{Sch.Barrier{},[]}}}}
def attached(~S:Data,value:Checked.Attachment<Registered(~S),B.Bindings<World(~S),Guards(~S),select(~S)>,Application(~S)>) -> Maybe<&1,Application(~S)>:
  match value:
    case Checked.Attached{app}:Some{app}
    case Checked.Invalid{_,_}:None{}
def installed2(~S:Data,value:Registered(~S)) -> Maybe<&1,Application(~S)>:attached(~S,Checked.attach(~S,~Array<U32>,~Resources(~S),~U32,~FamilyState(~S),~Owners(~S),~Rows(),~observe(~S),~fold(~S),~Guards(~S),~select(~S),value,"checked-readers",plan(~S),bindings(~S)))
def rejected2(~S:Data,_:First(~S)) -> Maybe<&1,Application(~S)>:None{}
def installed1(~S:Data,value:First(~S)) -> Maybe<&1,Application(~S)>:Reader.install(~S,~Array<U32>,~Resources(~S),~U32,~U32,~FamilyState(~S),~Unit,~Unit,~Callback,~take(~S),~put(~S),~runner(~S),~Owner1(~S),~Rows1(),~observe1(~S),~fold1(~S),~Maybe<&1,Application(~S)>,installed2(~S),rejected2(~S),value,"slow")
def rejected1(~S:Data,_:Before(~S)) -> Maybe<&1,Application(~S)>:None{}
def register(~S:Data,value:Before(~S)) -> Maybe<&1,Application(~S)>:Reader.install(~S,~Array<U32>,~Resources(~S),~U32,~U32,~FamilyState(~S),~Unit,~Unit,~Callback,~take(~S),~put(~S),~runner(~S),~Unit,~Unit,~Build.empty_observe(~World(~S)),~Leaf.empty(~S),~Maybe<&1,Application(~S)>,installed1(~S),rejected1(~S),value,"fast")
def recorded(~S:Data,id:U32,family:FamilyState(~S),completion:Ev.Completion<Unit,Callback,Unit>,success:Bool) -> FamilyState(~S) & Bool:
  match family:
    case Product.Owner{stream,Held{owned,receipts,count}}:(Product.Owner{stream,Held{owned,List.append(&1,Receipt,receipts,[Receipt{id,completion}]),count}},success)
def record(~S:Data,id:U32,family:FamilyState(~S),completion:Ev.Completion<Unit,Callback,Unit>) -> FamilyState(~S) & Bool:
  match completion:
    case Ev.Succeeded{output}:recorded(~S,id,family,Ev.Succeeded{output},True{})
    case Ev.Failed{error}:recorded(~S,id,family,Ev.Failed{error},False{})
    case Ev.Rejected{args}:recorded(~S,id,family,Ev.Rejected{args},False{})
def Packed(~S:Data) -> Type:Owners(~S) & (FamilyState(~S) & Nat)
def completed(~S:Data,owners:Owners(~S),tick:Nat,world:World(~S),value:FamilyState(~S) & Bool) -> Packed(~S) & Sys.Outcome<World(~S),Unit,Unit>:
  match value:
    case (family,True{}):((owners,(family,tick)),Sys.Succeeded{world,Unit{}})
    case (family,False{}):((owners,(family,tick)),Sys.Failed{world,Unit{}})
def first_returned(~S:Data,prior:Unit,other:Owner(~S),value:Reader.RunResult<S,Array<U32>,Resources(~S),U32,U32,FamilyState(~S),Unit,Unit,Callback,take(~S),put(~S),runner(~S)>) -> Packed(~S) & Sys.Outcome<World(~S),Unit,Unit>:
  match value:
    case Reader.Ran{Route.Runtime{world,family,tick},owner,completion}:completed(~S,((prior,owner),other),tick,world,record(~S,1,family,completion))
def second_returned(~S:Data,prior:Owner1(~S),value:Reader.RunResult<S,Array<U32>,Resources(~S),U32,U32,FamilyState(~S),Unit,Unit,Callback,take(~S),put(~S),runner(~S)>) -> Packed(~S) & Sys.Outcome<World(~S),Unit,Unit>:
  match value:
    case Reader.Ran{Route.Runtime{world,family,tick},owner,completion}:completed(~S,(prior,owner),tick,world,record(~S,2,family,completion))
# Trusted scheduling seam only. Gameplay callback is body(Ev.Input), above.
def dispatch(~S:Data,owners:Packed(~S),world:World(~S),id:U32) -> Packed(~S) & Sys.Outcome<World(~S),Unit,Unit>:
  match owners id:
    case (((prior,first),second),(family,tick)) 1:first_returned(~S,prior,second,Reader.run(~S,~Array<U32>,~Resources(~S),~U32,~U32,~FamilyState(~S),~Unit,~Unit,~Callback,~take(~S),~put(~S),~runner(~S),~synchronize(~S),first,Route.Runtime{world,family,tick},Unit{}))
    case ((prior,second),(family,tick)) 2:second_returned(~S,prior,Reader.run(~S,~Array<U32>,~Resources(~S),~U32,~U32,~FamilyState(~S),~Unit,~Unit,~Callback,~take(~S),~put(~S),~runner(~S),~synchronize(~S),second,Route.Runtime{world,family,tick},Unit{}))
    case owners _:(owners,Sys.Failed{world,Unit{}})
def provision(~S:Data,world:World(~S)) -> World(~S) & List<&2,SP.Requirement<S>>:(world,[])
def run(~S:Data,app:Application(~S)) -> Single.RunResult<Application(~S),S,Error.Error<Unit>>:Checked.run(~S,~Array<U32>,~Resources(~S),~U32,~FamilyState(~S),~Owners(~S),~Rows(),~observe(~S),~fold(~S),~Guards(~S),~select(~S),~Unit,~dispatch(~S),~provision(~S),app)
def before(~S:Data,world:World(~S)) -> Before(~S):App.attached(~S,~Array<U32>,~Resources(~S),~U32,~FamilyState(~S),~Unit,~Unit,~Build.empty_observe(~World(~S)),~Leaf.empty(~S),Product.Owner{Stream.append(~S,~U32,Stream.provision(~S,~U32,domain(~S),8n),1n,[7,8]),Held{Source.pair(600),[],0}},1n,SchemaApp.Application{Schema.Schema{Binding.entries(~S,~Resources(~S),~Source.Index(~S),Source.schema(~S))},Build.empty(~S,~World(~S),world)})
def Input(~S:Data) -> Type:Source.Input(~S)
def enabled(~S:Data,app:Application(~S),flag:Bool) -> Application(~S):Checked.enabled(~S,~Array<U32>,~Resources(~S),~U32,~FamilyState(~S),~Owners(~S),~Rows(),~observe(~S),~fold(~S),~Guards(~S),~select(~S),app,flag)
def snapshot(~S:Data,app:Application(~S)) -> Application(~S) & Maybe<&2,Old.Description<S,Rows()>>:Checked.snapshot(~S,~Array<U32>,~Resources(~S),~U32,~FamilyState(~S),~Owners(~S),~Rows(),~observe(~S),~fold(~S),~Guards(~S),~select(~S),app)
type Rest<S:Data> is Type:
  Rest{schema:Schema.Schema<S,Array<U32>,Resources(~S)>,owners:Packed(~S),recipe:Tree.Recipe<World(~S),Rows(),observe(~S)>,debug:Bool,plan:SP.Plan<S>,namespace:U32,name:String,steps:List<&2,Sch.Step>,needs:List<&2,SP.Requirement<S>>,bindings:B.Bindings<World(~S),Guards(~S),select(~S)>}
def take_world(~S:Data,app:Application(~S)) -> Rest<S> & World(~S):
  match app:
    case Checked.Application{Old.Application{Single.Application{SchemaApp.Application{schema,Build.Registered{world,owners,recipe,debug}},plan,namespace,name,steps,needs},bindings}}:(Rest{schema,owners,recipe,debug,plan,namespace,name,steps,needs,bindings},world)
def put_world(~S:Data,rest:Rest<S>,world:World(~S)) -> Application(~S):
  match rest:
    case Rest{schema,owners,recipe,debug,plan,namespace,name,steps,needs,bindings}:Checked.Application{Old.Application{Single.Application{SchemaApp.Application{schema,Build.Registered{world,owners,recipe,debug}},plan,namespace,name,steps,needs},bindings}}
def guard_value(~S:Data,value:Bool) -> Cond.Condition<World(~S),Bool & Unit,guard_run(~S)>:Cond.and_then(~World(~S),~Bool,~Unit,~left_run(~S),~right_run(~S),Cond.constant(~World(~S),value),Cond.check(~S,~Array<U32>,~Resources(~S),~U32,~GateOps(~S),~Unit,~positive(~S),~gate_declaration(~S),"Threshold-positive",Unit{}))
def bindings_value(~S:Data,+value:Bool) -> B.Bindings<World(~S),Guards(~S),select(~S)>:B.pair(~World(~S),~Bound(~S),~Bound(~S),~leaf_select(~S),~leaf_select(~S),B.bind(~World(~S),~(Bool & Unit),~guard_run(~S),1,guard_value(~S,value)),B.bind(~World(~S),~(Bool & Unit),~guard_run(~S),2,guard_value(~S,value)))
def bypass_rest(~S:Data,value:Bool,rest:Rest<S>,world:World(~S)) -> Application(~S):
  match rest:
    case Rest{schema,owners,recipe,debug,plan,namespace,name,steps,needs,_}:put_world(~S,Rest{schema,owners,recipe,debug,plan,namespace,name,steps,needs,bindings_value(~S,value)},world)
def bypass_taken(~S:Data,value:Bool,parts:Rest<S> & World(~S)) -> Application(~S):
  match parts:
    case (rest,world):bypass_rest(~S,value,rest,world)
def bypass(~S:Data,value:Bool,app:Application(~S)) -> Application(~S):bypass_taken(~S,value,take_world(~S,app))
def bindings_values(~S:Data,first:Bool,second:Bool) -> B.Bindings<World(~S),Guards(~S),select(~S)>:B.pair(~World(~S),~Bound(~S),~Bound(~S),~leaf_select(~S),~leaf_select(~S),B.bind(~World(~S),~(Bool & Unit),~guard_run(~S),1,guard_value(~S,first)),B.bind(~World(~S),~(Bool & Unit),~guard_run(~S),2,guard_value(~S,second)))
def guards_rest(~S:Data,first:Bool,second:Bool,rest:Rest<S>,world:World(~S)) -> Application(~S):
  match rest:
    case Rest{schema,owners,recipe,debug,plan,namespace,name,steps,needs,_}:put_world(~S,Rest{schema,owners,recipe,debug,plan,namespace,name,steps,needs,bindings_values(~S,first,second)},world)
def guards_taken(~S:Data,first:Bool,second:Bool,value:Rest<S> & World(~S)) -> Application(~S):
  match value:
    case (rest,world):guards_rest(~S,first,second,rest,world)
def guards(~S:Data,first:Bool,second:Bool,app:Application(~S)) -> Application(~S):guards_taken(~S,first,second,take_world(~S,app))
def empty(~S:Data,_:Unit) -> Array<U32>:Source.pair(700)
def resources(~S:Data) -> Resources(~S):Product.Owner{Source.pair(10),Product.Owner{Slot.Present{Source.pair(0)},Source.pair(900)}}
def command_returned(~S:Data,value:World(~S) & U32) -> World(~S):
  match value:
    case (world,_):world
def command(~S:Data,world:World(~S)) -> World(~S):command_returned(~S,W.advance_clock(~S,~Array<U32>,~Resources(~S),~U32,world))
def queued(~S:Data,world:World(~S)) -> World(~S):W.enqueue(~S,~Array<U32>,~Resources(~S),~U32,world,command(~S))
