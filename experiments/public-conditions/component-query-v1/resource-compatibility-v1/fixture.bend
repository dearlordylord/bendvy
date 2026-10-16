import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-condition-composition.bend as Old
import /workspace/formal-proofs/bendvy/src/ecs/checked-condition-schedule.bend as CheckedError
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/owner-product.bend as Product
import /workspace/formal-proofs/bendvy/src/ecs/resource-field-binding.bend as Binding
import /workspace/formal-proofs/bendvy/src/ecs/optional-resource-binding.bend as Optional
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-optional-resource.bend as Slot
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-check-declaration.bend as CD
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-checked-condition.bend as Cond
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-checked-bindings.bend as Bindings
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-checked-schedule.bend as Checked
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schedule.bend as Single
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schema.bend as App
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-registration-fields.bend as Records
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-records.bend as Leaf
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-recipe.bend as Tree
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-resource-field.bend as AppField
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-resource-field-observation.bend as Leaves
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-resource-field-declaration.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-resource-field-system.bend as Field
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-registration-run.bend as Transport
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as SP
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
import /workspace/formal-proofs/bendvy/src/ecs/check.bend as K

type Workshop is Data:Workshop{}
type Garden is Data:Garden{}
def identity(~S:Data) -> Schema.Resource<S,Array<U32>>:Schema.resource(~S,~Array<U32>,"Counter")
def input_identity(~S:Data) -> Schema.Resource<S,Array<U32>>:Schema.resource(~S,~Array<U32>,"Input")
def sentinel_identity(~S:Data) -> Schema.Resource<S,Array<U32>>:Schema.resource(~S,~Array<U32>,"Sentinel")
def Input(~S:Data) -> Type:Slot.Slot<S,Array<U32>,input_identity(~S)>
def Siblings(~S:Data) -> Type:Product.Owner<Input(~S),Array<U32>>
def Resources(~S:Data) -> Type:Product.Owner<Array<U32>,Siblings(~S)>
def World(~S:Data) -> Type:W.World<S,Unit,Resources(~S),Unit>
def InputIndex(~S:Data) -> Data:Optional.Index<S,Array<U32>,input_identity(~S)>
def SiblingIndex(~S:Data) -> Data:Binding.Branch<Binding.Built<S,Input(~S),InputIndex(~S)>,Binding.Built<S,Array<U32>,Schema.Resource<S,Array<U32>>>>
def Index(~S:Data) -> Data:Binding.Branch<Binding.Built<S,Array<U32>,Schema.Resource<S,Array<U32>>>,Binding.Built<S,Siblings(~S),SiblingIndex(~S)>>
def schema(~S:Data) -> Binding.Built<S,Resources(~S),Index(~S)>:
  Binding.joined(~S,~Array<U32>,~Siblings(~S),~Schema.Resource<S,Array<U32>>,~SiblingIndex(~S),Binding.leaf(~S,~Array<U32>,identity(~S)),Binding.joined(~S,~Input(~S),~Array<U32>,~InputIndex(~S),~Schema.Resource<S,Array<U32>>,Optional.leaf(~S,~Array<U32>,input_identity(~S)),Binding.leaf(~S,~Array<U32>,sentinel_identity(~S))))
def lens(~S:Data) -> Product.Lens<Resources(~S),Array<U32>,Unit & Siblings(~S)>:Binding.left_lens(~Resources(~S),~Array<U32>,~Siblings(~S),~Unit,~Binding.whole(~Resources(~S)))
def right_lens(~S:Data) -> Product.Lens<Resources(~S),Siblings(~S),Unit & Array<U32>>:Binding.right_lens(~Resources(~S),~Array<U32>,~Siblings(~S),~Unit,~Binding.whole(~Resources(~S)))
def input_lens(~S:Data) -> Product.Lens<Resources(~S),Input(~S),(Unit & Array<U32>) & Array<U32>>:Binding.left_lens(~Resources(~S),~Input(~S),~Array<U32>,~(Unit & Array<U32>),~right_lens(~S))
def cursor(~S:Data) -> Binding.Cursor<S,Resources(~S),Array<U32>,Unit & Siblings(~S),Schema.Resource<S,Array<U32>>,lens(~S)>:
  Binding.left(~S,~Resources(~S),~Array<U32>,~Siblings(~S),~Unit,~Schema.Resource<S,Array<U32>>,~SiblingIndex(~S),~Binding.whole(~Resources(~S)),Binding.root(~S,~Resources(~S),~Index(~S),schema(~S)))
