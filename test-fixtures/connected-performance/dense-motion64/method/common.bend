import Base
import ../consumer/s-perf/canonical-api-v1/dense-runtime-v1/motion.bend as F
import ../consumer/s-perf/canonical-api-v1/dense-runtime-v1/types.bend as T
import ../../../../src/ecs/world.bend as W
import ../consumer/s-perf/canonical-api-v1/dense-runtime-v1/motion-driver.bend as Driver
import ../consumer/s-perf/canonical-api-v1/dense-runtime-v1/motion-logical.bend as Logical
import ../consumer/s-perf/canonical-api-v1/dense-runtime-v1/payload.bend as P
import ../../../../src/ecs/entity-allocator.bend as Allocator
import ../../../../src/ecs/deferred-command.bend as Deferred


import ../../../../src/ecs/owner-product.bend as Product

type Common is Data:
  Common{rows:Logical.Rows(),ledger:T.LedgerView,audits:List<&2,Driver.Audit>,statuses:List<&2,Driver.Status>}
def captured(owner:Driver.Owner(),+audits:List<&2,Driver.Audit>,+statuses:List<&2,Driver.Status>,+rows:Logical.Rows(),+namespace:U32,allocator:Allocator.Allocator,store:F.Store(),unit:Unit,+events:List<&2,Nat>,pending:List<Deferred.Command<F.World()>>,+registrations:List<&2,W.RegistrationMeta>,+nextSystem:U32,+clock:U32,observed:T.MotionLedger & T.LedgerView) -> Driver.View & Common:
  match observed:
    case (ledger,+view):(Driver.View{W.World{namespace,allocator,store,Product.Owner{ledger,unit},events,pending,registrations,nextSystem,clock},owner,audits,statuses},Common{rows,view,audits,statuses})
def captured_world(owner:Driver.Owner(),audits:List<&2,Driver.Audit>,statuses:List<&2,Driver.Status>,rows:Logical.Rows(),world:F.World()) -> Driver.View & Common:
  match world:
    case W.World{namespace,allocator,store,Product.Owner{ledger,unit},events,pending,registrations,nextSystem,clock}:captured(owner,audits,statuses,rows,namespace,allocator,store,unit,events,pending,registrations,nextSystem,clock,P.motion_ledger_get(ledger))
def captured_rows(owner:Driver.Owner(),audits:List<&2,Driver.Audit>,statuses:List<&2,Driver.Status>,observed:F.World() & Logical.Rows()) -> Driver.View & Common:
  match observed:
    case (world,rows):captured_world(owner,audits,statuses,rows,world)
def capture_view(value:Driver.View) -> Driver.View & Common:
  match value:
    case Driver.View{world,owner,audits,statuses}:captured_rows(owner,audits,statuses,Logical.rows(world))

def capture(value:Driver.State) -> Driver.State & Common:Driver.inspect(~Common,capture_view,value)
