import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-check-machine.bend as MC
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-machine-initialization.bend as Init
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-machine-declaration.bend as MD
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-machine-initialization-marker.bend as Marker
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-machine-operations.bend as MachineOps
import /workspace/formal-proofs/bendvy/src/ecs/machine-handlers.bend as Handlers
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as Machine
import /workspace/formal-proofs/bendvy/src/ecs/commands.bend as Cmd
import /workspace/formal-proofs/bendvy/src/ecs/schema-fragments.bend as Fragment
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import ./schema.bend as Model
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-check-query.bend as CQ
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query-projection.bend as Projection
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query.bend as ReadQuery
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as Cmp
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

def identity(~S:Data) -> Schema.Resource<S,Array<U32>>:Schema.resource(~S,~Array<U32>,"Counter")
def input_identity(~S:Data) -> Schema.Resource<S,Array<U32>>:Schema.resource(~S,~Array<U32>,"Threshold")
def sentinel_identity(~S:Data) -> Schema.Resource<S,Array<U32>>:Schema.resource(~S,~Array<U32>,"Sentinel")
def Input(~S:Data) -> Type:Slot.Slot<S,Array<U32>,input_identity(~S)>
def Siblings(~S:Data) -> Type:Product.Owner<Input(~S),Array<U32>>
def BaseResources(~S:Data) -> Type:Product.Owner<Array<U32>,Siblings(~S)>

def base_InputIndex(~S:Data) -> Data:Optional.Index<S,Array<U32>,input_identity(~S)>
def base_SiblingIndex(~S:Data) -> Data:Binding.Branch<Binding.Built<S,Input(~S),base_InputIndex(~S)>,Binding.Built<S,Array<U32>,Schema.Resource<S,Array<U32>>>>
def base_Index(~S:Data) -> Data:Binding.Branch<Binding.Built<S,Array<U32>,Schema.Resource<S,Array<U32>>>,Binding.Built<S,Siblings(~S),base_SiblingIndex(~S)>>
def base_schema(~S:Data) -> Binding.Built<S,BaseResources(~S),base_Index(~S)>:
  Binding.joined(~S,~Array<U32>,~Siblings(~S),~Schema.Resource<S,Array<U32>>,~base_SiblingIndex(~S),Binding.leaf(~S,~Array<U32>,identity(~S)),Binding.joined(~S,~Input(~S),~Array<U32>,~base_InputIndex(~S),~Schema.Resource<S,Array<U32>>,Optional.leaf(~S,~Array<U32>,input_identity(~S)),Binding.leaf(~S,~Array<U32>,sentinel_identity(~S))))
