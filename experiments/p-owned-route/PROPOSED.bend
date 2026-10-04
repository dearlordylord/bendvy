import Base
import ../t11-replacement/types.bend as T
import ../t11-replacement/model.bend as M
import ../t11-replacement/spec.bend as S
import ../t11-replacement/runtime.bend as R
import ../t11-replacement/owned-spec.bend as O

# UNAPPROVED proposal: only -world -> world in the exact original law.
law owned_runtime_schedule_correspondence:
  for +limit: U32
  for world: R.World
  for +steps: List<&2,R.Step>
  S.When(S.run_safe(O.steps(steps),U32.to_nat(limit),O.snapshot(world)), {M.observe(R.snapshot(R.project(R.tick(steps,limit,world)))) == S.schedule_observation(U32.to_nat(limit),O.snapshot(world),O.steps(steps)) : T.Observation})
