import Base
import ./schema.bend as Schema
import ./declarations.bend as D
import ./application.bend as Application
import ./feature-motion.bend as Motion
import ./feature-labels.bend as Labels
import ../../src/ecs/execution-composer-app.bend as Compose
import ../../src/ecs/dependency-composer.bend as Composition
import ../../src/ecs/dependency-composer-program.bend as Scoped
import ../../src/ecs/dependency-application.bend as Dep
import ../../src/ecs/dependency-registration.bend as Reg
import ../../src/ecs/dependency-plan.bend as Plan
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-composer-service.bend as Service
import ../../src/ecs/schema-fragments.bend as Fragment
import ../../src/ecs/chunk-column.bend as Col
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/world.bend as W
import ../../src/ecs/deferred-command.bend as Deferred
import ../../src/ecs/owner-product.bend as Product
import ../../test-fixtures/common/column-observation.bend as Common

def uint(result:Array<U32> & U32) -> String:
  match result:
    case (_,value):U32.show(value)
def text(result:Array<String> & String) -> String:
  match result:
    case (_,value):value
def position_returned(+cache:String,result:Motion.Position & String) -> Layout.Viewed<Motion.Position,String> & String:
  match result:
    case (owner,+value):(Layout.Viewed{owner,cache},value ++ "/cache=" ++ cache)
def position(value:Layout.Viewed<Motion.Position,String>) -> Layout.Viewed<Motion.Position,String> & String:
  match value:
    case Layout.Viewed{owner,cache}:position_returned(cache,Motion.position(owner))
def label_returned(+cache:String,result:Labels.Label & String) -> Layout.Viewed<Labels.Label,String> & String:
  match result:
    case (owner,value):(Layout.Viewed{owner,cache},value ++ "/cache=" ++ cache)
def label(value:Layout.Viewed<Labels.Label,String>) -> Layout.Viewed<Labels.Label,String> & String:
  match value:
    case Layout.Viewed{owner,cache}:label_returned(cache,Labels.label(owner))
def store(value:Schema.Store()) -> String:
  match value:
    case Product.Owner{Layout.ColumnSlot{positions},Layout.ColumnSlot{labels}}:"positions=" ++ Common.capacity_done(~Schema.Nominal,~Layout.Viewed<Motion.Position,String>,~position,Col.capacity(~Schema.Nominal,~Layout.Viewed<Motion.Position,String>,positions)) ++ ";labels=" ++ Common.capacity_done(~Schema.Nominal,~Layout.Viewed<Labels.Label,String>,~label,Col.capacity(~Schema.Nominal,~Layout.Viewed<Labels.Label,String>,labels))
def optional_uint(value:Maybe<&1,Array<U32>>) -> String:
  match value:
    case None{}:"none"
    case Some{owner}:"some:" ++ uint(Array.get(U32,owner,0))
def counter(value:Motion.Counter) -> String:
  match value:
    case Motion.Counter{token,count,optional}:uint(Array.get(U32,token,0)) ++ ":" ++ U32.show(count) ++ "/optional=" ++ optional_uint(optional)
def host(value:Labels.Host) -> String:Common.projected(~Labels.Host,Labels.host(value))
def optional_host(value:Maybe<&1,Labels.Host>) -> String:
  match value:
    case None{}:"none"
    case Some{owner}:host(owner)
def service(value:Service.Slot<Labels.Host>) -> String:
  match value:
    case Service.Missing{}:"missing"
    case Service.Provided{owner}:host(owner)
def readiness(value:Service.Status<String>) -> String:
  match value:
    case Service.Status{None{}}:"missing"
    case Service.Status{Some{text}}:text
def resources(value:Schema.Resources()) -> String:
  match value:
    case Product.Owner{Layout.ResourceSlot{Layout.Viewed{count,cc}},Product.Owner{Layout.ResourceSlot{Layout.Viewed{host,hc}},Layout.ResourceSlot{Layout.Viewed{optional,oc}}}}:"counter=" ++ counter(count) ++ "/cache=" ++ cc ++ ";host=" ++ service(host) ++ "/cache=" ++ readiness(hc) ++ ";optional=" ++ Common.projected(~Maybe<&1,Array<String>>,Schema.optional(optional)) ++ "/cache=" ++ oc
