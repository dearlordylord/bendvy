import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-machine-initialization.bend as Init
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as Machine
import /workspace/formal-proofs/bendvy/src/ecs/machine-handlers.bend as H
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/experiments/public-captured-schedules/ordinary-v1/conditions-v1/state.bend as MachineDump
import fixture.bend as F
import schema.bend as Model
import setup.bend as Setup
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as Cmp
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query.bend as ReadQuery
import /workspace/formal-proofs/bendvy/experiments/public-audit61/app-a-owned-handoff-v1/owner-observer.bend as Dump
import /workspace/formal-proofs/bendvy/experiments/public-audit61/app-a-owned-handoff-v1/capture-observe.bend as OldDump
import /workspace/formal-proofs/bendvy/experiments/public-recovery/automatic-app-v1/observe.bend as Common
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/owner-product.bend as Product
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-optional-resource.bend as Slot
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-checked-condition.bend as Cond
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-check-declaration.bend as CD
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-checked-bindings.bend as Bindings
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-checked-schedule.bend as Checked
import /workspace/formal-proofs/bendvy/src/ecs/checked-condition-schedule.bend as CheckedError
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schedule.bend as Single
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schema.bend as App
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-recipe.bend as Tree
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/schema-fragments.bend as Fragment
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-records.bend as Leaf
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-registration-fields.bend as Records
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-query-declaration.bend as Query
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as SP
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
import /workspace/formal-proofs/bendvy/src/ecs/check.bend as K

def strings(values:List<&2,String>) -> String:List.show(&2,String,x=>x,values)
def unit(value:Unit) -> String:"Unit"
def slot_join(~S:Data,result:Array<U32> & String) -> F.Input(~S) & String:
  (owner,text)=result
  (Slot.Present{owner},"Present{" ++ text ++ "}")
def input(~S:Data,value:F.Input(~S)) -> F.Input(~S) & String:
  match value:
    case Slot.Missing{}:(Slot.Missing{},"Missing")
    case Slot.Present{owner}:slot_join(~S,Dump.u32_array(owner))
def resources_join(~S:Data,a:Array<U32> & String,b:F.Input(~S) & String,c:Array<U32> & String) -> F.BaseResources(~S) & String:
  (a,at)=a
  (b,bt)=b
  (c,ct)=c
  (Product.Owner{a,Product.Owner{b,c}},"Counter=" ++ at ++ ";Threshold=" ++ bt ++ ";Sentinel=" ++ ct)
def base_resources(~S:Data,value:F.BaseResources(~S)) -> F.BaseResources(~S) & String:
  match value:
    case Product.Owner{a,Product.Owner{b,c}}:resources_join(~S,Dump.u32_array(a),input(~S,b),Dump.u32_array(c))
def slot(~S:Data,value:Machine.Slot<S,F.FlowToken,U32>) -> String:
  match value:
    case Machine.Missing{}:"Missing"
    case Machine.Present{current,next,last,changed}:"Present{current=" ++ U32.show(current) ++ ";next=" ++ MachineDump.pending(next) ++ ";previous=" ++ MachineDump.previous(last) ++ ";changed=" ++ Bool.show(changed) ++ "}"
def machine(~S:Data,value:F.MachineState(~S)) -> String:
  match value:
    case Init.State{current,stream,revision}:"MachineState{slot=" ++ slot(~S,current) ++ ";stream=" ++ MachineDump.stream(stream) ++ ";revision=" ++ Nat.show(revision) ++ "}"
def resources_complete(~S:Data,+state:F.MachineState(~S),observed:F.BaseResources(~S) & String) -> F.Resources(~S) & String:
  (base,text)=observed
  (Product.Owner{base,state},"Base={" ++ text ++ "};machine={" ++ machine(~S,state) ++ "}")
def resources(~S:Data,value:F.Resources(~S)) -> F.Resources(~S) & String:
  match value:
    case Product.Owner{base,state}:resources_complete(~S,state,base_resources(~S,base))
def unit_owner(value:Unit) -> Unit & String:(value,"Unit")
def store_join(~S:Data,a:Col.Column<S,Array<U32>> & String,b:Col.Column<S,Array<U32>> & String,c:Col.Column<S,Unit> & String,d:Col.Column<S,Unit> & String) -> Model.Store(~S) & String:
  (a,at)=a
  (b,bt)=b
  (c,ct)=c
  (d,dt)=d
  (Model.Columns{a,b,c,d},"Primary={" ++ at ++ "};Bonus={" ++ bt ++ "};Active={" ++ ct ++ "};Hidden={" ++ dt ++ "}")
