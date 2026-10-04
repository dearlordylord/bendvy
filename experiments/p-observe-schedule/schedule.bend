import Base
import ./relation.bend as R
import ./context.bend as C
import ./successor.bend as U
import ./barrier.bend as B
import ./induction.bend as I
import ../p-observe-flush/prefix.bend as F
import ../t11-replacement/types.bend as T
import ../t11-replacement/model.bend as M
import ../t11-replacement/spec.bend as S

# Each actual primitive dispatch passes its proved successor to the tail IH.
def dispatch(+operation: T.Step, +steps: List<&2,T.Step>, +limit: Nat, +id: Nat, +next: Nat,
  +left: List<&2,T.Row>, +right: List<&2,T.Row>, +pending: List<&2,T.Command>,
  +valid: {True{} == S.admissible(limit,T.World{id,next,left,pending}) : Bool},
  related: R.Slots(limit,0n,left,right), ih: I.Continuation(steps,limit,id))
  -> {M.observe(M.tick(steps,limit,M.step(limit,T.World{id,next,left,pending},operation)))
    == S.observe(S.run(steps,limit,S.step(limit,T.World{id,next,right,pending},operation))) : T.Observation}:
  match operation:
    case T.Reserve{value}:
      I.reserve_run(Nat.cmp(next,limit),steps,limit,id,next,left,right,pending,value,{==},valid,related,ih)
    case T.Publish{T.Handle{namespace,target},action}:
      I.publish_run(Nat.cmp(id,namespace),steps,limit,id,next,left,right,pending,target,action,valid,related,ih)
    case T.Bump{target}:
      ih(next,M.bump_rows(target,left),S.bumped(next,0n,target,right),pending,
        C.bump_success(limit,id,next,left,pending,target,valid),
        U.bump_slots(limit,0n,next,target,left,right,C.live_valid(limit,id,next,left,pending,valid),related))
    case T.Barrier{}:
      ih(next,M.apply_all(pending,left),S.materialize(next,0n,right,pending),[],
        B.barrier_success(limit,id,next,left,pending,valid),
        B.barrier_slots(limit,0n,next,left,right,pending,
          F.apply_all_rows_valid(pending,left,next,C.live_valid(limit,id,next,left,pending,valid),C.queue_valid(limit,id,next,left,pending,valid)),related))