def world(value:Schema.World()) -> String:
  match value:
    case W.World{namespace,allocator,components,resource,events,pending,registrations,next,clock,lifecycle}:"namespace=" ++ U32.show(namespace) ++ ";allocator={" ++ Common.allocator(allocator) ++ "};" ++ store(components) ++ ";" ++ resources(resource) ++ ";events=" ++ Nat.show(List.length(&2,Unit,events)) ++ ";pending=" ++ Nat.show(List.length(&1,Deferred.Command<Schema.World()>,pending)) ++ ";registrations=" ++ List.show(&2,W.RegistrationMeta,Common.registration,registrations) ++ ";next=" ++ U32.show(next) ++ ";clock=" ++ Common.clock(clock)
def handle(value:W.Handle<Schema.Nominal>) -> String:
  match value:
    case W.Handle{namespace,key}:U32.show(namespace) ++ ":" ++ Common.key(key)
def motion_local(value:Motion.Local<Schema.Nominal>) -> String:
  match value:
    case Motion.Local{token,runs,entity}:uint(Array.get(U32,token,0)) ++ ":" ++ U32.show(runs) ++ ":" ++ handle(entity)
def labels_local(value:Labels.Local<Schema.Nominal>) -> String:
  match value:
    case Labels.Local{token,runs,entity}:text(Array.get(String,token,0)) ++ ":" ++ U32.show(runs) ++ ":" ++ handle(entity)
def metadata(namespace:U32,id:U32,name:String,access:List<&2,String>,cursor:Maybe<&2,Tick.Tick>,local:String) -> String:
  "ns=" ++ U32.show(namespace) ++ ",id=" ++ U32.show(id) ++ ",name=" ++ name ++ ",access=" ++ List.show(&2,String,value=>value,access) ++ ",cursor=" ++ Tick.cursor_show(cursor) ++ ",local=" ++ local
def motion(value:D.MotionOwner()) -> String:
  match value:
    case Sys.Owner{namespace,id,name,access,cursor,local}:metadata(namespace,id,name,access,cursor,motion_local(local))
def labels(value:D.LabelsOwner()) -> String:
  match value:
    case Sys.Owner{namespace,id,name,access,cursor,local}:metadata(namespace,id,name,access,cursor,labels_local(local))
def guard_local(value:D.GuardLocal) -> String:
  match value:
    case D.GuardLocal{token,checks}:uint(Array.get(U32,token,0)) ++ ":" ++ U32.show(checks)
def guard(value:D.GuardOwner()) -> String:
  match value:
    case Sys.Owner{namespace,id,name,access,cursor,local}:metadata(namespace,id,name,access,cursor,guard_local(local))
def owners(value:D.Owners()) -> String:
  match value:
    case Reg.Product{Reg.Product{a,b,al},Reg.Product{c,d,bl},root}:"[" ++ motion(a) ++ ";" ++ motion(b) ++ ";" ++ labels(c) ++ ";" ++ labels(d) ++ "];cached-ids=" ++ List.show(&2,U32,U32.show,al) ++ "/" ++ List.show(&2,U32,U32.show,bl) ++ "/" ++ List.show(&2,U32,U32.show,root)
def guards(value:D.Guards()) -> String:
  match value:
    case Reg.Product{a,b,ids}:"[" ++ guard(a) ++ ";" ++ guard(b) ++ "];cached-ids=" ++ List.show(&2,U32,U32.show,ids)
def handler(value:Application.Handler) -> String:
  match value:
    case Application.Handler{token,errors}:uint(Array.get(U32,token,0)) ++ ":" ++ List.show(&2,String,value=>value,errors)
def provisions(value:Application.Provisions) -> String:
  match value:
    case Application.Provisions{a,b,pending,refused}:uint(Array.get(U32,a,0)) ++ ":" ++ text(Array.get(String,b,0)) ++ ";pending-host=" ++ optional_host(pending) ++ ";refused-host=" ++ List.show(&1,Labels.Host,host,refused)
def kind(value:Fragment.RegistryKind) -> String:
  match value:
    case Fragment.Component{}:"component"
    case Fragment.Resource{}:"resource"
    case Fragment.Service{}:"service"
    case Fragment.Event{}:"event"
    case Fragment.Relation{}:"relation"
def policy(value:Fragment.PersistenceKind) -> String:
  match value:
    case Fragment.Plain{}:"plain"
    case Fragment.Constructed{}:"constructed"
    case Fragment.Transient{}:"transient"
def entry(value:Fragment.Entry<Schema.Nominal>) -> String:
  match value:
    case Fragment.Entry{value,key,name}:kind(value) ++ ":" ++ key ++ ":" ++ name
    case Fragment.Classified{value,key,name,persistence}:kind(value) ++ ":" ++ key ++ ":" ++ name ++ ":" ++ policy(persistence)
