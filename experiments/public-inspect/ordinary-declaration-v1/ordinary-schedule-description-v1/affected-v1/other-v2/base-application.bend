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
def Previous() -> Type:App.Application<F.Other,F.Store,F.Resources,F.Events(),B.Owners4(),B.Rows4(),B.observe4(),B.fold4()>
def Application() -> Type:Family.Application<F.Other,F.Store,F.Resources,F.Events(),Events.State(),B.Owners4(),B.Rows4(),B.observe4(),B.fold4()>
def extracted(value:DumpProvision.Provision<F.Other,F.Store,F.Resources,F.empty,F.count(),F.values(),F.resources()>) -> Schema.Schema<F.Other,F.Store,F.Resources>:
  match value:
    case DumpProvision.Provision{Provision.Provision{schema}}:schema
def schema() -> Schema.Schema<F.Other,F.Store,F.Resources>:extracted(F.provision())
def started(value:B.App4()) -> Application():Family.start(~F.Other,~F.Store,~F.Resources,~F.Events(),~Events.Domains(),~Events.Metadata(),~Array<U32>,~Events.make(),~Events.sync(),~Events.frame(),~Events.retain(),~Events.inventory(),~B.Owners4(),~B.Rows4(),~B.observe4(),~B.fold4(),Events.provision(),ANode{ALeaf{31},ALeaf{32}},2n,App.attached(~F.Other,~F.Store,~F.Resources,~F.Events(),~B.Owners4(),~B.Rows4(),~B.observe4(),~B.fold4(),schema(),value))
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
def construct(world:F.World()) -> Construction:B.service(~Construction,component_registered,service_rejected,B.machine(Build.empty(~F.Other,~F.World(),world)))
def synchronized(schema:Schema.Schema<F.Other,F.Store,F.Resources>,owners:B.Owners4(),recipe:Tree.Recipe<F.World(),B.Rows4(),B.observe4()>,debug:Bool,+tick:Nat,result:F.World() & Events.State()) -> Application():
  match result:
    case (world,family):Family.Application{schema,Route.Runtime{world,family,tick},owners,recipe,debug}
def emitted(schema:Schema.Schema<F.Other,F.Store,F.Resources>,owners:B.Owners4(),recipe:Tree.Recipe<F.World(),B.Rows4(),B.observe4()>,debug:Bool,family:Events.State(),+tick:Nat,result:Tx.Returned<F.World(),Unit>) -> Application():
  match result:
    case Tx.Returned{world,_}:synchronized(schema,owners,recipe,debug,tick,FR.synchronize(~F.Other,~F.Store,~F.Resources,~F.Events(),~Events.Metadata(),~Array<U32>,~Events.sync(),world,family,tick))
def publish(value:Application()) -> Application():
  match value:
    case Family.Application{schema,Route.Runtime{world,family,tick},owners,recipe,debug}:emitted(schema,owners,recipe,debug,family,1n+tick,Cmd.tx_finish(~F.Other,~F.Store,~F.Resources,~F.Events(),~Unit,Pub.emit_first(~F.Other,~F.Store,~F.Resources,~F.PairEvents(),~F.UnusedEvent,Pub.emit_first(~F.Other,~F.Store,~F.Resources,~F.PairEvents(),~F.UnusedEvent,Tx.begin(~F.World(),~F.Events(),world),Pub.Publication{[F.FirstEvent{7}],[]}),Pub.Publication{[],[F.SecondEvent{True{}}]}),Tx.Success{}))
