import Base
import controls.bend as C
import /workspace/formal-proofs/bendvy/experiments/public-owned-events/generic-scoped-read-v1/main.bend as O

type Report is Data: Report{access:List<&2,String>,observations:O.Report}
def main() -> Report: Report{C.metadata(),O.finish(C.full())}
