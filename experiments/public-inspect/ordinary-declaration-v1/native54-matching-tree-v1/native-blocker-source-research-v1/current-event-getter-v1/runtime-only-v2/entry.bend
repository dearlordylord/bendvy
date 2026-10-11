import Base
import ./consumer.bend as C
import ./publisher-only.bend as Publisher
type Report is Data:Report{publisher:List<&2,Publisher.Observation>,registered:Maybe<&2,C.Report>}
# Terminal test-only detachment; both scenes thread complete affine owners until here.
def detached(value:Publisher.Returned,registered:Maybe<&2,C.Report>) -> Maybe<&2,Report>:
  match value:
    case Publisher.Ready{_,observations}:Some{Report{observations,registered}}
    case Publisher.Refused{_}:None{}
def main() -> Maybe<&2,Report>:detached(Publisher.run(),C.run())
