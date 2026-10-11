import Base
import workload.bend as Work
import /workspace/formal-proofs/bendvy/benchmarks/parity-features/timing.bend as Bench
def main() -> IO(Unit):
  do IO<Unit>:
    Bench.begin()
    Work.lifecycle()
    Work.lifecycle()
    Work.lifecycle()
    Work.lifecycle()
    Bench.end()
