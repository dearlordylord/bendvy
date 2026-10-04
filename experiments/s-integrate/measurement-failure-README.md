# Dynamic failed-transaction workload

This package implements the frozen `measurement-reference.mjs::transactions` workload through actual `D.tick`, retained Registry/Local/Run/Audit owners and rank-2 nominal transaction operations. It is finite executable evidence, not a universal refinement theorem or performance acceptance.

The immutable shared closure originates at `9bdcb55fd654fffbff9a8310b466f909f23ce809`; lifecycle fixture dependency was cherry-picked from root `bbab319` as `99eeae8`. Own initial modules are commits `86c51e3` and `8a903a0`; final source hashes in the evidence identify subsequent implementation precisely. This worktree does not claim verification of later root shared-module changes.

`measurement-failure-DRAFT.md` was persisted before implementation. Callback bodies receive fresh abstract Tx getters/setters, resource access, typed reservation, Ping and Audit functions. They never receive World, inverse journal or rewind authority. Private automatic inverses restore both writes and Ledger while allocation remains consumed; full owned reservation payload is observed before failed staging is discarded. Real B reader failure preserves its cursor, so retry sees the same batch. Independent Publications is a distinct registered instance.

The observer reads every returned row and all declared four-cell Main/Aux arrays, metadata, flags, full Ledger and each current/historical reservation lookup. It observes actual OwnWrites, typed reservation bundles, Audit effects, Local capture counts and actual frame/publication clocks. The oracle checks every field against source-derived inputs and matches fresh TS audit hashes, complete read batches, diagnostics and effects. Compact evidence is produced only after validating complete actual output; no range constant substitutes for a query. Array claims cover these concrete depth-two payloads, not arbitrary hidden array leaves or pointer identity.

Run from this worktree:

```sh
taskset -c 7 python3 experiments/s-integrate/measurement-failure-build.py
taskset -c 7 python3 experiments/s-integrate/measurement-failure-run.py
taskset -c 7 python3 experiments/s-integrate/measurement-failure-bounded.py
```

Every checker, actual executable and fresh Node reference has a five-second limit. Code generation has 30 seconds and clang compilation 120 seconds, separately. The t05 command helper kills the task-owned process group on timeout. The initial O0 correctness sweep ran with default affinity; its possible overlap with other sampling is a limitation. Supplementary runs pin CPU7 and descendants. No unrelated process is modified.

Two genuine oracle failures were corrected without changing the TS expectations: repeated Host fixture labels initially resolved old p/q/r handles, and an out-of-dispatch seed lacked the reference Seed system's clock advancement. The dedicated wrapper now replaces each label using the actual escaped handle. Seed executes a closed rank-2 commands callback in actual `D.tick`, using a temporary affine owner wrapper for the runtime count. No clock offset or manufactured handle is added. Generic repeated-label binding behavior remains a follow-up outside this owned package.

The original report records complete Native O0/JS parity for both 64-entity, 64-iteration cases, and actual Native O0 five-second failures at 256/1024. Supplementary evidence records independently attempted large JS, O3 and compiling decision-path mutants. Compilation/timeouts never count as semantic mutant kills. The checker banner is a static check here, not an ECS proof.

Equivalent seven-repetition steady timing and RSS remain unavailable: Bend emits full diagnostic rows and events, while TS emits compact summaries. A ratio would compare different serialization work. No timing threshold or RSS claim is adopted. #20 follow-up: add a quiet adapter that still executes all original operations/queries/lookups and validates every declared field, validate its full digest/result against both existing actual diagnostic traces, then measure seven repetitions under the same five-second limits using the corrected standalone C RSS launcher. Return condition: equivalent complete work on all prescribed schema/count cases and fresh semantic mutation controls. Separate optimization is needed for cases that exceed current runtime/build limits; do not reduce iterations or remove retained failed handles.

Dispatcher reader interest currently conservatively includes lifecycle even in the Ping-only measurement callback. This is retained and documented, not a claim of an optimized production Ping-only reader API. Canonical Tower Defense and source references remain unchanged.

Observed bounded matrix (64 iterations throughout):

| Backend | Motion64 | Health64 | Motion256 | Health256 | Motion1024 | Health1024 |
|---|---|---|---|---|---|---|
| Native O0 | full equality | full equality | runtime5s | runtime5s | runtime5s | runtime5s |
| JavaScript | full equality | full equality | runtime5s | runtime5s | runtime5s | runtime5s |
| Native O3 | full equality | full equality | full equality | full equality | runtime5s | runtime5s |

O3 compilation passed within the separate120-second build limit. Full row-field validation covers16512 rows per64 case and65664 per256 case, plus all resource, reader, capture, reservation, lookup and own-write observations. Each source reference was freshly run within5 seconds. No backend acceptance is claimed for a timed-out case.

Four compiling JS mutants are checked on both complete64-entity cases: inverse replay order leaves B's first value11 instead of1 after failure; second-write+10 leaves11 instead of31 after retry; the fourth reservation cell40 replaces400 and is detected on actual materialized r; failed reader completion consumes the batch and retry reads[] instead of code0. Original CPU7 JS controls are independently rechecked. Evidence is segmented: initial original NativeO0/JS64 stage; independent largeJS/O3 stage; mutation replay with precise first-difference diagnostics. The original source/core hashes remain identical across these stages. The first mutation run already detected all eight counterexamples; the replay strengthens diagnostics and pins complete original controls. The original report's oracle hash identifies its earlier diagnostic formatter; the replay records the updated formatter, whose comparisons and expectations are unchanged.

## Joined-source coordinator audit

Every actual import hash in the completed `213af35` package matches the joined
root at `d1a976f`; its earlier base label does not imply different runtime bodies.
The coordinator independently verified that full closure and all eight actual
JS semantic witnesses. Native O3 original controls remain separate from these
JS mutations; the joined main gate already supplies its own twelve Native/JS
mutants. No Native dynamic-workload mutation sweep is inferred.

A fresh isolated root build is recorded in
`measurement-failure-source-current-evidence.json`: its byte-identical import
closure hits the five-second checker limit before backend generation. The
record is BUILD_BLOCKED, not a semantic mismatch or a passing reproducibility
gate. Earlier completed checker/build/runtime evidence is preserved at its exact
revision; no timeout was increased and no failed attempt was replaced. The
quiet equivalent-work adapter and stable compilation under the current budget
remain explicit #20 return conditions. Full-core performance remains unmet.
