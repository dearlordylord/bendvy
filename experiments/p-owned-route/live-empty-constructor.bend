import Base
import ./language.bend as P
import ../t11-replacement/runtime.bend as R
import ../t11-replacement/owned-spec.bend as O
import ../t11-replacement/types.bend as T
import ../t11-replacement/model.bend as M
import ../t11-replacement/spec.bend as S

# Only the proof input owner is now LIVE. The equation remains an explicit
# premise, so this is conditional construction, not correspondence established.
def construct(+limit: U32, world: R.World,
  proof: {M.observe(R.snapshot(R.project(R.tick([],limit,world)))) == S.schedule_observation(U32.to_nat(limit),O.snapshot(world),O.steps([])) : T.Observation})
  -> S.When(S.run_safe(O.steps([]),U32.to_nat(limit),O.snapshot(world)),
    {M.observe(R.snapshot(R.project(R.tick([],limit,world)))) == S.schedule_observation(U32.to_nat(limit),O.snapshot(world),O.steps([])) : T.Observation}):
  P.introduce(S.run_safe(O.steps([]),U32.to_nat(limit),O.snapshot(world)),
    {M.observe(R.snapshot(R.project(R.tick([],limit,world)))) == S.schedule_observation(U32.to_nat(limit),O.snapshot(world),O.steps([])) : T.Observation},proof)
