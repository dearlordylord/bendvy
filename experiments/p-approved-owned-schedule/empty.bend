import Base
import ./capture.bend as C
import ../t11-replacement/runtime.bend as R
import ../t11-replacement/owned-spec.bend as O
import ../t11-replacement/types.bend as T
import ../t11-replacement/model.bend as M
import ../t11-replacement/spec.bend as S
import ../p-observe-queries/complete.bend as Q
import ../p-observe-queries/helpers.bend as H

def data_observation(+limit: Nat, +world: T.World, valid: {True{} == S.admissible(limit,world) : Bool})
  -> {M.observe(world) == S.observe(world) : T.Observation}:
  match world:
    case T.World{+id,+next,+rows,+pending}:
      live = H.and_left(S.rows_valid(rows,rows,next),S.pending_valid(pending,pending,rows,next),
        H.and_right(Nat.is_le(next,limit),Bool.and(S.rows_valid(rows,rows,next),S.pending_valid(pending,pending,rows,next)),valid))
      Equal.cong(List<&2,T.Row>,T.Observation,rs => T.Observation{id,next,rs,pending},
        M.query_rows(T.Any{},rows),S.enumerate_rows(next,0n,rows,T.Any{}),Q.rows_complete(rows,next,T.Any{},live))

def data_guard(guard: Bool, +limit: Nat, +world: T.World, valid: {guard == S.admissible(limit,world) : Bool})
  -> S.When(guard,{M.observe(world) == S.observe(world) : T.Observation}):
  match guard:
    case False{}: Unit{}
    case True{}: data_observation(limit,world,valid)

def data_empty(+limit: Nat, +world: T.World)
  -> S.When(S.admissible(limit,world),{M.observe(world) == S.observe(world) : T.Observation}):
  data_guard(S.admissible(limit,world),limit,world,{==})

def empty_frame(+limit: U32, -world: R.World, frame: C.WorldFrame<world>)
  -> S.When(S.run_safe(O.steps([]),U32.to_nat(limit),O.snapshot(world)),
    {M.observe(R.snapshot(R.project(R.tick([],limit,world)))) == S.schedule_observation(U32.to_nat(limit),O.snapshot(world),O.steps([])) : T.Observation}):
  match frame:
    case C.WorldFrame{owner,+data,exact,observed,_}:
      %observed : S.When(S.admissible(U32.to_nat(limit),_),{M.observe(R.snapshot(R.project(world))) == S.observe(_) : T.Observation})
      %exact : S.When(S.admissible(U32.to_nat(limit),data),{M.observe(R.snapshot(_)) == S.observe(data) : T.Observation})
      data_empty(U32.to_nat(limit),data)

# Exact revised endpoint specialized ONLY to the empty authored schedule.
# Every live affine world and both branches of its original domain remain.
def empty(+limit: U32, world: R.World)
  -> S.When(S.run_safe(O.steps([]),U32.to_nat(limit),O.snapshot(world)),
    {M.observe(R.snapshot(R.project(R.tick([],limit,world)))) == S.schedule_observation(U32.to_nat(limit),O.snapshot(world),O.steps([])) : T.Observation}):
  empty_frame(limit,world,C.capture_world(world))
