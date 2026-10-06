# S-USER-API #26 — implementation ledger

Status: implementation in progress. This ledger is not a completion report.
The user authorized filling the audited gaps through `$implement` after the
independent interface review. Optimization remains paused.

## Implemented boundaries

- Caller-defined typed stores contain independent component columns, including
  affine Type payloads and Data payloads. Closed lenses are trusted schema
  provisioning; they do not grant gameplay access by constructor secrecy.
- Replacement journals retain previous owned components/resources and undo in
  reverse order. Commands and events publish only on successful transaction
  completion; explicit barriers apply structural changes.
- Closed caller runners have an affine function-indexed registration owner.
  Execution validates its world namespace and exact registered metadata.
  Success-only cursor advancement preserves registration identity on retry.
- Deferred despawn has a schema cleanup declaration which drops component
  owners. Liveness-only low-level despawn is not the public integration route.
- Independent affine event readers observe an append-only Data event log.

## Acceptance evidence

All bounded implementation/execution gates pass; final review and delivery are
pending. The final suite is [suite.json](../../experiments/user-api/suite.json).

| #26 condition | Observed evidence |
| --- | --- |
| Independent authored systems | [Blind consumer](../../experiments/user-api/fresh-consumer/README.md) authors and registers movement/damage without library edits or journals; current-source checker/Native/JS and five intended negatives pass. |
| Independent Type families | Main application has five independent families, three with complete owned Arrays; blind application has four affine Array-owning families. Data Armor/tag remain supported. |
| Finite application/reference | [Final backend receipt](../../experiments/user-api/application-evidence-final/receipt.json): both backends match all22 normative frozen TS checkpoints; the23rd separately verifies MissingEntity, unchanged queue and unchanged post-barrier world. |
| Transaction/access/ownership | 31 explicit design/core/system/transaction cases; public provider7 positive/5 intended negative cases and3 compiled programs. Read-your-writes, reverse rollback, earlier commits, retry/cursor identity, foreign rejection and five-column physical despawn cleanup pass in their bounded cases. |
| Connected source/timing | Exact-source replay hashes and reviewed15-row equal-work cohort; no transfer from earlier optimized source. |
| Fresh consumer/next integration | Blind consumer gate met; [query composition #27](../tickets/25-query-composition.md) records its usability gaps. Tower Defense remains conditional on separate integration/performance prerequisites. |

Replay command: `python3 experiments/user-api/run-all.py`. Default Bend checker5s,
codegen30s, host Clang120s and runtime5s for the full application. Bend2.0.35,
Node24.20.0, approved private Clang19.1.7; reference commits match the tracked
`.references/sources.json`. Supporting law approvals/kernel are unchanged.
Finite tests and compiler rejection controls are not ECS proofs or universal
runtime refinement.

The frozen TS failing retry writes both selected Positions before one resource
write/event/spawn and failure. An initial Bend callback failed after the first
row: observations matched, but that timing cohort is explicitly disqualified
for equivalent work. The corrected callback uses the retained final entity
handle. Actual body controls on both backends count failure `[2,1,1,1]` and
success `[0,1,0,0]` (component/resource/event/spawn operations). Final23-point
traces and the equal-work cohort were rerun. Initial invalid JSON and harness
failures, earlier receipts and the mismatched-work cohort remain archived.

[Reviewed bounded timing](../../experiments/user-api/timing-evidence-equal-work/receipt.json)
uses10 complete22-checkpoint applications per fresh process, five processes per
backend in fixed balanced order onCPU8. Medians: TS342.292ms, JS82.926ms,
Native9.034ms; elapsed ratios JS/TS0.24227, Native/TS0.02639. These include
startup/import/serialization, strongly favoring precompiled Native and showing
substantial process noise. They are **not ECS hot-path speedups**, a historical
API regression comparison, qualification or full5×3 acceptance. Raw outputs,
all15 rows, source/tool/artifact hashes and exact commands are retained. Existing
JS parity/Native2× representative-work goals remain open.

## Explicit follow-ups

- Event retention/lag and affine event payloads: bounded log is append-only Data;
  return when independent-reader retention semantics are integrated and tested.
- Arbitrary affine captured callbacks and runtime-extensible heterogeneous
  schedules: current runners are closed templates in a typed static composition;
  return with a repeatable ownership-preserving capture interface and controls.
- Arbitrary typed query tuples and composable capability combinations: bounded
  combinators supply two families and explicit movement/damage/full bundles;
  return after a third independently authored application/query declaration
  demonstrates a need and its access/ownership negatives pass.
- Universal root provisioning authority and globally unique independent factory
  roots: shared affine Factory creates distinct namespaces, but concrete public
  constructors are not protected against a malicious root owner. Callback
  confinement requires separate rank2 tests; no universal authority claim.
- Optimized storage/provider integration and qualified performance: this generic
  component-family boundary requires fresh connected measurements before any
  adoption. JS/TS <= 1 and Native/TS <= 0.5, complete connected gates and the
  full five-family/three-size matrix remain binding and open.

No new ECS laws, proofs, dependencies, compiler/kernel/reference changes or
Canonical Tower Defense edits are authorized or delivered by this task.
