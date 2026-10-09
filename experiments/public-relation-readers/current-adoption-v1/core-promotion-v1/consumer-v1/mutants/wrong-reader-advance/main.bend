import Base
import /workspace/formal-proofs/bendvy-worktrees/parity-43-readers-current/experiments/public-relation-readers/current-adoption-v1/core-promotion-v1/consumer-v1/mutants/wrong-reader-advance/library/public-relation-readers/keyed-candidate/application.bend as Schema
import /workspace/formal-proofs/bendvy-worktrees/parity-43-readers-current/experiments/public-relation-readers/current-adoption-v1/core-promotion-v1/consumer-v1/mutants/wrong-reader-advance/library/public-relation-readers/keyed-candidate/observe.bend as Retry
import /workspace/formal-proofs/bendvy-worktrees/parity-43-readers-current/experiments/public-relation-readers/current-adoption-v1/core-promotion-v1/consumer-v1/mutants/wrong-reader-advance/library/public-relation-readers/keyed-candidate/driven.bend as Drive
import /workspace/formal-proofs/bendvy-worktrees/parity-43-readers-current/experiments/public-relation-readers/current-adoption-v1/core-promotion-v1/consumer-v1/mutants/wrong-reader-advance/library/public-relation-readers/keyed-candidate/foreign.bend as Foreign
import /workspace/formal-proofs/bendvy-worktrees/parity-43-readers-current/experiments/public-relation-readers/current-adoption-v1/core-promotion-v1/consumer-v1/mutants/wrong-reader-advance/library/public-relation-readers/keyed-candidate/wider/lifecycle-v14.bend as Lifecycle
import /workspace/formal-proofs/bendvy-worktrees/parity-43-readers-current/experiments/public-relation-readers/current-adoption-v1/core-promotion-v1/consumer-v1/mutants/wrong-reader-advance/library/public-relation-readers/keyed-candidate/wider/mixed-clock-v16.bend as Mixed

# Complete independently created applications, never prefixes or rewritten
# observations. Runtime adoption is shared by every relation-reader route.
type Report<S: Data> is Data:
  Report{retry: Maybe<&2,Retry.Final<S>>,foreign: Maybe<&2,Foreign.ForeignResult<S>>,lifecycle: Lifecycle.Cases<S>,mixed: Maybe<&2,Mixed.Final<S>>}
type Output is Data:
  Output{alpha: Report<Schema.ReadersAlpha>,beta: Report<Schema.ReadersBeta>}

# Ordinary List uses recursive node_fields storage rather than Array arr_loc.
# Candidate is an honest transport wrapper; only Some with the complete Output
# qualifies. Private malformed input returns None, never a synthetic report.
type Candidate is Data: Candidate{result:Maybe<&2,Output>}

def report(~S: Data) -> Report<S>:
  Report{Retry.observed(~S,Drive.application(~S)),Foreign.application(~S),Lifecycle.cases(~S),Mixed.snapshot(~S,Mixed.application(~S))}

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