def input_cursor(~S:Data) -> Binding.Cursor<S,Resources(~S),Input(~S),(Unit & Array<U32>) & Array<U32>,InputIndex(~S),input_lens(~S)>:
  Binding.left(~S,~Resources(~S),~Input(~S),~Array<U32>,~(Unit & Array<U32>),~InputIndex(~S),~Schema.Resource<S,Array<U32>>,~right_lens(~S),Binding.right(~S,~Resources(~S),~Array<U32>,~Siblings(~S),~Unit,~Schema.Resource<S,Array<U32>>,~SiblingIndex(~S),~Binding.whole(~Resources(~S)),Binding.root(~S,~Resources(~S),~Index(~S),schema(~S))))
def binding(~S:Data) -> Binding.Binding<S,Resources(~S),Array<U32>,Unit & Siblings(~S),lens(~S),identity(~S)>:Binding.bind(~S,~Resources(~S),~Array<U32>,~(Unit & Siblings(~S)),~lens(~S),~cursor(~S))
def input_binding(~S:Data) -> Optional.Binding<S,Resources(~S),Array<U32>,(Unit & Array<U32>) & Array<U32>,input_identity(~S),input_lens(~S)>:Optional.bind(~S,~Resources(~S),~Array<U32>,~((Unit & Array<U32>) & Array<U32>),~input_identity(~S),~input_lens(~S),~input_cursor(~S))
def view(value:Array<U32>) -> Array<U32> & U32:Array.get(U32,value,0)
def Ops(~S:Data) -> Type -> Type:D.write_ops(~S,~Array<U32>,~identity(~S),~U32)
def declaration(~S:Data) -> D.Declaration<S,Unit,Resources(~S),Unit,Ops(~S),U32>:
  D.write(~S,~Unit,~Resources(~S),~Unit,~Array<U32>,~(Unit & Siblings(~S)),~U32,~lens(~S),~identity(~S),~binding(~S),~view,~U32.show)
def raw(~S:Data) -> Field.Declaration<S,T.Tx<World(~S),Unit>,Ops(~S)(T.Tx<World(~S),Unit>)>:D.ordinary(~S,~Unit,~Resources(~S),~Unit,~Ops(~S),~U32,declaration(~S))
def body_got(~S:Data,~H:Type,~caps:Ops(~S)(H),result:H & U32) -> H & (T.Outcome<String> & Unit):
  match result:
    case (owner,+value):(Field.set(~S,~Array<U32>,~identity(~S),~H,~U32,~caps,owner,ANode{ALeaf{(value+1:U32)},ALeaf{(value+2:U32)}}),(T.Success{},Unit{}))
