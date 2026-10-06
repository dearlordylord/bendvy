import Base
import /tmp/bendvy-health-ledger-flat-v3/experiments/s-integrate/held-adapter.bend as HA
import /tmp/bendvy-health-ledger-flat-v3/experiments/s-integrate/types.bend as T
import /tmp/bendvy-health-ledger-flat-v3/experiments/s-integrate/storage.bend as S
import /tmp/bendvy-health-ledger-flat-v3/experiments/s-integrate/transaction.bend as X
import /tmp/bendvy-health-ledger-flat-v3/experiments/s-integrate/uncached-payload.bend as P
import /tmp/bendvy-health-ledger-flat-v3/experiments/s-integrate/host-render.bend as R

def data_values(values:List<&1,U32>) -> List<&2,U32>:
  match values:
    case Nil{}: Nil{}
    case Con{value,rest}: value <> data_values(rest)
def observed_four(label:U32,main:T.VitalsView,main_cached:T.VitalsView,epoch:U32,cached:T.LedgerView,retained:T.LedgerView,handle:S.Handle<T.HealthSchema>,undo:List<&2,X.Inverse<S.Handle<T.HealthSchema>>>,marks:List<&2,S.Handle<T.HealthSchema>>,pair:Array<U32> & T.Four) -> IO(Unit):
  match undo marks pair:
    case Con{X.LedgerInverse{old},Con{X.LedgerInverse{prior},Nil{}}} Con{mark,Nil{}} product:
      match product:
        case (array,totals):
          IO.print("{\"label\":" ++ U32.show(label) ++ ",\"main\":" ++ R.render_vitals(main) ++ ",\"mainCached\":" ++ R.render_vitals(main_cached) ++ ",\"totals\":" ++ R.render_four(totals) ++ ",\"rawArray\":" ++ R.render_list(U32,U32.show,data_values(Array.to_list(~U32,array))) ++ ",\"epoch\":" ++ U32.show(epoch) ++ ",\"cached\":" ++ R.render_ledger(cached) ++ ",\"retained\":" ++ R.render_ledger(retained) ++ ",\"handle\":" ++ R.render_handle(T.HealthSchema,handle) ++ ",\"mark\":" ++ R.render_handle(T.HealthSchema,mark) ++ ",\"old\":" ++ U32.show(old) ++ ",\"prior\":" ++ U32.show(prior) ++ "}")
    case _ _ _: IO.print("unexpected-journal-or-mark")

def observed_main(label:U32,main_cached:T.VitalsView,totals:Array<U32>,epoch:U32,cached:T.LedgerView,retained:T.LedgerView,handle:S.Handle<T.HealthSchema>,undo:List<&2,X.Inverse<S.Handle<T.HealthSchema>>>,marks:List<&2,S.Handle<T.HealthSchema>>,pair:T.Vitals & T.VitalsView) -> IO(Unit):
  match pair:
    case (_,main): observed_four(label,main,main_cached,epoch,cached,retained,handle,undo,marks,P.original_four(totals))
def observe(label:U32,retained:T.LedgerView,owner:HA.PrototypeFlatLedgerRowOwner<T.Vitals,T.VitalsView,T.LedgerView,S.Handle<T.HealthSchema>>) -> IO(Unit):
  match owner:
    case HA.PrototypeFlatLedgerRowOwner{main,main_cached,totals,epoch,cached,handle,undo,marks}: observed_main(label,main_cached,totals,epoch,cached,retained,handle,undo,marks,P.vitals_get(main))
def run(label:U32,totals:Array<U32>) -> IO(Unit):
  +cached:T.LedgerView = T.LedgerView{T.Four{999,200,300,400},77}
  +handle:S.Handle<T.HealthSchema> = S.Handle{8,4}
  observe(label,cached,HA.prototype_flatledger_health_setledger(HA.PrototypeFlatLedgerRowOwner{T.Vitals{[10:U32^2n],9,2},T.VitalsView{T.Four{10,10,10,10},9,2},totals,4,cached,handle,[X.LedgerInverse{55}],[handle]},T.HealthLedgerToken{},500))
def main() -> IO(Unit):
  do IO<Unit>:
    run(1,[100:U32^0n])
    run(2,Array.set(U32,[100:U32^1n],1,101))
    run(4,Array.set(U32,Array.set(U32,Array.set(U32,[100:U32^2n],1,101),2,102),3,103))
    run(8,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,[100:U32^3n],1,101),2,102),3,103),4,104),5,105),6,106),7,107))
