import Base
import ../consumer/s-perf/canonical-api-v1/dense-runtime-v1/motion.bend as F
import ../consumer/s-perf/canonical-api-v1/dense-runtime-v1/types.bend as T
import ../../../../src/ecs/ordinary-system.bend as Ordinary
import ../../../../src/ecs/ordinary-query-declaration.bend as Decl
import ../../../../src/ecs/compose.bend as Q
import ../../../../src/ecs/transaction.bend as Tx
import ../../../../src/ecs/system.bend as Sys
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/ordinary-app-run.bend as EntryApp
import ../../../../src/ecs/ordinary-app-schedule.bend as Single
import ../../../../src/ecs/ordinary-app-schema.bend as SchemaApp
import ../../../../src/ecs/ordinary-app-composer.bend as Build
import ../../../../src/ecs/ordinary-app-execution-recipe.bend as Exec
import ../../../../src/ecs/ordinary-app-existing-execution.bend as Existing
import ../../../../src/ecs/ordinary-app-registration-fields.bend as Fields
import ../../../../src/ecs/ordinary-app-recipe.bend as Tree
import ../../../../src/ecs/ordinary-app-execution.bend as Execute
import ../../../../src/ecs/ordinary-schema.bend as Schema
import ../../../../src/ecs/schema-fragments.bend as Fragment
import ../../../../src/ecs/column.bend as Col
import ../../../../src/ecs/schedule-provision.bend as SP
import ../../../../src/ecs/schedule.bend as Sch
import ../../../../src/ecs/execution-context.bend as Ctx
import ../../../../src/ecs/trace-facts.bend as Facts
import ../consumer/s-perf/canonical-api-v1/dense-runtime-v1/motion-driver.bend as Driver
import ../consumer/s-perf/canonical-api-v1/dense-runtime-v1/motion-logical.bend as Logical
import ../consumer/s-perf/canonical-api-v1/dense-runtime-v1/payload.bend as P
import ../consumer/s-perf/canonical-api-v1/dense-runtime-v1/types.bend as T2
import ../../../../src/ecs/entity-allocator.bend as Allocator
import ../../../../src/ecs/deferred-command.bend as Deferred


import ../../../../src/ecs/owner-product.bend as Product
import ../../../../src/ecs/inspector-query-projection.bend as Projection
import ../../../../src/ecs/inspector-query.bend as IQ
import ../../../../src/ecs/component.bend as Cmp
import ../../../../src/ecs/entity-key.bend as Key

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
