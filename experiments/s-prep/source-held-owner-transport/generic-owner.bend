import Base
import /tmp/bendvy-held-flat-both-reproduced-v5/experiments/s-integrate/held-adapter.bend as HA
import /tmp/bendvy-held-flat-both-reproduced-v5/experiments/s-integrate/transaction.bend as X

type Owned is Type:
  Owned{cells:Array<U32>}
def generic_read(-W:Type,-R:Type,-V:Data,-L:Type,-LV:Data,-H:Data,-C:Type,owner:HA.PrototypeFlatHeld<W,R,V,L,LV,H,C>) -> HA.PrototypeFlatHeld<W,R,V,L,LV,H,C> & V:
  match owner:
    case HA.PrototypeFlatHeld{world,raw,+view,ledger,ledger_view,handle,undo,commands,pings,marks}:
      (HA.PrototypeFlatHeld{world,raw,view,ledger,ledger_view,handle,undo,commands,pings,marks},view)
def observe_ledger(retained:U32,view:U32,ledger_view:U32,main:U32,pair:Array<U32> & U32) -> U32:
  match pair:
    case (_,ledger): U32.add(retained,U32.add(view,U32.add(ledger_view,U32.add(main,ledger))))
def observe_main(retained:U32,view:U32,ledger_view:U32,ledger:Array<U32>,pair:Array<U32> & U32) -> U32:
  match pair:
    case (_,main): observe_ledger(retained,view,ledger_view,main,Array.get(U32,ledger,0))
def observe(pair:HA.PrototypeFlatHeld<Unit,Owned,U32,Owned,U32,U32,U32> & U32) -> U32:
  match pair:
    case (HA.PrototypeFlatHeld{_,Owned{main},view,Owned{ledger},ledger_view,_,_,_,_,_},retained):
      observe_main(retained,view,ledger_view,ledger,Array.get(U32,main,0))
def main() -> U32:
  observe(generic_read(Unit,Owned,U32,Owned,U32,U32,U32,HA.PrototypeFlatHeld{Unit{},Owned{[7:U32^2n]},11,Owned{[8:U32^2n]},13,1,[],[],[],[]}))