def store(~S:Data,value:Model.Store(~S)) -> Model.Store(~S) & String:
  match value:
    case Model.Columns{a,b,c,d}:store_join(~S,Dump.column(~S,~Array<U32>,~Dump.u32_array,a),Dump.column(~S,~Array<U32>,~Dump.u32_array,b),Dump.column(~S,~Unit,~unit_owner,c),Dump.column(~S,~Unit,~unit_owner,d))
def world_join(~S:Data,+ns:U32,+next:U32,+high:U32,+capacity:U32,+depth:Nat,+events:List<&2,Unit>,+regs:List<&2,W.RegistrationMeta>,+sid:U32,+clock:U32,a:Array<Bool> & String,b:F.Resources(~S) & String,c:List<(F.World(~S) -> F.World(~S))> & Nat,d:Model.Store(~S) & String) -> F.World(~S) & String:
  (live,lt)=a
  (resource,rt)=b
  (pending,count)=c
  (store,st)=d
  (W.World{ns,next,high,live,capacity,depth,store,resource,events,pending,regs,sid,clock},"world{namespace=" ++ U32.show(ns) ++ ";nextId=" ++ U32.show(next) ++ ";highWater=" ++ U32.show(high) ++ ";live=" ++ lt ++ ";capacity=" ++ U32.show(capacity) ++ ";depth=" ++ Nat.show(depth) ++ ";store={" ++ st ++ "};resources={" ++ rt ++ "};events=" ++ List.show(&2,Unit,unit,events) ++ ";pending=" ++ Nat.show(count) ++ ";registrations=" ++ List.show(&2,W.RegistrationMeta,Dump.registration,regs) ++ ";nextSystemId=" ++ U32.show(sid) ++ ";clock=" ++ U32.show(clock) ++ "}")
def world(~S:Data,value:F.World(~S)) -> F.World(~S) & String:
  match value:
    case W.World{ns,next,high,live,capacity,depth,column,resource,events,pending,regs,sid,clock}:world_join(~S,ns,next,high,capacity,depth,events,regs,sid,clock,Dump.bool_array(live),resources(~S,resource),Dump.callbacks(~F.World(~S),~F.World(~S),pending),store(~S,column))
def component_selection(value:CD.ComponentSelection) -> String:
  match value:
    case CD.Required{}:"Required"
    case CD.Optional{}:"Optional"
    case CD.With{}:"With"
    case CD.Without{}:"Without"
def use(value:CD.Use) -> String:
  match value:
    case CD.Use{CD.Machine{},key,CD.Read{},required}:"Machine{" ++ key ++ ";mode=Read;required=" ++ Bool.show(required) ++ "}"
    case CD.Use{CD.Resource{},key,CD.Read{},required}:"Resource{" ++ key ++ ";mode=Read;required=" ++ Bool.show(required) ++ "}"
    case CD.Use{CD.Component{selection},key,CD.Read{},required}:"Component{" ++ component_selection(selection) ++ ";key=" ++ key ++ ";mode=Read;required=" ++ Bool.show(required) ++ "}"
def shape(value:Cond.Shape) -> String:
  match value:
    case Cond.Existing{facts}:"Existing{" ++ OldDump.description(facts) ++ "}"
    case Cond.Check{name}:"Check{" ++ name ++ "}"
    case Cond.Constant{value}:"Constant{" ++ Bool.show(value) ++ "}"
    case Cond.Not{inner}:"Not{" ++ shape(inner) ++ "}"
    case Cond.And{left,right}:"And{" ++ shape(left) ++ "," ++ shape(right) ++ "}"
    case Cond.Or{left,right}:"Or{" ++ shape(left) ++ "," ++ shape(right) ++ "}"
def description(value:Cond.Description) -> String:
  match value:
    case Cond.Description{value,uses}:"description{shape=" ++ shape(value) ++ ";uses=" ++ List.show(&2,CD.Use,use,uses) ++ "}"
def binding(value:Bindings.Description) -> String:
  match value:
    case Bindings.Description{id,facts}:"binding{systemId=" ++ U32.show(id) ++ ";" ++ description(facts) ++ "}"
