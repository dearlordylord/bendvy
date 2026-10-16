import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-machine-initialization.bend as Init
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-machine-declaration.bend as MachineDeclaration
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-machine-condition.bend as Changed
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import /workspace/formal-proofs/bendvy/src/ecs/registration.bend as Reg
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
type Mode is Data:Mode{}
def Machine(~S:Data) -> Data:Init.State<S,Mode,U32>
type Garden is Data:Garden{}
def identity(~S:Data) -> Schema.Resource<S,Array<U32>>:Schema.resource(~S,~Array<U32>,"Counter")
def input_identity(~S:Data) -> Schema.Resource<S,Array<U32>>:Schema.resource(~S,~Array<U32>,"Input")
def machine_identity(~S:Data) -> Schema.Resource<S,Machine(~S)>:Schema.resource(~S,~Machine(~S),"MachineBacking")
def Input(~S:Data) -> Type:Slot.Slot<S,Array<U32>,input_identity(~S)>
def Siblings(~S:Data) -> Type:Product.Owner<Input(~S),Machine(~S)>
def Resources(~S:Data) -> Type:Product.Owner<Array<U32>,Siblings(~S)>
def World(~S:Data) -> Type:W.World<S,Unit,Resources(~S),Unit>
def InputIndex(~S:Data) -> Data:Optional.Index<S,Array<U32>,input_identity(~S)>
def SiblingIndex(~S:Data) -> Data:Binding.Branch<Binding.Built<S,Input(~S),InputIndex(~S)>,Binding.Built<S,Machine(~S),Schema.Resource<S,Machine(~S)>>>
def Index(~S:Data) -> Data:Binding.Branch<Binding.Built<S,Array<U32>,Schema.Resource<S,Array<U32>>>,Binding.Built<S,Siblings(~S),SiblingIndex(~S)>>
def schema(~S:Data) -> Binding.Built<S,Resources(~S),Index(~S)>:
  Binding.joined(~S,~Array<U32>,~Siblings(~S),~Schema.Resource<S,Array<U32>>,~SiblingIndex(~S),Binding.leaf(~S,~Array<U32>,identity(~S)),Binding.joined(~S,~Input(~S),~Machine(~S),~InputIndex(~S),~Schema.Resource<S,Machine(~S)>,Optional.leaf(~S,~Array<U32>,input_identity(~S)),Binding.leaf(~S,~Machine(~S),machine_identity(~S))))
def lens(~S:Data) -> Product.Lens<Resources(~S),Array<U32>,Unit & Siblings(~S)>:Binding.left_lens(~Resources(~S),~Array<U32>,~Siblings(~S),~Unit,~Binding.whole(~Resources(~S)))
def right_lens(~S:Data) -> Product.Lens<Resources(~S),Siblings(~S),Unit & Array<U32>>:Binding.right_lens(~Resources(~S),~Array<U32>,~Siblings(~S),~Unit,~Binding.whole(~Resources(~S)))
def input_lens(~S:Data) -> Product.Lens<Resources(~S),Input(~S),(Unit & Array<U32>) & Machine(~S)>:Binding.left_lens(~Resources(~S),~Input(~S),~Machine(~S),~(Unit & Array<U32>),~right_lens(~S))
def cursor(~S:Data) -> Binding.Cursor<S,Resources(~S),Array<U32>,Unit & Siblings(~S),Schema.Resource<S,Array<U32>>,lens(~S)>:
  Binding.left(~S,~Resources(~S),~Array<U32>,~Siblings(~S),~Unit,~Schema.Resource<S,Array<U32>>,~SiblingIndex(~S),~Binding.whole(~Resources(~S)),Binding.root(~S,~Resources(~S),~Index(~S),schema(~S)))
