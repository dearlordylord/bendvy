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
