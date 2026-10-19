import Base
import method.bend as M
import ../consumer/motion-program.bend as P
import ../../../consumer/motion-logical.bend as Logical
import ../../../consumer/motion.bend as F
import ../../../consumer/types.bend as T
import ../../../consumer/events.bend as E
import ../../../consumer/payload.bend as Payload
import ../../../method/json.bend as J
import ../../../../../../src/ecs/world.bend as W
import ../../../../../../src/ecs/owner-product.bend as Product

type Captured is Data:
  Captured{carriers:M.Carriers,public:J.Value}
def resource_returned(unit:Unit,result:T.MotionLedger & T.LedgerView) -> F.Resources() & T.LedgerView:
  match result:
    case (owner,view):(Product.Owner{owner,unit},view)
def resource(value:F.Resources()) -> F.Resources() & T.LedgerView:
  match value:
    case Product.Owner{owner,unit}:resource_returned(unit,Payload.motion_ledger_get(owner))
def rows_done(+seed:List<&2,W.Reservation<T.MotionSchema>>,seedCall:J.Value,+view:P.Capture,ledger:T.LedgerView,result:F.World() & Logical.Rows()) -> Captured:
  match result:
    case (_,rows):Captured{M.build(seed,view,rows,ledger),M.public(seed,seedCall,view)}
def ledger_done(seed:List<&2,W.Reservation<T.MotionSchema>>,seedCall:J.Value,view:P.Capture,result:F.World() & T.LedgerView) -> Captured:
  match result:
    case (world,ledger):rows_done(seed,seedCall,view,ledger,Logical.rows(world))
def state_done(seed:List<&2,W.Reservation<T.MotionSchema>>,seedCall:J.Value,result:P.State & P.Capture) -> Captured:
  match result:
    case (state,view):ledger_done(seed,seedCall,view,W.observe_resource(~T.MotionSchema,~F.Store(),~F.Resources(),~E.event_type(),~T.LedgerView,~resource,P.finish_world(state)))
def run(seed:List<&2,W.Reservation<T.MotionSchema>>,seedCall:J.Value,state:P.State) -> Captured:state_done(seed,seedCall,P.capture(state))
