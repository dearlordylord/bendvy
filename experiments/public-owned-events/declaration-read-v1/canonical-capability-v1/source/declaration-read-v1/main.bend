import Base
import /workspace/formal-proofs/bendvy-worktrees/parity-53-canonical-capability/experiments/public-owned-events/declaration-read-v1/canonical-capability-v1/source/declaration-read-v1/controls.bend as C
import /workspace/formal-proofs/bendvy/experiments/public-owned-events/generic-scoped-read-v1/main.bend as O

type Report is Data: Report{access:List<&2,String>,observations:O.Report}
def main() -> Report: Report{C.metadata(),O.finish(C.full())}
