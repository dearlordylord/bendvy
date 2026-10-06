import Base
import ./held-adapter.bend as HA
import ./cached-payload.bend as CP
import ./types.bend as T
import ./storage.bend as S
import ./transaction.bend as X
import ./host-render.bend as R
import ./transaction-dispatch-adapters.bend as A
import ./cache.bend as C
import ./host.bend as H
import ./raw-boundaries.bend as RB

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
def client(~O:Type,~get:O -> T.PositionToken -> O & T.Access<T.PositionView>,~set:O -> T.PositionToken -> U32 -> O,~ledger:O -> T.MotionLedgerToken -> O & Maybe<&2,T.LedgerView>,~setledger:O -> T.MotionLedgerToken -> U32 -> O,owner:O) -> O & U32:
  client_observed(~O,get(set(set(owner,T.PositionToken{},500),T.PositionToken{},700),T.PositionToken{}))
def World() -> Type: S.World<T.MotionSchema,CP.PrototypeMotionMainSlot,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>
def finished(label:U32,retained:T.PositionView,result:X.Finished<World(),S.Command<CP.PrototypeMotionMainSlot,T.Velocity,T.Selected>,S.Handle<T.MotionSchema>>) -> IO(Unit):
  match result:
    case X.Reverted{S.World{ns,next,S.Rows{ANode{ANode{ALeaf{None{}},ALeaf{None{}}},ANode{ALeaf{Some{CP.PrototypeMotionMainSlot{array,frame,a,b,c,d,cf}}},ALeaf{None{}}}},ANode{ANode{ALeaf{None{}},ALeaf{None{}}},ANode{ALeaf{None{}},ALeaf{None{}}}},S.MetadataColumns{ANode{ANode{ALeaf{False{}},ALeaf{False{}}},ANode{ALeaf{True{}},ALeaf{False{}}}},ANode{ANode{ALeaf{None{}},ALeaf{None{}}},ANode{ALeaf{Some{T.Selected{55}}},ALeaf{None{}}}},added,changed},capacity,depth,high},Con{S.Despawn{pending},Nil{}},Some{C.Cache{T.MotionLedger{totals,epoch},lc}},T.MotionOn{}}}:
      IO.print("{\"length\":" ++ U32.show(label) ++ ",\"array\":" ++ R.render_list(U32,U32.show,data(Array.to_list(~U32,array))) ++ ",\"rawFrame\":" ++ U32.show(frame) ++ ",\"cached\":" ++ R.render_position(T.PositionView{T.Four{a,b,c,d},cf}) ++ ",\"retained\":" ++ R.render_position(retained) ++ ",\"namespace\":" ++ U32.show(ns) ++ ",\"next\":" ++ U32.show(next) ++ ",\"capacity\":" ++ U32.show(capacity) ++ ",\"depth\":" ++ Nat.show(depth) ++ ",\"high\":" ++ U32.show(high) ++ ",\"pending\":" ++ U32.show(pending) ++ ",\"added\":" ++ R.render_list(U32,U32.show,data(Array.to_list(~U32,added))) ++ ",\"changed\":" ++ R.render_list(U32,U32.show,data(Array.to_list(~U32,changed))) ++ ",\"ledger\":" ++ R.render_list(U32,U32.show,data(Array.to_list(~U32,totals))) ++ ",\"epoch\":" ++ U32.show(epoch) ++ ",\"ledgerCached\":" ++ R.render_ledger(lc) ++ "}")
    case _: IO.print("unexpected-reverted-world")
def world() -> World():
  S.World{7,9,S.Rows{Array.set(Maybe<CP.PrototypeMotionMainSlot>,S.slots_empty(CP.PrototypeMotionMainSlot,2n),2,Some{CP.PrototypeMotionMainSlot{Array.set(U32,Array.set(U32,Array.set(U32,[100:U32^2n],1,101),2,102),3,103),4,999,200,300,400,77}}),S.slots_empty(T.Velocity,2n),S.MetadataColumns{Array.set(Bool,[False{}:Bool^2n],2,True{}),Array.set(Maybe<&2,T.Selected>,[None{}:Maybe<&2,T.Selected>^2n],2,Some{T.Selected{55}}),[11:U32^2n],[22:U32^2n]},4,2n,3},S.Despawn{2} <> [],Some{C.Cache{T.MotionLedger{Array.set(U32,Array.set(U32,Array.set(U32,[10:U32^2n],1,11),2,12),3,13),6},T.LedgerView{T.Four{900,901,902,903},88}}},T.MotionOn{}}
def rejected(+label:U32,result:T.CommandResult<World(),T.Position>) -> IO(Unit):
  match result:
    case T.CommandMissing{world,T.Position{array,frame}}:
      do IO<Unit>:
        IO.print("{\"rejected\":" ++ U32.show(label) ++ ",\"raw\":" ++ R.render_list(U32,U32.show,data(Array.to_list(~U32,array))) ++ ",\"frame\":" ++ U32.show(frame) ++ "}")
        finished(label,T.PositionView{T.Four{999,200,300,400},77},X.Reverted{world})
        return Unit{}
    case _: IO.print("unexpected-queued")
def run(label:U32,array:Array<U32>) -> IO(Unit):
  rejected(label,RB.prototype_packed_motion_insert(world(),S.Handle{8,3},T.Position{array,91}))
def main() -> IO(Unit):
  do IO<Unit>:
    run(1,[700:U32^0n])
    run(2,Array.set(U32,[700:U32^1n],1,701))
    run(4,Array.set(U32,Array.set(U32,Array.set(U32,[700:U32^2n],1,701),2,702),3,703))
    run(8,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,[700:U32^3n],1,701),2,702),3,703),4,704),5,705),6,706),7,707))
    return Unit{}