def body(~S:Data,~H:Type,~caps:Ops(~S)(H),_:Unit,owner:H) -> H & (T.Outcome<String> & Unit):body_got(~S,~H,~caps,Field.get(~S,~Array<U32>,~identity(~S),~H,~U32,~caps,owner))
def runner(~S:Data) -> World(~S) -> Unit -> Sys.Outcome<World(~S),String,Unit>:Field.runner(~S,~Unit,~Resources(~S),~Unit,~Ops(~S),~Unit,~String,~Unit,~raw(~S),~body(~S))
def Registry(~S:Data) -> Type:Sys.Registry<S,Unit,Resources(~S),Unit,Unit,String,Unit,runner(~S)>
def Owner(~S:Data) -> Type:Leaf.Record<S,Records.Token<Registry(~S)>>
def Owners(~S:Data) -> Type:Unit & Owner(~S)
def Rows() -> Data:DTO.Product<Unit,U32>
def observe(~S:Data) -> World(~S) -> World(~S) & DTO.Observation<Rows()>:Tree.observe_pair(~World(~S),~Unit,~U32,~Build.empty_observe(~World(~S)),~Leaves.resource_observe(~S,~Unit,~Resources(~S),~Unit,~Ops(~S),~U32,~declaration(~S)))
def fold(~S:Data) -> Owners(~S) -> Owners(~S) & List<&2,Records.Fields<S>>:Leaf.fold_pair(~S,~Unit,~Owner(~S),~Leaf.empty(~S),~Leaf.observed(~S,~Records.Token<Registry(~S)>))
def Before(~S:Data) -> Type:Build.Registered<S,World(~S),Unit,Unit,Build.empty_observe(~World(~S)),Leaf.empty(~S)>
def Registered(~S:Data) -> Type:Build.Registered<S,World(~S),Owners(~S),Rows(),observe(~S),fold(~S)>
def dispatch_returned(~S:Data,prior:Unit,result:Transport.TransportResult<S,World(~S),Unit,String,Unit,Records.Token<Registry(~S)>>) -> Owners(~S) & Sys.Outcome<World(~S),String,Unit>:
  match result:
    case Transport.Completed{token,fields,outcome}:((prior,Leaf.Record{token,fields}),outcome)
    case Transport.RegistrationRejected{token,fields,world,_}:((prior,Leaf.Record{token,fields}),Sys.Failed{world,"registration"})
def dispatch(~S:Data,owners:Owners(~S),world:World(~S),id:U32) -> Owners(~S) & Sys.Outcome<World(~S),String,Unit>:
  match owners id:
    case (prior,Leaf.Record{token,fields}) 1:dispatch_returned(~S,prior,Transport.run(~S,~Unit,~Resources(~S),~Unit,~Unit,~String,~Unit,~runner(~S),token,fields,world,Unit{}))
    case owners _:(owners,Sys.Failed{world,"unknown"})
def CheckOps(~S:Data) -> Type -> Type:CD.Ops(~S,~Array<U32>,~input_identity(~S),~U32)
def optional(~S:Data) -> CD.Declaration<S,Unit,Resources(~S),Unit,CheckOps(~S)>:CD.optional_resource(~S,~Unit,~Resources(~S),~Unit,~Array<U32>,~((Unit & Array<U32>) & Array<U32>),~U32,~input_identity(~S),~input_lens(~S),~input_binding(~S),~view)
def required(~S:Data) -> CD.Declaration<S,Unit,Resources(~S),Unit,CheckOps(~S)>:CD.required_resource(~S,~Unit,~Resources(~S),~Unit,~Array<U32>,~((Unit & Array<U32>) & Array<U32>),~U32,~input_identity(~S),~input_lens(~S),~input_binding(~S),~view)
def presence_returned(~H:Type,result:H & Maybe<&2,U32>) -> H & Bool:
  match result:
    case (owner,None{}):(owner,False{})
    case (owner,Some{_}):(owner,True{})
def presence(~S:Data,~H:Type,~caps:CheckOps(~S)(H),bypass:Bool,owner:H) -> H & Bool:
  match bypass:
    case True{}:(owner,True{})
    case False{}:presence_returned(~H,CD.read(~S,~Array<U32>,~input_identity(~S),~H,~U32,~caps,owner))
def positive_returned(~H:Type,result:H & Maybe<&2,U32>) -> H & Bool:
  match result:
    case (owner,None{}):(owner,False{})
    case (owner,Some{value}):(owner,U32.is_lt(0,value))
