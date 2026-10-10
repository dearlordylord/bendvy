import Base
import trace-consumer.bend as C
import tree-consumer.bend as T
# Terminal test harness discards affine fixture only after all complete snapshots.
# Ordinary sequence itself returns every owner; no operational owner is replaced.
def detached(returned:T.Fixture & List<&2,C.Row>) -> List<&2,C.Row>:
  match returned:
    case (_,rows):rows
def main() -> List<&2,C.Row>:detached(C.scenario())
