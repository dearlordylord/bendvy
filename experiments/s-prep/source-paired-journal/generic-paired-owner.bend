import Base
import OVERLAY/experiments/s-integrate/storage.bend as S
import OVERLAY/experiments/s-integrate/held-adapter.bend as HA
import OVERLAY/experiments/s-integrate/transaction.bend as X

type Owned is Type:
  Owned{cells:Array<U32>}
def generic_read(-R:Type,-V:Data,-L:Type,-LV:Data,-H:Data,owner:HA.PrototypePairedRowOwner<R,V,L,LV,H>) -> HA.PrototypePairedRowOwner<R,V,L,LV,H> & V:
  match owner:
    case HA.PrototypePairedRowOwner{raw,+view,ledger,ledger_view,handle,undo,marks}:
      (HA.PrototypePairedRowOwner{raw,view,ledger,ledger_view,handle,undo,marks},view)
def observe_ledger(retained:U32,view:U32,ledger_view:U32,main:U32,pair:Array<U32> & U32) -> U32:
  match pair:
    case (_,ledger): U32.add(retained,U32.add(view,U32.add(ledger_view,U32.add(main,ledger))))
def observe_main(retained:U32,view:U32,ledger_view:U32,ledger:Array<U32>,pair:Array<U32> & U32) -> U32:
  match pair:
    case (_,main): observe_ledger(retained,view,ledger_view,main,Array.get(U32,ledger,0))
def observe(pair:HA.PrototypePairedRowOwner<Owned,U32,Owned,U32,Unit> & U32) -> U32:
  match pair:
    case (HA.PrototypePairedRowOwner{Owned{main},view,Owned{ledger},ledger_view,_,_,_},retained):
      observe_main(retained,view,ledger_view,ledger,Array.get(U32,main,0))
def main() -> U32:
  observe(generic_read(Owned,U32,Owned,U32,Unit,HA.PrototypePairedRowOwner{Owned{[7:U32^2n]},11,Owned{[8:U32^2n]},13,S.Handle{1,1},HA.PrototypePendingUndo{False{},0,0,0,X.PrototypeFlatEnd{}},X.PrototypeFlatMarksEnd{}}))
