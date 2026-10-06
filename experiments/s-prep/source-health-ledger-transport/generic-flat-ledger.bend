import Base
import /tmp/bendvy-health-ledger-flat-v3/experiments/s-integrate/held-adapter.bend as HA

type Owned is Type:
  Owned{cells:Array<U32>}
def generic_read(-R:Type,-V:Data,-LV:Data,-H:Data,owner:HA.PrototypeFlatLedgerRowOwner<R,V,LV,H>) -> HA.PrototypeFlatLedgerRowOwner<R,V,LV,H> & V:
  match owner:
    case HA.PrototypeFlatLedgerRowOwner{raw,+view,totals,epoch,ledger_view,handle,undo,marks}:
      (HA.PrototypeFlatLedgerRowOwner{raw,view,totals,epoch,ledger_view,handle,undo,marks},view)
def observe_ledger(retained:U32,view:U32,epoch:U32,ledger_view:U32,main:U32,pair:Array<U32> & U32) -> U32:
  match pair:
    case (_,ledger): U32.add(epoch,U32.add(retained,U32.add(view,U32.add(ledger_view,U32.add(main,ledger)))))
def observe_main(retained:U32,view:U32,epoch:U32,ledger_view:U32,ledger:Array<U32>,pair:Array<U32> & U32) -> U32:
  match pair:
    case (_,main): observe_ledger(retained,view,epoch,ledger_view,main,Array.get(U32,ledger,0))
def observe(pair:HA.PrototypeFlatLedgerRowOwner<Owned,U32,U32,U32> & U32) -> U32:
  match pair:
    case (HA.PrototypeFlatLedgerRowOwner{Owned{main},view,ledger,epoch,ledger_view,_,_,_},retained): observe_main(retained,view,epoch,ledger_view,ledger,Array.get(U32,main,0))
def main() -> IO(Unit):
  IO.print(U32.show(observe(generic_read(Owned,U32,U32,U32,HA.PrototypeFlatLedgerRowOwner{Owned{[7:U32^2n]},11,[8:U32^2n],17,13,1,[],[]}))))
