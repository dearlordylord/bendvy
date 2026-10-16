import Base
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/relation-types.bend as G
import /workspace/formal-proofs/bendvy/src/ecs/relation-query.bend as RQ
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query-projection.bend as Projection
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
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
def resources_join(~S:Data,a:Array<U32> & String,b:F.Input(~S) & String,c:Array<U32> & String) -> F.Resources(~S) & String:
  (a,at)=a
  (b,bt)=b
  (c,ct)=c
  (Product.Owner{a,Product.Owner{b,c}},"Counter=" ++ at ++ ";Threshold=" ++ bt ++ ";Sentinel=" ++ ct)
def resources(~S:Data,value:F.Resources(~S)) -> F.Resources(~S) & String:
  match value:
    case Product.Owner{a,Product.Owner{b,c}}:resources_join(~S,Dump.u32_array(a),input(~S,b),Dump.u32_array(c))
def unit_owner(value:Unit) -> Unit & String:(value,"Unit")
def columns_join(~S:Data,a:Col.Column<S,Array<U32>> & String,b:Col.Column<S,Array<U32>> & String,c:Col.Column<S,Unit> & String,d:Col.Column<S,Unit> & String) -> Model.Columns<S> & String:
  (a,at)=a
  (b,bt)=b
  (c,ct)=c
  (d,dt)=d
  (Model.Columns{a,b,c,d},"Primary={" ++ at ++ "};Bonus={" ++ bt ++ "};Active={" ++ ct ++ "};Hidden={" ++ dt ++ "}")
def columns(~S:Data,value:Model.Columns<S>) -> Model.Columns<S> & String:
  match value:
    case Model.Columns{a,b,c,d}:columns_join(~S,Dump.column(~S,~Array<U32>,~Dump.u32_array,a),Dump.column(~S,~Array<U32>,~Dump.u32_array,b),Dump.column(~S,~Unit,~unit_owner,c),Dump.column(~S,~Unit,~unit_owner,d))
def access(value:Cmp.Access<U32>) -> String:
  match value:
    case Cmp.MissingEntity{}:"MissingEntity"
    case Cmp.ComponentAbsent{}:"ComponentAbsent"
    case Cmp.Found{value}:"Found{" ++ U32.show(value) ++ "}"
def row_view(value:F.RowView) -> String:
  match value:
    case F.RowView{primary,bonus}:"RowView{primary=" ++ access(primary) ++ ";bonus=" ++ access(bonus) ++ "}"
def relation_kind(value:G.RelationKind) -> String:
  match value:
    case G.Ordinary{}:"ordinary"
    case G.Hierarchy{}:"hierarchy"
def descriptor(~S:Data,value:G.Descriptor<S>) -> String:
  match value:
    case G.Descriptor{key,name,inverseName,kind}:U32.show(key) ++ ":" ++ name ++ ":" ++ inverseName ++ ":" ++ relation_kind(kind)
def edge(~S:Data,value:G.Edge<S>) -> String:
  match value:
    case G.Edge{relation,source,target}:descriptor(~S,relation) ++ ":" ++ U32.show(source) ++ ">" ++ U32.show(target)
def inverse(~S:Data,value:G.Inverse<S>) -> String:
  match value:
    case G.Inverse{relation,target,sources}:descriptor(~S,relation) ++ ":" ++ U32.show(target) ++ ":" ++ List.show(&2,U32,U32.show,sources)
def graph_view(~S:Data,value:G.Graph<S>) -> String:
  match value:
    case G.Graph{edges,inverses}:List.show(&2,G.Edge<S>,edge(~S),edges) ++ ";" ++ List.show(&2,G.Inverse<S>,inverse(~S),inverses)
def operation(value:G.Operation) -> String:
  match value:
    case G.Relate{}:"relate"
    case G.ReorderChildren{}:"reorderChildren"
