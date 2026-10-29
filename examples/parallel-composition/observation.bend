import Base
import ./schema.bend as Schema
import ./registration.bend as Registration
import ./bootstrap.bend as Bootstrap
import ../../src/ecs/execution-composer-schema.bend as Init
import ../../src/ecs/execution-declaration.bend as Decl
import ../../src/ecs/execution-resource-admission.bend as Admission
import ../../src/ecs/execution-parallel-scope.bend as Scope
import ../../src/ecs/execution-resource-query-leaf.bend as Leaf
import ../../src/ecs/execution-resource-query-execution.bend as Execution
import ../../src/ecs/execution-compiled-binding.bend as Binding
import ../../src/ecs/execution-prepared.bend as Prep
import ./declarations.bend as D
import ./application.bend as Application
import ./feature-motion.bend as Motion
import ./feature-labels.bend as Labels
import ../../src/ecs/feature.bend as Feature
import ../../src/ecs/execution-generalized-root-application.bend as Root
import ../../src/ecs/execution-parallel-root-application.bend as Scheduled
import ../../src/ecs/execution-composer-schema.bend as Inventory
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
    case Product.Owner{Layout.ResourceSlot{Layout.Viewed{count,cc},_},Product.Owner{Layout.ResourceSlot{Layout.Viewed{host,hc},_},Layout.ResourceSlot{Layout.Viewed{optional,oc},_}}}:"counter=" ++ counter(count) ++ "/cache=" ++ cc ++ ";host=" ++ service(host) ++ "/cache=" ++ readiness(hc) ++ ";optional=" ++ Common.projected(~Maybe<&1,Array<String>>,Schema.optional(optional)) ++ "/cache=" ++ oc
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
def guards(value:D.Guards()) -> String:
  match value:
    case Reg.Product{Scope.CompiledBinding{_,a},Scope.CompiledBinding{_,b},ids}:"[" ++ guard(a) ++ ";" ++ guard(b) ++ "];cached-ids=" ++ List.show(&2,U32,U32.show,ids)
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
def feature_error(value:Feature.AssemblyError) -> String:
  match value:
    case Feature.InvalidComposition{error}:composition_error(error)
    case Feature.InvalidFeatures{_}:"invalid-features"
def optional_error(value:Maybe<&2,Feature.AssemblyError>) -> String:
  match value:
    case None{}:"none"
    case Some{error}:feature_error(error)
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

def event(value:Exec.Observation<String,String>) -> String:
  match value:
    case Exec.Ran{id,out}:U32.show(id) ++ ":ran:" ++ out
    case Exec.BodyFailed{id,error,out}:U32.show(id) ++ ":body-error:" ++ error ++ ":" ++ out
    case Exec.ConditionFailed{id,error}:U32.show(id) ++ ":condition-error:" ++ error
    case Exec.Skipped{id}:U32.show(id) ++ ":skipped"
    case Exec.ConditionRejected{id}:U32.show(id) ++ ":condition-refused"
    case Exec.AdmissionRejected{id}:U32.show(id) ++ ":admission-refused"
def report(value:Application.Report()) -> String:
  match value:
    case Feature.Executed{Dep.Finished{events}}:"finished:" ++ List.show(&2,Exec.Observation<String,String>,event,events)
    case Feature.Executed{Dep.Stopped{error,events}}:"stopped:" ++ error ++ ":" ++ List.show(&2,Exec.Observation<String,String>,event,events)
    case Feature.Executed{Dep.Invalid{reason}}:"invalid:" ++ invalid(reason)
    case Feature.Refused{error}:"refused:" ++ feature_error(error)
def rebuilt(~Owner:Type,~Node:Type,rebuild:Owner -> Node,result:Owner & String) -> Node & String:
  match result:
    case (owner,text):(rebuild(owner),text)