def input_cursor(~S:Data) -> Binding.Cursor<S,Resources(~S),Input(~S),(Unit & Array<U32>) & Machine(~S),InputIndex(~S),input_lens(~S)>:
  Binding.left(~S,~Resources(~S),~Input(~S),~Machine(~S),~(Unit & Array<U32>),~InputIndex(~S),~Schema.Resource<S,Machine(~S)>,~right_lens(~S),Binding.right(~S,~Resources(~S),~Array<U32>,~Siblings(~S),~Unit,~Schema.Resource<S,Array<U32>>,~SiblingIndex(~S),~Binding.whole(~Resources(~S)),Binding.root(~S,~Resources(~S),~Index(~S),schema(~S))))
def binding(~S:Data) -> Binding.Binding<S,Resources(~S),Array<U32>,Unit & Siblings(~S),lens(~S),identity(~S)>:Binding.bind(~S,~Resources(~S),~Array<U32>,~(Unit & Siblings(~S)),~lens(~S),~cursor(~S))
def input_binding(~S:Data) -> Optional.Binding<S,Resources(~S),Array<U32>,(Unit & Array<U32>) & Machine(~S),input_identity(~S),input_lens(~S)>:Optional.bind(~S,~Resources(~S),~Array<U32>,~((Unit & Array<U32>) & Machine(~S)),~input_identity(~S),~input_lens(~S),~input_cursor(~S))
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
def FirstOwners(~S:Data) -> Type:Unit & Owner(~S)
def Owners(~S:Data) -> Type:FirstOwners(~S) & Owner(~S)
def FirstRows() -> Data:DTO.Product<Unit,U32>
def Rows() -> Data:DTO.Product<FirstRows(),U32>
def first_observe(~S:Data) -> World(~S) -> World(~S) & DTO.Observation<FirstRows()>:Tree.observe_pair(~World(~S),~Unit,~U32,~Build.empty_observe(~World(~S)),~Leaves.resource_observe(~S,~Unit,~Resources(~S),~Unit,~Ops(~S),~U32,~declaration(~S)))
def observe(~S:Data) -> World(~S) -> World(~S) & DTO.Observation<Rows()>:Tree.observe_pair(~World(~S),~FirstRows(),~U32,~first_observe(~S),~Leaves.resource_observe(~S,~Unit,~Resources(~S),~Unit,~Ops(~S),~U32,~declaration(~S)))
def first_fold(~S:Data) -> FirstOwners(~S) -> FirstOwners(~S) & List<&2,Records.Fields<S>>:Leaf.fold_pair(~S,~Unit,~Owner(~S),~Leaf.empty(~S),~Leaf.observed(~S,~Records.Token<Registry(~S)>))
def fold(~S:Data) -> Owners(~S) -> Owners(~S) & List<&2,Records.Fields<S>>:Leaf.fold_pair(~S,~FirstOwners(~S),~Owner(~S),~first_fold(~S),~Leaf.observed(~S,~Records.Token<Registry(~S)>))
def Before(~S:Data) -> Type:Build.Registered<S,World(~S),Unit,Unit,Build.empty_observe(~World(~S)),Leaf.empty(~S)>
def First(~S:Data) -> Type:Build.Registered<S,World(~S),FirstOwners(~S),FirstRows(),first_observe(~S),first_fold(~S)>
def Registered(~S:Data) -> Type:Build.Registered<S,World(~S),Owners(~S),Rows(),observe(~S),fold(~S)>
def dispatched(~S:Data,other:Owner(~S),prior:Unit,left:Bool,result:Transport.TransportResult<S,World(~S),Unit,String,Unit,Records.Token<Registry(~S)>>) -> Owners(~S) & Sys.Outcome<World(~S),String,Unit>:
  match left result:
    case True{} Transport.Completed{token,fields,outcome}:(((prior,Leaf.Record{token,fields}),other),outcome)
    case False{} Transport.Completed{token,fields,outcome}:(((prior,other),Leaf.Record{token,fields}),outcome)
    case True{} Transport.RegistrationRejected{token,fields,world,_}:(((prior,Leaf.Record{token,fields}),other),Sys.Failed{world,"registration"})
    case False{} Transport.RegistrationRejected{token,fields,world,_}:(((prior,other),Leaf.Record{token,fields}),Sys.Failed{world,"registration"})
