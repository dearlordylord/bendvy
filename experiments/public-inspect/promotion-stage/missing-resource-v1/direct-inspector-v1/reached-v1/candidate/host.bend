import Base
import /workspace/formal-proofs/bendvy-worktrees/observable-query-boundaries/experiments/public-inspect/promotion-stage/missing-resource-v1/consumer-source-v1/state.bend as State
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-optional-resource.bend as O
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-optional-resource-declaration.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/check.bend as K
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-recipe.bend as Tree
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-registration-fields.bend as Records
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
import /workspace/formal-proofs/bendvy/src/ecs/resource-field.bend as Field
import /workspace/formal-proofs/bendvy/src/ecs/owner-product.bend as Product
import /workspace/formal-proofs/bendvy/src/ecs/resource-field-binding.bend as Binding
# The same closed canonical State binding/lens/view supplies the host grants.
def Ops(H:Type) -> Type:
  Cap.ValueRead<H,Maybe<&2,List<&2,U32>>>
def CounterOps(H:Type) -> Type:
  Cap.ValueRead<H,List<&2,U32>>
def InspectorOps(H:Type) -> Type:
  Cap.Bundle<Ops(H),CounterOps(H)>
def Output() -> Data:
  DTO.Product<Maybe<&2,List<&2,U32>>,List<&2,U32>>
def counter_shifted(result:Array<U32> & U32) -> Array<U32> & List<&2,U32>:
  match result:
    case (array,n):(array,[(n + 1 : U32)])
def counter_view(array:Array<U32>) -> Array<U32> & List<&2,U32>:
  counter_shifted(State.count(array))
def counter_project(~S:Data) -> State.Resource(~S) -> State.Resource(~S) & List<&2,U32>:
  Field.project(~State.Resource(~S),~Array<U32>,~((Unit & State.Slot(~S)) & Product.Owner<Array<U32>,Array<U32>>),~List<&2,U32>,~State.counter_lens(~S),~counter_view)
def counter_grant(~S:Data,binding:Binding.Binding<S,State.Resource(~S),Array<U32>,(Unit & State.Slot(~S)) & Product.Owner<Array<U32>,Array<U32>>,State.counter_lens(~S),State.counter(~S)>) -> CounterOps(I.Frame<S,Array<U32>,State.Resource(~S),U32>):
  I.read_resource(~S,~Array<U32>,~State.Resource(~S),~U32,~List<&2,U32>,~counter_project(~S))
def inspector_plan(~S:Data) -> I.Plan<S,Array<U32>,State.Resource(~S),U32,InspectorOps>:
  I.Plan{Cap.Bundle{O.inspect(~S,~Array<U32>,~State.Resource(~S),~U32,~Array<U32>,~(Unit & State.Tail()),~List<&2,U32>,~State.payload(~S),~State.slot_lens(~S),~State.view,~O.Declaration{}),counter_grant(~S,State.counter_binding(~S))}}
def required(~S:Data) -> W.World<S,Array<U32>,State.Resource(~S),U32> -> W.World<S,Array<U32>,State.Resource(~S),U32> & List<&2,String>:
  D.preflight(~S,~Array<U32>,~State.Resource(~S),~U32,~State.Ops(~S),~Maybe<&2,List<&2,U32>>,State.required_declaration(~S))
def check_plan(~S:Data) -> K.Plan<S,Array<U32>,State.Resource(~S),U32,Ops>:
  K.Plan{required(~S),O.condition(~S,~Array<U32>,~State.Resource(~S),~U32,~Array<U32>,~(Unit & State.Tail()),~List<&2,U32>,~State.payload(~S),~State.slot_lens(~S),~State.view,~O.Declaration{})}
def inspector_returned(~H:Type,value:Maybe<&2,List<&2,U32>>,result:H & List<&2,U32>) -> H & Result<&2,&2,Unit,Output()>:
  match result:
    case (owner,counter):(owner,Done{DTO.Product{value,counter}})
def inspector_optional(~H:Type,~counter:CounterOps(H),result:H & Maybe<&2,List<&2,U32>>) -> H & Result<&2,&2,Unit,Output()>:
  match result:
    case (owner,value):inspector_returned(~H,value,Cap.value_read(~H,~List<&2,U32>,~counter,owner))
def inspector_body(~H:Type,~cap:InspectorOps(H),args:Unit,owner:H) -> H & Result<&2,&2,Unit,Output()>:
  inspector_optional(~H,~Cap.second(~Ops(H),~CounterOps(H),cap),Cap.value_read(~H,~Maybe<&2,List<&2,U32>>,~Cap.first(~Ops(H),~CounterOps(H),cap),owner))
def present(value:Maybe<&2,List<&2,U32>>) -> Bool:
  match value:
    case None{}:False{}
    case Some{_}:True{}
def check_returned(~H:Type,result:H & Maybe<&2,List<&2,U32>>) -> H & Bool:
  match result:
    case (owner,value):(owner,present(value))
def check_body(~H:Type,~cap:Ops(H),args:Unit,owner:H) -> H & Bool:
  check_returned(~H,Cap.value_read(~H,~Maybe<&2,List<&2,U32>>,~cap,owner))
def instance_text(~S:Data,instance:I.Instance<S>) -> String:
  match instance:
    case I.Fresh{}:"Fresh"
    case I.Active{cursor,registeredAt}:"Active:" ++ U32.show(cursor) ++ ":" ++ U32.show(registeredAt)
