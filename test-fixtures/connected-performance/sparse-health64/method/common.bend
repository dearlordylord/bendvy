import Base
import ../consumer/s-perf/canonical-api-v1/sparse-runtime-v1/health.bend as F
import ../../sparse-motion64/consumer/s-perf/canonical-api-v1/sparse-runtime-v1/types.bend as T
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
import ../consumer/s-perf/canonical-api-v1/sparse-runtime-v1/health-driver.bend as Driver
import ../consumer/s-perf/canonical-api-v1/sparse-runtime-v1/health-logical.bend as Logical
import ../../sparse-motion64/consumer/s-perf/canonical-api-v1/sparse-runtime-v1/payload.bend as P
import ../../sparse-motion64/consumer/s-perf/canonical-api-v1/sparse-runtime-v1/types.bend as T2
import ../../../../src/ecs/entity-allocator.bend as Allocator
import ../../../../src/ecs/deferred-command.bend as Deferred


import ../../../../src/ecs/owner-product.bend as Product
import ../../../../src/ecs/inspector-query-projection.bend as Projection
import ../../../../src/ecs/inspector-query.bend as IQ
import ../../../../src/ecs/component.bend as Cmp
import ../../../../src/ecs/entity-key.bend as Key

type Common is Data:
  Common{rows:Logical.Rows(),ledger:T.LedgerView,audits:List<&2,Driver.Audit>,statuses:List<&2,Driver.Status>,cumulative:U32}
def captured(owner:Driver.Owner(),+audits:List<&2,Driver.Audit>,+statuses:List<&2,Driver.Status>,+rows:Logical.Rows(),+cumulative:U32,+namespace:U32,allocator:Allocator.Allocator,store:F.Store(),unit:Unit,+events:List<&2,Nat>,pending:List<Deferred.Command<F.World()>>,+registrations:List<&2,W.RegistrationMeta>,+nextSystem:U32,+clock:U32,observed:T.HealthLedger & T.LedgerView) -> Driver.View & Common:
  match observed:
    case (ledger,+view):(Driver.View{W.World{namespace,allocator,store,Product.Owner{ledger,unit},events,pending,registrations,nextSystem,clock},owner,audits,statuses,cumulative},Common{rows,view,audits,statuses,cumulative})
def captured_world(owner:Driver.Owner(),audits:List<&2,Driver.Audit>,statuses:List<&2,Driver.Status>,rows:Logical.Rows(),cumulative:U32,world:F.World()) -> Driver.View & Common:
  match world:
    case W.World{namespace,allocator,store,Product.Owner{ledger,unit},events,pending,registrations,nextSystem,clock}:captured(owner,audits,statuses,rows,cumulative,namespace,allocator,store,unit,events,pending,registrations,nextSystem,clock,P.health_ledger_get(ledger))
def captured_rows(owner:Driver.Owner(),audits:List<&2,Driver.Audit>,statuses:List<&2,Driver.Status>,cumulative:U32,observed:F.World() & Logical.Rows()) -> Driver.View & Common:
  match observed:
    case (world,rows):captured_world(owner,audits,statuses,rows,cumulative,world)
def capture_view(value:Driver.View) -> Driver.View & Common:
  match value:
    case Driver.View{world,owner,audits,statuses,cumulative}:captured_rows(owner,audits,statuses,cumulative,Logical.rows(world))

def capture(value:Driver.State) -> Driver.State & Common:Driver.inspect(~Common,capture_view,value)