def invalid(value:Plan.Invalid<String>) -> String:
  match value:
    case Plan.Duplicate{id}:"duplicate:" ++ U32.show(id)
    case Plan.UnknownDependency{id}:"unknown:" ++ U32.show(id)
    case Plan.Missing{id,key}:"missing:" ++ U32.show(id) ++ ":" ++ key
    case Plan.Cycle{}:"cycle"
    case Plan.InvalidCondition{id}:"invalid-condition:" ++ U32.show(id)
def nesting(value:Scoped.NestError) -> String:
  match value:
    case Scoped.UnknownScope{path}:"unknown-scope:" ++ List.show(&2,U32,U32.show,path)
    case Scoped.InvalidEdges{path,reason}:"invalid-nesting:" ++ List.show(&2,U32,U32.show,path) ++ ":" ++ invalid(reason)
def schema_error(value:Fragment.Error) -> String:
  match value:
    case Fragment.DuplicateKey{value,key}:"duplicate-key:" ++ kind(value) ++ ":" ++ key
    case Fragment.DuplicateName{value,name}:"duplicate-name:" ++ kind(value) ++ ":" ++ name
    case Fragment.UndeclaredDescriptor{value,key,name}:"undeclared:" ++ kind(value) ++ ":" ++ key ++ ":" ++ name
def composition_error(value:Composition.Error) -> String:
  match value:
    case Composition.Schema{error}:schema_error(error)
    case Composition.Schedule{error}:invalid(error)
    case Composition.Nesting{error}:nesting(error)
def optional_error(value:Maybe<&2,Composition.Error>) -> String:
  match value:
    case None{}:"none"
    case Some{error}:composition_error(error)
def edge(value:Plan.Edge) -> String:
  match value:
    case Plan.Edge{a,b}:U32.show(a) ++ ">" ++ U32.show(b)
def node(value:Plan.Node<String>) -> String:
  match value:
    case Plan.Node{id,needs}:U32.show(id) ++ ":" ++ List.show(&2,String,value=>value,needs)
def plan(value:Plan.Build<String>) -> String:
  match value:
    case Plan.Planned{nodes,edges}:List.show(&2,Plan.Node<String>,node,nodes) ++ ":" ++ List.show(&2,Plan.Edge,edge,edges)
    case Plan.Rejected{reason}:invalid(reason)
def binding(value:Dep.Binding) -> String:
  match value:
    case Dep.Binding{system,condition}:U32.show(system) ++ ">" ++ U32.show(condition)
def application(value:Application.Application()) -> String:
  match value:
    case Compose.Composed{Dep.Application{Dep.State{state,systems,conditions,errors,bindings},schedule,original},Fragment.Fragment{entries,owned},error}:"world={" ++ world(state) ++ "};systems={" ++ owners(systems) ++ "};guards={" ++ guards(conditions) ++ "};handler=" ++ handler(errors) ++ ";provisions=" ++ provisions(owned) ++ ";schema=" ++ List.show(&2,Fragment.Entry<Schema.Nominal>,entry,entries) ++ ";plan=" ++ plan(schedule) ++ ";bindings=" ++ List.show(&2,Dep.Binding,binding,bindings) ++ ";original-bindings=" ++ List.show(&2,Dep.Binding,binding,original) ++ ";invalid=" ++ optional_error(error)

def event(value:Exec.Observation<String,String>) -> String:
  match value:
    case Exec.Ran{id,out}:U32.show(id) ++ ":ran:" ++ out
    case Exec.BodyFailed{id,error,out}:U32.show(id) ++ ":body-error:" ++ error ++ ":" ++ out
    case Exec.ConditionFailed{id,error}:U32.show(id) ++ ":condition-error:" ++ error
    case Exec.Skipped{id}:U32.show(id) ++ ":skipped"
    case Exec.ConditionRejected{id}:U32.show(id) ++ ":condition-refused"
    case Exec.AdmissionRejected{id}:U32.show(id) ++ ":admission-refused"
def report(value:Compose.CompositionReport<String,String>) -> String:
  match value:
    case Compose.CompositionRan{Dep.Finished{events}}:"finished:" ++ List.show(&2,Exec.Observation<String,String>,event,events)
    case Compose.CompositionRan{Dep.Stopped{error,events}}:"stopped:" ++ error ++ ":" ++ List.show(&2,Exec.Observation<String,String>,event,events)
    case Compose.CompositionRan{Dep.Invalid{reason}}:"invalid:" ++ invalid(reason)
    case Compose.CompositionRejected{error}:"refused:" ++ composition_error(error)
