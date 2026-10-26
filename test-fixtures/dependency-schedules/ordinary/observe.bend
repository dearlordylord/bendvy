import Base
import ./schema.bend as Schema
import ./setup.bend as Setup
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/deferred-command.bend as Deferred
import ../../../src/ecs/clock-state.bend as Clock
import ../../../src/ecs/change-tick.bend as Tick
import ../../../src/ecs/entity-allocator.bend as Alloc
import ../../../src/ecs/entity-key.bend as Key
import ../../../src/ecs/owner-product.bend as Product
import ../../../src/ecs/execution-system.bend as Sys
import ../../../src/ecs/dependency-plan.bend as Plan
import ../../../src/ecs/dependency-executor.bend as Exec
import ../../../src/ecs/dependency-registration.bend as Reg
import ../../../src/ecs/dependency-application.bend as App
import ../../../src/ecs/execution-composer-layout.bend as Layout

def strings(items:List<&2,String>) -> String:
  match items:
    case []:""
    case first <> rest:first ++ "," ++ strings(rest)
def token_value(result:Array<U32> & U32) -> String:
  match result:
    case (_,id):U32.show(id)
def local(local:Schema.Local) -> String:
  match local:
    case Schema.Local{token,runs}:token_value(Array.get(U32,token,0)) ++ ":" ++ U32.show(runs)
def counter(owner:Schema.Counter) -> String:
  match owner:
    case Schema.Counter{token,value}:token_value(Array.get(U32,token,0)) ++ ":" ++ U32.show(value)
def sentinel(owner:Schema.Sentinel) -> String:
  match owner:
    case Schema.Sentinel{token,text}:token_value(Array.get(U32,token,0)) ++ ":" ++ text
def handler(owner:Schema.Handler) -> String:
  match owner:
    case Schema.Handler{token,errors}:token_value(Array.get(U32,token,0)) ++ ":" ++ strings(errors)
def resources(~S:Data,value:Schema.Resources(~S)) -> String:
  match value:
    case Product.Owner{Layout.ResourceSlot{Layout.Viewed{count,cachedCount}},Layout.ResourceSlot{Layout.Viewed{secret,cachedSecret}}}:counter(count) ++ ":cache=" ++ U32.show(cachedCount) ++ "/" ++ sentinel(secret) ++ ":cache=" ++ cachedSecret
def ticks(values:List<&2,Tick.Tick>) -> String:
  match values:
    case []:""
    case first <> rest:Nat.show(Tick.total(first)) ++ "," ++ ticks(rest)
def cursor(value:Maybe<&2,Tick.Tick>) -> String:
  match value:
    case None{}:"none"
    case Some{tick}:Nat.show(Tick.total(tick))
def clock(value:Clock.State) -> String:
  match value:
    case Clock.State{now,scopes}:Nat.show(Tick.total(now)) ++ ":" ++ ticks(scopes)
def registrations(values:List<&2,W.RegistrationMeta>) -> String:
  match values:
    case []:""
    case W.RegistrationMeta{id,name,access} <> rest:U32.show(id) ++ "/" ++ name ++ "/" ++ strings(access) ++ "," ++ registrations(rest)
def phase(value:Alloc.Phase) -> String:
  match value:
    case Alloc.Consumed{}:"consumed"
    case Alloc.Pending{}:"pending"
    case Alloc.Live{}:"live"
    case Alloc.DeadRetained{}:"dead"
    case Alloc.Free{}:"free"
def slot(result:Array<Alloc.Slot> & Alloc.Slot) -> String:
  match result:
    case (_,Alloc.Slot{generation,status}):U32.show(generation) ++ ":" ++ phase(status)
def allocator(value:Alloc.Allocator) -> String:
  match value:
    case Alloc.Allocator{next,high,slots,capacity,depth,free,order}:U32.show(next) ++ ":" ++ U32.show(high) ++ ":" ++ U32.show(capacity) ++ ":" ++ Nat.show(depth) ++ ":" ++ Nat.show(List.length(&2,U32,free)) ++ ":" ++ Nat.show(List.length(&2,Key.Key,order)) ++ ":" ++ slot(Array.get(Alloc.Slot,slots,0))
def world(~S:Data,value:Schema.World(~S)) -> String:
  match value:
    case W.World{namespace,entities,_,resource,events,pending,registered,nextSystemId,time,lifecycle}:"world=" ++ U32.show(namespace) ++ ":" ++ resources(~S,resource) ++ ":events=" ++ Nat.show(List.length(&2,Unit,events)) ++ ":pending=" ++ Nat.show(List.length(&1,Deferred.Command<Schema.World(~S)>,pending)) ++ ":registered=" ++ registrations(registered) ++ ":next=" ++ U32.show(nextSystemId) ++ ":clock=" ++ clock(time) ++ ":allocator=" ++ allocator(entities)
def owner(namespace:U32,id:U32,name:String,access:List<&2,String>,last:Maybe<&2,Tick.Tick>,owned:Schema.Local) -> String:
  U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ local(owned) ++ ":access=" ++ strings(access) ++ ":cursor=" ++ cursor(last)
