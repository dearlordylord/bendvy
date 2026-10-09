import Base
import ../declaration-adoption-v1/library/public-relation-readers/keyed-candidate/application.bend as Schema
import ../declaration-adoption-v1/library/public-relation-readers/keyed-candidate/observe.bend as Retry
import ../declaration-adoption-v1/library/public-relation-readers/keyed-candidate/driven.bend as Drive
import ../declaration-adoption-v1/library/public-relation-readers/keyed-candidate/foreign.bend as Foreign
import ../declaration-adoption-v1/library/public-relation-readers/keyed-candidate/wider/lifecycle-v14.bend as Lifecycle
import ../declaration-adoption-v1/library/public-relation-readers/keyed-candidate/wider/mixed-clock-v16.bend as Mixed
import ../declaration-adoption-v1/library/public-relation-readers/keyed-candidate/wider/application-v14.bend as Wide
import ../declaration-adoption-v1/library/public-relation-readers/keyed-candidate/wider/observe-v14.bend as Capacity

# Complete independently created applications, never prefixes or rewritten
# observations. Runtime adoption is shared by every relation-reader route.
type Report<S: Data> is Data:
  Report{retry: Maybe<&2,Retry.Final<S>>,foreign: Maybe<&2,Foreign.ForeignResult<S>>,lifecycle: Lifecycle.Cases<S>,mixed: Maybe<&2,Mixed.Final<S>>,capacity:Maybe<&2,Capacity.Final<S>>}
type Output is Data:
  Output{alpha: Report<Schema.ReadersAlpha>,beta: Report<Schema.ReadersBeta>}

# Ordinary List uses recursive node_fields storage rather than Array arr_loc.
# Candidate is an honest transport wrapper; only Some with the complete Output
# qualifies. Private malformed input returns None, never a synthetic report.
type Candidate is Data: Candidate{result:Maybe<&2,Output>}

def report(~S: Data) -> Report<S>:
  Report{Retry.observed(~S,Drive.application(~S)),Foreign.application(~S),Lifecycle.cases(~S),Mixed.snapshot(~S,Mixed.application(~S)),Capacity.observed(~S,Wide.application(~S,65537n))}

def held(~S: Data) -> List<&2,Report<S>>:
  [report(~S)]

def completed(first:List<&2,Report<Schema.ReadersAlpha>>,second:List<&2,Report<Schema.ReadersBeta>>) -> Maybe<&2,Output>:
  match first:
    case alpha <> []:
      match second:
        case beta <> []: Some{Output{alpha,beta}}
        case _: None{}
    case _: None{}

def main() -> Candidate:
  Candidate{completed(held(~Schema.ReadersAlpha),held(~Schema.ReadersBeta))}