def conditions(~S:Data,value:Bindings.Bindings<F.World(~S),F.Bound(~S),F.select(~S)>) -> Bindings.Bindings<F.World(~S),F.Bound(~S),F.select(~S)> & String:
  match value:
    case Bindings.Bindings{Bindings.BoundOwner{+id,(+bypass,Unit{})},+facts}:(Bindings.Bindings{Bindings.BoundOwner{id,(bypass,Unit{})},facts},"guards{systemId=" ++ U32.show(id) ++ ";optionalMachineOwner=" ++ Bool.show(bypass) ++ ";requiredJoinedOwner=Unit;descriptions=" ++ List.show(&2,Bindings.Description,binding,facts) ++ "}")
def category(value:Records.UseCategory) -> String:
  match value:
    case Records.ComponentUse{}:"Component"
    case Records.ResourceUse{}:"Resource"
    case Records.EventUse{}:"Event"
def source(value:Records.ReaderSource) -> String:
  match value:
    case Records.QuerySource{}:"Query"
    case Records.MessageSource{}:"Message"
    case Records.RemovalSource{}:"Removal"
    case Records.RelationFailureSource{}:"RelationFailure"
def declared_use(value:Records.DeclaredUse) -> String:
  match value:
    case Records.DeclaredUse{cat,src,key,mode}:category(cat) ++ ":" ++ source(src) ++ ":" ++ key ++ ":" ++ Common.mode(mode)
def kind(value:Records.RegistrationKind) -> String:
  match value:
    case Records.ComponentKind{}:"Component"
    case Records.ResourceKind{mode}:"Resource{" ++ Common.mode(mode) ++ "}"
    case Records.FieldKind{}:"Field"
    case Records.ServiceKind{}:"Service"
    case Records.EventKind{}:"Event"
    case Records.MixedKind{uses}:"Mixed{" ++ List.show(&2,Records.DeclaredUse,declared_use,uses) ++ "}"
def fields(~S:Data,value:Records.Fields<S>) -> String:
  match value:
    case Records.Fields{ns,id,name,access,cursor,slot,clauses,k}:"fields{" ++ Common.identity(ns,id,name,access,cursor) ++ ";slot=" ++ slot ++ ";clauses=" ++ List.show(&2,Query.Clause<S>,Common.clause(~S),clauses) ++ ";kind=" ++ kind(k) ++ "}"
def owners(~S:Data,value:F.Owners(~S)) -> F.Owners(~S) & String:
  match value:
    case (Unit{},Leaf.Record{Records.Token{},+facts}):((Unit{},Leaf.Record{Records.Token{},facts}),"owners{previous=Unit;token=Token;" ++ fields(~S,facts) ++ "}")
def registry_kind(value:Fragment.RegistryKind) -> String:
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
def schema_entry(~S:Data,value:Fragment.Entry<S>) -> String:
  match value:
    case Fragment.Entry{cat,key,name}:"Entry{" ++ registry_kind(cat) ++ ":" ++ key ++ ":" ++ name ++ "}"
    case Fragment.Classified{cat,key,name,p}:"Classified{" ++ registry_kind(cat) ++ ":" ++ key ++ ":" ++ name ++ ":" ++ persistence(p) ++ "}"
def requirement(~S:Data,value:SP.Requirement<S>) -> String:
  match value:
    case SP.Component{id}:"Component{" ++ U32.show(id) ++ "}"
    case SP.Resource{id}:"Resource{" ++ U32.show(id) ++ "}"
    case SP.Service{id}:"Service{" ++ U32.show(id) ++ "}"
def step(value:Sch.Step) -> String:
  match value:
    case Sch.System{id,condition}:"System{" ++ U32.show(id) ++ "," ++ U32.show(condition) ++ "}"
    case Sch.Phase{name}:"Phase{" ++ name ++ "}"
    case Sch.Barrier{}:"Barrier"
def plan(~S:Data,value:SP.Plan<S>) -> String:
  match value:
    case SP.Empty{}:"Empty"
    case SP.Entry{s,needs}:"Entry{" ++ step(s) ++ ";needs=" ++ List.show(&2,SP.Requirement<S>,requirement(~S),needs) ++ "}"
    case SP.Sequence{left,right}:"Sequence{" ++ plan(~S,left) ++ "," ++ plan(~S,right) ++ "}"