def writer(~S:Data,owner:Setup.Writer(~S)) -> String:
  match owner:
    case Sys.Owner{namespace,id,name,access,last,owned}:U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ local(owned) ++ ":access=" ++ strings(access) ++ ":cursor=" ++ cursor(last)
def reader(~S:Data,owner:Setup.Reader(~S)) -> String:
  match owner:
    case Sys.Owner{namespace,id,name,access,last,owned}:U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ local(owned) ++ ":access=" ++ strings(access) ++ ":cursor=" ++ cursor(last)
def positive(~S:Data,owner:Setup.Positive(~S)) -> String:
  match owner:
    case Sys.Owner{namespace,id,name,access,last,owned}:U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ local(owned) ++ ":access=" ++ strings(access) ++ ":cursor=" ++ cursor(last)
def changing(~S:Data,owner:Setup.Changing(~S)) -> String:
  match owner:
    case Sys.Owner{namespace,id,name,access,last,owned}:U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ local(owned) ++ ":access=" ++ strings(access) ++ ":cursor=" ++ cursor(last)
def ids(values:List<&2,U32>) -> String:
  match values:
    case []:""
    case id <> rest:U32.show(id) ++ "," ++ ids(rest)
def bindings(values:List<&2,App.Binding>) -> String:
  match values:
    case []:""
    case App.Binding{system,condition} <> rest:U32.show(system) ++ ">" ++ U32.show(condition) ++ "," ++ bindings(rest)
def nodes(values:List<&2,Plan.Node<String>>) -> String:
  match values:
    case []:""
    case Plan.Node{id,requirements} <> rest:U32.show(id) ++ ":" ++ strings(requirements) ++ ";" ++ nodes(rest)
def edges(values:List<&2,Plan.Edge>) -> String:
  match values:
    case []:""
    case Plan.Edge{before,after} <> rest:U32.show(before) ++ ">" ++ U32.show(after) ++ "," ++ edges(rest)
def invalid(reason:Plan.Invalid<String>) -> String:
  match reason:
    case Plan.Duplicate{id}:"duplicate/" ++ U32.show(id)
    case Plan.UnknownDependency{id}:"unknown/" ++ U32.show(id)
    case Plan.Missing{id,requirement}:"missing/" ++ U32.show(id) ++ "/" ++ requirement
    case Plan.Cycle{}:"cycle"
    case Plan.InvalidCondition{id}:"condition/" ++ U32.show(id)
def plan(value:Plan.Build<String>) -> String:
  match value:
    case Plan.Planned{order,dependencies}:"order=" ++ nodes(order) ++ ":edges=" ++ edges(dependencies)
    case Plan.Rejected{reason}:"rejected=" ++ invalid(reason)
def system_owners(~S:Data,owners:Setup.Owners(~S)) -> String:
  match owners:
    case Reg.Product{Reg.Product{w,a,leftIds},Reg.Product{b,c,rightIds},rootIds}:writer(~S,w) ++ "/" ++ reader(~S,a) ++ "/" ++ reader(~S,b) ++ "/" ++ reader(~S,c) ++ ":routes=" ++ ids(rootIds) ++ "/" ++ ids(leftIds) ++ "/" ++ ids(rightIds)
def guard_owners(~S:Data,guards:Setup.Guards(~S)) -> String:
  match guards:
    case Reg.Product{a,b,leftIds}:positive(~S,a) ++ "/" ++ changing(~S,b) ++ ":routes=" ++ ids(leftIds)
def state(~S:Data,value:App.State<Schema.World(~S),Setup.Owners(~S),Setup.Guards(~S),Schema.Handler>) -> String:
  match value:
    case App.State{owned,owners,guards,errors,stateBindings}:world(~S,owned) ++ ";systems=" ++ system_owners(~S,owners) ++ ";guards=" ++ guard_owners(~S,guards) ++ ";handler=" ++ handler(errors) ++ ";state-bindings=" ++ bindings(stateBindings)
def event(value:Exec.Observation<String,U32>) -> String:
  match value:
    case Exec.Ran{id,output}:"ran/" ++ U32.show(id) ++ "/" ++ U32.show(output)
    case Exec.BodyFailed{id,error,output}:"body/" ++ U32.show(id) ++ "/" ++ error ++ "/" ++ U32.show(output)
    case Exec.Skipped{id}:"skip/" ++ U32.show(id)
    case Exec.ConditionFailed{id,error}:"condition/" ++ U32.show(id) ++ "/" ++ error
    case Exec.ConditionRejected{id}:"condition-refused/" ++ U32.show(id)
    case Exec.AdmissionRejected{id}:"admission-refused/" ++ U32.show(id)
def events(values:List<&2,Exec.Observation<String,U32>>) -> String:
  match values:
    case []:""
    case first <> rest:event(first) ++ "," ++ events(rest)
def report(value:App.Report<String,U32>) -> String:
  match value:
    case App.Finished{values}:"finished=" ++ events(values)
    case App.Stopped{error,values}:"stopped=" ++ error ++ ":" ++ events(values)
    case App.Invalid{_}:"invalid"
def application(~S:Data,value:Setup.Application(~S)) -> String:
  match value:
    case App.Application{owned,actualPlan,appBindings}:state(~S,owned) ++ ";plan=" ++ plan(actualPlan) ++ ";app-bindings=" ++ bindings(appBindings)