def dispatch(~S:Data,owners:Owners(~S),world:World(~S),id:U32) -> Owners(~S) & Sys.Outcome<World(~S),String,Unit>:
  match owners id:
    case ((prior,Leaf.Record{token,fields}),other) 1:dispatched(~S,other,prior,True{},Transport.run(~S,~Unit,~Resources(~S),~Unit,~Unit,~String,~Unit,~runner(~S),token,fields,world,Unit{}))
    case ((prior,other),Leaf.Record{token,fields}) 2:dispatched(~S,other,prior,False{},Transport.run(~S,~Unit,~Resources(~S),~Unit,~Unit,~String,~Unit,~runner(~S),token,fields,world,Unit{}))
    case owners _:(owners,Sys.Failed{world,"unknown"})
def CheckOps(~S:Data) -> Type -> Type:CD.Ops(~S,~Array<U32>,~input_identity(~S),~U32)
def optional(~S:Data) -> CD.Declaration<S,Unit,Resources(~S),Unit,CheckOps(~S)>:CD.optional_resource(~S,~Unit,~Resources(~S),~Unit,~Array<U32>,~((Unit & Array<U32>) & Machine(~S)),~U32,~input_identity(~S),~input_lens(~S),~input_binding(~S),~view)
def required(~S:Data) -> CD.Declaration<S,Unit,Resources(~S),Unit,CheckOps(~S)>:CD.required_resource(~S,~Unit,~Resources(~S),~Unit,~Array<U32>,~((Unit & Array<U32>) & Machine(~S)),~U32,~input_identity(~S),~input_lens(~S),~input_binding(~S),~view)
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
def take(~S:Data,value:Resources(~S)) -> Resources(~S) & Machine(~S):
  match value:
    case Product.Owner{counter,Product.Owner{input,+state}}:(Product.Owner{counter,Product.Owner{input,state}},state)
def put(~S:Data,value:Resources(~S),state:Machine(~S)) -> Resources(~S):
  match value:
    case Product.Owner{counter,Product.Owner{input,_}}:Product.Owner{counter,Product.Owner{input,state}}
def machine_declaration(~S:Data) -> MachineDeclaration.Declaration<S,Mode,U32,Resources(~S),Init.take_slot(~S,~Mode,~U32,~Resources(~S),~take(~S),~put(~S))>:
  Init.declared(~S,~Mode,~U32,~Resources(~S),~take(~S),~put(~S),"Mode",[0,1,2])
def Instance(~S:Data) -> Type:Changed.Instance<S,Mode,U32,Unit,Resources(~S),Unit,take(~S),put(~S)>
def old_run(~S:Data) -> Instance(~S) -> World(~S) -> Cond.Evaluation<World(~S),Instance(~S)>:Cond.lift_run(~World(~S),~Instance(~S),~Old.changed_run(~S,~Mode,~U32,~Resources(~S),~take(~S),~put(~S),~Unit,~Unit))
def guard_run(~S:Data) -> (Instance(~S) & (Bool & Unit)) -> World(~S) -> Cond.Evaluation<World(~S),Instance(~S) & (Bool & Unit)>:Cond.combined_run(~World(~S),~Instance(~S),~(Bool & Unit),~old_run(~S),~inner_run(~S),~True{})
def guard(~S:Data,bypass:Bool,instance:Instance(~S)) -> Cond.Condition<World(~S),Instance(~S) & (Bool & Unit),guard_run(~S)>:
  Cond.and_then(~World(~S),~Instance(~S),~(Bool & Unit),~old_run(~S),~inner_run(~S),Cond.lift(~World(~S),~Instance(~S),~Old.changed_run(~S,~Mode,~U32,~Resources(~S),~take(~S),~put(~S),~Unit,~Unit),Old.state_changed(~S,~Mode,~U32,~Resources(~S),~take(~S),~put(~S),~Unit,~Unit,instance)),inner(~S,bypass))
