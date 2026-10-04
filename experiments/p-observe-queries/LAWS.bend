import Base
import ../t11-replacement/types.bend as T
import ../t11-replacement/model.bend as M
import ../t11-replacement/spec.bend as S

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