def app_join(~S:Data,+entries:List<&2,Fragment.Entry<S>>,+debug:Bool,+p:SP.Plan<S>,+ns:U32,+name:String,+steps:List<&2,Sch.Step>,+needs:List<&2,SP.Requirement<S>>,a:F.World(~S) & String,b:F.Owners(~S) & String,c:Bindings.Bindings<F.World(~S),F.Bound(~S),F.select(~S)> & String) -> F.Application(~S) & String:
  (current,wt)=a
  (owned,ot)=b
  (guards,gt)=c
  (Checked.Application{Single.Application{App.Application{Schema.Schema{entries},Build.Registered{current,owned,Tree.Recipe{},debug}},p,ns,name,steps,needs},guards},"app{schema=" ++ List.show(&2,Fragment.Entry<S>,schema_entry(~S),entries) ++ ";debug=" ++ Bool.show(debug) ++ ";recipe=Recipe;plan=" ++ plan(~S,p) ++ ";namespace=" ++ U32.show(ns) ++ ";name=" ++ name ++ ";steps=" ++ List.show(&2,Sch.Step,step,steps) ++ ";needs=" ++ List.show(&2,SP.Requirement<S>,requirement(~S),needs) ++ "|" ++ wt ++ "|" ++ ot ++ "|" ++ gt ++ "}")
def app(~S:Data,value:F.Application(~S)) -> F.Application(~S) & String:
  match value:
    case Checked.Application{Single.Application{App.Application{Schema.Schema{entries},Build.Registered{current,owned,Tree.Recipe{},debug}},p,ns,name,steps,needs},guards}:app_join(~S,entries,debug,p,ns,name,steps,needs,world(~S,current),owners(~S,owned),conditions(~S,guards))
def planned(~S:Data,value:Single.PlannedStep<S>) -> String:
  match value:
    case Single.PlannedStep{s,needs}:"planned{" ++ step(s) ++ ";needs=" ++ List.show(&2,SP.Requirement<S>,requirement(~S),needs) ++ "}"
def snapshot(~S:Data,value:Maybe<&2,Checked.Description<S,F.Rows()>>) -> String:
  match value:
    case None{}:"None"
    case Some{Checked.Description{Single.Description{App.Description{entries,DTO.Product{bindings,DTO.Observation{DTO.Product{Unit{},row},rendered}}},ns,name,steps},facts}}:"Some{schema=" ++ List.show(&2,Fragment.Entry<S>,schema_entry(~S),entries) ++ ";bindings=" ++ List.show(&2,DTO.Binding<S>,Common.binding(~S),bindings) ++ ";rows=Product{Unit," ++ U32.show(row) ++ "};rendered=" ++ strings(rendered) ++ ";namespace=" ++ U32.show(ns) ++ ";name=" ++ name ++ ";steps=" ++ List.show(&2,Single.PlannedStep<S>,planned(~S),steps) ++ ";checkedBindings=" ++ List.show(&2,Bindings.Description,binding,facts) ++ "}"
def check_error(value:K.Error) -> String:
  match value:
    case K.MissingRuntimeRequirements{resources}:"MissingRuntimeRequirements{" ++ strings(resources) ++ "}"
def condition_error(value:Cond.Error) -> String:
  match value:
    case Cond.CheckError{error}:"CheckError{" ++ check_error(error) ++ "}"
    case Cond.NoValue{}:"NoValue"
    case Cond.InvalidRegistration{}:"InvalidRegistration"
    case Cond.NoBinding{}:"NoBinding"
def result(value:Result<&2,&2,Cond.Error,Bool>) -> String:
  match value:
    case Done{value}:"Done{" ++ Bool.show(value) ++ "}"
    case Fail{error}:"Fail{" ++ condition_error(error) ++ "}"
def run_observation(value:Sch.Observation) -> String:
  match value:
    case Sch.Entered{name}:"Entered{" ++ name ++ "}"
    case Sch.Ran{id}:"Ran{" ++ U32.show(id) ++ "}"
    case Sch.Skipped{id}:"Skipped{" ++ U32.show(id) ++ "}"
    case Sch.Applied{}:"Applied"
