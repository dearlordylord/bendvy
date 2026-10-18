import Base
import method.bend as M
import /tmp/bendvy-readers-health-matched-method/experiments/s-perf/canonical-api-v1/readers-runtime-v1/health-stream.bend as Stream
import /tmp/bendvy-readers-health-matched-method/experiments/s-perf/canonical-api-v1/readers-runtime-v1/health-program.bend as P
import /tmp/bendvy-readers-health-matched-method/experiments/s-perf/canonical-api-v1/readers-runtime-v1/health-logical.bend as Logical
import /tmp/bendvy-readers-health-matched-method/experiments/s-perf/canonical-api-v1/readers-runtime-v1/health-observe.bend as O
import /tmp/bendvy-readers-health-matched-method/experiments/s-perf/canonical-api-v1/readers-runtime-v1/health.bend as F
import /tmp/bendvy-readers-health-matched-method/experiments/s-perf/canonical-api-v1/readers-runtime-v1/types.bend as T
import /tmp/bendvy-readers-health-matched-method/experiments/s-perf/canonical-api-v1/readers-runtime-v1/health-events.bend as E
import /tmp/bendvy-readers-health-matched-method/experiments/s-perf/canonical-api-v1/readers-runtime-v1/payload.bend as Payload
import /tmp/bendvy-readers-health-matched-method/src/ecs/world.bend as W
import /tmp/bendvy-readers-health-matched-method/src/ecs/owner-product.bend as Product

type Captured is Data:
  Captured{prefix:String,view:Stream.StateView,logical:String,after:String,carriers:M.Carriers}
def resource_returned(unit:Unit,result:T.HealthLedger & T.LedgerView) -> F.Resources() & T.LedgerView:
  match result:
    case (owner,view):(Product.Owner{owner,unit},view)
def resource(value:F.Resources()) -> F.Resources() & T.LedgerView:
  match value:
    case Product.Owner{owner,unit}:resource_returned(unit,Payload.health_ledger_get(owner))
def after(seed:List<&2,W.Reservation<T.HealthSchema>>,prefix:String,+view:Stream.StateView,rows:Logical.Rows(),ledger:T.LedgerView,text:String,result:F.World() & String) -> Captured:
  match result:
    case (_,snapshot):Captured{prefix,view,text,snapshot,M.build(seed,view,rows,ledger)}
def rendered(seed:List<&2,W.Reservation<T.HealthSchema>>,prefix:String,view:Stream.StateView,rows:Logical.Rows(),ledger:T.LedgerView,result:F.World() & String) -> Captured:
  match result:
    case (world,text):after(seed,prefix,view,rows,ledger,text,O.world(world))
def rows_done(seed:List<&2,W.Reservation<T.HealthSchema>>,prefix:String,view:Stream.StateView,ledger:T.LedgerView,result:F.World() & Logical.Rows()) -> Captured:
  match result:
    case (world,+rows):rendered(seed,prefix,view,rows,ledger,O.rows_observed((world,rows)))
def ledger_done(seed:List<&2,W.Reservation<T.HealthSchema>>,prefix:String,view:Stream.StateView,result:F.World() & T.LedgerView) -> Captured:
  match result:
    case (world,ledger):rows_done(seed,prefix,view,ledger,Logical.rows(world))
def state_done(seed:List<&2,W.Reservation<T.HealthSchema>>,prefix:String,result:P.State & Stream.StateView) -> Captured:
  match result:
    case (state,view):ledger_done(seed,prefix,view,W.observe_resource(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),~T.LedgerView,~resource,P.finish_world(state)))
def run(seed:List<&2,W.Reservation<T.HealthSchema>>,prefix:String,state:P.State) -> Captured:state_done(seed,prefix,Stream.state(state))
def write(value:Captured) -> IO(Unit):
  match value:
    case Captured{prefix,view,logical,after,_}:IO.bind(Unit,Unit,IO.write(prefix ++ "final={"),_=>IO.bind(Unit,Unit,Stream.write_state(view),_=>IO.bind(Unit,Unit,IO.write("};finalLogicalRows=" ++ logical),_=>IO.write(";afterLogicalWorld={" ++ after ++ "}\n\n"))))
