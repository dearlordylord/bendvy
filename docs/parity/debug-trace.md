## Parent

#1 — full Bend-native bevy-ts core parity.

Remaining-core specification: #37.

## What to build

A developer subscribes to ordered execution observations and unsubscribes/resets them without interfering with ECS execution.

## Acceptance criteria

- [ ] Observe pinned observe/unsubscribe/reset behavior and complete success/skip/failure/barrier/relation/transition-handler trace formats; document normalization of nondeterministic fields only.
- [ ] Run subscriber lifecycle and reset during repeated schedules. No retention participation, reader advancement or owner mutation; disabled debug performs no trace publication work.
- [ ] Detect reached missing-failure/order/disposal mutants; retain description/dump consumers and record enabled/disabled timing and sampled allocation separately.

## Blocked by

- #56

## Delivery and evidence

- Apply the [SPEC reference order](../SPEC.md#implementation-decisions): Rust Bevy architecture and ECS semantics first; Bend types, affine ownership and runtime constraints second; bevy-ts feature inventory and porting inspiration third. Record exact reference commits. Execute bevy-ts comparisons for shared agreed scenarios, not as a blanket behavior authority; preserve approved contracts and record reference differences explicitly.
- Verify through independently authored public application operations, complete JS/Native observations and an actually executed Node TS reference. Test two nominal schemas where composition/authority is extended, and actual independently created same-schema worlds for foreign-handle operations. Preserve arbitrary component families and affine Type payloads; reject undeclared access, cross-schema misuse, writes through read and owner duplication at their actual boundary.
- Freeze exact sources and retain command/input/output receipts, intended negative diagnostics and at least one reached compiling semantic mutant. Earlier task evidence does not substitute for this task's source-current acceptance. Finite traces are not universal proofs/refinement.
- Run the unchanged default #28 paired regression gate before delivering executable core changes. Keep its workload/baseline/statistics unchanged. Add equivalent complete feature-specific TS/JS/Native correctness observations without dropping work; keep boundary and capacity correctness checks. Comparative timing/scaling is qualified on the combined feature workload under #21/#23/#24 and is not a prerequisite for individual semantic delivery. Consequential hot-path changes and detected regressions still require targeted performance investigation. Final JS <= TS and Native <= 0.5 * TS goals remain unchanged. No new numerical tolerance or baseline is approved by this ticket. During CPU contention defer comparative measurements, not semantics investigation; a timeout is inconclusive.
- Use before/after JS call and allocation profiles for a consequential performance change; report allocation sampling separately from physical/RSS memory. Optimize demonstrated bottlenecks while completing features. The scoped #30 amendment is not a global gate waiver; full performance remains under #21/#23/#24.
- Specific new laws require drafting, falsification with planted defects and human approval before ECS proofs. New dependencies and unresolved contract changes require the existing SPEC approvals. Checker default remains five seconds; retain separately approved diagnostic scope without generalizing it.
- Commit verified work directly on master, obtain independent Spec/Standards review, push and post an English governing-issue completion report before closing. Preserve unrelated edits/processes, read-only references and canonical jev. Document any remaining limitation with a concrete owning task; do not close on a feasibility report or silently narrow this acceptance.

## Selected contract and implementation — 2026-10-17

The user selected detached copied trace delivery after the ECS run on
2026-10-16. IO remains outside ECS execution and rollback. Subscribers own affine
state and use reusable top-level pure steps that return that state. Subscribe,
reset and unsubscribe occur between completed runs. Reset replaces state and
returns the displaced owner; unsubscribe returns the actual retained state. The
affine subscription owner supplies identity. This contract requires neither
function equality nor repeated copies of an affine callback. Inline fallible or
reentrant IO delivery is outside the selected API.

Delivery receives copied observations without World, reader or retention
authority. Disabled debug bypasses the metadata fold/catalog, journal, facts,
value projections and publication before doing that work. Enabling debug selects
the trace transport from the ordinary App entry; users keep the same declaration,
rank-polymorphic body and dispatch path. Canonical declarations derive operation
identity and access metadata. Optional display functions on the same binding may
format opaque values; an absent display is represented explicitly as opaque.
Trusted raw callbacks/declarations do not acquire invented operation internals.
The automatic publisher registration rejects opaque or partially described
inventories before mutating the App and returns its existing owners.

Trace records distinguish actual success, skip, admission refusal and failure.
`Ran` alone is insufficient because a failed system can still produce that
schedule observation. Transaction facts distinguish attempted, applied and
rolled-back changes. Deferred facts follow the actual FIFO staging/application
boundaries; opaque raw callbacks remain opaque. Relation facts derive the real
descriptor and full source/target keys. Handler facts preserve actual registered
identity, ordinal, phase and outcome, including selector requirements and the
four distinct phase markers. Reader facts use the actual reading's lagged flag;
trace delivery never consumes another reading or changes a reader position.
A false condition can skip a reader while a later ordinary barrier still runs.

## References and qualified scope

[SPEC reference order](../SPEC.md#implementation-decisions) applies. Pinned Rust
Bevy `ad678262` observes condition/system/deferred boundaries in
[single_threaded.rs](../../.references/bevy/crates/bevy_ecs/src/schedule/executor/single_threaded.rs).
Pinned Bend `a950fd68` [GUIDE](../../.references/bend2/guide/GUIDE.md) separates
Data observations, affine Type owners and reusable top-level definitions from
affine closures. These constraints support detached pure delivery; they do not
imply a JavaScript listener registry or host callback error policy.

Pinned bevy-ts `3040a3b2` is inventory and scoped comparison evidence. Its
`Runtime.ts` callback Set, callback-reference stop, exception/reentrancy behavior
and inline publication do not define Bend subscription ownership. Historical
executed [lifecycle](../../experiments/public-debug-trace/lifecycle-reference-v1/RESULT.md),
[success/failure](../../experiments/public-debug-trace/runtime-reference-v1/RESULT.md)
and [skip/defect/recovery](../../experiments/public-debug-trace/skip-defect-reference-v1/RESULT.md)
comparators retain complete journals/world dumps. Their collector reset is not a
Debug reset API; TS omits schedule.end for the thrown defect. Only finite elapsed
milliseconds were normalized. Those receipts remain historical development
comparisons, not a claim that every current Bend field has TS-identical behavior.
The checked-reader TS false-condition discard versus selected Bend/Bevy cursor
preservation remains a documented reference difference.

The ordinary delivery path has complete independently modeled JS/Native
observations for these bounded consumers:

| Consumer | Qualified behavior and source basis |
| --- | --- |
| Public operation lifecycle (`a913b7242` / canonical execution `a089`) | Fourteen same-World operations cover component/resource/event/relation/machine facts, actual handlers, rollback, delivery/reset/unsubscribe and physical owners. [Current observer adoption](../../experiments/public-debug-trace/deferred-delivery-v1/public-operation-hooks-v1/README.md) adds exhaustive BoundaryFact/ReaderFact rendering; current-source applicability is retained in the integration map and independent final review. |
| Selector handlers (`8ae434d5d`) | Requirements before the barrier, selectors, registered identities/ordinals, all four phase markers, failures/recovery and repeated snapshots. Both nominal schemas have complete JS/Native reports. |
| Reader Context (`1e4a645b5`) | False/no-read, lagged reading, retained failed arguments and retry, family state, cursor completion and subscriber lifecycle. |
| Query reader Context (`73596bd6f`) | Actual indexed component/query owners, semantic failure and retry, full stream/journal/history, all outputs and debug metadata; both nominal schemas have complete JS/Native reports. The merged-current consumer also passes both backends for both schemas; applicability to the other retained consumers is explicitly source-bound. |
| Initial marker (`c583c1770`) | Marker reader identity, repeated initialization and disabled consumption without replay. The corrected independent model derives the source's absent nominal header; the original model mismatch is retained. |

These are finite complete-output witnesses, not universal proofs. Their frozen
sources, historical failures and exact raw receipts remain immutable. Current
adoption must bind every changed reached dependency and every exhaustive
renderer; a previous receipt is not silently relabeled current.

## Remaining delivery gates

Current [authority controls](../../experiments/public-debug-trace/deferred-delivery-v1/authority-v1/)
and [reached mutants](../../experiments/public-debug-trace/deferred-delivery-v1/acceptance-mutants-v1/)
retain genuine affine/type refusals, opaque-inventory preservation and exact
canonical-copy provenance. Missing-failure, delivery-order and displaced-owner
defects now have complete stock JS/Native countermodel matches and full normal
baseline rejection; the relocated positive control matches the complete normal
model on both backends. The selected portable receipts retain every checkpoint.

The [forced-mode workload](../../experiments/public-debug-trace/deferred-delivery-v1/timing-allocation-v1/)
keeps the same 21 steps, 31 checkpoints and ten ordinary runs while selecting On
or Off for the complete replay. Plain full-output qualification passes on JS and Native for both modes; the
reviewed timing/allocation batch completed all 98 commands, including 20 balanced pairs per backend and four separate JS CPU/heap profiles. Its portable archive retains full output/Timer joins, all guards, four profiles and independently recomputed summaries. The existing host Timer includes fresh World
creation, lifecycle, complete rendering and UTF-8 materialization/hash, then
flushes outside the interval. CPU and sampled heap profiles run separately;
profiled duration, sampled allocation, physical memory and RSS are distinct.
Different required trace report bytes are part of this whole-consumer workload,
not an isolated hook-cost measurement. No threshold or baseline changes here.

Independent final source/evidence review found no blocking implementation defect.
The passing unchanged default #28 gate has a portable archive; its verification
is included in the same independent final review, which reports no blocking
implementation/evidence defect. Master delivery e9096051b passed actual commit hooks and CI39003777004; #57 is closed. The completed gate reports NO_CONFIRMED_REGRESSION
for both backends (20 pairs each); this is scoped to its frozen Workshop workload,
not full-feature performance equivalence.
Feature-wide performance goals remain #21/#23/#24. No issue checkbox or closure
is implied by this reconciliation, and no new law, callback policy or dependency
is approved by it.
