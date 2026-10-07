import Base
import ../../../src/ecs/schema-fragments.bend as F
import ./model.bend as M

# DRAFT, unapproved. Open claims only: no paired ECS proof definitions.
# Exact key/name classification, kind-local and key-first.
law collision_classification:
  for +seen: List<&2,F.Entry<M.Schema>>
  for +item: F.Entry<M.Schema>
  {F.check_one(~M.Schema,seen,item) == M.classify(seen,item) : F.Validation}

# First collision by fixed kind order, then declaration order within kind.
law validation_priority:
  for +entries: List<&2,F.Entry<M.Schema>>
  {F.validate(~M.Schema,entries) == M.validate(entries) : F.Validation}

# Membership requires all three fields, not merely a matching key or name.
law declaration_membership:
  for +entries: List<&2,F.Entry<M.Schema>>
  for +item: F.Entry<M.Schema>
  {F.descriptor_present(~M.Schema,entries,item) == M.member(entries,item) : Bool}