def retained_node(~Compilation:Type,~World:Type,~Owner:Type,~Evidence:Data,~Permit:Data,observe:Owner -> Owner & String,held:Leaf.Node<Compilation,World,Owner,Evidence,Permit>) -> Leaf.Node<Compilation,World,Owner,Evidence,Permit> & String:
  match held:
    case Leaf.Uninspected{Scope.CompiledBinding{compilation,owner}}:rebuilt(~Owner,~Leaf.Node<Compilation,World,Owner,Evidence,Permit>,owner=>Leaf.Uninspected{Scope.CompiledBinding{compilation,owner}},observe(owner))
    case Leaf.Inspected{Scope.CompiledBinding{compilation,owner},evidence,id,valid}:rebuilt(~Owner,~Leaf.Node<Compilation,World,Owner,Evidence,Permit>,owner=>Leaf.Inspected{Scope.CompiledBinding{compilation,owner},evidence,id,valid},observe(owner))
    case Leaf.Prepared{Execution.HeldReady{Binding.Binding{compilation,Prep.Prepared{namespace,owner,permits,provenance},evidence}}}:rebuilt(~Owner,~Leaf.Node<Compilation,World,Owner,Evidence,Permit>,owner=>Leaf.Prepared{Execution.HeldReady{Binding.Binding{compilation,Prep.Prepared{namespace,owner,permits,provenance},evidence}}},observe(owner))
    case Leaf.Prepared{Execution.HeldInventory{compilation,Prep.Inventory{owner,provenance},evidence}}:rebuilt(~Owner,~Leaf.Node<Compilation,World,Owner,Evidence,Permit>,owner=>Leaf.Prepared{Execution.HeldInventory{compilation,Prep.Inventory{owner,provenance},evidence}},observe(owner))
def motion_retained_returned(+namespace:U32,+id:U32,+name:String,+access:List<&2,String>,+cursor:Maybe<&2,Tick.Tick>,+runs:U32,+entity:W.Handle<Schema.Nominal>,result:Array<U32> & U32) -> D.MotionOwner() & String:
  match result:
    case (token,value):(Sys.Owner{namespace,id,name,access,cursor,Motion.Local{token,runs,entity}},metadata(namespace,id,name,access,cursor,U32.show(value) ++ ":" ++ U32.show(runs) ++ ":" ++ handle(entity)))
def motion_retained(owner:D.MotionOwner()) -> D.MotionOwner() & String:
  match owner:
    case Sys.Owner{namespace,id,name,access,cursor,Motion.Local{token,runs,entity}}:motion_retained_returned(namespace,id,name,access,cursor,runs,entity,Array.get(U32,token,0))
def labels_retained_returned(+namespace:U32,+id:U32,+name:String,+access:List<&2,String>,+cursor:Maybe<&2,Tick.Tick>,+runs:U32,+entity:W.Handle<Schema.Nominal>,result:Array<String> & String) -> D.LabelsOwner() & String:
  match result:
    case (token,value):(Sys.Owner{namespace,id,name,access,cursor,Labels.Local{token,runs,entity}},metadata(namespace,id,name,access,cursor,value ++ ":" ++ U32.show(runs) ++ ":" ++ handle(entity)))
def labels_retained(owner:D.LabelsOwner()) -> D.LabelsOwner() & String:
  match owner:
    case Sys.Owner{namespace,id,name,access,cursor,Labels.Local{token,runs,entity}}:labels_retained_returned(namespace,id,name,access,cursor,runs,entity,Array.get(String,token,0))
def motion_node(held:D.MotionNode()) -> D.MotionNode() & String:
  retained_node(~Decl.Compilation<Schema.Nominal,Schema.Store(),D.C(),D.R(),Motion.Family(~Schema.Nominal)>,~Schema.World(),~D.MotionOwner(),~Admission.Evidence<Schema.Nominal,Schema.components(),Schema.resources(),D.C(),D.R(),Motion.Family(~Schema.Nominal),D.motion_kernel>,~Prep.Permit<Schema.Nominal,Schema.Store()>,motion_retained,held)
def labels_node(held:D.LabelsNode()) -> D.LabelsNode() & String:
  retained_node(~Decl.Compilation<Schema.Nominal,Schema.Store(),D.C(),D.R(),Labels.Family(~Schema.Nominal)>,~Schema.World(),~D.LabelsOwner(),~Admission.Evidence<Schema.Nominal,Schema.components(),Schema.resources(),D.C(),D.R(),Labels.Family(~Schema.Nominal),D.labels_kernel>,~Prep.Permit<Schema.Nominal,Schema.Store()>,labels_retained,held)
