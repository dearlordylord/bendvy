import Base
import ./fixture.bend as F
import /workspace/formal-proofs/bendvy/experiments/public-conditions/relation-query-check-v1/observe.bend as Prior
import /workspace/formal-proofs/bendvy/experiments/public-audit61/app-a-owned-handoff-v1/owner-observer.bend as Dump
import /workspace/formal-proofs/bendvy/experiments/public-recovery/automatic-app-v1/observe.bend as Common
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev
import /workspace/formal-proofs/bendvy/src/ecs/event-stream.bend as Stream
import /workspace/formal-proofs/bendvy/src/ecs/event-family-routing.bend as Route
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-event-declaration.bend as Event
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-event-family-reader.bend as Reader
import /workspace/formal-proofs/bendvy/src/ecs/owner-product.bend as Product
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-checked-bindings.bend as B
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-recipe.bend as Tree
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-checked-schedule.bend as Old
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schedule.bend as Single
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schema.bend as SchemaApp
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/schema-fragments.bend as Fragment
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as SP
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
import /workspace/formal-proofs/bendvy/src/ecs/checked-condition-schedule.bend as Error

def input(~S:Data,value:F.Input(~S)) -> F.Input(~S) & String:Prior.input(~S,value)
def world_join(~S:Data,+ns:U32,+next:U32,+high:U32,+capacity:U32,+depth:Nat,+events:List<&2,U32>,+regs:List<&2,W.RegistrationMeta>,+sid:U32,+clock:U32,a:Array<Bool> & String,b:F.Resources(~S) & String,c:List<(F.World(~S) -> F.World(~S))> & Nat,d:Array<U32> & String) -> F.World(~S) & String:
  (live,lt)=a
  (resource,rt)=b
  (pending,count)=c
  (store,st)=d
  (W.World{ns,next,high,live,capacity,depth,store,resource,events,pending,regs,sid,clock},"world{namespace=" ++ U32.show(ns) ++ ";nextId=" ++ U32.show(next) ++ ";highWater=" ++ U32.show(high) ++ ";live=" ++ lt ++ ";capacity=" ++ U32.show(capacity) ++ ";depth=" ++ Nat.show(depth) ++ ";store=" ++ st ++ ";resources={" ++ rt ++ "};events=" ++ List.show(&2,U32,U32.show,events) ++ ";pending=" ++ Nat.show(count) ++ ";registrations=" ++ List.show(&2,W.RegistrationMeta,Dump.registration,regs) ++ ";nextSystemId=" ++ U32.show(sid) ++ ";clock=" ++ U32.show(clock) ++ "}")
def world(~S:Data,value:F.World(~S)) -> F.World(~S) & String:
  match value:
    case W.World{ns,next,high,live,capacity,depth,store,resource,events,pending,regs,sid,clock}:world_join(~S,ns,next,high,capacity,depth,events,regs,sid,clock,Dump.bool_array(live),Prior.resources(~S,resource),Dump.callbacks(~F.World(~S),~F.World(~S),pending),Dump.u32_array(store))
def batch(value:Ev.Batch<U32>) -> String:
  match value:
    case Ev.Batch{tick,values}:"Batch{" ++ Nat.show(tick) ++ ";values=" ++ List.show(&2,U32,U32.show,values) ++ "}"
def position(value:Ev.Position) -> String:
  match value:
    case Ev.Position{id,cursor,registered}:"Position{" ++ U32.show(id) ++ ";cursor=" ++ Nat.show(cursor) ++ ";registeredAt=" ++ Nat.show(registered) ++ "}"
def stream(~S:Data,value:Stream.Stream<S,U32>) -> String:
  match value:
    case Stream.Stream{Event.Domain{key},batches,positions,next,frame,boundary,capacity,dropped}:"stream{domain=" ++ key ++ ";batches=" ++ List.show(&2,Ev.Batch<U32>,batch,batches) ++ ";positions=" ++ List.show(&2,Ev.Position,position,positions) ++ ";nextReader=" ++ U32.show(next) ++ ";frameStart=" ++ Nat.show(frame) ++ ";boundary=" ++ Nat.show(boundary) ++ ";capacity=" ++ Nat.show(capacity) ++ ";dropped=" ++ Nat.show(dropped) ++ "}"
def reading(value:Ev.Reading<U32>) -> String:
  match value:
    case Ev.Reading{values,lagged}:"Reading{values=" ++ List.show(&2,U32,U32.show,values) ++ ";lagged=" ++ Bool.show(lagged) ++ "}"
