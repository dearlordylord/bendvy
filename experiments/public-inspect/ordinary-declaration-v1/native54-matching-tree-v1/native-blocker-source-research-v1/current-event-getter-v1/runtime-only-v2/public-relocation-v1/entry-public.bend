import Base
import ./publisher-public.bend as Publisher
# Complete physical owner is retained until terminal test-only detachment.
def detached(value:Publisher.Returned) -> Maybe<&2,List<&2,Publisher.Observation>>:
  match value:
    case Publisher.Ready{_,observations}:Some{observations}
    case Publisher.Refused{_}:None{}
def main() -> Maybe<&2,List<&2,Publisher.Observation>>:detached(Publisher.run())
