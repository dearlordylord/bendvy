import Base
import method.bend as M
import ../consumer/motion-report-doc.bend as Doc
import ../consumer/motion-doc-world.bend as DocWorld
import ../consumer/motion-stream.bend as Stream
import ../consumer/motion-program.bend as P
import ../consumer/motion-logical.bend as Logical
import ../consumer/motion-observe.bend as O
import ../consumer/motion.bend as F
import ../consumer/types.bend as T
import ../consumer/events.bend as E
import ../consumer/payload.bend as Payload
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/owner-product.bend as Product

type Captured is Data:
  Captured{prefix:Doc.Doc,view:Stream.StateView,logical:String,after:Doc.Doc,carriers:M.Carriers}
def resource_returned(unit:Unit,result:T.MotionLedger & T.LedgerView) -> F.Resources() & T.LedgerView:
  match result:
    case (owner,view):(Product.Owner{owner,unit},view)
def resource(value:F.Resources()) -> F.Resources() & T.LedgerView:
  match value:
    case Product.Owner{owner,unit}:resource_returned(unit,Payload.motion_ledger_get(owner))
def after(seed:List<&2,W.Reservation<T.MotionSchema>>,prefix:Doc.Doc,+view:Stream.StateView,rows:Logical.Rows(),ledger:T.LedgerView,text:String,result:F.World() & Doc.Doc) -> Captured:
  match result:
    case (_,snapshot):Captured{prefix,view,text,snapshot,M.build(seed,view,rows,ledger)}
def rendered(seed:List<&2,W.Reservation<T.MotionSchema>>,prefix:Doc.Doc,view:Stream.StateView,rows:Logical.Rows(),ledger:T.LedgerView,result:F.World() & String) -> Captured:
  match result:
    case (world,text):after(seed,prefix,view,rows,ledger,text,DocWorld.world(world))
def rows_done(seed:List<&2,W.Reservation<T.MotionSchema>>,prefix:Doc.Doc,view:Stream.StateView,ledger:T.LedgerView,result:F.World() & Logical.Rows()) -> Captured:
  match result:
    case (world,+rows):rendered(seed,prefix,view,rows,ledger,O.rows_observed((world,rows)))
def ledger_done(seed:List<&2,W.Reservation<T.MotionSchema>>,prefix:Doc.Doc,view:Stream.StateView,result:F.World() & T.LedgerView) -> Captured:
  match result:
    case (world,ledger):rows_done(seed,prefix,view,ledger,Logical.rows(world))
def state_done(seed:List<&2,W.Reservation<T.MotionSchema>>,prefix:Doc.Doc,result:P.State & Stream.StateView) -> Captured:
  match result:
    case (state,view):ledger_done(seed,prefix,view,W.observe_resource(~T.MotionSchema,~F.Store(),~F.Resources(),~E.event_type(),~T.LedgerView,~resource,P.finish_world(state)))
def run(seed:List<&2,W.Reservation<T.MotionSchema>>,prefix:Doc.Doc,state:P.State) -> Captured:state_done(seed,prefix,Stream.state(state))
def write(value:Captured) -> IO(Unit):
  match value:
    case Captured{prefix,view,logical,after,_}:IO.bind(Unit,Unit,Doc.write(Doc.join(prefix,Doc.text("final={"))),_=>IO.bind(Unit,Unit,Stream.write_state(view),_=>IO.bind(Unit,Unit,IO.write("};finalLogicalRows=" ++ logical),_=>Doc.write(Doc.concat([Doc.text(";afterLogicalWorld={"),after,Doc.text("}\n\n")])))))