def positive(~S:Data,~H:Type,~caps:CheckOps(~S)(H),_:Unit,owner:H) -> H & Bool:positive_returned(~H,CD.read(~S,~Array<U32>,~input_identity(~S),~H,~U32,~caps,owner))
def left_run(~S:Data) -> Bool -> World(~S) -> Cond.Evaluation<World(~S),Bool>:Cond.check_run(~S,~Unit,~Resources(~S),~Unit,~CheckOps(~S),~Bool,~presence(~S),~optional(~S))
def right_run(~S:Data) -> Unit -> World(~S) -> Cond.Evaluation<World(~S),Unit>:Cond.check_run(~S,~Unit,~Resources(~S),~Unit,~CheckOps(~S),~Unit,~positive(~S),~required(~S))
def left(~S:Data,bypass:Bool) -> Cond.Condition<World(~S),Bool,left_run(~S)>:Cond.check(~S,~Unit,~Resources(~S),~Unit,~CheckOps(~S),~Bool,~presence(~S),~optional(~S),"presence-or-bypass",bypass)
def right(~S:Data) -> Cond.Condition<World(~S),Unit,right_run(~S)>:Cond.check(~S,~Unit,~Resources(~S),~Unit,~CheckOps(~S),~Unit,~positive(~S),~required(~S),"required-positive",Unit{})
def inner_run(~S:Data) -> (Bool & Unit) -> World(~S) -> Cond.Evaluation<World(~S),Bool & Unit>:Cond.combined_run(~World(~S),~Bool,~Unit,~left_run(~S),~right_run(~S),~True{})
def inner(~S:Data,bypass:Bool) -> Cond.Condition<World(~S),Bool & Unit,inner_run(~S)>:Cond.and_then(~World(~S),~Bool,~Unit,~left_run(~S),~right_run(~S),left(~S,bypass),right(~S))
def old_run(~S:Data) -> Bool -> World(~S) -> Cond.Evaluation<World(~S),Bool>:Cond.lift_run(~World(~S),~Bool,~Old.constant_run(~World(~S)))
def guard_run(~S:Data) -> (Bool & (Bool & Unit)) -> World(~S) -> Cond.Evaluation<World(~S),Bool & (Bool & Unit)>:Cond.combined_run(~World(~S),~Bool,~(Bool & Unit),~old_run(~S),~inner_run(~S),~True{})
def guard(~S:Data,bypass:Bool) -> Cond.Condition<World(~S),Bool & (Bool & Unit),guard_run(~S)>:Cond.and_then(~World(~S),~Bool,~(Bool & Unit),~old_run(~S),~inner_run(~S),Cond.lift(~World(~S),~Bool,~Old.constant_run(~World(~S)),Old.constant(~World(~S),True{})),inner(~S,bypass))
def Bound(~S:Data) -> Type:Bindings.BoundOwner<(Bool & (Bool & Unit))>
def select(~S:Data) -> Bound(~S) -> World(~S) -> U32 -> Bindings.Selection<World(~S),Bound(~S)>:Bindings.select(~World(~S),~(Bool & (Bool & Unit)),~guard_run(~S))
def Application(~S:Data) -> Type:Checked.Application<S,Unit,Resources(~S),Unit,Owners(~S),Rows(),observe(~S),fold(~S),Bound(~S),select(~S)>
def provision(~S:Data,world:World(~S)) -> World(~S) & List<&2,SP.Requirement<S>>:(world,[])
def plan(~S:Data) -> SP.Plan<S>:SP.Sequence{SP.Entry{Sch.Phase{"checked"},[]},SP.Sequence{SP.Entry{Sch.System{1,0},[]},SP.Entry{Sch.Barrier{},[]}}}
def bound_attached(~S:Data,value:Checked.Attachment<Single.Application<S,Unit,Resources(~S),Unit,Owners(~S),Rows(),observe(~S),fold(~S)>,Bindings.Bindings<World(~S),Bound(~S),select(~S)>,Application(~S)>) -> Maybe<&1,Application(~S)>:
  match value:
    case Checked.Attached{app}:Some{app}
    case Checked.Invalid{_,_}:None{}
