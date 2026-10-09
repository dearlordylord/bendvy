import Base
import ../library/public-relation-readers/keyed-candidate/application.bend as Schema
import ../library/public-relation-readers/keyed-candidate/observe.bend as Retry
import ../library/public-relation-readers/keyed-candidate/driven.bend as Drive
import ../library/public-relation-readers/keyed-candidate/foreign.bend as Foreign
import ../library/public-relation-readers/keyed-candidate/wider/lifecycle-v14.bend as Lifecycle
import ../library/public-relation-readers/keyed-candidate/wider/mixed-clock-v16.bend as Mixed

# Complete independently created applications, never prefixes or rewritten
# observations. Runtime adoption is shared by every relation-reader route.
type Report<S: Data> is Data:
  Report{retry: Maybe<&2,Retry.Final<S>>,foreign: Maybe<&2,Foreign.ForeignResult<S>>,lifecycle: Lifecycle.Cases<S>,mixed: Maybe<&2,Mixed.Final<S>>}
type Output is Data:
  Output{alpha: Report<Schema.ReadersAlpha>,beta: Report<Schema.ReadersBeta>}

# Arrays keep physical heap storage; extraction has no call between leaves.
def report(~S: Data) -> Report<S>:
  Report{Retry.observed(~S,Drive.application(~S)),Foreign.application(~S),Lifecycle.cases(~S),Mixed.snapshot(~S,Mixed.application(~S))}

def held(~S: Data) -> Array<Report<S>>:
  ALeaf{report(~S)}

def completed(first: Array<Report<Schema.ReadersAlpha>>, second: Array<Report<Schema.ReadersBeta>>) -> Output:
  match first:
    case ALeaf{alpha}:
      match second:
        case ALeaf{beta}: Output{alpha,beta}
        case ANode{left,_}: completed(ALeaf{alpha},left)
    case ANode{left,_}: completed(left,second)

def main() -> Output:
  completed(held(~Schema.ReadersAlpha),held(~Schema.ReadersBeta))
