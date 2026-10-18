import Base
import /tmp/bendvy-sparse-health-matched-method/experiments/s-perf/canonical-api-v1/sparse-runtime-v1/health.bend as F
import /tmp/bendvy-sparse-health-matched-method/experiments/s-perf/canonical-api-v1/sparse-runtime-v1/types.bend as T
import /tmp/bendvy-sparse-health-matched-method/src/ecs/ordinary-system.bend as Ordinary
import /tmp/bendvy-sparse-health-matched-method/src/ecs/ordinary-query-declaration.bend as Decl
import /tmp/bendvy-sparse-health-matched-method/src/ecs/compose.bend as Q
import /tmp/bendvy-sparse-health-matched-method/src/ecs/transaction.bend as Tx
import /tmp/bendvy-sparse-health-matched-method/src/ecs/system.bend as Sys
import /tmp/bendvy-sparse-health-matched-method/src/ecs/world.bend as W
import /tmp/bendvy-sparse-health-matched-method/src/ecs/ordinary-app-run.bend as EntryApp
import /tmp/bendvy-sparse-health-matched-method/src/ecs/ordinary-app-schedule.bend as Single
import /tmp/bendvy-sparse-health-matched-method/src/ecs/ordinary-app-schema.bend as SchemaApp
import /tmp/bendvy-sparse-health-matched-method/src/ecs/ordinary-app-composer.bend as Build
import /tmp/bendvy-sparse-health-matched-method/src/ecs/ordinary-app-execution-recipe.bend as Exec
import /tmp/bendvy-sparse-health-matched-method/src/ecs/ordinary-app-existing-execution.bend as Existing
import /tmp/bendvy-sparse-health-matched-method/src/ecs/ordinary-app-registration-fields.bend as Fields
import /tmp/bendvy-sparse-health-matched-method/src/ecs/ordinary-app-recipe.bend as Tree
import /tmp/bendvy-sparse-health-matched-method/src/ecs/ordinary-app-execution.bend as Execute
import /tmp/bendvy-sparse-health-matched-method/src/ecs/ordinary-schema.bend as Schema
import /tmp/bendvy-sparse-health-matched-method/src/ecs/schema-fragments.bend as Fragment
import /tmp/bendvy-sparse-health-matched-method/src/ecs/column.bend as Col
import /tmp/bendvy-sparse-health-matched-method/src/ecs/schedule-provision.bend as SP
import /tmp/bendvy-sparse-health-matched-method/src/ecs/schedule.bend as Sch
import /tmp/bendvy-sparse-health-matched-method/src/ecs/execution-context.bend as Ctx
import /tmp/bendvy-sparse-health-matched-method/src/ecs/trace-facts.bend as Facts
import /tmp/bendvy-sparse-health-matched-method/experiments/s-perf/canonical-api-v1/sparse-runtime-v1/health-driver.bend as Driver
import /tmp/bendvy-sparse-health-matched-method/experiments/s-perf/canonical-api-v1/sparse-runtime-v1/health-logical.bend as Logical
import /tmp/bendvy-sparse-health-matched-method/experiments/s-perf/canonical-api-v1/sparse-runtime-v1/payload.bend as P
import /tmp/bendvy-sparse-health-matched-method/experiments/s-perf/canonical-api-v1/sparse-runtime-v1/types.bend as T2
import /tmp/bendvy-sparse-health-matched-method/src/ecs/entity-allocator.bend as Allocator
import /tmp/bendvy-sparse-health-matched-method/src/ecs/deferred-command.bend as Deferred


import /tmp/bendvy-sparse-health-matched-method/src/ecs/owner-product.bend as Product
import /tmp/bendvy-sparse-health-matched-method/src/ecs/inspector-query-projection.bend as Projection
import /tmp/bendvy-sparse-health-matched-method/src/ecs/inspector-query.bend as IQ
import /tmp/bendvy-sparse-health-matched-method/src/ecs/component.bend as Cmp
import /tmp/bendvy-sparse-health-matched-method/src/ecs/entity-key.bend as Key

type Common is Data:
  Common{rows:Logical.Rows(),ledger:T.LedgerView,audits:List<&2,Driver.Audit>,statuses:List<&2,Driver.Status>,cumulative:U32}