def relation_error(value:G.Error) -> String:
  match value:
    case G.MissingEntity{source}:"missingEntity:" ++ U32.show(source)
    case G.MissingTargetEntity{source,target,relation}:"missingTarget:" ++ U32.show(source) ++ ":" ++ U32.show(target) ++ ":" ++ relation
    case G.SelfRelationNotAllowed{source,relation}:"selfRelation:" ++ U32.show(source) ++ ":" ++ relation
    case G.HierarchyCycle{source,target,relation}:"hierarchyCycle:" ++ U32.show(source) ++ ":" ++ U32.show(target) ++ ":" ++ relation
    case G.MissingChildEntity{source,child,relation}:"missingChild:" ++ U32.show(source) ++ ":" ++ U32.show(child) ++ ":" ++ relation
    case G.DuplicateChild{source,child,relation}:"duplicateChild:" ++ U32.show(source) ++ ":" ++ U32.show(child) ++ ":" ++ relation
    case G.ChildNotRelatedToParent{source,child,relation}:"childNotRelated:" ++ U32.show(source) ++ ":" ++ U32.show(child) ++ ":" ++ relation
    case G.ChildSetMismatch{source,relation}:"childSetMismatch:" ++ U32.show(source) ++ ":" ++ relation
def failure(~S:Data,value:G.Failure<S>) -> String:
  match value:
    case G.Failure{relation,op,source,target,error}:descriptor(~S,relation) ++ ":" ++ operation(op) ++ ":" ++ U32.show(source) ++ ":" ++ U32.show(target) ++ ":" ++ relation_error(error)
def cleanup(~S:Data,value:G.CleanupFrame<S>) -> String:
  match value:
    case G.CleanupEnter{id}:"enter:" ++ U32.show(id)
    case G.CleanupDescriptors{id,remaining}:"descriptors:" ++ U32.show(id) ++ ":" ++ List.show(&2,G.Descriptor<S>,descriptor(~S),remaining)
    case G.CleanupChildren{id,relation,remaining,children}:"children:" ++ U32.show(id) ++ ":" ++ descriptor(~S,relation) ++ ":" ++ List.show(&2,G.Descriptor<S>,descriptor(~S),remaining) ++ ":" ++ List.show(&2,U32,U32.show,children)
    case G.CleanupFinish{id}:"finish:" ++ U32.show(id)
def notice(~S:Data,value:A.Notice<S,Unit>) -> String:
  match value:
    case A.Original{Unit{}}:"user:Unit"
    case A.RelationFailed{value}:"relationFailed:" ++ failure(~S,value)
    case A.ComponentRemoved{id}:"componentRemoved:" ++ U32.show(id)
    case A.CleanupPaused{frames}:"cleanupPaused:" ++ List.show(&2,G.CleanupFrame<S>,cleanup(~S),frames)
def relation_value(~S:Data,value:RQ.Value<S>) -> String:
  match value:
    case RQ.Missing{}:"Missing"
    case RQ.Target{handle}:"Target{" ++ Common.handle(~S,handle) ++ "}"
    case RQ.Sources{handles}:"Sources{" ++ List.show(&2,W.Handle<S>,Common.handle(~S),handles) ++ "}"
def relation_end(value:RQ.End) -> String:
  match value:
    case RQ.Outgoing{}:"Outgoing"
    case RQ.Incoming{}:"Incoming"
def cell(~S:Data,value:RQ.Cell<S>) -> String:
  match value:
    case RQ.Cell{key,end,value}:"Cell{key=" ++ key ++ ";end=" ++ relation_end(end) ++ ";value=" ++ relation_value(~S,value) ++ "}"
def relation_row(~S:Data,value:F.RelationRow(~S)) -> String:
  match value:
    case Projection.Product{row,cells}:"Product{" ++ row_view(row) ++ ";cells=" ++ List.show(&2,RQ.Cell<S>,cell(~S),cells) ++ "}"
def metadata_kind(value:CD.RelationKind) -> String:
  match value:
    case CD.Ordinary{}:"Ordinary"
    case CD.Hierarchy{}:"Hierarchy"
def relation_identity(value:CD.RelationIdentity) -> String:
  match value:
    case CD.RelationIdentity{id,name,inverseName,kind}:"identity{id=" ++ U32.show(id) ++ ";name=" ++ name ++ ";inverseName=" ++ inverseName ++ ";kind=" ++ metadata_kind(kind) ++ "}"
def direction_view(value:CD.RelationDirection) -> String:
  match value:
    case CD.Outgoing{}:"Outgoing"
    case CD.Incoming{}:"Incoming"
def selection_view(value:CD.RelationSelection) -> String:
  match value:
    case CD.RelationRequired{}:"Required"
    case CD.RelationOptional{}:"Optional"
    case CD.RelationPresent{}:"Present"
    case CD.RelationAbsent{}:"Absent"
