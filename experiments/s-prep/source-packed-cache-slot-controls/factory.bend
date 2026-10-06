import Base
import ./cached-payload.bend as CP
import ./raw-boundaries.bend as RB
import ./types.bend as T
import ./storage.bend as S
import ./cache.bend as C
import ./host-render.bend as R

def World() -> Type: S.World<T.MotionSchema,CP.PrototypeMotionMainSlot,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>
def data(values:List<&1,U32>) -> List<&2,U32>:
  match values:
    case Nil{}: []
    case Con{head,tail}: head <> data(tail)
def ledger(unit:Unit) -> T.MotionLedger:
  T.MotionLedger{Array.set(U32,Array.set(U32,Array.set(U32,[10:U32^2n],1,11),2,12),3,13),6}
def created(result:T.Creation<S.Factory,World()>) -> IO(Unit):
  match result:
    case T.Created{S.Factory{factory},S.World{ns,next,S.Rows{ALeaf{None{}},ALeaf{None{}},S.MetadataColumns{ALeaf{False{}},ALeaf{None{}},ALeaf{0},ALeaf{0}},capacity,depth,high},Nil{},Some{C.Cache{T.MotionLedger{totals,epoch},cached}},T.MotionOn{}}}:
      IO.print("{\"factory\":" ++ U32.show(factory) ++ ",\"namespace\":" ++ U32.show(ns) ++ ",\"next\":" ++ U32.show(next) ++ ",\"capacity\":" ++ U32.show(capacity) ++ ",\"depth\":" ++ Nat.show(depth) ++ ",\"high\":" ++ U32.show(high) ++ ",\"ledger\":" ++ R.render_list(U32,U32.show,data(Array.to_list(~U32,totals))) ++ ",\"epoch\":" ++ U32.show(epoch) ++ ",\"cached\":" ++ R.render_ledger(cached) ++ "}")
    case T.CreateRejected{S.Factory{next}}: IO.print("{\"rejected\":" ++ U32.show(next) ++ "}")
    case _: IO.print("unexpected-factory")
def main() -> IO(Unit):
  do IO<Unit>:
    created(RB.prototype_packed_motion_create(~ledger,S.Factory{1},T.MotionOn{}))
    created(RB.prototype_packed_motion_create(~ledger,S.Factory{4294967295},T.MotionOn{}))
    return Unit{}
