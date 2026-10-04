import Base
import ../t11-replacement/types.bend as T
import ../t11-replacement/model.bend as M
import ../t11-replacement/spec.bend as S

law explicit_flush_independent:
  for +limit: Nat
  for +world: T.World
  S.When(S.admissible(limit, world), {M.observe(M.flush(world)) == S.flush_observation(world) : T.Observation})
