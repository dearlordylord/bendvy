import Base
import /workspace/formal-proofs/bendvy-worktrees/parity-41-public-readiness/src/ecs/bundle-insert-adapter.bend as AD
import /workspace/formal-proofs/bendvy-worktrees/parity-41-public-readiness/src/ecs/world.bend as W
type Schema is Data:
  Schema{}
type Other is Data:
  Other{}
def bad(input:AD.Input<Other,Array<U32>>) -> AD.Input<Schema,Array<U32>>:
  input