def run_observations(value:List<&2,Sch.Observation>) -> String:List.show(&2,Sch.Observation,run_observation,value)
def run_error(value:CheckedError.Error<String>) -> String:
  match value:
    case CheckedError.SystemError{error}:"SystemError{" ++ error ++ "}"
    case CheckedError.CheckError{error}:"CheckError{" ++ check_error(error) ++ "}"
    case CheckedError.ConditionUnavailable{}:"ConditionUnavailable"
    case CheckedError.ConditionRegistrationRejected{}:"ConditionRegistrationRejected"
def reservation(~S:Data,value:W.Reservation<S>) -> String:
  match value:
    case W.Reserved{handle}:"Reserved{" ++ Common.handle(~S,handle) ++ "}"
    case W.ReservationRejected{error}:"ReservationRejected{" ++ Common.world_error(error) ++ "}"
def status(value:W.Status) -> String:
  match value:
    case W.Accepted{}:"Accepted"
    case W.Rejected{error}:"Rejected{" ++ Common.world_error(error) ++ "}"
def fact(~S:Data,value:Setup.Fact<S>) -> String:
  match value:
    case Setup.Reserved{value}:"Reserve:" ++ reservation(~S,value)
    case Setup.Activated{value}:"Activate:" ++ status(value)
    case Setup.Replaced{key}:"Replaced{" ++ key ++ "}"
    case Setup.Rejected{key,error}:"Rejected{" ++ key ++ ":" ++ Common.world_error(error) ++ "}"
def owned_join(~S:Data,+handles:List<&2,W.Handle<S>>,+facts:List<&2,Setup.Fact<S>>,a:List<Maybe<&1,Array<U32>>> & String,b:List<Maybe<&1,Unit>> & String) -> Setup.Owned<S> & String:
  (arrays,at)=a
  (units,ut)=b
  (Setup.Owned{handles,arrays,units,facts},"setup{handles=" ++ List.show(&2,W.Handle<S>,Common.handle(~S),handles) ++ ";returnedArrays=" ++ at ++ ";returnedUnits=" ++ ut ++ ";facts=" ++ List.show(&2,Setup.Fact<S>,fact(~S),facts) ++ "}")
def owned(~S:Data,value:Setup.Owned<S>) -> Setup.Owned<S> & String:
  match value:
    case Setup.Owned{handles,arrays,units,facts}:owned_join(~S,handles,facts,Common.items(~Maybe<&1,Array<U32>>,~Dump.optional(~Array<U32>,~Dump.u32_array),arrays),Common.items(~Maybe<&1,Unit>,~Dump.optional(~Unit,~unit_owner),units))
def setup(~S:Data,value:Setup.Owned<S>) -> Setup.Owned<S> & String:owned(~S,value)
def access(value:Cmp.Access<U32>) -> String:
  match value:
    case Cmp.MissingEntity{}:"MissingEntity"
    case Cmp.ComponentAbsent{}:"ComponentAbsent"
    case Cmp.Found{value}:"Found{" ++ U32.show(value) ++ "}"
def row_view(value:F.RowView) -> String:
  match value:
    case F.RowView{primary,bonus}:"RowView{primary=" ++ access(primary) ++ ";bonus=" ++ access(bonus) ++ "}"
def queryrow(~S:Data,value:ReadQuery.ProjectedRow<S,F.RowView>) -> String:
  match value:
    case ReadQuery.ProjectedRow{handle,value}:"row{handle=" ++ Common.handle(~S,handle) ++ ";" ++ row_view(value) ++ "}"
def queryrows(~S:Data,values:List<&2,ReadQuery.ProjectedRow<S,F.RowView>>) -> String:List.show(&2,ReadQuery.ProjectedRow<S,F.RowView>,queryrow(~S),values)
def presence_row(~S:Data,value:ReadQuery.ProjectedRow<S,Unit>) -> String:
  match value:
    case ReadQuery.ProjectedRow{handle,Unit{}}:"row{handle=" ++ Common.handle(~S,handle) ++ ";value=Unit}"
def threshold(value:Maybe<&2,U32>) -> String:
  match value:
    case None{}:"None"
    case Some{value}:"Some{" ++ U32.show(value) ++ "}"
def readout(~S:Data,value:F.Readout<S>) -> String:
  match value:
    case F.Readout{joined,presence,value}:"readout{joined=" ++ queryrows(~S,joined) ++ ";presence=" ++ List.show(&2,ReadQuery.ProjectedRow<S,Unit>,presence_row(~S),presence) ++ ";threshold=" ++ threshold(value) ++ "}"
