import Base
import /workspace/formal-proofs/bendvy-worktrees/parity-41-public-readiness/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/registered-lifecycle-v1/lifecycle-a.bend as A
import /workspace/formal-proofs/bendvy-worktrees/parity-41-public-readiness/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/registered-lifecycle-v1/lifecycle-b.bend as B
def invalid(world:B.World()) -> B.World() & String:
  A.observe("foreign-observer",world)
