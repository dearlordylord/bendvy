# Relation failure reader reference — #43 preparation

Actual pinned public TS execution asserts eighteen complete checkpoints across
 two nominal roots. Self-link refusal and missing-target failures are queued in
 authored order and appear only after the structural barrier. The fast reader and a slow reader
 omitted from the publication schedule have independent cursors. A failing slow reader observes
 both exact payloads again on retry; its successful retry then consumes them.
 Callback logging is host IO and remains visible despite system failure.

Run: `timeout 5s node experiments/public-relation-readers/reference.mjs`.
Source/output/version receipt: `evidence/reference/receipt.json`.

Preparation only: #42/#35 remain prerequisites. Full component/graph affine
owners, foreign commands, lag/disposal, earlier commits, Bend backends, negative
access controls, reached mutants and equivalent timing remain #43 obligations.
Node type stripping establishes no type-level authority. No policy, law approval,
new dependencies or task closure follows from these finite observations.

A false run condition is a distinct registered-skip path that discards the
relation-failure backlog in pinned TS; this cohort does not exercise that path.
Independent read-only source/evidence review found no other discrepancy.

The separate `condition-reference.mjs` cohort asserts twelve checkpoints:
a registered false-condition reader does not run, discards the old backlog,
resumes empty, then receives a new publication. It is intentionally separate
from the omitted-reader cohort. Receipt: `evidence/condition-reference/receipt.json`.

## Current integration boundary

The registered relation application and real foreign-command refusal are delivered
as finite #42 evidence (`e37ab309`, `929d5462`); #42 production integration and
feature timing still remain prerequisites for #43 acceptance. Reader composition
must consume the actual keyed `Notice.RelationFailed` carrier, preserving its
descriptor, operation, source, target and exact error, rather than synthesizing
another failure store or conflating it with `SystemFailure`.

Pinned `Runtime.ts` (`3040a3b2`) registers relation-failure readers in
`registerStreamReader` and creates their slots only after run conditions pass
(`slotOf`/`runSystem`). A never-activated condition skip therefore has no cursor;
an already activated skip advances only its stream cursor. These are distinct
cases for the next actual application. `internal/streams.ts` retains registered
readers by key and exposes no unregister operation; the public Runtime interface
also has no system/reader disposal. Existing Bend disposal controls can verify
owned cleanup as an explicit supplemental behavior, but cannot be reported as an
observed public TS disposal operation. No new disposal policy is selected here.

Actual `never-activated-reference.mjs` now observes twelve full public debug
world/stream/delivery checkpoints across both roots: initial skips invoke no
reader, an unheld publication ages out before first activation, the first read
is empty and not lagged, then a new failure is delivered once. Its five-second
Node-only run and 37 before/after input pins are retained in
`evidence/never-activated-reference/receipt.json`. This is TS observation only;
Bend comparison and #43 acceptance remain untested.
