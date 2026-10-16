import Base
import fixture.bend as F
import /tmp/bendvy-checked-predicate/experiments/public-conditions/checked-predicate-v1/observe.bend as Prior
import /workspace/formal-proofs/bendvy/experiments/public-audit61/app-a-owned-handoff-v1/owner-observer.bend as Dump
import /workspace/formal-proofs/bendvy/experiments/public-recovery/automatic-app-v1/observe.bend as Common
import /workspace/formal-proofs/bendvy/experiments/public-captured-schedules/ordinary-v1/conditions-v1/state.bend as MachineDump
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/owner-product.bend as Product
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-optional-resource.bend as Slot
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-machine-initialization.bend as Init
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-machine-condition.bend as Changed
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-checked-bindings.bend as Bindings
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-checked-schedule.bend as Checked
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schedule.bend as Single
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schema.bend as App
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-recipe.bend as Tree
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/schema-fragments.bend as Fragment
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-records.bend as Leaf
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-registration-fields.bend as Records
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as SP
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch

def machine_slot(~S:Data,value:M.Slot<S,F.Mode,U32>) -> String:
  match value:
    case M.Missing{}:"Missing"
    case M.Present{current,next,last,changed}:"Present{current=" ++ U32.show(current) ++ ";next=" ++ MachineDump.pending(next) ++ ";previous=" ++ MachineDump.previous(last) ++ ";changed=" ++ Bool.show(changed) ++ "}"
def machine(~S:Data,value:F.Machine(~S)) -> String:
  match value:
    case Init.State{slot,stream,revision}:"Machine{slot=" ++ machine_slot(~S,slot) ++ ";stream=" ++ MachineDump.stream(stream) ++ ";revision=" ++ Nat.show(revision) ++ "}"
def input_join(~S:Data,result:Array<U32> & String) -> F.Input(~S) & String:
  (value,text)=result
  (Slot.Present{value},"Present{" ++ text ++ "}")
def input(~S:Data,value:F.Input(~S)) -> F.Input(~S) & String:
  match value:
    case Slot.Missing{}:(Slot.Missing{},"Missing")
    case Slot.Present{value}:input_join(~S,Dump.u32_array(value))
def resources_join(~S:Data,+state:F.Machine(~S),a:Array<U32> & String,b:F.Input(~S) & String) -> F.Resources(~S) & String:
  (counter,ct)=a
  (input,it)=b
  (Product.Owner{counter,Product.Owner{input,state}},"Counter=" ++ ct ++ ";Input=" ++ it ++ ";" ++ machine(~S,state))
def resources(~S:Data,value:F.Resources(~S)) -> F.Resources(~S) & String:
  match value:
    case Product.Owner{counter,Product.Owner{value,state}}:resources_join(~S,state,Dump.u32_array(counter),input(~S,value))
def world_join(~S:Data,+ns:U32,+next:U32,+high:U32,+capacity:U32,+depth:Nat,+events:List<&2,Unit>,+regs:List<&2,W.RegistrationMeta>,+sid:U32,+clock:U32,a:Array<Bool> & String,b:F.Resources(~S) & String,c:List<(F.World(~S) -> F.World(~S))> & Nat) -> F.World(~S) & String:
  (live,lt)=a
  (resource,rt)=b
  (pending,count)=c
  (W.World{ns,next,high,live,capacity,depth,Unit{},resource,events,pending,regs,sid,clock},"world{namespace=" ++ U32.show(ns) ++ ";nextId=" ++ U32.show(next) ++ ";highWater=" ++ U32.show(high) ++ ";live=" ++ lt ++ ";capacity=" ++ U32.show(capacity) ++ ";depth=" ++ Nat.show(depth) ++ ";store=Unit;resources={" ++ rt ++ "};events=" ++ List.show(&2,Unit,Prior.unit,events) ++ ";pending=" ++ Nat.show(count) ++ ";registrations=" ++ List.show(&2,W.RegistrationMeta,Dump.registration,regs) ++ ";nextSystemId=" ++ U32.show(sid) ++ ";clock=" ++ U32.show(clock) ++ "}")
def world(~S:Data,value:F.World(~S)) -> F.World(~S) & String:
  match value:
    case W.World{ns,next,high,live,capacity,depth,Unit{},resource,events,pending,regs,sid,clock}:world_join(~S,ns,next,high,capacity,depth,events,regs,sid,clock,Dump.bool_array(live),resources(~S,resource),Dump.callbacks(~F.World(~S),~F.World(~S),pending))