def scheduled(~S:Data,bypass:Bool,value:Single.Attachment<App.Application<S,Unit,Resources(~S),Unit,Owners(~S),Rows(),observe(~S),fold(~S)>,Single.Application<S,Unit,Resources(~S),Unit,Owners(~S),Rows(),observe(~S),fold(~S)>>) -> Maybe<&1,Application(~S)>:
  match value:
    case Single.Invalid{_}:None{}
    case Single.Attached{app}:bound_attached(~S,Checked.attach(~S,~Unit,~Resources(~S),~Unit,~Owners(~S),~Rows(),~observe(~S),~fold(~S),~Bound(~S),~select(~S),app,Bindings.bind(~World(~S),~(Bool & (Bool & Unit)),~guard_run(~S),1,guard(~S,bypass))))
def registered(~S:Data,bypass:Bool,app:Registered(~S)) -> Maybe<&1,Application(~S)>:
  scheduled(~S,bypass,Single.attach(~S,~Unit,~Resources(~S),~Unit,~Owners(~S),~Rows(),~observe(~S),~fold(~S),App.Application{Schema.Schema{Binding.entries(~S,~Resources(~S),~Index(~S),schema(~S))},app},"guarded-counter",plan(~S)))
def rejected(~S:Data,_:Before(~S)) -> Maybe<&1,Application(~S)>:None{}
def register(~S:Data,bypass:Bool,world:World(~S)) -> Maybe<&1,Application(~S)>:
  AppField.register(~S,~Unit,~Resources(~S),~Unit,~Unit,~Unit,~Build.empty_observe(~World(~S)),~Leaf.empty(~S),~Ops(~S),~Unit,~String,~Unit,~U32,~declaration(~S),~body(~S),~Maybe<&1,Application(~S)>,registered(~S,bypass),rejected(~S),Build.empty(~S,~World(~S),world),"increment","Counter")
def run(~S:Data,app:Application(~S)) -> Single.RunResult<Application(~S),S,CheckedError.Error<String>>:Checked.run(~S,~Unit,~Resources(~S),~Unit,~Owners(~S),~Rows(),~observe(~S),~fold(~S),~Bound(~S),~select(~S),~String,~dispatch(~S),~provision(~S),app)
def not_run(~S:Data) -> Bool -> World(~S) -> Cond.Evaluation<World(~S),Bool>:Cond.not_run(~World(~S),~Bool,~left_run(~S))
def or_run(~S:Data) -> (Bool & Unit) -> World(~S) -> Cond.Evaluation<World(~S),Bool & Unit>:Cond.combined_run(~World(~S),~Bool,~Unit,~Cond.constant_run(~World(~S)),~right_run(~S),~False{})
type ProbeResult is Data:ProbeResult{name:String,result:Result<&2,&2,Cond.Error,Bool>}
def Probes(~S:Data) -> Type:ProbeOwners<S>
type ProbeOwners<S:Data> is Type:
  ProbeOwners{neg:Cond.Condition<World(~S),Bool,not_run(~S)>,skip:Cond.Condition<World(~S),Bool & Unit,or_run(~S)>,reached:Cond.Condition<World(~S),Bool & Unit,or_run(~S)>}
def probes(~S:Data) -> Probes(~S):
  ProbeOwners{Cond.not(~World(~S),~Bool,~left_run(~S),left(~S,False{})),Cond.or_else(~World(~S),~Bool,~Unit,~Cond.constant_run(~World(~S)),~right_run(~S),Cond.constant(~World(~S),True{}),right(~S)),Cond.or_else(~World(~S),~Bool,~Unit,~Cond.constant_run(~World(~S)),~right_run(~S),Cond.constant(~World(~S),False{}),right(~S))}
def probe_last(~S:Data,neg:Cond.Condition<World(~S),Bool,not_run(~S)>,skip:Cond.Condition<World(~S),Bool & Unit,or_run(~S)>,before:List<&2,ProbeResult>,value:Cond.Returned<World(~S),Bool & Unit,or_run(~S)>) -> World(~S) & (Probes(~S) & List<&2,ProbeResult>):
  match value:
    case Cond.Returned{world,reached,result}:(world,(ProbeOwners{neg,skip,reached},List.append(&2,ProbeResult,before,[ProbeResult{"false.or(required)",result}])))