def captured(owner:F.Owner(),+audits:List<&2,Driver.Audit>,+statuses:List<&2,Driver.Status>,+rows:Logical.Rows(),+cumulative:U32,+namespace:U32,allocator:Allocator.Allocator,store:F.Store(),unit:Unit,+events:List<&2,Nat>,pending:List<Deferred.Command<F.World()>>,+registrations:List<&2,W.RegistrationMeta>,+nextSystem:U32,+clock:U32,observed:T.HealthLedger & T.LedgerView) -> Driver.View & Common:
  match observed:
    case (ledger,+view):(Driver.View{W.World{namespace,allocator,store,Product.Owner{ledger,unit},events,pending,registrations,nextSystem,clock},owner,audits,statuses,cumulative},Common{rows,view,audits,statuses,cumulative})
def captured_world(owner:F.Owner(),audits:List<&2,Driver.Audit>,statuses:List<&2,Driver.Status>,rows:Logical.Rows(),cumulative:U32,world:F.World()) -> Driver.View & Common:
  match world:
    case W.World{namespace,allocator,store,Product.Owner{ledger,unit},events,pending,registrations,nextSystem,clock}:captured(owner,audits,statuses,rows,cumulative,namespace,allocator,store,unit,events,pending,registrations,nextSystem,clock,P.health_ledger_get(ledger))
def captured_rows(owner:F.Owner(),audits:List<&2,Driver.Audit>,statuses:List<&2,Driver.Status>,cumulative:U32,observed:F.World() & Logical.Rows()) -> Driver.View & Common:
  match observed:
    case (world,rows):captured_world(owner,audits,statuses,rows,cumulative,world)
def capture_view(value:Driver.View) -> Driver.View & Common:
  match value:
    case Driver.View{world,owner,audits,statuses,cumulative}:captured_rows(owner,audits,statuses,cumulative,Logical.rows(world))

def live_view(schema:Schema.Schema<T.HealthSchema,F.Store(),F.Resources()>,recipe:Tree.Recipe<F.World(),Unit,Build.empty_observe(~F.World())>,debug:Bool,plan:SP.Plan<T.HealthSchema>,namespace:U32,name:String,steps:List<&2,Sch.Step>,needs:List<&2,SP.Requirement<T.HealthSchema>>,result:Driver.View & Common) -> Driver.State & Common:
  match result:
    case (Driver.View{world,owner,audit,statuses,cumulative},text):(Driver.State{Single.Attached{EntryApp.Application{Single.Application{SchemaApp.Application{schema,Build.Registered{world,(owner,Driver.Shared{audit,statuses,cumulative}),recipe,debug}},plan,namespace,name,steps,needs},Exec.Recipe{}}}},text)
def invalid_view(recipe:Tree.Recipe<F.World(),Unit,Build.empty_observe(~F.World())>,debug:Bool,result:Driver.View & Common) -> Driver.State & Common:
  match result:
    case (Driver.View{world,owner,audit,statuses,cumulative},text):(Driver.State{Single.Invalid{Exec.Registered{Build.Registered{world,(owner,Driver.Shared{audit,statuses,cumulative}),recipe,debug},Exec.Recipe{}}}},text)
def inspect(~observe:Driver.View -> Driver.View & Common,state:Driver.State) -> Driver.State & Common:
  match state:
    case Driver.State{Single.Attached{EntryApp.Application{Single.Application{SchemaApp.Application{schema,Build.Registered{world,(owner,Driver.Shared{audit,statuses,cumulative}),recipe,debug}},plan,namespace,name,steps,needs},_}}}:live_view(schema,recipe,debug,plan,namespace,name,steps,needs,observe(Driver.View{world,owner,audit,statuses,cumulative}))
    case Driver.State{Single.Invalid{Exec.Registered{Build.Registered{world,(owner,Driver.Shared{audit,statuses,cumulative}),recipe,debug},_}}}:invalid_view(recipe,debug,observe(Driver.View{world,owner,audit,statuses,cumulative}))

def capture(value:Driver.State) -> Driver.State & Common:inspect(~capture_view,value)
