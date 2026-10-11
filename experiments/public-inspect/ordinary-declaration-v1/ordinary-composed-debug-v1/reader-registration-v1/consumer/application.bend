import Base
import /workspace/formal-proofs/bendvy/src/ecs/event-publication.bend as Pub
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as Tx
import /workspace/formal-proofs/bendvy/src/ecs/commands.bend as Cmd
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-recipe.bend as Tree
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-service-declaration.bend as D
import state.bend as F
import bindings.bend as B
import dispatch.bend as Dispatch
import event-setup.bend as Events
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-event-family-runtime.bend as Family
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schema.bend as App
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schedule.bend as SchApp
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as SP
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema-dump.bend as DumpProvision
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema-provision.bend as Provision
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-dump.bend as Dump
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-dump-filter.bend as Filter
import /workspace/formal-proofs/bendvy/src/ecs/event-family-runtime.bend as FR
import /workspace/formal-proofs/bendvy/src/ecs/event-family-routing.bend as Route
def Previous() -> Type:App.Application<F.S,F.Store,F.Resources,F.Events(),B.Owners4(),B.Rows4(),B.observe4(),B.fold4()>
def Application() -> Type:Family.Application<F.S,F.Store,F.Resources,F.Events(),Events.State(),B.Owners4(),B.Rows4(),B.observe4(),B.fold4()>
def Scheduled() -> Type:SchApp.Application<F.S,F.Store,F.Resources,F.Events(),B.Owners4(),B.Rows4(),B.observe4(),B.fold4()>
def extracted(value:DumpProvision.Provision<F.S,F.Store,F.Resources,F.empty,F.count(),F.values(),F.resources()>) -> Schema.Schema<F.S,F.Store,F.Resources>:
  match value:
    case DumpProvision.Provision{Provision.Provision{schema}}:schema
def schema() -> Schema.Schema<F.S,F.Store,F.Resources>:extracted(F.provision())
def started(value:B.App4()) -> Application():Family.start(~F.S,~F.Store,~F.Resources,~F.Events(),~Events.Domains(),~Events.Metadata(),~Array<U32>,~Events.make(),~Events.sync(),~Events.frame(),~Events.retain(),~Events.inventory(),~B.Owners4(),~B.Rows4(),~B.observe4(),~B.fold4(),Events.provision(),ANode{ALeaf{31},ALeaf{32}},2n,App.attached(~F.S,~F.Store,~F.Resources,~F.Events(),~B.Owners4(),~B.Rows4(),~B.observe4(),~B.fold4(),schema(),value))
def ready(value:B.App4()) -> Maybe<&1,Application()>:Some{started(value)}
def failed3(app:B.App3()) -> B.App3():app
def failed2(app:B.App2()) -> B.App2():app
def failed1(app:B.App1()) -> B.App1():app
type Construction is Type:
  Ready{app:Application()}
  ServiceRejected{app:B.App1()}
  ComponentRejected{app:B.App2()}
  ResourceRejected{app:B.App3()}
def constructed(app:B.App4()) -> Construction:Ready{started(app)}
def resource_rejected(app:B.App3()) -> Construction:ResourceRejected{app}
def component_rejected(app:B.App2()) -> Construction:ComponentRejected{app}
def service_rejected(app:B.App1()) -> Construction:ServiceRejected{app}
def resource_registered(app:B.App3()) -> Construction:B.resource(~Construction,constructed,resource_rejected,app)
def component_registered(app:B.App2()) -> Construction:B.component(~Construction,resource_registered,component_rejected,app)
def construct(world:F.World()) -> Construction:B.service(~Construction,component_registered,service_rejected,B.machine(Build.empty(~F.S,~F.World(),world)))
def snapshot(value:Application()) -> Application() & Maybe<&2,App.Description<F.S,B.Rows4()>>:Family.snapshot(~F.S,~F.Store,~F.Resources,~F.Events(),~Events.State(),~B.Owners4(),~B.Rows4(),~B.observe4(),~B.fold4(),value)
def enabled(value:Application(),flag:Bool) -> Application():Family.enabled(~F.S,~F.Store,~F.Resources,~F.Events(),~Events.State(),~B.Owners4(),~B.Rows4(),~B.observe4(),~B.fold4(),value,flag)
def inventory(value:Application()) -> Application() & Maybe<&2,List<&2,String>>:Family.inventory(~F.S,~F.Store,~F.Resources,~F.Events(),~Events.Metadata(),~Array<U32>,~Events.inventory(),~B.Owners4(),~B.Rows4(),~B.observe4(),~B.fold4(),value)
def dump_previous(value:Previous()) -> Previous() & Maybe<&2,Dump.Dump<F.S>>:Dump.schema_snapshot(~F.S,~F.Store,~F.Resources,~F.Events(),~B.Owners4(),~B.Rows4(),~B.observe4(),~B.fold4(),~F.count(),~F.values(),~F.resources(),Filter.Filter{None{},[],Some{1n}},value)
def dump(value:Application()) -> Application() & Maybe<&2,Dump.Dump<F.S>>:Family.with_previous(~F.S,~F.Store,~F.Resources,~F.Events(),~Events.State(),~B.Owners4(),~B.Rows4(),~B.observe4(),~B.fold4(),~Maybe<&2,Dump.Dump<F.S>>,dump_previous,value)
def plan(sid:U32,cid:U32,rid:U32) -> SP.Plan<F.S>:
  SP.Sequence{SP.Entry{Sch.Barrier{},[]},SP.Sequence{SP.Entry{Sch.System{cid,0},[]},SP.Sequence{SP.Entry{Sch.System{rid,0},[]},SP.Entry{Sch.System{sid,0},[D.requirement(~F.S,~F.Resources,~Array<U32>,~F.ClockRest,~F.clock_take,~F.clock_put,~F.clock_call,F.clock_declaration())]}}}}
