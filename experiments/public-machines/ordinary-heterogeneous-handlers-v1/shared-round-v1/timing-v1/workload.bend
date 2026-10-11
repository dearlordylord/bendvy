import Base
import /workspace/formal-proofs/bendvy/benchmarks/parity-features/timing.bend as Bench
import /workspace/formal-proofs/bendvy-worktrees/handlers49-current-ordinary-v1/experiments/public-machines/ordinary-heterogeneous-handlers-v1/shared-round-v1/main.bend as Scenario
def captured(items:List<&2,String>) -> IO(Unit):
  match items:
    case []:IO.pure(Unit,Unit{})
    case head <> tail:
      do IO<Unit>:
        Bench.capture(head)
        captured(tail)
def lifecycle() -> IO(Unit):
  captured(Scenario.main())