def view(value:Array<U32>) -> Array<U32> & U32:Array.get(U32,value,0)
type FlowToken is Data:FlowToken{}
def MachineState(~S:Data) -> Data:Init.State<S,FlowToken,U32>
def Resources(~S:Data) -> Type:Product.Owner<BaseResources(~S),MachineState(~S)>
def World(~S:Data) -> Type:W.World<S,Model.Store(~S),Resources(~S),Unit>
def Index(~S:Data) -> Data:Binding.Branch<Binding.Built<S,BaseResources(~S),base_Index(~S)>,Binding.Built<S,MachineState(~S),Unit>>
def schema(~S:Data) -> Binding.Built<S,Resources(~S),Index(~S)>:Binding.joined(~S,~BaseResources(~S),~MachineState(~S),~base_Index(~S),~Unit,base_schema(~S),Binding.Built{[],Unit{}})
def outer_lens(~S:Data) -> Product.Lens<Resources(~S),BaseResources(~S),Unit & MachineState(~S)>:Binding.left_lens(~Resources(~S),~BaseResources(~S),~MachineState(~S),~Unit,~Binding.whole(~Resources(~S)))
def base_cursor(~S:Data) -> Binding.Cursor<S,Resources(~S),BaseResources(~S),Unit & MachineState(~S),base_Index(~S),outer_lens(~S)>:Binding.left(~S,~Resources(~S),~BaseResources(~S),~MachineState(~S),~Unit,~base_Index(~S),~Unit,~Binding.whole(~Resources(~S)),Binding.root(~S,~Resources(~S),~Index(~S),schema(~S)))
def lens(~S:Data) -> Product.Lens<Resources(~S),Array<U32>,(Unit & MachineState(~S)) & Siblings(~S)>:Binding.left_lens(~Resources(~S),~Array<U32>,~Siblings(~S),~(Unit & MachineState(~S)),~outer_lens(~S))
def cursor(~S:Data) -> Binding.Cursor<S,Resources(~S),Array<U32>,(Unit & MachineState(~S)) & Siblings(~S),Schema.Resource<S,Array<U32>>,lens(~S)>:Binding.left(~S,~Resources(~S),~Array<U32>,~Siblings(~S),~(Unit & MachineState(~S)),~Schema.Resource<S,Array<U32>>,~base_SiblingIndex(~S),~outer_lens(~S),base_cursor(~S))
def binding(~S:Data) -> Binding.Binding<S,Resources(~S),Array<U32>,(Unit & MachineState(~S)) & Siblings(~S),lens(~S),identity(~S)>:Binding.bind(~S,~Resources(~S),~Array<U32>,~((Unit & MachineState(~S)) & Siblings(~S)),~lens(~S),~cursor(~S))
def right_lens(~S:Data) -> Product.Lens<Resources(~S),Siblings(~S),(Unit & MachineState(~S)) & Array<U32>>:Binding.right_lens(~Resources(~S),~Array<U32>,~Siblings(~S),~(Unit & MachineState(~S)),~outer_lens(~S))
def right_cursor(~S:Data) -> Binding.Cursor<S,Resources(~S),Siblings(~S),(Unit & MachineState(~S)) & Array<U32>,base_SiblingIndex(~S),right_lens(~S)>:Binding.right(~S,~Resources(~S),~Array<U32>,~Siblings(~S),~(Unit & MachineState(~S)),~Schema.Resource<S,Array<U32>>,~base_SiblingIndex(~S),~outer_lens(~S),base_cursor(~S))
def input_lens(~S:Data) -> Product.Lens<Resources(~S),Input(~S),((Unit & MachineState(~S)) & Array<U32>) & Array<U32>>:Binding.left_lens(~Resources(~S),~Input(~S),~Array<U32>,~((Unit & MachineState(~S)) & Array<U32>),~right_lens(~S))
def input_cursor(~S:Data) -> Binding.Cursor<S,Resources(~S),Input(~S),((Unit & MachineState(~S)) & Array<U32>) & Array<U32>,base_InputIndex(~S),input_lens(~S)>:Binding.left(~S,~Resources(~S),~Input(~S),~Array<U32>,~((Unit & MachineState(~S)) & Array<U32>),~base_InputIndex(~S),~Schema.Resource<S,Array<U32>>,~right_lens(~S),right_cursor(~S))
def input_binding(~S:Data) -> Optional.Binding<S,Resources(~S),Array<U32>,((Unit & MachineState(~S)) & Array<U32>) & Array<U32>,input_identity(~S),input_lens(~S)>:Optional.bind(~S,~Resources(~S),~Array<U32>,~(((Unit & MachineState(~S)) & Array<U32>) & Array<U32>),~input_identity(~S),~input_lens(~S),~input_cursor(~S))
def take_state(~S:Data,resource:Resources(~S)) -> Resources(~S) & MachineState(~S):
  match resource:
    case Product.Owner{base,+state}:(Product.Owner{base,state},state)
def put_state(~S:Data,resource:Resources(~S),state:MachineState(~S)) -> Resources(~S):
  match resource:
    case Product.Owner{base,_}:Product.Owner{base,state}
def take_slot(~S:Data) -> Resources(~S) -> Resources(~S) & Machine.Slot<S,FlowToken,U32>:Init.take_slot(~S,~FlowToken,~U32,~Resources(~S),~take_state(~S),~put_state(~S))
def put_slot(~S:Data) -> Resources(~S) -> Machine.Slot<S,FlowToken,U32> -> Resources(~S):Init.put_slot(~S,~FlowToken,~U32,~Resources(~S),~take_state(~S),~put_state(~S),~U32.is_eq)
def machine(~S:Data) -> MD.Declaration<S,FlowToken,U32,Resources(~S),take_slot(~S)>:Init.declared(~S,~FlowToken,~U32,~Resources(~S),~take_state(~S),~put_state(~S),"Mode",[0,1])
def MachineReadOps(~S:Data) -> Type -> Type:MC.Ops(~S,~FlowToken,~U32)
def optional_machine(~S:Data) -> CD.Declaration<S,Model.Store(~S),Resources(~S),Unit,MachineReadOps(~S)>:MC.optional(~S,~FlowToken,~U32,~Model.Store(~S),~Resources(~S),~Unit,~take_slot(~S),~machine(~S))
def required_machine(~S:Data) -> CD.Declaration<S,Model.Store(~S),Resources(~S),Unit,MachineReadOps(~S)>:MC.required(~S,~FlowToken,~U32,~Model.Store(~S),~Resources(~S),~Unit,~take_slot(~S),~machine(~S))
def Ops(~S:Data) -> Type -> Type:D.write_ops(~S,~Array<U32>,~identity(~S),~U32)
def declaration(~S:Data) -> D.Declaration<S,Model.Store(~S),Resources(~S),Unit,Ops(~S),U32>:
  D.write(~S,~Model.Store(~S),~Resources(~S),~Unit,~Array<U32>,~((Unit & MachineState(~S)) & Siblings(~S)),~U32,~lens(~S),~identity(~S),~binding(~S),~view,~U32.show)
