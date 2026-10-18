import Base
import /tmp/bendvy-dense-plan-once/experiments/s-perf/canonical-api-v1/dense-runtime-v1/motion.bend as F
import /tmp/bendvy-dense-plan-once/experiments/s-perf/canonical-api-v1/dense-runtime-v1/types.bend as T
import /tmp/bendvy-dense-plan-once/src/ecs/ordinary-system.bend as Ordinary
import /tmp/bendvy-dense-plan-once/src/ecs/ordinary-query-declaration.bend as Decl
import /tmp/bendvy-dense-plan-once/src/ecs/compose.bend as Q
import /tmp/bendvy-dense-plan-once/src/ecs/transaction.bend as Tx
import /tmp/bendvy-dense-plan-once/src/ecs/system.bend as Sys
import /tmp/bendvy-dense-plan-once/src/ecs/world.bend as W
import /tmp/bendvy-dense-plan-once/src/ecs/ordinary-app-run.bend as EntryApp
import /tmp/bendvy-dense-plan-once/src/ecs/ordinary-app-schedule.bend as Single
import /tmp/bendvy-dense-plan-once/src/ecs/ordinary-app-schema.bend as SchemaApp
import /tmp/bendvy-dense-plan-once/src/ecs/ordinary-app-composer.bend as Build
import /tmp/bendvy-dense-plan-once/src/ecs/ordinary-app-execution-recipe.bend as Exec
import /tmp/bendvy-dense-plan-once/src/ecs/ordinary-app-existing-execution.bend as Existing
import /tmp/bendvy-dense-plan-once/src/ecs/ordinary-app-registration-fields.bend as Fields
import /tmp/bendvy-dense-plan-once/src/ecs/ordinary-app-recipe.bend as Tree
import /tmp/bendvy-dense-plan-once/src/ecs/ordinary-app-execution.bend as Execute
import /tmp/bendvy-dense-plan-once/src/ecs/ordinary-schema.bend as Schema
import /tmp/bendvy-dense-plan-once/src/ecs/schema-fragments.bend as Fragment
import /tmp/bendvy-dense-plan-once/src/ecs/column.bend as Col
import /tmp/bendvy-dense-plan-once/src/ecs/schedule-provision.bend as SP
import /tmp/bendvy-dense-plan-once/src/ecs/schedule.bend as Sch
import /tmp/bendvy-dense-plan-once/src/ecs/execution-context.bend as Ctx
import /tmp/bendvy-dense-plan-once/src/ecs/trace-facts.bend as Facts
import /tmp/bendvy-dense-plan-once/experiments/s-perf/canonical-api-v1/dense-runtime-v1/motion-driver.bend as Driver
import /tmp/bendvy-dense-plan-once/experiments/s-perf/canonical-api-v1/dense-runtime-v1/motion-logical.bend as Logical
import /tmp/bendvy-dense-plan-once/experiments/s-perf/canonical-api-v1/dense-runtime-v1/payload.bend as P
import /tmp/bendvy-dense-plan-once/experiments/s-perf/canonical-api-v1/dense-runtime-v1/types.bend as T2
import /tmp/bendvy-dense-plan-once/src/ecs/entity-allocator.bend as Allocator
import /tmp/bendvy-dense-plan-once/src/ecs/deferred-command.bend as Deferred


import /tmp/bendvy-dense-plan-once/src/ecs/owner-product.bend as Product
import /tmp/bendvy-dense-plan-once/src/ecs/inspector-query-projection.bend as Projection
import /tmp/bendvy-dense-plan-once/src/ecs/inspector-query.bend as IQ
import /tmp/bendvy-dense-plan-once/src/ecs/component.bend as Cmp
import /tmp/bendvy-dense-plan-once/src/ecs/entity-key.bend as Key

type Common is Data:
  Common{rows:Logical.Rows(),ledger:T.LedgerView,audits:List<&2,Driver.Audit>,statuses:List<&2,Driver.Status>}
