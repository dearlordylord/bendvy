import Base
import ../../declaration-adoption-v1/library/public-relation-readers/keyed-candidate/application.bend as Schema
import ../../declaration-adoption-v1/library/public-relation-readers/keyed-candidate/observe.bend as Retry
import ../../declaration-adoption-v1/library/public-relation-readers/keyed-candidate/driven.bend as Drive
import ../../declaration-adoption-v1/library/public-relation-readers/keyed-candidate/foreign.bend as Foreign
import ../../declaration-adoption-v1/library/public-relation-readers/keyed-candidate/wider/lifecycle-v14.bend as Lifecycle
import ../../declaration-adoption-v1/library/public-relation-readers/keyed-candidate/wider/mixed-clock-v16.bend as Mixed
import ../../declaration-adoption-v1/library/public-relation-readers/keyed-candidate/wider/application-v14.bend as Wide
import ../../declaration-adoption-v1/library/public-relation-readers/keyed-candidate/wider/observe-v14.bend as Capacity

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

type Finite<S: Data> is Data:
  Finite{retry: Maybe<&2,Retry.Final<S>>,foreign: Maybe<&2,Foreign.ForeignResult<S>>,lifecycle: Lifecycle.Cases<S>,mixed: Maybe<&2,Mixed.Final<S>>}

def finite(~S: Data) -> List<&2,Finite<S>>:
  [Finite{Retry.observed(~S,Drive.application(~S)),Foreign.application(~S),Lifecycle.cases(~S),Mixed.snapshot(~S,Mixed.application(~S))}]

def held_finish(~S:Data,prior:List<&2,Finite<S>>,capacity:Maybe<&2,Capacity.Final<S>>) -> List<&2,Report<S>>:
  match prior:
    case Finite{retry,foreign,lifecycle,mixed} <> []:
      [Report{retry,foreign,lifecycle,mixed,capacity}]
    case _: []

def held(~S: Data) -> List<&2,Report<S>>:
  held_finish(~S,finite(~S),Capacity.observed(~S,Wide.application(~S,65537n)))

def completed(first:List<&2,Report<Schema.ReadersAlpha>>,second:List<&2,Report<Schema.ReadersBeta>>) -> List<&2,Candidate>:
  match first:
    case alpha <> []:
      match second:
        case beta <> []: [Candidate{Some{Output{alpha,beta}}}]
        case _: []
    case _: []

def main() -> List<&2,Candidate>:
  completed(held(~Schema.ReadersAlpha),held(~Schema.ReadersBeta))
