import Base
import /workspace/formal-proofs/bendvy-worktrees/resource-field-integration/src/ecs/ordinary-resource-field-system.bend as P
import /workspace/formal-proofs/bendvy-worktrees/resource-field-integration/experiments/public-resource-fields/core-adoption-v1/source/operations.bend as O
import /workspace/formal-proofs/bendvy-worktrees/resource-field-integration/experiments/public-resource-fields/core-adoption-v1/source/schema-a.bend as A
import /workspace/formal-proofs/bendvy-worktrees/resource-field-integration/experiments/public-resource-fields/core-adoption-v1/source/schema-b.bend as Other
def attempt(~H:Type,~cap:P.Write<A.A,O.Counter,A.first(),H,U32>,owner:H) -> H:
  P.set(~Other.Other,~O.Counter,~Other.first(),~H,~U32,~cap,owner,O.counter(1,2,3,4))