def raw(~S:Data) -> Field.Declaration<S,T.Tx<World(~S),Unit>,Ops(~S)(T.Tx<World(~S),Unit>)>:D.ordinary(~S,~Model.Store(~S),~Resources(~S),~Unit,~Ops(~S),~U32,declaration(~S))
def body_got(~S:Data,~H:Type,~caps:Ops(~S)(H),result:H & U32) -> H & (T.Outcome<String> & Unit):
  match result:
    case (owner,+value):(Field.set(~S,~Array<U32>,~identity(~S),~H,~U32,~caps,owner,ANode{ALeaf{(value+1:U32)},ALeaf{(value+2:U32)}}),(T.Success{},Unit{}))
def body(~S:Data,~H:Type,~caps:Ops(~S)(H),_:Unit,owner:H) -> H & (T.Outcome<String> & Unit):body_got(~S,~H,~caps,Field.get(~S,~Array<U32>,~identity(~S),~H,~U32,~caps,owner))
def runner(~S:Data) -> World(~S) -> Unit -> Sys.Outcome<World(~S),String,Unit>:Field.runner(~S,~Model.Store(~S),~Resources(~S),~Unit,~Ops(~S),~Unit,~String,~Unit,~raw(~S),~body(~S))
def Registry(~S:Data) -> Type:Sys.Registry<S,Model.Store(~S),Resources(~S),Unit,Unit,String,Unit,runner(~S)>
def Owner(~S:Data) -> Type:Leaf.Record<S,Records.Token<Registry(~S)>>
def Owners(~S:Data) -> Type:Unit & Owner(~S)
def Rows() -> Data:DTO.Product<Unit,U32>
def observe(~S:Data) -> World(~S) -> World(~S) & DTO.Observation<Rows()>:Tree.observe_pair(~World(~S),~Unit,~U32,~Build.empty_observe(~World(~S)),~Leaves.resource_observe(~S,~Model.Store(~S),~Resources(~S),~Unit,~Ops(~S),~U32,~declaration(~S)))
def fold(~S:Data) -> Owners(~S) -> Owners(~S) & List<&2,Records.Fields<S>>:Leaf.fold_pair(~S,~Unit,~Owner(~S),~Leaf.empty(~S),~Leaf.observed(~S,~Records.Token<Registry(~S)>))
def Before(~S:Data) -> Type:Build.Registered<S,World(~S),Unit,Unit,Build.empty_observe(~World(~S)),Leaf.empty(~S)>
def Registered(~S:Data) -> Type:Build.Registered<S,World(~S),Owners(~S),Rows(),observe(~S),fold(~S)>
def dispatch_returned(~S:Data,prior:Unit,result:Transport.TransportResult<S,World(~S),Unit,String,Unit,Records.Token<Registry(~S)>>) -> Owners(~S) & Sys.Outcome<World(~S),String,Unit>:
  match result:
    case Transport.Completed{token,fields,outcome}:((prior,Leaf.Record{token,fields}),outcome)
    case Transport.RegistrationRejected{token,fields,world,_}:((prior,Leaf.Record{token,fields}),Sys.Failed{world,"registration"})
def dispatch(~S:Data,owners:Owners(~S),world:World(~S),id:U32) -> Owners(~S) & Sys.Outcome<World(~S),String,Unit>:
  match owners id:
    case (prior,Leaf.Record{token,fields}) 1:dispatch_returned(~S,prior,Transport.run(~S,~Model.Store(~S),~Resources(~S),~Unit,~Unit,~String,~Unit,~runner(~S),token,fields,world,Unit{}))
    case owners _:(owners,Sys.Failed{world,"unknown"})
type RowView is Data:RowView{primary:Cmp.Access<U32>,bonus:Cmp.Access<U32>}
def row_view(value:Projection.Product<Cmp.Access<U32>,Cmp.Access<U32>>) -> RowView:
  match value:
    case Projection.Product{primary,bonus}:RowView{primary,bonus}