def optional_string(value:Maybe<&2,String>) -> String:
  match value:
    case None{}:"None"
    case Some{value}:"Some{" ++ value ++ "}"
def queue_status(value:A.QueueStatus) -> String:
  match value:
    case A.Queued{}:"Queued"
    case A.MissingEntity{}:"MissingEntity"
def tx_outcome(value:T.Outcome<Unit>) -> String:
  match value:
    case T.Success{}:"Success"
    case T.Failure{Unit{}}:"Failure{Unit}"

def store_join(~S:Data,+graph:G.Graph<S>,value:Model.Columns<S> & String) -> Model.Store(~S) & String:
  (owner,text)=value
  (A.Store{owner,graph},"columns={" ++ text ++ "};graph={" ++ graph_view(~S,graph) ++ "}")
def store(~S:Data,value:Model.Store(~S)) -> Model.Store(~S) & String:
  match value:
    case A.Store{owner,graph}:store_join(~S,graph,columns(~S,owner))
def world_join(~S:Data,+ns:U32,+next:U32,+high:U32,+capacity:U32,+depth:Nat,+events:List<&2,A.Notice<S,Unit>>,+regs:List<&2,W.RegistrationMeta>,+sid:U32,+clock:U32,a:Array<Bool> & String,b:F.Resources(~S) & String,c:List<(F.World(~S) -> F.World(~S))> & Nat,d:Model.Store(~S) & String) -> F.World(~S) & String:
  (live,lt)=a
  (resource,rt)=b
  (pending,count)=c
  (store,st)=d
  (W.World{ns,next,high,live,capacity,depth,store,resource,events,pending,regs,sid,clock},"world{namespace=" ++ U32.show(ns) ++ ";nextId=" ++ U32.show(next) ++ ";highWater=" ++ U32.show(high) ++ ";live=" ++ lt ++ ";capacity=" ++ U32.show(capacity) ++ ";depth=" ++ Nat.show(depth) ++ ";store={" ++ st ++ "};resources={" ++ rt ++ "};events=" ++ List.show(&2,A.Notice<S,Unit>,notice(~S),events) ++ ";pending=" ++ Nat.show(count) ++ ";registrations=" ++ List.show(&2,W.RegistrationMeta,Dump.registration,regs) ++ ";nextSystemId=" ++ U32.show(sid) ++ ";clock=" ++ U32.show(clock) ++ "}")
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
    case CD.Use{CD.Relation{identity,direction,selection,cellKey},key,CD.Read{},required}:"Relation{" ++ relation_identity(identity) ++ ";direction=" ++ direction_view(direction) ++ ";selection=" ++ selection_view(selection) ++ ";cellKey=" ++ optional_string(cellKey) ++ ";key=" ++ key ++ ";mode=Read;required=" ++ Bool.show(required) ++ "}"
    case CD.Use{CD.Resource{},key,CD.Read{},required}:"Resource{" ++ key ++ ";mode=Read;required=" ++ Bool.show(required) ++ "}"
    case CD.Use{CD.Component{selection},key,CD.Read{},required}:"Component{" ++ component_selection(selection) ++ ";key=" ++ key ++ ";mode=Read;required=" ++ Bool.show(required) ++ "}"
def uses(values:List<&2,CD.Use>) -> String:List.show(&2,CD.Use,use,values)
def mode_uses(values:List<&2,List<&2,CD.Use>>) -> String:List.show(&2,List<&2,CD.Use>,uses,values)
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
    case Bindings.Bindings{Bindings.BoundOwner{+id,(Unit{},Unit{})},+facts}:(Bindings.Bindings{Bindings.BoundOwner{id,(Unit{},Unit{})},facts},"guards{systemId=" ++ U32.show(id) ++ ";presenceOwner=Unit;joinedOwner=Unit;descriptions=" ++ List.show(&2,Bindings.Description,binding,facts) ++ "}")
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
def queryrow(~S:Data,value:ReadQuery.ProjectedRow<S,F.RelationRow(~S)>) -> String:
  match value:
    case ReadQuery.ProjectedRow{handle,value}:"row{handle=" ++ Common.handle(~S,handle) ++ ";" ++ relation_row(~S,value) ++ "}"
def queryrows(~S:Data,values:List<&2,ReadQuery.ProjectedRow<S,F.RelationRow(~S)>>) -> String:List.show(&2,ReadQuery.ProjectedRow<S,F.RelationRow(~S)>,queryrow(~S),values)
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
