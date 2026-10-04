import Base
import ../t11-replacement/types.bend as T
import ../t11-replacement/model.bend as M
import ../t11-replacement/spec.bend as S
import ../t11-replacement/runtime.bend as R
import ../t11-replacement/owned-spec.bend as O

law query_any_complete_ordered:
  for +limit: Nat
  for +world: T.World
  S.When(S.admissible(limit, world), {M.query(world, T.Any{}) == S.query(world, T.Any{}) : List<&2,T.Row>})

law query_present_complete_ordered:
  for +limit: Nat
  for +world: T.World
  S.When(S.admissible(limit, world), {M.query(world, T.Present{}) == S.query(world, T.Present{}) : List<&2,T.Row>})

law query_absent_complete_ordered:
  for +limit: Nat
  for +world: T.World
  S.When(S.admissible(limit, world), {M.query(world, T.Absent{}) == S.query(world, T.Absent{}) : List<&2,T.Row>})

law lookup_full_exact:
  for +world: T.World
  for +handle: T.Handle
  for +selection: T.Selection
  {M.lookup(world, handle, selection) == S.lookup(world, handle, selection) : T.Lookup}

law explicit_flush_independent:
  for +limit: Nat
  for +world: T.World
  S.When(S.admissible(limit, world), {M.observe(M.flush(world)) == S.flush_observation(world) : T.Observation})

law schedule_execution_exact:
  for +limit: Nat
  for +world: T.World
  for +steps: List<&2, T.Step>
  S.When(S.admissible(limit, world), {M.observe(M.tick(steps, limit, world)) == S.schedule_observation(limit, world, steps) : T.Observation})

law owned_runtime_schedule_correspondence:
  for +limit: U32
  for world: R.World
  for +steps: List<&2,R.Step>
  S.When(S.run_safe(O.steps(steps),U32.to_nat(limit),O.snapshot(world)), {M.observe(R.snapshot(R.project(R.tick(steps,limit,world)))) == S.schedule_observation(U32.to_nat(limit),O.snapshot(world),O.steps(steps)) : T.Observation})
