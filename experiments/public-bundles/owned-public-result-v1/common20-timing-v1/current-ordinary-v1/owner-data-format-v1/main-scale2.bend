import Base
import /workspace/formal-proofs/bendvy/benchmarks/parity-features/timing.bend as Bench
import /workspace/formal-proofs/bendvy-worktrees/bundle41-authority-refresh-v1/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/current-ordinary-v1/owner-data-format-v1/main.bend as Loop
def main() -> IO(Unit):
  do IO<Unit>:
    Bench.begin()
    Loop.lifecycle()
    Loop.lifecycle()
    Bench.end()
