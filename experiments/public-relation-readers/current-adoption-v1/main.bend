import Base
import ./library/public-relation-readers/keyed-candidate/application.bend as Schema
import ./library/public-relation-readers/keyed-candidate/observe.bend as Retry
import ./library/public-relation-readers/keyed-candidate/driven.bend as Drive
import ./library/public-relation-readers/keyed-candidate/foreign.bend as Foreign
import ./library/public-relation-readers/keyed-candidate/wider/lifecycle-v14.bend as Lifecycle
import ./library/public-relation-readers/keyed-candidate/wider/mixed-clock-v16.bend as Mixed

# Complete independently created applications, never prefixes or rewritten
# observations. Runtime adoption is shared by every relation-reader route.
type Report<S: Data> is Data:
  Report{retry: Maybe<&2,Retry.Final<S>>,foreign: Maybe<&2,Foreign.ForeignResult<S>>,lifecycle: Lifecycle.Cases<S>,mixed: Maybe<&2,Mixed.Final<S>>}
type Output is Data:
  Output{alpha: Report<Schema.ReadersAlpha>,beta: Report<Schema.ReadersBeta>}

def main() -> Output:
  Output{Report{Retry.observed(~Schema.ReadersAlpha,Drive.application(~Schema.ReadersAlpha)),Foreign.application(~Schema.ReadersAlpha),Lifecycle.cases(~Schema.ReadersAlpha),Mixed.snapshot(~Schema.ReadersAlpha,Mixed.application(~Schema.ReadersAlpha))},Report{Retry.observed(~Schema.ReadersBeta,Drive.application(~Schema.ReadersBeta)),Foreign.application(~Schema.ReadersBeta),Lifecycle.cases(~Schema.ReadersBeta),Mixed.snapshot(~Schema.ReadersBeta,Mixed.application(~Schema.ReadersBeta))}}
