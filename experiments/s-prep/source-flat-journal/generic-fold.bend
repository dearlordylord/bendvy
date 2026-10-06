import Base
import OVERLAY/experiments/s-integrate/held-adapter.bend as HA
import OVERLAY/experiments/s-integrate/storage.bend as S
import OVERLAY/experiments/s-integrate/transaction.bend as X

type Owned is Type:
  Owned{cells:Array<U32>}
def ledger_value(total:U32,result:Array<U32> & U32) -> U32:
  match result:
    case (_,n): U32.add(total,n)
def aux_value(main:U32,ledger:Array<U32>,result:Array<U32> & U32) -> U32:
  match result:
    case (_,aux): ledger_value(U32.add(main,aux),Array.get(U32,ledger,0))
def main_value(aux:Array<U32>,ledger:Array<U32>,result:Array<U32> & U32) -> U32:
  match result:
    case (_,main): aux_value(main,ledger,Array.get(U32,aux,0))
def aux_picked(main:Array<U32>,ledger:Array<U32>,result:Array<Maybe<Owned>> & Maybe<Owned>) -> U32:
  match result:
    case (_,Some{Owned{aux}}): main_value(aux,ledger,Array.get(U32,main,0))
    case (_,None{}): 0
def main_picked(aux:Array<Maybe<Owned>>,ledger:Array<U32>,result:Array<Maybe<Owned>> & Maybe<Owned>) -> U32:
  match result:
    case (_,Some{Owned{main}}): aux_picked(main,ledger,Array.swap(Maybe<Owned>,aux,0,None{}))
    case (_,None{}): 0
def observe(scope:HA.PrototypeFlatFold<Unit,Owned,Owned,Unit,Owned,Unit>) -> U32:
  match scope:
    case HA.PrototypeFlatFold{_,_,columns,aux,_,_,_,_,_,Some{Owned{ledger}},_,_,_,_,_,_,_}: main_picked(aux,ledger,Array.swap(Maybe<Owned>,columns,0,None{}))
    case HA.PrototypeFlatFold{_,_,_,_,_,_,_,_,_,None{},_,_,_,_,_,_,_}: 0
def main() -> IO(Unit):
  IO.print(U32.show(observe(HA.PrototypeFlatFold{1,2,ALeaf{Some{Owned{[7:U32^2n]}}},ALeaf{Some{Owned{[9:U32^2n]}}},S.MetadataColumns{[True{}:Bool^0n],[None{}:Maybe<&2,Unit>^0n],[1:U32^0n],[1:U32^0n]},1,0n,1,[],Some{Owned{[8:U32^2n]}},Unit{},S.Handle{1,1},X.PrototypeFlatEnd{},[],[],X.PrototypeFlatMarksEnd{},0})))
