import Base
import /tmp/bendvy-fourhour-closed-reader-initial-probe/experiments/s-integrate/storage.bend as S
type Raw is Type:
  Raw{payload:Array<U32>}
def bad(owner:S.Bundle<Raw,Raw,U32>) -> S.Bundle<Raw,Raw,U32> & S.Bundle<Raw,Raw,U32>:
  (owner,owner)
def main() -> U32: 0