def probe_middle(~S:Data,neg:Cond.Condition<World(~S),Bool,not_run(~S)>,reached:Cond.Condition<World(~S),Bool & Unit,or_run(~S)>,before:List<&2,ProbeResult>,value:Cond.Returned<World(~S),Bool & Unit,or_run(~S)>) -> World(~S) & (Probes(~S) & List<&2,ProbeResult>):
  match value:
    case Cond.Returned{world,skip,result}:probe_last(~S,neg,skip,List.append(&2,ProbeResult,before,[ProbeResult{"true.or(required)",result}]),Cond.run(~World(~S),~(Bool & Unit),~or_run(~S),reached,world))
def probe_first(~S:Data,skip:Cond.Condition<World(~S),Bool & Unit,or_run(~S)>,reached:Cond.Condition<World(~S),Bool & Unit,or_run(~S)>,value:Cond.Returned<World(~S),Bool,not_run(~S)>) -> World(~S) & (Probes(~S) & List<&2,ProbeResult>):
  match value:
    case Cond.Returned{world,neg,result}:probe_middle(~S,neg,reached,[ProbeResult{"not(exists)",result}],Cond.run(~World(~S),~(Bool & Unit),~or_run(~S),skip,world))
def probes_world(~S:Data,owners:Probes(~S),world:World(~S)) -> World(~S) & (Probes(~S) & List<&2,ProbeResult>):
  match owners:
    case ProbeOwners{neg,skip,reached}:probe_first(~S,skip,reached,Cond.run(~World(~S),~Bool,~not_run(~S),neg,world))
def probes_returned(~S:Data,schema:Schema.Schema<S,Unit,Resources(~S)>,owners:Owners(~S),recipe:Tree.Recipe<World(~S),Rows(),observe(~S)>,debug:Bool,plan:SP.Plan<S>,namespace:U32,name:String,steps:List<&2,Sch.Step>,needs:List<&2,SP.Requirement<S>>,bindings:Bindings.Bindings<World(~S),Bound(~S),select(~S)>,result:World(~S) & (Probes(~S) & List<&2,ProbeResult>)) -> Application(~S) & (Probes(~S) & List<&2,ProbeResult>):
  match result:
    case (world,observed):(Checked.Application{Single.Application{App.Application{schema,Build.Registered{world,owners,recipe,debug}},plan,namespace,name,steps,needs},bindings},observed)
def probe(~S:Data,app:Application(~S),probes:Probes(~S)) -> Application(~S) & (Probes(~S) & List<&2,ProbeResult>):
  match app:
    case Checked.Application{Single.Application{App.Application{schema,Build.Registered{world,owners,recipe,debug}},plan,namespace,name,steps,needs},bindings}:probes_returned(~S,schema,owners,recipe,debug,plan,namespace,name,steps,needs,bindings,probes_world(~S,probes,world))
def enable(~S:Data,app:Application(~S),flag:Bool) -> Application(~S):Checked.enabled(~S,~Unit,~Resources(~S),~Unit,~Owners(~S),~Rows(),~observe(~S),~fold(~S),~Bound(~S),~select(~S),app,flag)
def snapshot(~S:Data,app:Application(~S)) -> Application(~S) & Maybe<&2,Checked.Description<S,Rows()>>:Checked.snapshot(~S,~Unit,~Resources(~S),~Unit,~Owners(~S),~Rows(),~observe(~S),~fold(~S),~Bound(~S),~select(~S),app)
def pair(+value:U32) -> Array<U32>:ANode{ALeaf{value},ALeaf{(value+1:U32)}}
def input(~S:Data,value:Maybe<&2,U32>) -> Input(~S):
  match value:
    case None{}:Slot.Missing{}
    case Some{value}:Slot.Present{pair(value)}
def resources(~S:Data,value:Maybe<&2,U32>) -> Resources(~S):Product.Owner{pair(10),Product.Owner{input(~S,value),pair(900)}}
