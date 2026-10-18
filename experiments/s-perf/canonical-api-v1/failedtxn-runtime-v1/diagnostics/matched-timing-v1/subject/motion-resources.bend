import Base
import /tmp/bendvy-failedtxn-matched-method/experiments/s-perf/canonical-api-v1/dense-runtime-v1/types.bend as T
import /tmp/bendvy-failedtxn-matched-method/experiments/s-perf/canonical-api-v1/dense-runtime-v1/payload.bend as Payload
import /tmp/bendvy-failedtxn-matched-method/src/ecs/owner-product.bend as Product
import /tmp/bendvy-failedtxn-matched-method/src/ecs/ordinary-service-declaration.bend as Service

# One quiet service owner survives outside the Ledger field's undo journal.
type Audit is Type:
  Recorded{effects:List<&2,String>}
type AuditView is Data:
  Missing{}
  RecordedView{effects:List<&2,String>}
type View is Data:
  View{ledger:T.LedgerView,audit:AuditView}
def Resources() -> Type:Product.Owner<T.MotionLedger,Service.Slot<Audit>>
def ledger_lens() -> Product.Lens<Resources(),T.MotionLedger,Service.Slot<Audit>>:
  Product.lens(~T.MotionLedger,~Service.Slot<Audit>,~Product.Left{})
def take_audit(owner:Resources()) -> T.MotionLedger & Service.Slot<Audit>:
  Product.take(~T.MotionLedger,~Service.Slot<Audit>,Product.Right{},owner)
def put_audit(ledger:T.MotionLedger,audit:Service.Slot<Audit>) -> Resources():
  Product.put(~T.MotionLedger,~Service.Slot<Audit>,Product.Right{},ledger,audit)
def record(owner:Audit,text:String) -> Audit & Unit:
  match owner:
    case Recorded{effects}:(Recorded{text <> effects},Unit{})
def audit_view(slot:Service.Slot<Audit>) -> Service.Slot<Audit> & AuditView:
  match slot:
    case Service.Missing{}:(Service.Missing{},Missing{})
    case Service.Ready{Recorded{+effects}}:(Service.Ready{Recorded{effects}},RecordedView{effects})
def observed(ledger:T.MotionLedger,view:T.LedgerView,result:Service.Slot<Audit> & AuditView) -> Resources() & View:
  match result:
    case (slot,audit):(Product.Owner{ledger,slot},View{view,audit})
def ledger_observed(slot:Service.Slot<Audit>,result:T.MotionLedger & T.LedgerView) -> Resources() & View:
  match result:
    case (ledger,view):observed(ledger,view,audit_view(slot))
def observe(owner:Resources()) -> Resources() & View:
  match owner:
    case Product.Owner{ledger,slot}:ledger_observed(slot,Payload.motion_ledger_get(ledger))
def initial() -> Resources():
  Product.Owner{T.MotionLedger{ANode{ANode{ALeaf{0},ALeaf{101}},ANode{ALeaf{102},ALeaf{103}}},4},Service.Ready{Recorded{[]}}}
