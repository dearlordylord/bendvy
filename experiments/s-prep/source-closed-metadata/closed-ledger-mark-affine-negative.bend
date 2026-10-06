import Base
import /tmp/bendvy-closed-ledger-mark-probe/experiments/s-integrate/storage.bend as S
type Raw is Type:
  Raw{payload:Array<U32>}
def bad(owner:S.Command<Raw,Raw,U32>) -> S.Command<Raw,Raw,U32> & S.Command<Raw,Raw,U32>:
  (owner,owner)
def main() -> U32: 0