def owners(~S:Data,value:F.Owners(~S)) -> F.Owners(~S) & String:
  match value:
    case ((Unit{},Leaf.Record{Records.Token{},+a}),Leaf.Record{Records.Token{},+b}):(((Unit{},Leaf.Record{Records.Token{},a}),Leaf.Record{Records.Token{},b}),"owners{previous=Unit;A=" ++ Prior.fields(~S,a) ++ ";B=" ++ Prior.fields(~S,b) ++ ";tokens=Token,Token}")
def conditions(~S:Data,value:Bindings.Bindings<F.World(~S),F.Bound(~S),F.select(~S)>) -> Bindings.Bindings<F.World(~S),F.Bound(~S),F.select(~S)> & String:
  match value:
    case Bindings.Bindings{Bindings.BoundOwner{+id,(Changed.Instance{Sys.Registry{+ns,+rid,+name,+access,+cursor},+revision},(+bypass,Unit{}))},+facts}:(Bindings.Bindings{Bindings.BoundOwner{id,(Changed.Instance{Sys.Registry{ns,rid,name,access,cursor},revision},(bypass,Unit{}))},facts},"guards{systemId=" ++ U32.show(id) ++ ";machineRegistry=" ++ U32.show(ns) ++ ":" ++ U32.show(rid) ++ ":" ++ name ++ ":" ++ Prior.strings(access) ++ ";cursor=" ++ U32.show(cursor) ++ ";revision=" ++ Nat.show(revision) ++ ";bypass=" ++ Bool.show(bypass) ++ ";requiredOwner=Unit;descriptions=" ++ List.show(&2,Bindings.Description,Prior.binding,facts) ++ "}")
def app_join(~S:Data,+entries:List<&2,Fragment.Entry<S>>,+debug:Bool,+p:SP.Plan<S>,+ns:U32,+name:String,+steps:List<&2,Sch.Step>,+needs:List<&2,SP.Requirement<S>>,a:F.World(~S) & String,b:F.Owners(~S) & String,c:Bindings.Bindings<F.World(~S),F.Bound(~S),F.select(~S)> & String) -> F.Application(~S) & String:
  (current,wt)=a
  (owned,ot)=b
  (guards,gt)=c
  (Checked.Application{Single.Application{App.Application{Schema.Schema{entries},Build.Registered{current,owned,Tree.Recipe{},debug}},p,ns,name,steps,needs},guards},"app{schema=" ++ List.show(&2,Fragment.Entry<S>,Prior.schema_entry(~S),entries) ++ ";debug=" ++ Bool.show(debug) ++ ";recipe=Recipe;plan=" ++ Prior.plan(~S,p) ++ ";namespace=" ++ U32.show(ns) ++ ";name=" ++ name ++ ";steps=" ++ List.show(&2,Sch.Step,Prior.step,steps) ++ ";needs=" ++ List.show(&2,SP.Requirement<S>,Prior.requirement(~S),needs) ++ "|" ++ wt ++ "|" ++ ot ++ "|" ++ gt ++ "}")
def app(~S:Data,value:F.Application(~S)) -> F.Application(~S) & String:
  match value:
    case Checked.Application{Single.Application{App.Application{Schema.Schema{entries},Build.Registered{current,owned,Tree.Recipe{},debug}},p,ns,name,steps,needs},guards}:app_join(~S,entries,debug,p,ns,name,steps,needs,world(~S,current),owners(~S,owned),conditions(~S,guards))
def snapshot(~S:Data,value:Maybe<&2,Checked.Description<S,F.Rows()>>) -> String:
  match value:
    case None{}:"None"
    case Some{Checked.Description{Single.Description{App.Description{entries,DTO.Product{bindings,DTO.Observation{DTO.Product{DTO.Product{Unit{},a},b},rendered}}},ns,name,steps},facts}}:"Some{schema=" ++ List.show(&2,Fragment.Entry<S>,Prior.schema_entry(~S),entries) ++ ";bindings=" ++ List.show(&2,DTO.Binding<S>,Common.binding(~S),bindings) ++ ";rows=Product{Product{Unit," ++ U32.show(a) ++ "}," ++ U32.show(b) ++ "};rendered=" ++ Prior.strings(rendered) ++ ";namespace=" ++ U32.show(ns) ++ ";name=" ++ name ++ ";steps=" ++ List.show(&2,Single.PlannedStep<S>,Prior.planned(~S),steps) ++ ";checkedBindings=" ++ List.show(&2,Bindings.Description,Prior.binding,facts) ++ "}"
