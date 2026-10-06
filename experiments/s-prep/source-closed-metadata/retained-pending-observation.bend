import Base
import /tmp/bendvy-closed-world-observation-probe/experiments/s-integrate/storage.bend as S
import /tmp/bendvy-closed-world-observation-probe/experiments/s-integrate/observations.bend as O
import /tmp/bendvy-closed-world-observation-probe/experiments/s-integrate/types.bend as T

type Raw is Type:
  Raw{payload:Array<U32>}
def value(view:O.WorldView<U32,U32,U32,U32,U32>,result:Array<U32> & U32) -> O.WorldView<U32,U32,U32,U32,U32> & U32:
  match result:
    case (_,v): (view,v)
def ledger(view:O.WorldView<U32,U32,U32,U32,U32>,owner:Maybe<Raw>) -> O.WorldView<U32,U32,U32,U32,U32> & U32:
  match owner:
    case None{}: (view,0)
    case Some{Raw{payload}}: value(view,Array.get(U32,payload,0))
def observed(result:S.World<T.MotionSchema,Raw,Raw,U32,Raw,U32> & O.WorldView<U32,U32,U32,U32,U32>) -> O.WorldView<U32,U32,U32,U32,U32> & U32:
  match result:
    case (S.World{_,_,_,_,owner,_},view): ledger(view,owner)
def main() -> O.WorldView<U32,U32,U32,U32,U32> & U32:
  observed(O.prototype_closed_observation_world_ledger(~T.MotionSchema,~Raw,~Raw,~U32,~Raw,~U32,~U32,~U32,~U32,7,3,S.prototype_closed_rows_empty(~Raw,~Raw,~U32),[],[S.InsertFlag{2,7},S.RemoveMain{1}],[O.FlagView{2,7},O.RemoveMainView{1}],9,(Some{Raw{ALeaf{42}}},Some{88})))