def owners_observed(a:D.MotionNode() & String,b:D.MotionNode() & String,c:D.LabelsNode() & String,d:D.LabelsNode() & String) -> D.Owners() & String:
  match a b c d:
    case (a,at),(b,bt),(c,ct),(d,dt):(Product.Owner{Product.Owner{a,b},Product.Owner{c,d}},"[" ++ at ++ ";" ++ bt ++ ";" ++ ct ++ ";" ++ dt ++ "]")
def owners(value:D.Owners()) -> D.Owners() & String:
  match value:
    case Product.Owner{Product.Owner{a,b},Product.Owner{c,d}}:owners_observed(motion_node(a),motion_node(b),labels_node(c),labels_node(d))
def terminal_owners(value:D.Owners() & String) -> String:
  match value:
    case (_,text):text
# Terminal console projection; the owners observer above returns all node evidence.
def storage(value:Application.Storage()) -> String:
  match value:
    case Root.Present{state,_}:world(state)
    case Root.CutRefused{_,_,_}:"cut-inventory-retained"
    case Root.JoinRefused{_,_,_}:"join-inventory-retained"
    case Root.NestedRefused{_,_,_,_}:"nested-inventory-retained"
def application(value:Application.Application()) -> String:
  match value:
    case Feature.Application{Scheduled.Scheduled{Dep.State{state,systems,conditions,errors,bindings},schedule,original,_,_},owned,error}:"world={" ++ storage(state) ++ "};systems={" ++ terminal_owners(owners(systems)) ++ "};guards={" ++ guards(conditions) ++ "};handler=" ++ handler(errors) ++ ";provisions=" ++ provisions(owned) ++ ";schema=" ++ List.show(&2,Fragment.Entry<Schema.Nominal>,entry,Inventory.inventory(~Schema.Nominal,~Schema.components(),~Schema.resources())) ++ ";plan=" ++ plan(schedule) ++ ";bindings=" ++ List.show(&2,Dep.Binding,binding,bindings) ++ ";original-bindings=" ++ List.show(&2,Dep.Binding,binding,original) ++ ";invalid=" ++ optional_error(error)
def pending_motion(value:Registration.MotionSlot) -> String:
  match value:
    case Registration.MotionPending{_,local}:"pending:" ++ motion_local(local)
    case Registration.MotionRegistered{Scope.CompiledBinding{_,owner}}:motion(owner)
def pending_labels(value:Registration.LabelsSlot) -> String:
  match value:
    case Registration.LabelsPending{_,local}:"pending:" ++ labels_local(local)
    case Registration.LabelsRegistered{Scope.CompiledBinding{_,owner}}:labels(owner)
def pending_guard(value:Registration.GuardSlot) -> String:
  match value:
    case Registration.GuardPending{_,local}:"pending:" ++ guard_local(local)
    case Registration.GuardRegistered{Scope.CompiledBinding{_,owner}}:guard(owner)
def registration(value:Registration.Inventory) -> String:
  match value:
    case Registration.Inventory{state,a,b,c,d,e,f}:"definition-refused;world={" ++ world(state) ++ "};systems=[" ++ pending_motion(a) ++ ";" ++ pending_motion(b) ++ ";" ++ pending_labels(c) ++ ";" ++ pending_labels(d) ++ "];guards=[" ++ pending_guard(e) ++ ";" ++ pending_guard(f) ++ "]"
def bootstrap(value:Bootstrap.Outcome) -> String:
  match value:
    case Bootstrap.Registered{Registration.Refused{inventory}}:registration(inventory)
    case Bootstrap.Registered{Registration.Registered{value}}:application(value)
    case Bootstrap.InitializationRefused{Init.SchemaRefused{_,owners,error}}:"schema-refused:" ++ schema_error(error) ++ ";" ++ resources(owners)
    case Bootstrap.InitializationRefused{Init.NamespaceRefused{_,owners}}:"namespace-refused;" ++ resources(owners)
    case Bootstrap.InitializationRefused{Init.SchemaCreated{_,state}}:"created;" ++ world(state)
    case Bootstrap.ReservationRefused{state,_}:"reservation-refused;" ++ world(state)
    case Bootstrap.ActivationRefused{state,_}:"activation-refused;" ++ world(state)