def callback_join(+value:Ev.Reading<U32>,result:Array<U32> & String) -> F.Callback & String:
  (owner,text)=result
  (F.Callback{owner,value},"Callback{owned=" ++ text ++ ";" ++ reading(value) ++ "}")
def callback(value:F.Callback) -> F.Callback & String:
  match value:
    case F.Callback{owner,value}:callback_join(value,Dump.u32_array(owner))
def completion_join(result:F.Callback & String) -> Ev.Completion<Unit,F.Callback,Unit> & String:
  (owner,text)=result
  (Ev.Succeeded{owner},"Succeeded{" ++ text ++ "}")
def completion(value:Ev.Completion<Unit,F.Callback,Unit>) -> Ev.Completion<Unit,F.Callback,Unit> & String:
  match value:
    case Ev.Succeeded{owner}:completion_join(callback(owner))
    case Ev.Failed{Unit{}}:(Ev.Failed{Unit{}},"Failed{Unit}")
    case Ev.Rejected{Unit{}}:(Ev.Rejected{Unit{}},"Rejected{Unit}")
def receipt_join(+id:U32,result:Ev.Completion<Unit,F.Callback,Unit> & String) -> F.Receipt & String:
  (owner,text)=result
  (F.Receipt{id,owner},"Receipt{reader=" ++ U32.show(id) ++ ";completion=" ++ text ++ "}")
def receipt(value:F.Receipt) -> F.Receipt & String:
  match value:
    case F.Receipt{id,value}:receipt_join(id,completion(value))
def held_join(+count:U32,a:Array<U32> & String,b:List<F.Receipt> & String) -> F.Held & String:
  (owner,ot)=a
  (receipts,rt)=b
  (F.Held{owner,receipts,count},"Held{owned=" ++ ot ++ ";receipts=" ++ rt ++ ";syncCalls=" ++ U32.show(count) ++ "}")
def held(value:F.Held) -> F.Held & String:
  match value:
    case F.Held{owner,receipts,count}:held_join(count,Dump.u32_array(owner),Common.items(~F.Receipt,~receipt,receipts))
def family_join(~S:Data,+value:Stream.Stream<S,U32>,result:F.Held & String) -> F.FamilyState(~S) & String:
  (owner,text)=result
  (Product.Owner{value,owner},"family{" ++ stream(~S,value) ++ ";" ++ text ++ "}")
def family(~S:Data,value:F.FamilyState(~S)) -> F.FamilyState(~S) & String:
  match value:
    case Product.Owner{value,owner}:family_join(~S,value,held(owner))
def event_mode(value:Event.Mode) -> String:
  match value:
    case Event.Read{}:"Read"
    case Event.Write{}:"Write"
def owner(~S:Data,value:F.Owner(~S)) -> F.Owner(~S) & String:
  match value:
    case Reader.Owner{Event.Declaration{Event.Domain{+key},+mode},Route.Reader{+ns,+id,+rid},Sys.Registry{+rns,+sid,+name,+access,+cursor}}:(Reader.Owner{Event.Declaration{Event.Domain{key},mode},Route.Reader{ns,id,rid},Sys.Registry{rns,sid,name,access,cursor}},"owner{declaration=" ++ key ++ ":" ++ event_mode(mode) ++ ";reader{namespace=" ++ U32.show(ns) ++ ";id=" ++ U32.show(id) ++ ";registryId=" ++ U32.show(rid) ++ "};registry{" ++ Common.identity(rns,sid,name,access,cursor) ++ "}}")
def owners_join(~S:Data,a:F.Owner(~S) & String,b:F.Owner(~S) & String) -> F.Owners(~S) & String:
  (a,at)=a
  (b,bt)=b
  (((Unit{},a),b),"owners{previous=Unit;first=" ++ at ++ ";second=" ++ bt ++ "}")
def owners(~S:Data,value:F.Owners(~S)) -> F.Owners(~S) & String:
  match value:
    case ((Unit{},a),b):owners_join(~S,owner(~S,a),owner(~S,b))
def packed_join(~S:Data,+tick:Nat,a:F.Owners(~S) & String,b:F.FamilyState(~S) & String) -> F.Packed(~S) & String:
  (owners,ot)=a
  (family,ft)=b
  ((owners,(family,tick)),"packed{tick=" ++ Nat.show(tick) ++ ";" ++ ot ++ ";" ++ ft ++ "}")
