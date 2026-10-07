import Base
import feature.bend as F
import spec.bend as Spec
import ../../src/ecs/schema-fragments.bend as SF
# DRAFT / UNAPPROVED. No PROOF definitions or runtime owner-refinement law.
law selected_names_order:
  for S:Data
  for +tree:F.Tree<S>
  {F.names(~S,tree) == Spec.names_into(~S,tree,[]) : List<&2,String>}
law transitive_authored_visibility:
  for S:Data
  for +tree:F.Tree<S>
  {F.visibility(~S,tree) == Spec.visibility_into(~S,tree,[]) : List<&2,SF.Entry<S>>}
# Specific validation priority candidates, not runtime World refinement.
law duplicate_before_missing:
  for S:Data
  {F.validate(~S,F.Sequence{F.Feature{"Combat",[],F.Feature{"Core",[],F.Empty{}}},F.Feature{"Combat",[],F.Feature{"Core",[],F.Empty{}}}}) == F.Invalid{F.DuplicateFeature{"Combat"}} : F.Validation}
law missing_before_schema:
  for S:Data
  {F.validate(~S,F.Feature{"Combat",[SF.Entry{SF.Component{},"x","x"},SF.Entry{SF.Component{},"x","x"}],F.Feature{"Core",[],F.Empty{}}}) == F.Invalid{F.MissingDependency{"Core"}} : F.Validation}