def captured(owner:F.Owner(),+audits:List<&2,Driver.Audit>,+statuses:List<&2,Driver.Status>,+rows:Logical.Rows(),+namespace:U32,allocator:Allocator.Allocator,store:F.Store(),unit:Unit,+events:List<&2,Nat>,pending:List<Deferred.Command<F.World()>>,+registrations:List<&2,W.RegistrationMeta>,+nextSystem:U32,+clock:U32,observed:T.MotionLedger & T.LedgerView) -> Driver.View & Common:
  match observed:
    case (ledger,+view):(Driver.View{W.World{namespace,allocator,store,Product.Owner{ledger,unit},events,pending,registrations,nextSystem,clock},owner,audits,statuses},Common{rows,view,audits,statuses})
def captured_world(owner:F.Owner(),audits:List<&2,Driver.Audit>,statuses:List<&2,Driver.Status>,rows:Logical.Rows(),world:F.World()) -> Driver.View & Common:
  match world:
    case W.World{namespace,allocator,store,Product.Owner{ledger,unit},events,pending,registrations,nextSystem,clock}:captured(owner,audits,statuses,rows,namespace,allocator,store,unit,events,pending,registrations,nextSystem,clock,P.motion_ledger_get(ledger))
def captured_rows(owner:F.Owner(),audits:List<&2,Driver.Audit>,statuses:List<&2,Driver.Status>,observed:F.World() & Logical.Rows()) -> Driver.View & Common:
  match observed:
    case (world,rows):captured_world(owner,audits,statuses,rows,world)
def capture_view(value:Driver.View) -> Driver.View & Common:
  match value:
    case Driver.View{world,owner,audits,statuses}:captured_rows(owner,audits,statuses,Logical.rows(world))

def live_view(schema:Schema.Schema<T.MotionSchema,F.Store(),F.Resources()>,recipe:Tree.Recipe<F.World(),Unit,Build.empty_observe(~F.World())>,debug:Bool,plan:SP.Plan<T.MotionSchema>,namespace:U32,name:String,steps:List<&2,Sch.Step>,needs:List<&2,SP.Requirement<T.MotionSchema>>,result:Driver.View & Common) -> Driver.State & Common:
  match result:
    case (Driver.View{world,owner,audit,statuses},text):(Driver.State{Single.Attached{EntryApp.Application{Single.Application{SchemaApp.Application{schema,Build.Registered{world,(owner,Driver.Shared{audit,statuses}),recipe,debug}},plan,namespace,name,steps,needs},Exec.Recipe{}}}},text)
def invalid_view(recipe:Tree.Recipe<F.World(),Unit,Build.empty_observe(~F.World())>,debug:Bool,result:Driver.View & Common) -> Driver.State & Common:
  match result:
    case (Driver.View{world,owner,audit,statuses},text):(Driver.State{Single.Invalid{Exec.Registered{Build.Registered{world,(owner,Driver.Shared{audit,statuses}),recipe,debug},Exec.Recipe{}}}},text)
def inspect(~observe:Driver.View -> Driver.View & Common,state:Driver.State) -> Driver.State & Common:
  match state:
    case Driver.State{Single.Attached{EntryApp.Application{Single.Application{SchemaApp.Application{schema,Build.Registered{world,(owner,Driver.Shared{audit,statuses}),recipe,debug}},plan,namespace,name,steps,needs},_}}}:live_view(schema,recipe,debug,plan,namespace,name,steps,needs,observe(Driver.View{world,owner,audit,statuses}))
    case Driver.State{Single.Invalid{Exec.Registered{Build.Registered{world,(owner,Driver.Shared{audit,statuses}),recipe,debug},_}}}:invalid_view(recipe,debug,observe(Driver.View{world,owner,audit,statuses}))

def capture(value:Driver.State) -> Driver.State & Common:inspect(~capture_view,value)
