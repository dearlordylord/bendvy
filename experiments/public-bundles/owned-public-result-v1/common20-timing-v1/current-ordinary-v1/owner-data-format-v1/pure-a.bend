import Base
import /workspace/formal-proofs/bendvy-worktrees/bundle41-authority-refresh-v1/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/current-ordinary-v1/owner-data-format-v1/lifecycle-a.bend as Flow
import /workspace/formal-proofs/bendvy-worktrees/bundle41-authority-refresh-v1/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/current-ordinary-v1/source-v1/experiments/public-bundles/combined-control.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
def consume(world:W.World<A.Schema,A.Store,A.Mail,U32>,invalid:Bool,retry:Bool,fail:Bool,cleanup:Bool) -> String:Flow.run(invalid,retry,fail,cleanup,world)