type RunDescription is Data:
  Finished{observations:List<&2,Sch.Observation>}
  Failed{error:Dispatch.Error,observations:List<&2,Sch.Observation>}
  Missing{requirements:List<&2,SP.Requirement<F.S>>}
  Rejected{}
def detached_scheduled(value:Scheduled()) -> Previous():
  match value:
    case SchApp.Application{app,_,_,_,_,_}:app
def executed(result:SchApp.RunResult<Scheduled(),F.S,Dispatch.Error>) -> Previous() & RunDescription:
  match result:
    case SchApp.Finished{app,observations}:(detached_scheduled(app),Finished{observations})
    case SchApp.Failed{app,error,observations}:(detached_scheduled(app),Failed{error,observations})
    case SchApp.Missing{app,requirements}:(detached_scheduled(app),Missing{requirements})
    case SchApp.Rejected{app}:(detached_scheduled(app),Rejected{})
def attached(result:SchApp.Attachment<Previous(),Scheduled()>) -> Previous() & RunDescription:
  match result:
    case SchApp.Invalid{app}:(app,Rejected{})
    case SchApp.Attached{app}:executed(SchApp.run(~F.S,~F.Store,~F.Resources,~F.Events(),~B.Owners4(),~B.Rows4(),~B.observe4(),~B.fold4(),~Dispatch.Error,~Dispatch.dispatch,~Dispatch.condition,~Dispatch.provision,app))
def identified(schema:Schema.Schema<F.S,F.Store,F.Resources>,recipe:Tree.Recipe<F.World(),B.Rows4(),B.observe4()>,debug:Bool,world:F.World(),result:B.Owners4() & (U32 & (U32 & U32))) -> Previous() & RunDescription:
  match result:
    case (owners,(sid,(cid,rid))):attached(SchApp.attach(~F.S,~F.Store,~F.Resources,~F.Events(),~B.Owners4(),~B.Rows4(),~B.observe4(),~B.fold4(),App.Application{schema,Build.Registered{world,owners,recipe,debug}},"Composed",plan(sid,cid,rid)))
def run_previous(value:Previous()) -> Previous() & RunDescription:
  match value:
    case App.Application{schema,Build.Registered{world,owners,recipe,debug}}:identified(schema,recipe,debug,world,Dispatch.identified(owners))
def run(value:Application()) -> Application() & RunDescription:Family.with_previous(~F.S,~F.Store,~F.Resources,~F.Events(),~Events.State(),~B.Owners4(),~B.Rows4(),~B.observe4(),~B.fold4(),~RunDescription,run_previous,value)
def synchronized(schema:Schema.Schema<F.S,F.Store,F.Resources>,owners:B.Owners4(),recipe:Tree.Recipe<F.World(),B.Rows4(),B.observe4()>,debug:Bool,+tick:Nat,result:F.World() & Events.State()) -> Application():
  match result:
    case (world,family):Family.Application{schema,Route.Runtime{world,family,tick},owners,recipe,debug}
def emitted(schema:Schema.Schema<F.S,F.Store,F.Resources>,owners:B.Owners4(),recipe:Tree.Recipe<F.World(),B.Rows4(),B.observe4()>,debug:Bool,family:Events.State(),+tick:Nat,result:Tx.Returned<F.World(),Unit>) -> Application():
  match result:
    case Tx.Returned{world,_}:synchronized(schema,owners,recipe,debug,tick,FR.synchronize(~F.S,~F.Store,~F.Resources,~F.Events(),~Events.Metadata(),~Array<U32>,~Events.sync(),world,family,tick))
def publish(value:Application()) -> Application():
  match value:
    case Family.Application{schema,Route.Runtime{world,family,tick},owners,recipe,debug}:emitted(schema,owners,recipe,debug,family,1n+tick,Cmd.tx_finish(~F.S,~F.Store,~F.Resources,~F.Events(),~Unit,Pub.emit_first(~F.S,~F.Store,~F.Resources,~F.PairEvents(),~F.UnusedEvent,Pub.emit_first(~F.S,~F.Store,~F.Resources,~F.PairEvents(),~F.UnusedEvent,Tx.begin(~F.World(),~F.Events(),world),Pub.Publication{[F.FirstEvent{7}],[]}),Pub.Publication{[],[F.SecondEvent{True{}}]}),Tx.Success{}))
