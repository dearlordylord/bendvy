# Integrated trace prerequisites — Standards review

Reviewed `git diff 23ef716...7208946`, governing AGENTS/SPEC and S-INTEGRATE
ticket, plus the allocation adapter, report and recorded JSON. This is the
Standards axis; the complete #19 trace and Bend implementation are outside this
checkpoint. Preserve original references and `jev`.

## Fresh TS allocation checkpoint

**Hard violations: none found.** The adapter verifies the pinned bevy-ts commit
against the tracked manifest and records adapter/source SHA256 hashes. It imports
the public core directly using the existing Node runtime, with no new dependency.
Systems access component payloads through declared read/write queries; durable
handles and their resolution use public Entity/lookup APIs. No internal allocator
or debug dump supplies observations.

Raw IDs come from actual `commands.spawn` returns. Assertions relate subsequent
reservations and record raw IDs rather than inserting constants or normalizing
away the consumed failed reservation. Escaping the failed handle into host state
is intentional and disclosed. Fresh public dispatcher checkpoints demonstrate
earlier commit retention, failed scalar-write restoration, discarded failed spawn,
unreissued failed handle, explicit barriers and skipped tail.

The report limits claims to one schema/scalar TS reference execution; it does not
represent this as integrated Bend Type payloads, readers/lifecycle, generic allocator
policy, universal refinement or performance acceptance. The five-second execution
bound is supplied by the documented command/coordinator, not falsely claimed as an
internal Node timer.

Reviewer independently replayed the adapter with Python subprocess timeout 5,
without changing artifacts. Exit 0 produced JSON exactly equal to recorded evidence:
seven checkpoints and raw reservations 1/2/3/4. Adapter and all ten recorded source
hashes matched current bytes. No reference or original game file was modified.

**Heuristic findings: none actionable.** Explicit scenario steps keep transaction,
reservation and publication boundaries independently visible; small repeated
observation assertions improve this finite reference evidence.

Result: 0 hard findings; 0 actionable heuristics. Full two-schema trace review,
integrated runtime evidence and performance gates remain open.

## Source seams and measurement drafts

Reviewed `docs/design/s-integrate-seams.md` (inventory from `7774517`, including
the fresh allocation link) and current `docs/design/s-integrate-measurement.md`.
Inspected actual source declarations for provider/query, Type payload, identity,
transaction, reader, service and owned-storage seams. Signatures are openly
abbreviated; cited interfaces and ownership descriptions match their sources.

**Hard violations: none found.** The inventory distinguishes actual functions
from required joins: separate Type/Data storage probes, identity-only tick,
String-command clearing versus structural application, count cursor versus real
reader clocks, nominal schema fixtures versus generic registry and trusted factory
lineage versus global namespace authority. Failed allocation consumption now links
fresh public TS evidence without claiming Bend correspondence. Numeric inverses
do not become arbitrary destructive Type restoration or proof acceptance.

Measurement drafts require equivalent authored dispatch/provider/transaction/
barrier work and full declared observations before timing. Indexed materialization
and map/relocation costs belong to the integrated path when used; no raw-array
shortcut or favorable standalone loop can replace that path. First/middle/last
rotating churn avoids silently preserving the earlier favorable head-only case.
Message/reader rates, failed publication/retry/consumed reservation and captures
remain visible, with raw allocation IDs retained across normalization.

Setup/final dumps are separated from steady-state, while actual intermediate
trace operations and dispatch/barriers remain timed. Fresh-world repetitions,
warmups, raw samples, individual regressions, checksum supplementation and RSS
scope prevent average or startup-memory claims from accepting performance.
Unstable duration requires repinned equivalent inputs for every backend. Numeric
thresholds, production layout and broader scaling/mutation capabilities remain
unapproved; draft inputs do not silently establish those policies.

The documents correctly remain prerequisites: exact field values/capacities and
full concrete trace must still be frozen/reviewed before implementation. There is
no integrated runtime, complete trace or measured performance acceptance here.

**Heuristic findings: none actionable.** The comparison matrix organizes real
seam dependencies rather than introducing speculative production abstractions.

## Concrete trace draft `00b053a...d6adf30`

Reviewed `docs/design/s-integrate-trace.md` and revised measurement contract.
Checked pinned source anchors for allocation, commit/rollback, reader
skip/success/failure and explicit transition/deferred barriers.

**Hard violations: none found.** All integrated E checkpoints remain expressly
source-derived future expectations; only X names the separately executed scalar
allocation prerequisite. Neither prior probes nor scalar X become Type-integrated
acceptance. Links pin Sandro's original commit and actual source locations rather
than presenting unexecuted expectations as observations.

The trace requires complete four-field payload arrays plus schema-specific record
metadata/resources, owner-returning projections and fresh closed abstract
capabilities. Two distinct schemas and same-schema pairs are separately exercised;
numeric collisions do not substitute for threaded factory provenance. Actual base
instances/dispatcher, retry/skip/nested failure, real structural barriers, full
reader logs and service effects must execute. Diagnostic strings explicitly cannot
stand in for claimed host-effect parity. Allocation retains actual returned IDs
and escaped handles, and failed writes/publications/marks are observed separately.

