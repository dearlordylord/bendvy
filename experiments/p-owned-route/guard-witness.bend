import Base
import ./language.bend as P
import ../t11-replacement/runtime.bend as R
import ../t11-replacement/owned-spec.bend as O
import ../t11-replacement/types.bend as T
import ../t11-replacement/model.bend as M
import ../t11-replacement/spec.bend as S

# Legal transport requires two additional LIVE inputs absent from the theorem:
# a guard value tied to the actual world and evidence of the entire equation.
def transport(+guard: Bool, +limit: U32, -world: R.World,
  e: {guard == S.run_safe(O.steps([]),U32.to_nat(limit),O.snapshot(world)) : Bool},
  proof: {M.observe(R.snapshot(R.project(R.tick([],limit,world)))) == S.schedule_observation(U32.to_nat(limit),O.snapshot(world),O.steps([])) : T.Observation})
  -> S.When(S.run_safe(O.steps([]),U32.to_nat(limit),O.snapshot(world)),
    {M.observe(R.snapshot(R.project(R.tick([],limit,world)))) == S.schedule_observation(U32.to_nat(limit),O.snapshot(world),O.steps([])) : T.Observation}):
  %e : S.When(_,{M.observe(R.snapshot(R.project(R.tick([],limit,world)))) == S.schedule_observation(U32.to_nat(limit),O.snapshot(world),O.steps([])) : T.Observation})
  P.introduce(guard,{M.observe(R.snapshot(R.project(R.tick([],limit,world)))) == S.schedule_observation(U32.to_nat(limit),O.snapshot(world),O.steps([])) : T.Observation},proof)
