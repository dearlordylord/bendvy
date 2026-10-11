import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-access.bend as Access
import /workspace/formal-proofs/bendvy/src/ecs/event-publication.bend as Pub
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as Tx
import /workspace/formal-proofs/bendvy/src/ecs/commands.bend as Cmd
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-recipe.bend as Tree
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-service-declaration.bend as D
import state.bend as F
import reader-bindings.bend as B
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
def Previous() -> Type:App.Application<F.S,F.Store,F.Resources,F.Events(),B.Owners7(),B.Rows7(),B.observe7(),B.fold7()>
def Application() -> Type:B.App7()
def snapshot(value:Application()) -> Application() & Maybe<&2,App.Description<F.S,B.Rows7()>>:Family.snapshot(~F.S,~F.Store,~F.Resources,~F.Events(),~Events.State(),~B.Owners7(),~B.Rows7(),~B.observe7(),~B.fold7(),value)
def enabled(value:Application(),flag:Bool) -> Application():Family.enabled(~F.S,~F.Store,~F.Resources,~F.Events(),~Events.State(),~B.Owners7(),~B.Rows7(),~B.observe7(),~B.fold7(),value,flag)
def inventory(value:Application()) -> Application() & Maybe<&2,List<&2,String>>:Family.inventory(~F.S,~F.Store,~F.Resources,~F.Events(),~Events.Metadata(),~Array<U32>,~Events.inventory(),~B.Owners7(),~B.Rows7(),~B.observe7(),~B.fold7(),value)
def dump_previous(value:Previous()) -> Previous() & Maybe<&2,Dump.Dump<F.S>>:Dump.schema_snapshot(~F.S,~F.Store,~F.Resources,~F.Events(),~B.Owners7(),~B.Rows7(),~B.observe7(),~B.fold7(),~F.count(),~F.values(),~F.resources(),Filter.Filter{None{},[],Some{1n}},value)
def dump(value:Application()) -> Application() & Maybe<&2,Dump.Dump<F.S>>:Family.with_previous(~F.S,~F.Store,~F.Resources,~F.Events(),~Events.State(),~B.Owners7(),~B.Rows7(),~B.observe7(),~B.fold7(),~Maybe<&2,Dump.Dump<F.S>>,dump_previous,value)
def synchronized(schema:Schema.Schema<F.S,F.Store,F.Resources>,owners:B.Owners7(),recipe:Tree.Recipe<F.World(),B.Rows7(),B.observe7()>,debug:Bool,+tick:Nat,result:F.World() & Events.State()) -> Application():
  match result:
    case (world,family):Family.Application{schema,Route.Runtime{world,family,tick},owners,recipe,debug}
def emitted(schema:Schema.Schema<F.S,F.Store,F.Resources>,owners:B.Owners7(),recipe:Tree.Recipe<F.World(),B.Rows7(),B.observe7()>,debug:Bool,family:Events.State(),+tick:Nat,result:Tx.Returned<F.World(),Unit>) -> Application():
  match result:
    case Tx.Returned{world,_}:synchronized(schema,owners,recipe,debug,tick,FR.synchronize(~F.S,~F.Store,~F.Resources,~F.Events(),~Events.Metadata(),~Array<U32>,~Events.sync(),world,family,tick))
def publish(value:Application()) -> Application():
  match value:
    case Family.Application{schema,Route.Runtime{world,family,tick},owners,recipe,debug}:emitted(schema,owners,recipe,debug,family,1n+tick,Cmd.tx_finish(~F.S,~F.Store,~F.Resources,~F.Events(),~Unit,Pub.emit_first(~F.S,~F.Store,~F.Resources,~F.PairEvents(),~F.UnusedEvent,Pub.emit_first(~F.S,~F.Store,~F.Resources,~F.PairEvents(),~F.UnusedEvent,Tx.begin(~F.World(),~F.Events(),world),Pub.Publication{[F.FirstEvent{7}],[]}),Pub.Publication{[],[F.SecondEvent{True{}}]}),Tx.Success{}))
def index_previous(value:Previous()) -> Previous() & Maybe<&2,List<&2,Access.Entry>>:Access.schema_index(~F.S,~F.Store,~F.Resources,~F.Events(),~B.Owners7(),~B.Rows7(),~B.observe7(),~B.fold7(),value)
def index(value:Application()) -> Application() & Maybe<&2,List<&2,Access.Entry>>:Family.with_previous(~F.S,~F.Store,~F.Resources,~F.Events(),~Events.State(),~B.Owners7(),~B.Rows7(),~B.observe7(),~B.fold7(),~Maybe<&2,List<&2,Access.Entry>>,index_previous,value)
