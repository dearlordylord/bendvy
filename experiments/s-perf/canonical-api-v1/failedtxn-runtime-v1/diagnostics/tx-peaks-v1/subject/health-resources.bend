import Base
import ../../../../dense-runtime-v1/types.bend as T
import ../../../../dense-runtime-v1/payload.bend as Payload
import ../../../../../../../src/ecs/owner-product.bend as Product
import ../../../../../../../src/ecs/ordinary-service-declaration.bend as Service

# One quiet service owner survives outside the Ledger field's undo journal.
type Audit is Type:
  Recorded{effects:List<&2,String>}
type AuditView is Data:
  Missing{}
  RecordedView{effects:List<&2,String>}
type View is Data:
  View{ledger:T.LedgerView,audit:AuditView}
def Resources() -> Type:Product.Owner<T.HealthLedger,Service.Slot<Audit>>
def ledger_lens() -> Product.Lens<Resources(),T.HealthLedger,Service.Slot<Audit>>:
  Product.lens(~T.HealthLedger,~Service.Slot<Audit>,~Product.Left{})
def take_audit(owner:Resources()) -> T.HealthLedger & Service.Slot<Audit>:
  Product.take(~T.HealthLedger,~Service.Slot<Audit>,Product.Right{},owner)
def put_audit(ledger:T.HealthLedger,audit:Service.Slot<Audit>) -> Resources():
  Product.put(~T.HealthLedger,~Service.Slot<Audit>,Product.Right{},ledger,audit)
def record(owner:Audit,text:String) -> Audit & Unit:
  match owner:
    case Recorded{effects}:(Recorded{text <> effects},Unit{})
def audit_view(slot:Service.Slot<Audit>) -> Service.Slot<Audit> & AuditView:
  match slot:
    case Service.Missing{}:(Service.Missing{},Missing{})
    case Service.Ready{Recorded{+effects}}:(Service.Ready{Recorded{effects}},RecordedView{effects})
def observed(ledger:T.HealthLedger,view:T.LedgerView,result:Service.Slot<Audit> & AuditView) -> Resources() & View:
  match result:
    case (slot,audit):(Product.Owner{ledger,slot},View{view,audit})
def ledger_observed(slot:Service.Slot<Audit>,result:T.HealthLedger & T.LedgerView) -> Resources() & View:
  match result:
    case (ledger,view):observed(ledger,view,audit_view(slot))
def observe(owner:Resources()) -> Resources() & View:
  match owner:
    case Product.Owner{ledger,slot}:ledger_observed(slot,Payload.health_ledger_get(ledger))
def initial() -> Resources():
  Product.Owner{T.HealthLedger{ANode{ANode{ALeaf{0},ALeaf{101}},ANode{ALeaf{102},ALeaf{103}}},4},Service.Ready{Recorded{[]}}}