def primary(~S:Data) -> CQ.Selection<K.Frame<S,Model.Store(~S),Resources(~S),Unit>,S,Cmp.Access<U32>>:CQ.read(~S,~Model.Store(~S),~Resources(~S),~Unit,~Model.primary_rest(~S),~Array<U32>,~U32,~Model.PrimaryToken,~Model.take_primary(~S),~Model.put_primary(~S),~Model.array_view,~Model.primary(~S))
def bonus(~S:Data) -> CQ.Selection<K.Frame<S,Model.Store(~S),Resources(~S),Unit>,S,Cmp.Access<U32>>:CQ.optional(~S,~Model.Store(~S),~Resources(~S),~Unit,~Model.bonus_rest(~S),~Array<U32>,~U32,~Model.BonusToken,~Model.take_bonus(~S),~Model.put_bonus(~S),~Model.array_view,~Model.bonus(~S))
def active(~S:Data) -> CQ.Predicate<K.Frame<S,Model.Store(~S),Resources(~S),Unit>,S>:CQ.with_component(~S,~Model.Store(~S),~Resources(~S),~Unit,~Model.active_rest(~S),~Unit,~Unit,~Model.ActiveToken,~Model.take_active(~S),~Model.put_active(~S),~Model.unit_view,~Model.active(~S))
def hidden(~S:Data) -> CQ.Predicate<K.Frame<S,Model.Store(~S),Resources(~S),Unit>,S>:CQ.without_component(~S,~Model.Store(~S),~Resources(~S),~Unit,~Model.hidden_rest(~S),~Unit,~Unit,~Model.HiddenToken,~Model.take_hidden(~S),~Model.put_hidden(~S),~Model.unit_view,~Model.hidden(~S))
def joined(~S:Data) -> CQ.Selection<K.Frame<S,Model.Store(~S),Resources(~S),Unit>,S,RowView>:
  CQ.map(~K.Frame<S,Model.Store(~S),Resources(~S),Unit>,~S,~Projection.Product<Cmp.Access<U32>,Cmp.Access<U32>>,~RowView,~CQ.constrain(~K.Frame<S,Model.Store(~S),Resources(~S),Unit>,~S,~Projection.Product<Cmp.Access<U32>,Cmp.Access<U32>>,~CQ.pair(~K.Frame<S,Model.Store(~S),Resources(~S),Unit>,~S,~Cmp.Access<U32>,~Cmp.Access<U32>,~primary(~S),~bonus(~S)),~CQ.both(~K.Frame<S,Model.Store(~S),Resources(~S),Unit>,~S,~active(~S),~hidden(~S))),~row_view)
def presence(~S:Data) -> CQ.Selection<K.Frame<S,Model.Store(~S),Resources(~S),Unit>,S,Unit>:CQ.constrain(~K.Frame<S,Model.Store(~S),Resources(~S),Unit>,~S,~Unit,~CQ.empty(~K.Frame<S,Model.Store(~S),Resources(~S),Unit>,~S),~active(~S))
def JoinOps(~S:Data) -> Type -> Type:CQ.Ops(~S,~RowView)
def PresenceOps(~S:Data) -> Type -> Type:CQ.Ops(~S,~Unit)
def joined_declaration(~S:Data) -> CD.Declaration<S,Model.Store(~S),Resources(~S),Unit,JoinOps(~S)>:CQ.declaration(~S,~Model.Store(~S),~Resources(~S),~Unit,~RowView,~joined(~S))
def presence_declaration(~S:Data) -> CD.Declaration<S,Model.Store(~S),Resources(~S),Unit,PresenceOps(~S)>:CQ.declaration(~S,~Model.Store(~S),~Resources(~S),~Unit,~Unit,~presence(~S))
def any_returned(~H:Type,~S:Data,~V:Data,result:H & List<&2,ReadQuery.ProjectedRow<S,V>>) -> H & Bool:
  match result:
    case (owner,[]):(owner,False{})
    case (owner,_ <> _):(owner,True{})
def any_present(~S:Data,~H:Type,~caps:PresenceOps(~S)(H),_:Unit,owner:H) -> H & Bool:any_returned(~H,~S,~Unit,CQ.each(~S,~Unit,~H,~caps,owner))
def positive_rows(~S:Data,threshold:U32,rows:List<&2,ReadQuery.ProjectedRow<S,RowView>>) -> Bool:
  match rows:
    case []:False{}
    case ReadQuery.ProjectedRow{_,RowView{Cmp.Found{value},_}} <> _:U32.is_lt(threshold,value)
    case _ <> _:False{}
def ThresholdOps(~S:Data) -> Type -> Type:CD.Ops(~S,~Array<U32>,~input_identity(~S),~U32)
def threshold_declaration(~S:Data) -> CD.Declaration<S,Model.Store(~S),Resources(~S),Unit,ThresholdOps(~S)>:CD.required_resource(~S,~Model.Store(~S),~Resources(~S),~Unit,~Array<U32>,~(((Unit & MachineState(~S)) & Array<U32>) & Array<U32>),~U32,~input_identity(~S),~input_lens(~S),~input_binding(~S),~view)
def MixedOps(~S:Data) -> Type -> Type:CD.PairOps(~JoinOps(~S),~ThresholdOps(~S))
def mixed_declaration(~S:Data) -> CD.Declaration<S,Model.Store(~S),Resources(~S),Unit,MixedOps(~S)>:CD.both(~S,~Model.Store(~S),~Resources(~S),~Unit,~JoinOps(~S),~ThresholdOps(~S),~joined_declaration(~S),~threshold_declaration(~S))
def positive_threshold(~H:Type,~S:Data,rows:List<&2,ReadQuery.ProjectedRow<S,RowView>>,result:H & Maybe<&2,U32>) -> H & Bool:
  match result:
    case (owner,None{}):(owner,False{})
    case (owner,Some{threshold}):(owner,positive_rows(~S,threshold,rows))