def packed(~S:Data,value:F.Packed(~S)) -> F.Packed(~S) & String:
  match value:
    case (value,(f,tick)):packed_join(~S,tick,owners(~S,value),family(~S,f))
def guards(~S:Data,value:B.Bindings<F.World(~S),F.Guards(~S),F.select(~S)>) -> B.Bindings<F.World(~S),F.Guards(~S),F.select(~S)> & String:
  match value:
    case B.Bindings{(B.BoundOwner{+a,(+av,Unit{})},B.BoundOwner{+b,(+bv,Unit{})}),+facts}:(B.Bindings{(B.BoundOwner{a,(av,Unit{})},B.BoundOwner{b,(bv,Unit{})}),facts},"guards{firstId=" ++ U32.show(a) ++ ";firstOwner=Bool(" ++ Bool.show(av) ++ ")&Unit;secondId=" ++ U32.show(b) ++ ";secondOwner=Bool(" ++ Bool.show(bv) ++ ")&Unit;descriptions=" ++ List.show(&2,B.Description,Prior.binding,facts) ++ "}")
def app_join(~S:Data,+entries:List<&2,Fragment.Entry<S>>,+debug:Bool,+plan:SP.Plan<S>,+ns:U32,+name:String,+steps:List<&2,Sch.Step>,+needs:List<&2,SP.Requirement<S>>,recipe:Tree.Recipe<F.World(~S),F.Rows(),F.observe(~S)>,a:F.World(~S) & String,b:F.Packed(~S) & String,c:B.Bindings<F.World(~S),F.Guards(~S),F.select(~S)> & String) -> F.Application(~S) & String:
  (current,wt)=a
  (owned,ot)=b
  (bindings,bt)=c
  (F.put_world(~S,F.Rest{Schema.Schema{entries},owned,recipe,debug,plan,ns,name,steps,needs,bindings},current),"app{schema=" ++ List.show(&2,Fragment.Entry<S>,Prior.schema_entry(~S),entries) ++ ";debug=" ++ Bool.show(debug) ++ ";recipe=Recipe;plan=" ++ Prior.plan(~S,plan) ++ ";namespace=" ++ U32.show(ns) ++ ";name=" ++ name ++ ";steps=" ++ List.show(&2,Sch.Step,Prior.step,steps) ++ ";needs=" ++ List.show(&2,SP.Requirement<S>,Prior.requirement(~S),needs) ++ ";" ++ wt ++ ";" ++ ot ++ ";" ++ bt ++ "}")
def app_taken(~S:Data,value:F.Rest<S> & F.World(~S)) -> F.Application(~S) & String:
  match value:
    case (F.Rest{Schema.Schema{entries},owned,recipe,debug,plan,ns,name,steps,needs,bindings},current):app_join(~S,entries,debug,plan,ns,name,steps,needs,recipe,world(~S,current),packed(~S,owned),guards(~S,bindings))
def app(~S:Data,value:F.Application(~S)) -> F.Application(~S) & String:app_taken(~S,F.take_world(~S,value))
def snapshot(~S:Data,value:Maybe<&2,Old.Description<S,F.Rows()>>) -> String:
  match value:
    case None{}:"None"
    case Some{Old.Description{Single.Description{SchemaApp.Description{entries,DTO.Product{bindings,DTO.Observation{DTO.Product{DTO.Product{Unit{},Unit{}},Unit{}},rendered}}},ns,name,steps},facts}}:"Some{schema=" ++ List.show(&2,Fragment.Entry<S>,Prior.schema_entry(~S),entries) ++ ";bindings=" ++ List.show(&2,DTO.Binding<S>,Common.binding(~S),bindings) ++ ";rows=Product{Product{Unit,Unit},Unit};rendered=" ++ Prior.strings(rendered) ++ ";namespace=" ++ U32.show(ns) ++ ";name=" ++ name ++ ";steps=" ++ List.show(&2,Single.PlannedStep<S>,Prior.planned(~S),steps) ++ ";checkedBindings=" ++ List.show(&2,B.Description,Prior.binding,facts) ++ "}"
def run_observations(value:List<&2,Sch.Observation>) -> String:Prior.run_observations(value)
def run_error(value:Error.Error<Unit>) -> String:
  match value:
    case Error.SystemError{Unit{}}:"SystemError{Unit}"
    case Error.CheckError{error}:"CheckError{" ++ Prior.check_error(error) ++ "}"
    case Error.ConditionUnavailable{}:"ConditionUnavailable"
    case Error.ConditionRegistrationRejected{}:"ConditionRegistrationRejected"
