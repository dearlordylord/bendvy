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
def view_sum(view:T.VitalsView) -> U32:
  match view:
    case T.VitalsView{T.Four{a,b,c,d},frame,class}: U32.add(U32.add(a,b),U32.add(U32.add(U32.add(c,d),class),frame))
def client_after(~O:Type,owner:O,result:T.Access<T.VitalsView>) -> O & U32:
  match result:
    case T.Found{view}: (owner,view_sum(view))
    case _: (owner,0)
def client_observed(~O:Type,result:O & T.Access<T.VitalsView>) -> O & U32:
  match result:
    case (owner,view): client_after(~O,owner,view)
def client(~O:Type,~get:O -> T.VitalsToken -> O & T.Access<T.VitalsView>,~set:O -> T.VitalsToken -> U32 -> O,~ledger:O -> T.HealthLedgerToken -> O & Maybe<&2,T.LedgerView>,~setledger:O -> T.HealthLedgerToken -> U32 -> O,owner:O) -> O & U32:
  client_observed(~O,get(setledger(set(setledger(set(owner,T.VitalsToken{},500),T.HealthLedgerToken{},700),T.VitalsToken{},600),T.HealthLedgerToken{},800),T.VitalsToken{}))
def flushed(result:HA.PrototypePackedHealthRowOwner & U32) -> HA.PrototypePackedHealthRowOwner & U32:
  match result:
    case (HA.PrototypePackedHealthRowOwner{array,frame,class,a,b,c,d,cf,cc,totals,epoch,cached,handle,undo,marks},value): (HA.PrototypePackedHealthRowOwner{array,frame,class,a,b,c,d,cf,cc,totals,epoch,cached,handle,HA.PrototypePendingUndo{False{},0,0,0,HA.prototype_pending_flush(~T.HealthSchema,undo)},marks},value)
def observe(label:U32,retained:T.VitalsView,result:HA.PrototypePackedHealthRowOwner & U32) -> IO(Unit):
  match result:
    case (HA.PrototypePackedHealthRowOwner{array,frame,class,a,b,c,d,cf,cc,totals,epoch,lc,S.Handle{ns,id},HA.PrototypePendingUndo{False{},_,_,_,X.PrototypeFlatPair{space,mid,old,ledgerold,X.PrototypeFlatPair{ps,pid,prior,ledgerprior,X.PrototypeFlatEnd{}}}},X.PrototypeFlatMark{ms,mi,X.PrototypeFlatMark{pms,pmi,X.PrototypeFlatMarksEnd{}}}},value):
      IO.print("{\"length\":" ++ U32.show(label) ++ ",\"array\":" ++ R.render_list(U32,U32.show,data(Array.to_list(~U32,array))) ++ ",\"rawReserve\":" ++ U32.show(frame) ++ ",\"rawClass\":" ++ U32.show(class) ++ ",\"cached\":" ++ R.render_vitals(T.VitalsView{T.Four{a,b,c,d},cf,cc}) ++ ",\"retained\":" ++ R.render_vitals(retained) ++ ",\"ledger\":" ++ R.render_list(U32,U32.show,data(Array.to_list(~U32,totals))) ++ ",\"epoch\":" ++ U32.show(epoch) ++ ",\"ledgerCached\":" ++ R.render_ledger(lc) ++ ",\"handle\":[" ++ U32.show(ns) ++ "," ++ U32.show(id) ++ "],\"inverse\":[[" ++ U32.show(space) ++ "," ++ U32.show(mid) ++ "," ++ U32.show(old) ++ "," ++ U32.show(ledgerold) ++ "],[" ++ U32.show(ps) ++ "," ++ U32.show(pid) ++ "," ++ U32.show(prior) ++ "," ++ U32.show(ledgerprior) ++ "]],\"marks\":[[" ++ U32.show(ms) ++ "," ++ U32.show(mi) ++ "],[" ++ U32.show(pms) ++ "," ++ U32.show(pmi) ++ "]],\"clientValue\":" ++ U32.show(value) ++ "}")
    case _: IO.print("unexpected-row")
def taken(label:U32,result:HA.PrototypePackedHealthRowOwner & T.Access<T.VitalsView>) -> IO(Unit):
  match result:
    case (owner,T.Found{+retained}): observe(label,retained,flushed(HA.prototype_packed_prototype_journalledger_health_invoke(~client,owner)))
    case _: IO.print("unexpected-read")
def run(label:U32,array:Array<U32>) -> IO(Unit):
  taken(label,HA.prototype_packed_prototype_journalledger_health_get(HA.PrototypePackedHealthRowOwner{array,4,5,999,200,300,400,77,88,Array.set(U32,Array.set(U32,Array.set(U32,[10:U32^2n],1,11),2,12),3,13),6,T.LedgerView{T.Four{900,901,902,903},88},S.Handle{7,3},HA.PrototypePendingUndo{False{},0,0,0,X.PrototypeFlatEnd{}},X.PrototypeFlatMarksEnd{}},T.VitalsToken{}))
def main() -> IO(Unit):
  do IO<Unit>:
    run(1,[100:U32^0n])
    run(2,Array.set(U32,[100:U32^1n],1,101))
    run(4,Array.set(U32,Array.set(U32,Array.set(U32,[100:U32^2n],1,101),2,102),3,103))
    run(8,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,[100:U32^3n],1,101),2,102),3,103),4,104),5,105),6,106),7,107))
    return Unit{}