def positive_returned(~H:Type,~S:Data,~caps:ThresholdOps(~S)(H),result:H & List<&2,ReadQuery.ProjectedRow<S,RowView>>) -> H & Bool:
  match result:
    case (owner,rows):positive_threshold(~H,~S,rows,CD.read(~S,~Array<U32>,~input_identity(~S),~H,~U32,~caps,owner))
def query_positive(~S:Data,~H:Type,~caps:MixedOps(~S)(H),_:Unit,owner:H) -> H & Bool:positive_returned(~H,~S,~Cap.second(~JoinOps(~S)(H),~ThresholdOps(~S)(H),caps),CQ.each(~S,~RowView,~H,~Cap.first(~JoinOps(~S)(H),~ThresholdOps(~S)(H),caps),owner))
def AllOps(~S:Data) -> Type -> Type:CD.PairOps(~MixedOps(~S),~MachineReadOps(~S))
def all_declaration(~S:Data) -> CD.Declaration<S,Model.Store(~S),Resources(~S),Unit,AllOps(~S)>:CD.both(~S,~Model.Store(~S),~Resources(~S),~Unit,~MixedOps(~S),~MachineReadOps(~S),~mixed_declaration(~S),~required_machine(~S))
def guard_seen(~S:Data,~H:Type,value:H & Machine.CurrentView<S,FlowToken,U32>) -> H & Bool:
  match value:
    case (owner,Machine.Unavailable{}):(owner,False{})
    case (owner,Machine.Current{_}):(owner,True{})
def optional_body(~S:Data,~H:Type,~caps:MachineReadOps(~S)(H),bypass:Bool,owner:H) -> H & Bool:
  match bypass:
    case True{}:(owner,True{})
    case False{}:guard_seen(~S,~H,MC.read(~S,~FlowToken,~U32,~H,~caps,owner))
def machine_seen(~S:Data,~H:Type,query_ok:Bool,value:H & Machine.CurrentView<S,FlowToken,U32>) -> H & Bool:
  match value:
    case (owner,Machine.Unavailable{}):(owner,False{})
    case (owner,Machine.Current{current}):(owner,Bool.and(query_ok,U32.is_eq(current,0)))
def query_seen(~S:Data,~H:Type,~caps:MachineReadOps(~S)(H),value:H & Bool) -> H & Bool:
  match value:
    case (owner,query_ok):machine_seen(~S,~H,query_ok,MC.read(~S,~FlowToken,~U32,~H,~caps,owner))
def positive(~S:Data,~H:Type,~caps:AllOps(~S)(H),arg:Unit,owner:H) -> H & Bool:query_seen(~S,~H,~Cap.second(~MixedOps(~S)(H),~MachineReadOps(~S)(H),caps),query_positive(~S,~H,~Cap.first(~MixedOps(~S)(H),~MachineReadOps(~S)(H),caps),arg,owner))
def left_run(~S:Data) -> Bool -> World(~S) -> Cond.Evaluation<World(~S),Bool>:Cond.check_run(~S,~Model.Store(~S),~Resources(~S),~Unit,~MachineReadOps(~S),~Bool,~optional_body(~S),~optional_machine(~S))
def right_run(~S:Data) -> Unit -> World(~S) -> Cond.Evaluation<World(~S),Unit>:Cond.check_run(~S,~Model.Store(~S),~Resources(~S),~Unit,~AllOps(~S),~Unit,~positive(~S),~all_declaration(~S))
def guard_run(~S:Data) -> (Bool & Unit) -> World(~S) -> Cond.Evaluation<World(~S),Bool & Unit>:Cond.combined_run(~World(~S),~Bool,~Unit,~left_run(~S),~right_run(~S),~True{})
def guard(~S:Data) -> Cond.Condition<World(~S),Bool & Unit,guard_run(~S)>:Cond.and_then(~World(~S),~Bool,~Unit,~left_run(~S),~right_run(~S),Cond.check(~S,~Model.Store(~S),~Resources(~S),~Unit,~MachineReadOps(~S),~Bool,~optional_body(~S),~optional_machine(~S),"machine-presence-or-bypass",False{}),Cond.check(~S,~Model.Store(~S),~Resources(~S),~Unit,~AllOps(~S),~Unit,~positive(~S),~all_declaration(~S),"query-threshold-mode",Unit{}))
def Bound(~S:Data) -> Type:Bindings.BoundOwner<(Bool & Unit)>
def select(~S:Data) -> Bound(~S) -> World(~S) -> U32 -> Bindings.Selection<World(~S),Bound(~S)>:Bindings.select(~World(~S),~(Bool & Unit),~guard_run(~S))
def Application(~S:Data) -> Type:Checked.Application<S,Model.Store(~S),Resources(~S),Unit,Owners(~S),Rows(),observe(~S),fold(~S),Bound(~S),select(~S)>
def provision(~S:Data,world:World(~S)) -> World(~S) & List<&2,SP.Requirement<S>>:(world,[])
def plan(~S:Data) -> SP.Plan<S>:SP.Sequence{SP.Entry{Sch.Phase{"checked"},[]},SP.Sequence{SP.Entry{Sch.System{1,0},[]},SP.Entry{Sch.Barrier{},[]}}}
def bound_attached(~S:Data,value:Checked.Attachment<Single.Application<S,Model.Store(~S),Resources(~S),Unit,Owners(~S),Rows(),observe(~S),fold(~S)>,Bindings.Bindings<World(~S),Bound(~S),select(~S)>,Application(~S)>) -> Maybe<&1,Application(~S)>:
  match value:
    case Checked.Attached{app}:Some{app}
    case Checked.Invalid{_,_}:None{}
