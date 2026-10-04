import Base
import ./capture.bend as C
import ./schedule.bend as D
import ./frames.bend as F
import ./tick-context.bend as K
import ./final-observation.bend as E
import ../p-approved-owned-safety/safety.bend as V
import ../p-approved-owned-safety/transport.bend as P
import ../t11-replacement/runtime.bend as R
import ../t11-replacement/owned-spec.bend as O
import ../t11-replacement/types.bend as T
import ../t11-replacement/model.bend as M
import ../t11-replacement/spec.bend as S

def initial_valid(+steps: List<&2,T.Step>, +limit: Nat, +data: T.World,
  safe: {True{} == V.ModelSafe(steps,limit,data) : Bool}) -> {True{} == S.admissible(limit,data) : Bool}:
  match steps:
    case Nil{}: safe
    case Con{+operation,+tail}: K.head_valid(operation,tail,limit,data,safe)

def guarded(guard: Bool, +limit: U32, world: R.World, +data: T.World, +steps: List<&2,R.Step>,
  observed: {O.snapshot(world) == data : T.World}, safe: {guard == S.run_safe(O.steps(steps),U32.to_nat(limit),data) : Bool})
  -> S.When(guard,{M.observe(R.snapshot(R.project(R.tick(steps,limit,world)))) == S.schedule_observation(U32.to_nat(limit),data,O.steps(steps)) : T.Observation}):
  match guard:
    case False{}: Unit{}
    case True{}:
      +prefixes = P.from_independent(O.steps(steps),U32.to_nat(limit),data,safe)
      E.finish(limit,steps,world,data,initial_valid(O.steps(steps),U32.to_nat(limit),data,prefixes),D.tick(steps,limit,world,data,observed,prefixes))

def retained(-source: R.World, -owner: R.World, +data: T.World,
  same: {owner == source : R.World}, observation: {data == O.snapshot(source) : T.World})
  -> {O.snapshot(owner) == data : T.World}:
  Equal.trans(T.World,O.snapshot(owner),O.snapshot(source),data,
    Equal.cong(R.World,T.World,w => O.snapshot(w),owner,source,same),Equal.sym(T.World,data,O.snapshot(source),observation))

def captured(+limit: U32, -world: R.World, +steps: List<&2,R.Step>, frame: C.WorldFrame<world>)
  -> S.When(S.run_safe(O.steps(steps),U32.to_nat(limit),O.snapshot(world)), {M.observe(R.snapshot(R.project(R.tick(steps,limit,world)))) == S.schedule_observation(U32.to_nat(limit),O.snapshot(world),O.steps(steps)) : T.Observation}):
  match frame:
    case C.WorldFrame{owner,+data,_,+observation,+same}:
      h = retained(world,owner,data,same,observation)
      %observation : S.When(S.run_safe(O.steps(steps),U32.to_nat(limit),_), {M.observe(R.snapshot(R.project(R.tick(steps,limit,world)))) == S.schedule_observation(U32.to_nat(limit),_,O.steps(steps)) : T.Observation})
      %same : S.When(S.run_safe(O.steps(steps),U32.to_nat(limit),data), {M.observe(R.snapshot(R.project(R.tick(steps,limit,_)))) == S.schedule_observation(U32.to_nat(limit),data,O.steps(steps)) : T.Observation})
      guarded(S.run_safe(O.steps(steps),U32.to_nat(limit),data),limit,owner,data,steps,h,{==})
