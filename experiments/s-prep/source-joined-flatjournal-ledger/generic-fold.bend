import Base
import /tmp/bendvy-write-row-fold-v2/experiments/s-integrate/held-adapter.bend as HA
import /tmp/bendvy-write-row-fold-v2/experiments/s-integrate/storage.bend as S

type Owned is Type:
  Owned{cells:Array<U32>}
def ledger_value(result:Array<U32> & U32,value:U32) -> U32:
  match result:
    case (_,n): U32.add(value,n)
def main_value(result:Array<U32> & U32,ledger:Array<U32>) -> U32:
  match result:
    case (_,n): ledger_value(Array.get(U32,ledger,0),n)
def picked(result:Array<Maybe<Owned>> & Maybe<Owned>,ledger:Array<U32>) -> U32:
  match result:
    case (_,Some{Owned{cells}}): main_value(Array.get(U32,cells,0),ledger)
    case (_,None{}): 0
def observe(scope:HA.PrototypeWriteFold<Unit,Owned,Owned,Unit,Owned,Unit>) -> U32:
  match scope:
    case HA.PrototypeWriteFold{_,_,columns,_,_,_,_,_,_,Some{Owned{ledger}},_,_,_,_,_,_,_}: picked(Array.swap(Maybe<Owned>,columns,0,None{}),ledger)
    case HA.PrototypeWriteFold{_,_,_,_,_,_,_,_,_,None{},_,_,_,_,_,_,_}: 0
def main() -> IO(Unit):
  IO.print(U32.show(observe(HA.PrototypeWriteFold{1,2,ALeaf{Some{Owned{[7:U32^2n]}}},ALeaf{None{}},S.MetadataColumns{[True{}:Bool^0n],[None{}:Maybe<&2,Unit>^0n],[1:U32^0n],[1:U32^0n]},1,0n,1,[],Some{Owned{[8:U32^2n]}},Unit{},S.Handle{1,1},[],[],[],[],0})))