def scheduled(~S:Data,value:Single.Attachment<App.Application<S,Model.Store(~S),Resources(~S),Unit,Owners(~S),Rows(),observe(~S),fold(~S)>,Single.Application<S,Model.Store(~S),Resources(~S),Unit,Owners(~S),Rows(),observe(~S),fold(~S)>>) -> Maybe<&1,Application(~S)>:
  match value:
    case Single.Invalid{_}:None{}
    case Single.Attached{app}:bound_attached(~S,Checked.attach(~S,~Model.Store(~S),~Resources(~S),~Unit,~Owners(~S),~Rows(),~observe(~S),~fold(~S),~Bound(~S),~select(~S),app,Bindings.bind(~World(~S),~(Bool & Unit),~guard_run(~S),1,guard(~S))))
def registered(~S:Data,app:Registered(~S)) -> Maybe<&1,Application(~S)>:
  scheduled(~S,Single.attach(~S,~Model.Store(~S),~Resources(~S),~Unit,~Owners(~S),~Rows(),~observe(~S),~fold(~S),App.Application{Schema.Schema{List.append(&2,Fragment.Entry<S>,Model.component_entries(~S),Binding.entries(~S,~Resources(~S),~Index(~S),schema(~S)))},app},"guarded-counter",plan(~S)))
def rejected(~S:Data,_:Before(~S)) -> Maybe<&1,Application(~S)>:None{}
def register(~S:Data,world:World(~S)) -> Maybe<&1,Application(~S)>:
  AppField.register(~S,~Model.Store(~S),~Resources(~S),~Unit,~Unit,~Unit,~Build.empty_observe(~World(~S)),~Leaf.empty(~S),~Ops(~S),~Unit,~String,~Unit,~U32,~declaration(~S),~body(~S),~Maybe<&1,Application(~S)>,registered(~S),rejected(~S),Build.empty(~S,~World(~S),world),"increment","Counter")
def run(~S:Data,app:Application(~S)) -> Single.RunResult<Application(~S),S,CheckedError.Error<String>>:Checked.run(~S,~Model.Store(~S),~Resources(~S),~Unit,~Owners(~S),~Rows(),~observe(~S),~fold(~S),~Bound(~S),~select(~S),~String,~dispatch(~S),~provision(~S),app)
def enable(~S:Data,app:Application(~S),flag:Bool) -> Application(~S):Checked.enabled(~S,~Model.Store(~S),~Resources(~S),~Unit,~Owners(~S),~Rows(),~observe(~S),~fold(~S),~Bound(~S),~select(~S),app,flag)
def snapshot(~S:Data,app:Application(~S)) -> Application(~S) & Maybe<&2,Checked.Description<S,Rows()>>:Checked.snapshot(~S,~Model.Store(~S),~Resources(~S),~Unit,~Owners(~S),~Rows(),~observe(~S),~fold(~S),~Bound(~S),~select(~S),app)
def pair(+value:U32) -> Array<U32>:ANode{ALeaf{value},ALeaf{(value+1:U32)}}
def resources(~S:Data) -> Resources(~S):Product.Owner{Product.Owner{pair(10),Product.Owner{Slot.Present{pair(5)},pair(900)}},Init.empty(~S,~FlowToken,~U32)}
type Readout<S:Data> is Data:
  Readout{joined:List<&2,ReadQuery.ProjectedRow<S,RowView>>,presence:List<&2,ReadQuery.ProjectedRow<S,Unit>>,threshold:Maybe<&2,U32>}
