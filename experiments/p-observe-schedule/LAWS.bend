import Base
import ../t11-replacement/types.bend as T
import ../t11-replacement/model.bend as M
import ../t11-replacement/spec.bend as S

law schedule_execution_exact:
  for +limit: Nat
  for +world: T.World
  for +steps: List<&2, T.Step>
  S.When(S.admissible(limit, world), {M.observe(M.tick(steps, limit, world)) == S.schedule_observation(limit, world, steps) : T.Observation})
