import Base
import ../../../src/ecs/schedule-provision.bend as P
import ../../../src/ecs/schedule.bend as Sch
import ./spec.bend as Spec

# DRAFT / UNAPPROVED. No proof definitions or runtime refinement claim.
law category_identity:
  for S: Data
  for +a: P.Requirement<S>
  for +b: P.Requirement<S>
  {P.same(~S,a,b) == Spec.equal(~S,a,b) : Bool}
law stable_first_union:
  for S: Data
  for +items: List<&2,P.Requirement<S>>
  {P.unique(~S,items) == Spec.union(~S,items) : List<&2,P.Requirement<S>>}
law authored_flatten:
  for S: Data
  for +plan: P.Plan<S>
  {P.flatten(~S,plan) == Spec.flatten_into(~S,plan,[]) : List<&2,Sch.Step>}
law authored_requirements:
  for S: Data
  for +plan: P.Plan<S>
  {P.requirements(~S,plan) == Spec.needs_into(~S,plan,[]) : List<&2,P.Requirement<S>>}
law complete_ordered_missing:
  for S: Data
  for +needs: List<&2,P.Requirement<S>>
  for +grants: List<&2,P.Requirement<S>>
  {P.missing_requirements(~S,needs,grants) == Spec.missing(~S,grants,needs) : List<&2,P.Requirement<S>>}