def Bound(~S:Data) -> Type:Bindings.BoundOwner<(Instance(~S) & (Bool & Unit))>
def select(~S:Data) -> Bound(~S) -> World(~S) -> U32 -> Bindings.Selection<World(~S),Bound(~S)>:Bindings.select(~World(~S),~(Instance(~S) & (Bool & Unit)),~guard_run(~S))
def Application(~S:Data) -> Type:Checked.Application<S,Unit,Resources(~S),Unit,Owners(~S),Rows(),observe(~S),fold(~S),Bound(~S),select(~S)>
def provision(~S:Data,world:World(~S)) -> World(~S) & List<&2,SP.Requirement<S>>:(world,[])
def plan(~S:Data) -> SP.Plan<S>:SP.Sequence{SP.Entry{Sch.Phase{"checked"},[]},SP.Sequence{SP.Entry{Sch.System{1,0},[]},SP.Sequence{SP.Entry{Sch.System{2,0},[]},SP.Entry{Sch.Barrier{},[]}}}}
def bound_attached(~S:Data,value:Checked.Attachment<Single.Application<S,Unit,Resources(~S),Unit,Owners(~S),Rows(),observe(~S),fold(~S)>,Bindings.Bindings<World(~S),Bound(~S),select(~S)>,Application(~S)>) -> Maybe<&1,Application(~S)>:
  match value:
    case Checked.Attached{app}:Some{app}
    case Checked.Invalid{_,_}:None{}
def scheduled(~S:Data,bypass:Bool,instance:Instance(~S),value:Single.Attachment<App.Application<S,Unit,Resources(~S),Unit,Owners(~S),Rows(),observe(~S),fold(~S)>,Single.Application<S,Unit,Resources(~S),Unit,Owners(~S),Rows(),observe(~S),fold(~S)>>) -> Maybe<&1,Application(~S)>:
  match value:
    case Single.Invalid{_}:None{}
    case Single.Attached{app}:bound_attached(~S,Checked.attach(~S,~Unit,~Resources(~S),~Unit,~Owners(~S),~Rows(),~observe(~S),~fold(~S),~Bound(~S),~select(~S),app,Bindings.bind(~World(~S),~(Instance(~S) & (Bool & Unit)),~guard_run(~S),1,guard(~S,bypass,instance))))
def machine_registered(~S:Data,bypass:Bool,schema:Schema.Schema<S,Unit,Resources(~S)>,owners:Owners(~S),recipe:Tree.Recipe<World(~S),Rows(),observe(~S)>,debug:Bool,result:Changed.Definition<S,Mode,U32,Unit,Resources(~S),Unit,take(~S),put(~S)>) -> Maybe<&1,Application(~S)>:
  match result:
    case Changed.Defined{world,instance}:scheduled(~S,bypass,instance,Single.attach(~S,~Unit,~Resources(~S),~Unit,~Owners(~S),~Rows(),~observe(~S),~fold(~S),App.Application{schema,Build.Registered{world,owners,recipe,debug}},"machine-check-unbound",plan(~S)))
    case Changed.DefinitionRejected{_}:None{}
def registered(~S:Data,bypass:Bool,app:Registered(~S)) -> Maybe<&1,Application(~S)>:
  match app:
    case Build.Registered{world,owners,recipe,debug}:machine_registered(~S,bypass,Schema.Schema{Binding.entries(~S,~Resources(~S),~Index(~S),schema(~S))},owners,recipe,debug,Changed.define(~S,~Mode,~U32,~Resources(~S),~take(~S),~put(~S),~Unit,~Unit,~machine_declaration(~S),world,"mode-changed"))
def second_rejected(~S:Data,_:First(~S)) -> Maybe<&1,Application(~S)>:None{}
def first_registered(~S:Data,bypass:Bool,app:First(~S)) -> Maybe<&1,Application(~S)>:
  AppField.register(~S,~Unit,~Resources(~S),~Unit,~FirstOwners(~S),~FirstRows(),~first_observe(~S),~first_fold(~S),~Ops(~S),~Unit,~String,~Unit,~U32,~declaration(~S),~body(~S),~Maybe<&1,Application(~S)>,registered(~S,bypass),second_rejected(~S),app,"unbound-B","Counter")