type Observation is Data:
  Observation{first:Result<&2,&2,Unit,Output()>,firstInstance:String,second:Result<&2,&2,Unit,Output()>,secondInstance:String,check:Result<&2,&2,K.Error,Bool>}
type Carry<-S:Data> is Type:
  Carry{factory:W.Factory,instance:I.Instance<S>,observations:List<&2,Observation>}
def HostApp(~S:Data,~Owners:Type,~Rows:Data,~observe:W.World<S,Array<U32>,State.Resource(~S),U32> -> W.World<S,Array<U32>,State.Resource(~S),U32> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>) -> Type:
  Build.Registered<S,W.World<S,Array<U32>,State.Resource(~S),U32>,Owners,Rows,observe,fold>
def checked(~S:Data,~Owners:Type,~Rows:Data,~observe:W.World<S,Array<U32>,State.Resource(~S),U32> -> W.World<S,Array<U32>,State.Resource(~S),U32> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>,owners:Owners,recipe:Tree.Recipe<W.World<S,Array<U32>,State.Resource(~S),U32>,Rows,observe>,debug:Bool,factory:W.Factory,instance:I.Instance<S>,prior:List<&2,Observation>,first:Result<&2,&2,Unit,Output()>,firstInstance:String,second:Result<&2,&2,Unit,Output()>,secondInstance:String,result:K.Checked<S,Array<U32>,State.Resource(~S),U32>) -> HostApp(~S,~Owners,~Rows,~observe,~fold) & Carry<S>:
  match result:
    case K.Checked{world,outcome}:(Build.Registered{world,owners,recipe,debug},Carry{factory,instance,List.append(&2,Observation,prior,[Observation{first,firstInstance,second,secondInstance,outcome}])})
def second(~S:Data,~Owners:Type,~Rows:Data,~observe:W.World<S,Array<U32>,State.Resource(~S),U32> -> W.World<S,Array<U32>,State.Resource(~S),U32> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>,owners:Owners,recipe:Tree.Recipe<W.World<S,Array<U32>,State.Resource(~S),U32>,Rows,observe>,debug:Bool,factory:W.Factory,prior:List<&2,Observation>,first:Result<&2,&2,Unit,Output()>,firstInstance:String,result:I.Observed<S,Array<U32>,State.Resource(~S),U32,Unit,Output()>) -> HostApp(~S,~Owners,~Rows,~observe,~fold) & Carry<S>:
  match result:
    case I.Observed{world,I.Active{+cursor,+registeredAt},outcome}:checked(~S,~Owners,~Rows,~observe,~fold,owners,recipe,debug,factory,I.Active{cursor,registeredAt},prior,first,firstInstance,outcome,"Active:" ++ U32.show(cursor) ++ ":" ++ U32.show(registeredAt),K.run(~S,~Array<U32>,~State.Resource(~S),~U32,~Ops,~Unit,~check_body,~check_plan(~S),Unit{},world))
    case I.Observed{world,I.Fresh{},outcome}:checked(~S,~Owners,~Rows,~observe,~fold,owners,recipe,debug,factory,I.Fresh{},prior,first,firstInstance,outcome,"Fresh",K.run(~S,~Array<U32>,~State.Resource(~S),~U32,~Ops,~Unit,~check_body,~check_plan(~S),Unit{},world))
def first(~S:Data,~Owners:Type,~Rows:Data,~observe:W.World<S,Array<U32>,State.Resource(~S),U32> -> W.World<S,Array<U32>,State.Resource(~S),U32> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>,owners:Owners,recipe:Tree.Recipe<W.World<S,Array<U32>,State.Resource(~S),U32>,Rows,observe>,debug:Bool,factory:W.Factory,prior:List<&2,Observation>,result:I.Observed<S,Array<U32>,State.Resource(~S),U32,Unit,Output()>) -> HostApp(~S,~Owners,~Rows,~observe,~fold) & Carry<S>:
  match result:
    case I.Observed{world,I.Active{+cursor,+registeredAt},outcome}:second(~S,~Owners,~Rows,~observe,~fold,owners,recipe,debug,factory,prior,outcome,"Active:" ++ U32.show(cursor) ++ ":" ++ U32.show(registeredAt),I.run(~S,~Array<U32>,~State.Resource(~S),~U32,~InspectorOps,~Unit,~Unit,~Output(),~inspector_plan(~S),~inspector_body,I.Active{cursor,registeredAt},Unit{},world))
    case I.Observed{world,I.Fresh{},outcome}:second(~S,~Owners,~Rows,~observe,~fold,owners,recipe,debug,factory,prior,outcome,"Fresh",I.run(~S,~Array<U32>,~State.Resource(~S),~U32,~InspectorOps,~Unit,~Unit,~Output(),~inspector_plan(~S),~inspector_body,I.Fresh{},Unit{},world))
def probe(~S:Data,~Owners:Type,~Rows:Data,~observe:W.World<S,Array<U32>,State.Resource(~S),U32> -> W.World<S,Array<U32>,State.Resource(~S),U32> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>,app:HostApp(~S,~Owners,~Rows,~observe,~fold),carry:Carry<S>) -> HostApp(~S,~Owners,~Rows,~observe,~fold) & Carry<S>:
  match app carry:
    case Build.Registered{world,owners,recipe,debug} Carry{factory,instance,prior}:first(~S,~Owners,~Rows,~observe,~fold,owners,recipe,debug,factory,prior,I.run(~S,~Array<U32>,~State.Resource(~S),~U32,~InspectorOps,~Unit,~Unit,~Output(),~inspector_plan(~S),~inspector_body,instance,Unit{},world))