def mixed_caps(~S:Data) -> MixedOps(~S)(K.Frame<S,Model.Store(~S),Resources(~S),Unit>):K.caps_field(~S,~Model.Store(~S),~Resources(~S),~Unit,~MixedOps(~S),CD.plan(~S,~Model.Store(~S),~Resources(~S),~Unit,~MixedOps(~S),mixed_declaration(~S)))
def presence_caps(~S:Data) -> PresenceOps(~S)(K.Frame<S,Model.Store(~S),Resources(~S),Unit>):K.caps_field(~S,~Model.Store(~S),~Resources(~S),~Unit,~PresenceOps(~S),CD.plan(~S,~Model.Store(~S),~Resources(~S),~Unit,~PresenceOps(~S),presence_declaration(~S)))
def readout_returned(~S:Data,joined:List<&2,ReadQuery.ProjectedRow<S,RowView>>,threshold:Maybe<&2,U32>,value:K.Frame<S,Model.Store(~S),Resources(~S),Unit> & List<&2,ReadQuery.ProjectedRow<S,Unit>>) -> World(~S) & Readout<S>:
  match value:
    case (K.Frame{world},presence):(world,Readout{joined,presence,threshold})
def readout_threshold(~S:Data,joined:List<&2,ReadQuery.ProjectedRow<S,RowView>>,value:K.Frame<S,Model.Store(~S),Resources(~S),Unit> & Maybe<&2,U32>) -> World(~S) & Readout<S>:
  match value:
    case (owner,threshold):readout_returned(~S,joined,threshold,CQ.each(~S,~Unit,~K.Frame<S,Model.Store(~S),Resources(~S),Unit>,~presence_caps(~S),owner))
def readout_joined(~S:Data,value:K.Frame<S,Model.Store(~S),Resources(~S),Unit> & List<&2,ReadQuery.ProjectedRow<S,RowView>>) -> World(~S) & Readout<S>:
  match value:
    case (owner,joined):readout_threshold(~S,joined,CD.read(~S,~Array<U32>,~input_identity(~S),~K.Frame<S,Model.Store(~S),Resources(~S),Unit>,~U32,~Cap.second(~JoinOps(~S)(K.Frame<S,Model.Store(~S),Resources(~S),Unit>),~ThresholdOps(~S)(K.Frame<S,Model.Store(~S),Resources(~S),Unit>),mixed_caps(~S)),owner))
# Trusted observation boundary only; gameplay receives the abstract grant.
def readout(~S:Data,world:World(~S)) -> World(~S) & Readout<S>:
  readout_joined(~S,CQ.each(~S,~RowView,~K.Frame<S,Model.Store(~S),Resources(~S),Unit>,~Cap.first(~JoinOps(~S)(K.Frame<S,Model.Store(~S),Resources(~S),Unit>),~ThresholdOps(~S)(K.Frame<S,Model.Store(~S),Resources(~S),Unit>),mixed_caps(~S)),K.Frame{world}))
# Fixture administration/observation retains every actual App field while
# temporarily threading its World through existing public setup/read grants.
type Rest<S:Data> is Type:
  Rest{schema:Schema.Schema<S,Model.Store(~S),Resources(~S)>,owners:Owners(~S),recipe:Tree.Recipe<World(~S),Rows(),observe(~S)>,debug:Bool,plan:SP.Plan<S>,namespace:U32,name:String,steps:List<&2,Sch.Step>,needs:List<&2,SP.Requirement<S>>,bindings:Bindings.Bindings<World(~S),Bound(~S),select(~S)>}
def take_world(~S:Data,app:Application(~S)) -> Rest<S> & World(~S):
  match app:
    case Checked.Application{Single.Application{App.Application{schema,Build.Registered{world,owners,recipe,debug}},plan,namespace,name,steps,needs},bindings}:(Rest{schema,owners,recipe,debug,plan,namespace,name,steps,needs,bindings},world)
def put_world(~S:Data,rest:Rest<S>,world:World(~S)) -> Application(~S):
  match rest:
    case Rest{schema,owners,recipe,debug,plan,namespace,name,steps,needs,bindings}:Checked.Application{Single.Application{App.Application{schema,Build.Registered{world,owners,recipe,debug}},plan,namespace,name,steps,needs},bindings}
type Views<S:Data> is Data:
  Views{query:Readout<S>,machine:Machine.CurrentView<S,FlowToken,U32>}
def optional_caps(~S:Data) -> MachineReadOps(~S)(K.Frame<S,Model.Store(~S),Resources(~S),Unit>):K.caps_field(~S,~Model.Store(~S),~Resources(~S),~Unit,~MachineReadOps(~S),CD.plan(~S,~Model.Store(~S),~Resources(~S),~Unit,~MachineReadOps(~S),optional_machine(~S)))
def viewed_machine(~S:Data,query:Readout<S>,value:K.Frame<S,Model.Store(~S),Resources(~S),Unit> & Machine.CurrentView<S,FlowToken,U32>) -> World(~S) & Views<S>:
  match value:
    case (K.Frame{world},machine):(world,Views{query,machine})
