import Base
import ./query.bend as Q
import ./held-adapter.bend as HA
import ./cached-payload.bend as CP
import ./types.bend as T
import ./storage.bend as S
import ./transaction.bend as X
import ./host-render.bend as R
import ./transaction-dispatch-adapters.bend as A
import ./cache.bend as C
import ./host.bend as H

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
def World() -> Type: S.World<T.HealthSchema,CP.PrototypeHealthMainSlot,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>
def finished(label:U32,retained:T.VitalsView,result:X.Finished<World(),S.Command<CP.PrototypeHealthMainSlot,T.Armor,T.Tracked>,S.Handle<T.HealthSchema>>) -> IO(Unit):
  match result:
    case X.Reverted{S.World{ns,next,S.Rows{ANode{ANode{ALeaf{None{}},ALeaf{None{}}},ANode{ALeaf{Some{CP.PrototypeHealthMainSlot{array,frame,class,a,b,c,d,cf,cc}}},ALeaf{None{}}}},ANode{ANode{ALeaf{None{}},ALeaf{None{}}},ANode{ALeaf{None{}},ALeaf{None{}}}},S.MetadataColumns{ANode{ANode{ALeaf{False{}},ALeaf{False{}}},ANode{ALeaf{True{}},ALeaf{False{}}}},ANode{ANode{ALeaf{None{}},ALeaf{None{}}},ANode{ALeaf{Some{T.Tracked{55}}},ALeaf{None{}}}},added,changed},capacity,depth,high},Con{S.Despawn{pending},Nil{}},Some{C.Cache{T.HealthLedger{totals,epoch},lc}},T.HealthOn{}}}:
      IO.print("{\"length\":" ++ U32.show(label) ++ ",\"array\":" ++ R.render_list(U32,U32.show,data(Array.to_list(~U32,array))) ++ ",\"rawReserve\":" ++ U32.show(frame) ++ ",\"rawClass\":" ++ U32.show(class) ++ ",\"cached\":" ++ R.render_vitals(T.VitalsView{T.Four{a,b,c,d},cf,cc}) ++ ",\"retained\":" ++ R.render_vitals(retained) ++ ",\"namespace\":" ++ U32.show(ns) ++ ",\"next\":" ++ U32.show(next) ++ ",\"capacity\":" ++ U32.show(capacity) ++ ",\"depth\":" ++ Nat.show(depth) ++ ",\"high\":" ++ U32.show(high) ++ ",\"pending\":" ++ U32.show(pending) ++ ",\"added\":" ++ R.render_list(U32,U32.show,data(Array.to_list(~U32,added))) ++ ",\"changed\":" ++ R.render_list(U32,U32.show,data(Array.to_list(~U32,changed))) ++ ",\"ledger\":" ++ R.render_list(U32,U32.show,data(Array.to_list(~U32,totals))) ++ ",\"epoch\":" ++ U32.show(epoch) ++ ",\"ledgerCached\":" ++ R.render_ledger(lc) ++ "}")
    case _: IO.print("unexpected-reverted-world")
def world(array:Array<U32>) -> World():
  S.World{7,9,S.Rows{Array.set(Maybe<CP.PrototypeHealthMainSlot>,S.slots_empty(CP.PrototypeHealthMainSlot,2n),2,Some{CP.PrototypeHealthMainSlot{array,4,5,999,200,300,400,77,88}}),S.slots_empty(T.Armor,2n),S.MetadataColumns{Array.set(Bool,[False{}:Bool^2n],2,True{}),Array.set(Maybe<&2,T.Tracked>,[None{}:Maybe<&2,T.Tracked>^2n],2,Some{T.Tracked{55}}),[11:U32^2n],[22:U32^2n]},4,2n,3},S.Despawn{2} <> [],Some{C.Cache{T.HealthLedger{Array.set(U32,Array.set(U32,Array.set(U32,[10:U32^2n],1,11),2,12),3,13),6},T.LedgerView{T.Four{900,901,902,903},88}}},T.HealthOn{}}
def returned(label:U32,retained:T.VitalsView,result:X.PrototypeFlatTx<T.HealthSchema,World(),S.Command<CP.PrototypeHealthMainSlot,T.Armor,T.Tracked>> & U32) -> IO(Unit):
  match result:
    case (owner,_): finished(label,retained,A.prototype_packed_health_finish_failure(X.prototype_flat_unpack(~T.HealthSchema,~World(),~S.Command<CP.PrototypeHealthMainSlot,T.Armor,T.Tracked>,owner)))
def taken(label:U32,result:X.Tx<World(),S.Handle<T.HealthSchema>,S.Command<CP.PrototypeHealthMainSlot,T.Armor,T.Tracked>> & T.Access<T.VitalsView>) -> IO(Unit):
  match result:
    case (owner,T.Found{retained}): returned(label,retained,HA.prototype_cursor_flatfold_health(~client,Q.PrototypeIdCursor{7,[3]},X.prototype_flat_pack(~T.HealthSchema,~World(),~S.Command<CP.PrototypeHealthMainSlot,T.Armor,T.Tracked>,owner),0))
    case _: IO.print("unexpected-read")
def run(label:U32,array:Array<U32>) -> IO(Unit):
  taken(label,A.prototype_packed_health_read_main(X.tx_begin(World(),S.Handle<T.HealthSchema>,S.Command<CP.PrototypeHealthMainSlot,T.Armor,T.Tracked>,world(array),S.Handle{7,3}),T.VitalsToken{}))
def main() -> IO(Unit):
  do IO<Unit>:
    run(1,[100:U32^0n])
    run(2,Array.set(U32,[100:U32^1n],1,101))
    run(4,Array.set(U32,Array.set(U32,Array.set(U32,[100:U32^2n],1,101),2,102),3,103))
    run(8,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,[100:U32^3n],1,101),2,102),3,103),4,104),5,105),6,106),7,107))
    return Unit{}