Compiler controls require intended paired failures, actual consumed aliases and
Type/Data boundaries; meaningful runtime mutants require compilation and both
backend differences. Overflow lanes compare complete sequences, distinguish
whole-batch message versus individual lifecycle retention, and remain unresolved
if runtime bounds prevent execution. Small internal diagnostics cannot silently
satisfy public integrated lanes. Unapproved foreign-command result, root authority,
destructive recovery, law revisions/dependencies and performance remain explicit
decisions; the document grants none.

Revised measurement now observes A/B successful pending publications before a
FIFO barrier, then actual successful-spawn disposal at a second barrier. Initial
live count is restored while allocator consumption persists. Reader work includes
nonvacuous live additions/changes and subsequent retained deletion observations.
Dispatch/provider/transaction/barrier/map costs remain included, complete semantic
traces precede checksum timing controls, and no favorable aggregate hides regressions.

**Heuristic findings: none actionable.** Sequential tables preserve distinct
publication/application/reader boundaries. These documents remain reviewable
prerequisites, with #18 dependency and exact trace/interface/law gates before
runtime implementation; no measured or production acceptance is inferred.

## Fresh public E11 retention reference — `891370b`

Reviewed adapter, README, refreshed ten-case evidence and trace's lifecycle lag
observability correction. Current adapter/trace hashes match recorded evidence.

**Hard violations: none found.** Each complete schema/case child is bounded by
`execFileSync(timeout:5000)`, including imports, runtime operations, comparisons
and serialization. Timeout or execution/semantic failure remains nonzero for the
sweep; only task-owned children are controlled. Pins include actual bevy-ts
commit/files, manifest, adapter and trace hashes, with no dependency changes.

Public query/added/changed rows are deeply compared at every actual element,
including all four Main cells, metadata, Aux fields and Flag. Ordered message/
removal/despawn/raw-ID arrays are compared before compact range/formula encoding;
first full discrepancies are retained and leave the lane failed. Encodings do
not replace actual reads with expected ranges. Ten PASS cases are freshly recorded
across both nominal schemas.

B's first post-drop attempt fails with actual dispatcher B/code7, and the same
base instance retries the retained sequences. Independent Fast and late
registration are separately observed. Message lag uses the real public reader
API; lifecycle views expose values but no lagged method, so public debug system
trace `missed` supplies that distinct signal. No private saved cursor is read
or invented lifecycle method claimed. Deleted-row records and surviving changed
marks are tested separately.

The initial adapter ordering failure is disclosed: Fast moved into the actual
Delete/deferred-barrier tick to observe pre-trim removals, preserving expected
retention instead of changing answers. Reports distinguish initial-check outcomes,
real reads and scope; they accept no integrated Bend ownership/runtime or performance.

Reviewer independently replayed Motion/removal under a five-second subprocess
limit without writing artifacts: exit 0 and JSON exactly matched its recorded case
after excluding the sweep's wall-time metadata. Other nine cases were inspected,
not independently replayed by this reviewer.

**Heuristic findings: none actionable.** Explicit lane separation and full-field
checks make registration/drop/failure boundaries verifiable.

## Main reference and internal retention supplement — `b2ba594`, `e00d1eb`

Reviewed both adapters, READMEs and coordinator-refreshed evidence. Independently
replayed the complete four-lane main adapter and all five internal cases, each
under a five-second subprocess limit without writing artifacts. Main JSON matched
the recorded evidence exactly; internal case JSON matched after removing only the
sweep's measured wall time. All passed. Recorded adapter/trace/source hashes match
current bytes; both adapters check the pinned manifest commit and reference HEAD.
The internal supplement additionally records the manifest hash.

**Hard violations: none found.** Main observations use actual public system
instances, nested dispatcher, queries/lookups, resource access, command reservations
and Audit calls. Complete ordered payload fields, metadata, memberships, lifecycle
records, messages, capture histories and resource values are deeply compared.
Reservation labels retain actual returned IDs and verify collision/failed-reservation
consumption; they do not replace allocator execution. Diagnostic snapshot copying
does not implement rollback: failed transactional writes/publications and unchanged
receiver worlds are observed through the runtime, while real Audit effects survive
failed B. Retry uses the same B instance, and preflight failures preserve invocation
counts and effects. Returned-owner and regenerated-closure lanes establish TS
capture behavior only, without claiming Bend affine typing or owner guarantees.

The internal supplement explicitly imports internal streams/world APIs and uses
capacity three/zero, actual allocation/deletion, full seed payloads and ordered
retained IDs. It distinguishes repeated boundary reads from dispatcher failure/
retry and does not satisfy public capacity or integrated runtime requirements.
Its complete child invocations have five-second bounds; only directly owned Node
children are controlled. The main adapter is bounded by its documented external
command and was independently replayed with the same complete-invocation limit.

Reports preserve the outstanding Bend runtime, ownership/access negative controls,
index relocation, foreign structural-command policy and performance gates. Public
E11 retention remains separately evidenced; no internal diagnostic or favorable
TS result grants production API, universal refinement or performance acceptance.

**Heuristic findings: none actionable.** Repeated assertions keep complete schema
and publication boundaries explicit; extraction would not materially improve this
bounded reference adapter.