def viewed_query(~S:Data,value:World(~S) & Readout<S>) -> World(~S) & Views<S>:
  match value:
    case (world,query):viewed_machine(~S,query,MC.read(~S,~FlowToken,~U32,~K.Frame<S,Model.Store(~S),Resources(~S),Unit>,~optional_caps(~S),K.Frame{world}))
def views(~S:Data,world:World(~S)) -> World(~S) & Views<S>:viewed_query(~S,readout(~S,world))
# No handler entry is installed. This closed administrative runner is only the
# existing engine's empty handler-owner index, not a gameplay World callback.
def handler_runner(~S:Data,world:World(~S),_:Handlers.Invocation<U32>) -> Sys.Outcome<World(~S),String,Unit>:Sys.Succeeded{world,Unit{}}
def TransitionOwners(~S:Data) -> Type:Handlers.Owners<S,Model.Store(~S),Resources(~S),Unit,U32,handler_runner(~S)>
def transition_owners(~S:Data) -> TransitionOwners(~S):Handlers.Owners{[],[],[]}
def marker_take(~S:Data) -> World(~S) -> World(~S) & Machine.Slot<S,FlowToken,U32>:Marker.take_world(~S,~FlowToken,~U32,~Resources(~S),~take_state(~S),~put_state(~S),~Model.Store(~S),~Unit)
def marker_put(~S:Data) -> World(~S) -> Machine.Slot<S,FlowToken,U32> -> World(~S):Marker.put_world(~S,~FlowToken,~U32,~Resources(~S),~take_state(~S),~put_state(~S),~Model.Store(~S),~Unit,~U32.is_eq)
def marker_publish(~S:Data) -> World(~S) -> Machine.Transition<U32> -> World(~S):Marker.publish(~S,~FlowToken,~U32,~Resources(~S),~take_state(~S),~put_state(~S),~Model.Store(~S),~Unit)
type TransitionResult<S:Data> is Type:
  TransitionResult{captured:Machine.Snapshot<U32>,result:Handlers.HandlerResult<S,Model.Store(~S),Resources(~S),Unit,U32,handler_runner(~S)>}
def transition_captured(~S:Data,owners:TransitionOwners(~S),world:World(~S),+captured:Machine.Snapshot<U32>) -> TransitionResult<S>:
  TransitionResult{captured,Handlers.run(~S,~Model.Store(~S),~Resources(~S),~Unit,~U32,~handler_runner(~S),~FlowToken,~marker_take(~S),~marker_put(~S),~marker_publish(~S),~U32.is_eq,owners,world,captured)}
def transition_taken(~S:Data,owners:TransitionOwners(~S),value:World(~S) & Machine.Slot<S,FlowToken,U32>) -> TransitionResult<S>:
  match value:
    case (world,+slot):transition_captured(~S,owners,world,Machine.snapshot(~S,~FlowToken,~U32,slot))
def transition(~S:Data,owners:TransitionOwners(~S),world:World(~S)) -> TransitionResult<S>:transition_taken(~S,owners,marker_take(~S)(world))
def queue(~S:Data,world:World(~S),value:U32) -> T.Returned<World(~S),Unit>:
  Cmd.tx_finish(~S,~Model.Store(~S),~Resources(~S),~Unit,~Unit,Cap.value_set(~T.Tx<World(~S),Unit>,~Machine.QueueInput<U32>,~Machine.CurrentView<S,FlowToken,U32>,~MachineOps.write(~S,~FlowToken,~U32,~Model.Store(~S),~Resources(~S),~Unit,~take_slot(~S),~put_slot(~S),~U32.is_eq,~machine(~S)),T.begin(~World(~S),~Unit,world),Machine.Set{value,False{}}),T.Success{})
def insert(~S:Data,world:World(~S),value:U32) -> World(~S):Init.insert_state(~S,~FlowToken,~U32,~Resources(~S),~take_state(~S),~put_state(~S),~Model.Store(~S),~Unit,~machine(~S),world,value)
def machine_lens(~S:Data) -> Product.Lens<Resources(~S),MachineState(~S),Unit & BaseResources(~S)>:Binding.right_lens(~Resources(~S),~BaseResources(~S),~MachineState(~S),~Unit,~Binding.whole(~Resources(~S)))
def bypass(~S:Data,app:Application(~S),flag:Bool) -> Application(~S):
  match app:
    case Checked.Application{app,Bindings.Bindings{Bindings.BoundOwner{id,(_,unit)},facts}}:Checked.Application{app,Bindings.Bindings{Bindings.BoundOwner{id,(flag,unit)},facts}}