def rejected(~S:Data,_:Before(~S)) -> Maybe<&1,Application(~S)>:None{}
def register(~S:Data,bypass:Bool,world:World(~S)) -> Maybe<&1,Application(~S)>:
  AppField.register(~S,~Unit,~Resources(~S),~Unit,~Unit,~Unit,~Build.empty_observe(~World(~S)),~Leaf.empty(~S),~Ops(~S),~Unit,~String,~Unit,~U32,~declaration(~S),~body(~S),~Maybe<&1,Application(~S)>,first_registered(~S,bypass),rejected(~S),Build.empty(~S,~World(~S),world),"bound-A","Counter")
def insert(~S:Data,world:World(~S),value:U32) -> World(~S):Init.insert_state(~S,~Mode,~U32,~Resources(~S),~take(~S),~put(~S),~Unit,~Unit,~machine_declaration(~S),world,value)
def run(~S:Data,app:Application(~S)) -> Single.RunResult<Application(~S),S,CheckedError.Error<String>>:Checked.run(~S,~Unit,~Resources(~S),~Unit,~Owners(~S),~Rows(),~observe(~S),~fold(~S),~Bound(~S),~select(~S),~String,~dispatch(~S),~provision(~S),app)
def resources(~S:Data) -> Resources(~S):Product.Owner{ANode{ALeaf{10},ALeaf{11}},Product.Owner{Slot.Present{ANode{ALeaf{5},ALeaf{6}}},Init.empty(~S,~Mode,~U32)}}
def enabled(~S:Data,app:Application(~S),flag:Bool) -> Application(~S):Checked.enabled(~S,~Unit,~Resources(~S),~Unit,~Owners(~S),~Rows(),~observe(~S),~fold(~S),~Bound(~S),~select(~S),app,flag)
def snapshot(~S:Data,app:Application(~S)) -> Application(~S) & Maybe<&2,Checked.Description<S,Rows()>>:Checked.snapshot(~S,~Unit,~Resources(~S),~Unit,~Owners(~S),~Rows(),~observe(~S),~fold(~S),~Bound(~S),~select(~S),app)
def insert_app(~S:Data,app:Application(~S),value:U32) -> Application(~S):
  match app:
    case Checked.Application{Single.Application{App.Application{schema,Build.Registered{world,owners,recipe,debug}},plan,ns,name,steps,needs},guards}:Checked.Application{Single.Application{App.Application{schema,Build.Registered{insert(~S,world,value),owners,recipe,debug}},plan,ns,name,steps,needs},guards}
# Administrative removal uses the actual instance identity; the live condition
# owner remains affine and later reaches the lifted existing refusal transport.
def stale_returned(~S:Data,schema:Schema.Schema<S,Unit,Resources(~S)>,owners:Owners(~S),recipe:Tree.Recipe<World(~S),Rows(),observe(~S)>,debug:Bool,plan:SP.Plan<S>,ns:U32,name:String,steps:List<&2,Sch.Step>,needs:List<&2,SP.Requirement<S>>,guards:Bindings.Bindings<World(~S),Bound(~S),select(~S)>,removed:World(~S) & Bool) -> Application(~S) & Bool:
  (world,removed)=removed
  (Checked.Application{Single.Application{App.Application{schema,Build.Registered{world,owners,recipe,debug}},plan,ns,name,steps,needs},guards},removed)
def stale(~S:Data,app:Application(~S)) -> Application(~S) & Bool:
  match app:
    case Checked.Application{Single.Application{App.Application{schema,Build.Registered{world,owners,recipe,debug}},plan,ns,name,steps,needs},Bindings.Bindings{Bindings.BoundOwner{id,(Changed.Instance{Sys.Registry{+cns,+cid,+cname,+access,cursor},revision},other)},facts}}:stale_returned(~S,schema,owners,recipe,debug,plan,ns,name,steps,needs,Bindings.Bindings{Bindings.BoundOwner{id,(Changed.Instance{Sys.Registry{cns,cid,cname,access,cursor},revision},other)},facts},Reg.remove(~S,~Unit,~Resources(~S),~Unit,world,cns,cid,cname,access))