def current_view(~S:Data,value:Machine.CurrentView<S,F.FlowToken,U32>) -> String:
  match value:
    case Machine.Unavailable{}:"Unavailable"
    case Machine.Current{value}:"Current{" ++ U32.show(value) ++ "}"
def views(~S:Data,value:F.Views<S>) -> String:
  match value:
    case F.Views{query,machine}:"views{query=" ++ readout(~S,query) ++ ";machine=" ++ current_view(~S,machine) ++ "}"
def state_owner(~S:Data,+value:F.MachineState(~S)) -> F.MachineState(~S) & String:(value,machine(~S,value))
def state_value(~S:Data,value:F.MachineState(~S)) -> F.MachineState(~S) & String:state_owner(~S,value)
def states(~S:Data,value:List<F.MachineState(~S)>) -> List<F.MachineState(~S)> & String:Common.items(~F.MachineState(~S),~state_value(~S),value)
def HandlerEntry(~S:Data) -> Type:H.Entry<S,Model.Store(~S),F.Resources(~S),Unit,U32,F.handler_runner(~S)>
def handler_entry(~S:Data,value:HandlerEntry(~S)) -> HandlerEntry(~S) & String:
  match value:
    case H.Entry{+ordinal,Sys.Registry{+ns,+id,+name,+access,+cursor}}:(H.Entry{ordinal,Sys.Registry{ns,id,name,access,cursor}},"handler{ordinal=" ++ U32.show(ordinal) ++ ";" ++ Common.identity(ns,id,name,access,cursor) ++ "}")
def transition_owners_join(~S:Data,a:List<HandlerEntry(~S)> & String,b:List<HandlerEntry(~S)> & String,c:List<HandlerEntry(~S)> & String) -> F.TransitionOwners(~S) & String:
  (a,at)=a
  (b,bt)=b
  (c,ct)=c
  (H.Owners{a,b,c},"transitionOwners{exit=" ++ at ++ ";transition=" ++ bt ++ ";enter=" ++ ct ++ "}")
def transition_owners(~S:Data,value:F.TransitionOwners(~S)) -> F.TransitionOwners(~S) & String:
  match value:
    case H.Owners{a,b,c}:transition_owners_join(~S,Common.items(~HandlerEntry(~S),~handler_entry(~S),a),Common.items(~HandlerEntry(~S),~handler_entry(~S),b),Common.items(~HandlerEntry(~S),~handler_entry(~S),c))
def marker_snapshot(value:Machine.Snapshot<U32>) -> String:
  match value:
    case Machine.Unscheduled{}:"Unscheduled"
    case Machine.Scheduled{value,skipSame}:"Scheduled{value=" ++ U32.show(value) ++ ";skipSame=" ++ Bool.show(skipSame) ++ "}"
def phase(value:H.Phase) -> String:
  match value:
    case H.Exit{}:"Exit"
    case H.Transition{}:"Transition"
    case H.Enter{}:"Enter"
def transition_completed(~S:Data,+captured:Machine.Snapshot<U32>,a:F.TransitionOwners(~S) & String,b:F.World(~S) & String) -> F.TransitionResult<S> & String:
  (owners,ot)=a
  (world,wt)=b
  (F.TransitionResult{captured,H.Completed{owners,world}},"transition{captured=" ++ marker_snapshot(captured) ++ ";Completed|" ++ ot ++ "|" ++ wt ++ "}")
def transition_stopped(~S:Data,+captured:Machine.Snapshot<U32>,+at:H.Phase,+error:String,a:F.TransitionOwners(~S) & String,b:F.World(~S) & String) -> F.TransitionResult<S> & String:
  (owners,ot)=a
  (world,wt)=b
  (F.TransitionResult{captured,H.Stopped{owners,world,at,error}},"transition{captured=" ++ marker_snapshot(captured) ++ ";Stopped{phase=" ++ phase(at) ++ ";error=" ++ error ++ "}|" ++ ot ++ "|" ++ wt ++ "}")
def transition_result(~S:Data,value:F.TransitionResult<S>) -> F.TransitionResult<S> & String:
  match value:
    case F.TransitionResult{captured,H.Completed{owners,current}}:transition_completed(~S,captured,transition_owners(~S,owners),world(~S,current))
    case F.TransitionResult{captured,H.Stopped{owners,current,at,error}}:transition_stopped(~S,captured,at,error,transition_owners(~S,owners),world(~S,current))
