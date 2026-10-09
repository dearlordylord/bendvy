import Base
import /workspace/formal-proofs/bendvy-worktrees/parity-41-public-readiness/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/lifecycle-a.bend as A
def invalid(world:A.World()) -> (A.World() & String) & (A.World() & String):
  (A.observe(world),A.observe(world))
