import Base
import /tmp/bendvy-closed-storage-commit-probe/experiments/s-integrate/transaction.bend as X
import /tmp/bendvy-closed-storage-commit-probe/experiments/s-integrate/storage.bend as S
import /tmp/bendvy-closed-storage-commit-probe/experiments/s-integrate/types.bend as T

type Raw is Type:
  Raw{payload:Array<U32>}
def ledger(+namespace:U32,+next:U32,+mode:U32,+main:U32,pings:List<&2,U32>,result:Array<U32> & U32) -> U32 & (U32 & (U32 & (U32 & (U32 & List<&2,U32>)))):
  match result:
    case (_,value): (namespace,(next,(mode,(main,(value,pings)))))
def main_value(+namespace:U32,+next:U32,+mode:U32,raw:Array<U32>,pings:List<&2,U32>,result:Array<U32> & U32) -> U32 & (U32 & (U32 & (U32 & (U32 & List<&2,U32>)))):
  match result:
    case (_,value): ledger(namespace,next,mode,value,pings,Array.get(U32,raw,0))
def finish(result:S.World<T.MotionSchema,Raw,Raw,U32,Raw,U32> & List<&2,U32>) -> U32 & (U32 & (U32 & (U32 & (U32 & List<&2,U32>)))):
  match result:
    case (S.World{namespace,next,_,Con{S.RemoveMain{1},Con{S.InsertMain{2,Raw{main}},Con{S.RemoveFlag{9},Nil{}}}},Some{Raw{raw}},mode},pings): main_value(namespace,next,mode,raw,pings,Array.get(U32,main,0))
    case _: (0,(0,(0,(0,(0,[])))))
def main() -> U32 & (U32 & (U32 & (U32 & (U32 & List<&2,U32>)))):
  finish(X.prototype_closed_storage_commit(~Raw,~Raw,~U32,T.MotionSchema,Raw,U32,X.Committed{S.World{7,3,S.prototype_closed_rows_empty(~Raw,~Raw,~U32),[S.RemoveFlag{9}],Some{Raw{ALeaf{99}}},9},[S.InsertMain{2,Raw{ALeaf{71}}},S.RemoveMain{1}],[3,4],[S.Handle{8,0}]},11))
