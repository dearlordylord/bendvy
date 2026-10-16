import Base
import fixture.bend as F
import /workspace/formal-proofs/bendvy/experiments/public-audit61/app-a-owned-handoff-v1/owner-observer.bend as Dump
import /workspace/formal-proofs/bendvy/experiments/public-audit61/app-a-owned-handoff-v1/capture-observe.bend as OldDump
import /workspace/formal-proofs/bendvy/experiments/public-recovery/automatic-app-v1/observe.bend as Common
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/owner-product.bend as Product
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-optional-resource.bend as Slot
import ./ordinary-checked-condition.bend as Cond
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-check-declaration.bend as CD
import ./ordinary-checked-bindings.bend as Bindings
import ./ordinary-app-checked-schedule.bend as Checked
import ./checked-condition-schedule.bend as CheckedError
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
  (Product.Owner{a,Product.Owner{b,c}},"Counter=" ++ at ++ ";Input=" ++ bt ++ ";Sentinel=" ++ ct)
def resources(~S:Data,value:F.Resources(~S)) -> F.Resources(~S) & String:
  match value:
    case Product.Owner{a,Product.Owner{b,c}}:resources_join(~S,Dump.u32_array(a),input(~S,b),Dump.u32_array(c))
def world_join(~S:Data,+ns:U32,+next:U32,+high:U32,+capacity:U32,+depth:Nat,+events:List<&2,Unit>,+regs:List<&2,W.RegistrationMeta>,+sid:U32,+clock:U32,a:Array<Bool> & String,b:F.Resources(~S) & String,c:List<(F.World(~S) -> F.World(~S))> & Nat) -> F.World(~S) & String:
  (live,lt)=a
  (resource,rt)=b
  (pending,count)=c
  (W.World{ns,next,high,live,capacity,depth,Unit{},resource,events,pending,regs,sid,clock},"world{namespace=" ++ U32.show(ns) ++ ";nextId=" ++ U32.show(next) ++ ";highWater=" ++ U32.show(high) ++ ";live=" ++ lt ++ ";capacity=" ++ U32.show(capacity) ++ ";depth=" ++ Nat.show(depth) ++ ";store=Unit;resources={" ++ rt ++ "};events=" ++ List.show(&2,Unit,unit,events) ++ ";pending=" ++ Nat.show(count) ++ ";registrations=" ++ List.show(&2,W.RegistrationMeta,Dump.registration,regs) ++ ";nextSystemId=" ++ U32.show(sid) ++ ";clock=" ++ U32.show(clock) ++ "}")
def world(~S:Data,value:F.World(~S)) -> F.World(~S) & String:
  match value:
    case W.World{ns,next,high,live,capacity,depth,Unit{},resource,events,pending,regs,sid,clock}:world_join(~S,ns,next,high,capacity,depth,events,regs,sid,clock,Dump.bool_array(live),resources(~S,resource),Dump.callbacks(~F.World(~S),~F.World(~S),pending))
def use(value:CD.Use) -> String:
  match value:
    case CD.Use{CD.Resource{},key,CD.Read{},required}:"Resource{" ++ key ++ ";mode=Read;required=" ++ Bool.show(required) ++ "}"
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
    case Bindings.Bindings{Bindings.BoundOwner{+id,(+old,(+bypass,Unit{}))},+facts}:(Bindings.Bindings{Bindings.BoundOwner{id,(old,(bypass,Unit{}))},facts},"guards{systemId=" ++ U32.show(id) ++ ";oldOwner=" ++ Bool.show(old) ++ ";bypass=" ++ Bool.show(bypass) ++ ";requiredOwner=Unit;descriptions=" ++ List.show(&2,Bindings.Description,binding,facts) ++ "}")
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
def probes(~S:Data,value:F.Probes(~S)) -> F.Probes(~S) & String:
  match value:
    case F.ProbeOwners{Cond.Condition{+neg,+nd},Cond.Condition{(+skip,Unit{}),+sd},Cond.Condition{(+reached,Unit{}),+rd}}:(F.ProbeOwners{Cond.Condition{neg,nd},Cond.Condition{(skip,Unit{}),sd},Cond.Condition{(reached,Unit{}),rd}},"probes{negOwner=" ++ Bool.show(neg) ++ ";neg=" ++ description(nd) ++ ";skipOwner=" ++ Bool.show(skip) ++ ";skipRequiredOwner=Unit;skip=" ++ description(sd) ++ ";reachedOwner=" ++ Bool.show(reached) ++ ";reachedRequiredOwner=Unit;reached=" ++ description(rd) ++ "}")
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
def probe_result(value:F.ProbeResult) -> String:
  match value:
    case F.ProbeResult{name,value}:name ++ ":" ++ result(value)
def probe_results(value:List<&2,F.ProbeResult>) -> String:List.show(&2,F.ProbeResult,probe_result,value)
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
