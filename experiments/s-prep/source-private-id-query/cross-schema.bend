import Base
import ./held-adapter.bend as HA
import ./cached-payload.bend as CP
import ./types.bend as T
import ./storage.bend as S
import ./transaction.bend as X
import ./host-render.bend as R

def data(values:List<&1,U32>) -> List<&2,U32>:
  match values:
    case Nil{}: []
    case Con{head,tail}: head <> data(tail)
def view_sum(view:T.PositionView) -> U32:
  match view:
    case T.PositionView{T.Four{a,b,c,d},frame}: U32.add(U32.add(a,b),U32.add(U32.add(c,d),frame))
def client_after(~O:Type,owner:O,result:T.Access<T.PositionView>) -> O & U32:
  match result:
    case T.Found{view}: (owner,view_sum(view))
    case _: (owner,0)
def client_observed(~O:Type,result:O & T.Access<T.PositionView>) -> O & U32:
  match result:
    case (owner,view): client_after(~O,owner,view)
def bad(~O:Type,~get:O -> T.PositionToken -> O & T.Access<T.PositionView>,~set:O -> T.PositionToken -> U32 -> O,~ledger:O -> T.MotionLedgerToken -> O & Maybe<&2,T.LedgerView>,~setledger:O -> T.MotionLedgerToken -> U32 -> O,owner:O) -> O & U32:
  client_observed(~O,get(owner,T.VitalsToken{}))
def observe(label:U32,retained:T.PositionView,result:HA.PrototypePackedMotionRowOwner & U32) -> IO(Unit):
  match result:
    case (HA.PrototypePackedMotionRowOwner{array,frame,a,b,c,d,cf,T.MotionLedger{totals,epoch},lc,S.Handle{ns,id},X.PrototypeFlatMain{space,mid,old,X.PrototypeFlatMain{ps,pid,prior,X.PrototypeFlatEnd{}}},X.PrototypeFlatMark{ms,mi,X.PrototypeFlatMark{pms,pmi,X.PrototypeFlatMarksEnd{}}}},value):
      IO.print("{\"length\":" ++ U32.show(label) ++ ",\"array\":" ++ R.render_list(U32,U32.show,data(Array.to_list(~U32,array))) ++ ",\"rawFrame\":" ++ U32.show(frame) ++ ",\"cached\":" ++ R.render_position(T.PositionView{T.Four{a,b,c,d},cf}) ++ ",\"retained\":" ++ R.render_position(retained) ++ ",\"ledger\":" ++ R.render_list(U32,U32.show,data(Array.to_list(~U32,totals))) ++ ",\"epoch\":" ++ U32.show(epoch) ++ ",\"ledgerCached\":" ++ R.render_ledger(lc) ++ ",\"handle\":[" ++ U32.show(ns) ++ "," ++ U32.show(id) ++ "],\"inverse\":[[" ++ U32.show(space) ++ "," ++ U32.show(mid) ++ "," ++ U32.show(old) ++ "],[" ++ U32.show(ps) ++ "," ++ U32.show(pid) ++ "," ++ U32.show(prior) ++ "]],\"marks\":[[" ++ U32.show(ms) ++ "," ++ U32.show(mi) ++ "],[" ++ U32.show(pms) ++ "," ++ U32.show(pmi) ++ "]],\"clientValue\":" ++ U32.show(value) ++ "}")
    case _: IO.print("unexpected-row")
def taken(label:U32,result:HA.PrototypePackedMotionRowOwner & T.Access<T.PositionView>) -> IO(Unit):
  match result:
    case (owner,T.Found{+retained}): observe(label,retained,HA.prototype_packed_row_invoke(~bad,owner))
    case _: IO.print("unexpected-read")
def run(label:U32,array:Array<U32>) -> IO(Unit):
  taken(label,HA.prototype_packed_row_get(HA.PrototypePackedMotionRowOwner{array,4,999,200,300,400,77,T.MotionLedger{Array.set(U32,Array.set(U32,Array.set(U32,[10:U32^2n],1,11),2,12),3,13),6},T.LedgerView{T.Four{900,901,902,903},88},S.Handle{7,3},X.PrototypeFlatEnd{},X.PrototypeFlatMarksEnd{}},T.PositionToken{}))
def main() -> IO(Unit):
  do IO<Unit>:
    run(1,[100:U32^0n])
    run(2,Array.set(U32,[100:U32^1n],1,101))
    run(4,Array.set(U32,Array.set(U32,Array.set(U32,[100:U32^2n],1,101),2,102),3,103))
    run(8,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,[100:U32^3n],1,101),2,102),3,103),4,104),5,105),6,106),7,107))
    return Unit{}
