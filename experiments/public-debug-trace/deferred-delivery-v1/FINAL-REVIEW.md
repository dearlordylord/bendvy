# Issue 57 independent final review

Status: code and completed measurement/regression review complete; final acceptance pending master delivery gates below. No blocking implementation defect found in the reviewed candidate. This is one Spec/Standards review with an evidence addendum reserved for the pending results. It does not close #57 or establish full-core parity.

## Subject and authority

Reviewed on 2026-10-17 against the actual open [issue #57](https://github.com/dearlordylord/bendvy/issues/57), `docs/parity/debug-trace.md`, `docs/SPEC.md`, `docs/check-policy.md`, and `CODING_STANDARDS.md`. The selected contract is copied post-run observations with pure reusable subscriber steps, external IO, affine state returned on reset/unsubscribe, and lifecycle changes between runs.

The source subject is `e5da99c4d8e0eec701e733ba255779d5ad0e26fd` against `947ad64a7ee80937b2e19354f60dc60d9aeaa3df`. Independently compared all 79 owned root `.bend` files with their candidate commit blobs: exact equality. The root master worktree contains the materialized subject; its HEAD alone does not identify those bytes. Root allocator helpers retained from #38/#59 and the two pending-command carrier annotations in `restore-apply.inserted` and `restore-world.progress_join` are part of the integration reviewed here.

`DELIVERY-MANIFEST.json` SHA256 `e2d47d769d9e56136139600eba007a7d94858f8667ebf173c1a81f4f90425193`, together with `DELIVERY-PATHS.txt`, binds the selected delivery. `/tmp/bendvy57-master-materialization.json` and `/tmp/bendvy57-master-delivery-materialization.json` identify the root materialization. Source and destination provenance does not turn an execution in another worktree into a root execution.

Verified the actual reference HEADs, in governing order:

- Rust Bevy `ad678262ce53b5d142fe49ee5e08caff6f00ab60`: `single_threaded.rs` evaluates conditions before dispatch and applies deferred work at explicit executor boundaries.
- Bend `a950fd683c0d76f09794078e6174fe98a1492876`: `guide/GUIDE.md` distinguishes copyable Data, affine Type, affine closures, and reusable top-level definitions.
- bevy-ts `3040a3b2a3f28fa8554d856f9ccb6bf5433fa334`: `Debug.ts`/`Runtime.ts` supply inventory and scoped comparison. Inline callback publication and reference-based listeners are not Bend ownership requirements.

## Spec assessment

`execution-trace.bend` carries detached Data events and no World, stream, reader, or registration owner. `reset` returns the actual displaced state; `unsubscribe` extracts the actual retained state. `deliver` folds the supplied batch in order through a reusable top-level step. `both` composes affine owners without a fixed subscriber bound. This implements the selected pure API; it supplies no automatic IO finalizer or Rust Drop guarantee. Disposal IO remains the caller's responsibility after owner return.

`ordinary-app-execution.run`, checked schedule context, and handler context select transport while preserving the ordinary declarations and rank-polymorphic bodies. `ordinary-app-execution-run`, resource/component runners, and the shared schedule/provision and `machine-handler-engine` paths reach the same gameplay body and transaction mutation. No second traced gameplay engine was found. Canonical registration derives metadata; automatic opaque publisher registration checks completeness before mutating the App and returns existing owners on refusal. Optional display projects a value while returning its affine owner; opaque observations do not restrict component/resource/query storage to Data.

The Off branch precedes metadata fold/catalog creation. It passes `Facts.Off` through the shared dispatch, bypassing trace journals, identity/clock scans, publication, and display projections. Relation, reader, handler, and value recorders branch before constructing observations. This is a source finding, not a claim of zero host overhead or a measurement of isolated hook cost.

Completion/error comes from actual dispatch results, while `Sch.Ran` supplies merge position. Refusal, skip, failure, success, and schedule admission are distinct. Transaction settlement marks tentative facts applied or rolled back. Deferred commands retain affine payloads in one carrier and execute in the existing FIFO application order; traced barriers observe that application rather than inventing successful application at staging. Trusted raw callbacks remain opaque.

Relation observations use actual descriptors and complete namespace/index/generation keys. Handler observations take identity and ordinal from retained registrations and distinguish exit, transition, enter, and initial-enter. Reader facts use the actual `Ev.Reading.lagged`; delivery performs no second read or cursor advancement. Checked false conditions preserve the selected cursor behavior while subsequent barriers can execute.

The historical Node lifecycle/runtime/skip packets remain scoped reference executions. Collector reset differs from the selected Bend reset API, TS's thrown-defect journal omits schedule.end, and the false-condition reader difference is documented. Only finite elapsed time normalization is claimed. No new observable contract, law, dependency, or numerical criterion is introduced by this review.

## Standards assessment

No blocking Authority, Affine ownership, Candidate execution, or Handle provenance violation found in the inspected APIs and evidence. Arbitrary Type state and payload owners remain separate from copied Data observations. Affinity alone is not used to claim owner preservation: direct implementation inspection and complete lifecycle/countermodel observations support that narrower claim.

The source spans many carrier annotations and long erased signatures, but these preserve established world and declaration types. They do not justify a new restriction, duplicate engine, or compatibility layer. The restore adaptations replace only the changed pending-command carrier; retained allocator behavior is separately checked by the affected restore consumer.

Evidence is finite executable observation and source-path applicability, not universal refinement. Historical unsuccessful attempts remain visible. No initial sparse-worktree hook success is attributed to the candidate commit.

## Independent evidence checks

Performed read-only offline checks on CPU 8. No compiler, JS/Native ECS consumer, Node TS reference, or benchmark was launched by this reviewer.

- Verified embedded object compression hashes, uncompressed hashes, and lengths in all seven selected trace runtime packets: query (597 objects), integrated query (574), mutants (652), initial marker (568), reader Context (919), selectors (694), and authority (633).
- Ran the existing retained `verify.py.source` for integrated query, authority, mutants, initial marker, and reader Context, changing only the local `OUT` path in memory. All passed their isolated source/plan/receipt/raw-output joins and regenerated complete independent model outputs. External installed ELF identities remain distinct from archived generated Native ELF objects; `backendReplay` remained false.
- Integrated query: four Workshop/Garden JS/Native roles, complete 31-checkpoint observations. Model hashes: Workshop `b4506e5d2c28c94b4ed692be6334746d4d8625f1516caf3eadb7cb52d4eb2f8c`; Garden `fb40f38752d905196952ec48d5ed4b9aa747aab74d2014b95892bdbf87778998`.
- Authority: one generic positive plus six intended refusals. Three quantity refusals are qualified by primary affine diagnostics separately from three primary-type helper checks. Opaque-registration preservation has four complete nominal/backend observations. No rejected helper-only claim is promoted to success.
- Mutants: canonical relocation inverse and three sole-line mutation inverses pass. All six mutant backend roles equal their complete countermodels and reject the whole normal output. The two relocated positive roles equal the complete normal model. Missing failure, delivery order, and displaced-owner defects are reached; no universal mutation-completeness claim follows.
- Ran the selector packet’s existing `verify.py`: PASS, four complete Workshop/Garden JS/Native outputs, 3,694 source/oracle joins and 22 raw-output joins. Its original INCOMPLETE source failure remains unqualified.
- Initial marker and reader Context verifiers preserve the original INCOMPLETE attempts and their source/model repairs. The corrected initial oracle retains its actual unlabelled framing; no nominal header was fabricated.

Scoped reuse was checked against `integration-applicability-v1/SOURCE-APPLICABILITY.json` and its materialized successor, plus `public-operation-hooks-current-v1/SOURCE-BASIS.json`. Selector, reader, and initial consumers retain their full oracles only under the enumerated exact-body and reached-branch conditions. The public fourteen-operation successor adds exhaustive BoundaryFact/ReaderFact rendering without changing the reached existing cases. Its changed system wrapper preserves `tracked_outcome`; new marker APIs and bundle engine branches are not reached by that consumer. Independently verified all 137 integrated literal source pins for each public nominal entry against root. The integrated allocator binding is the appended-helper version; the older top-level mapping is historical. These are qualified applicability arguments, not relabelled current runtime receipts.

The integrated restore JS/Native consumer and the public pure-source check are separate root receipts (`/tmp/bendvy57-integrated-restore-workshop-first-actual02` and `/tmp/bendvy57-integrated-public-source01.{stdout,stderr}`). Root execution must retain its actual source bindings; the public source check alone does not establish backend acceptance.

## Remaining gates

1. Retain the completed timing/profile archive and #28 archive with exact source bindings. Same-review addenda below qualify the observed finite recording and regression gates; portable verification results remain source-bound.
2. The unchanged default #28 and its portable archive completed with NO_CONFIRMED_REGRESSION. Same-review addenda below record independent raw/source/statistical and archive checks.
3. Complete actual master integration hooks, commit/push, and CI. Initial candidate sparse setup lacked hooks; no previous hook PASS substitutes for this requirement.
4. Reconcile these results and any remaining source-current joins in this same review before final acceptance. Keep #57 open until its delivery and English issue report requirements are satisfied. Combined performance goals remain under #21/#23/#24.

## Same-review timing addendum

The admitted batch `/tmp/bendvy57-onoff-measurement-first-actual02/receipt.json` is COMPLETE_FINITE_TIMING_AND_SAMPLED_PROFILES_NO_PERFORMANCE_VERDICT. Its plan SHA256 is `00513b80f7158e21b6c23a519d5df729abee4aced64ab86b2a8601972f71880f`, with launch review `5d521632a`. Inspected the actual binding and Timer call path using the benchmark-checklist guidance. Timer begins before fresh World creation, runs the full lifecycle, materializes/hashes UTF-8 inside the interval, and flushes afterward. The separate profiles include startup/import/IO and use the existing profile script.

Independently joined the plan hash, 98 successful command exits, raw log hashes/lengths, 92 complete non-artifact stdout observations against their full independent oracles, 88 timer byte/digest reports, 197 guard hashes, and all four recomputed 20-sample summaries. Parsed and hash-verified the four separate CPU/heap profile files. No backend was replayed.

| Backend | Mode | Samples | Median ns | Range ns |
| --- | --- | ---: | ---: | ---: |
| JS | On | 20 | 36,807,605 | 29,287,791–98,893,884 |
| JS | Off | 20 | 29,368,854.5 | 24,872,420–51,206,186 |
| Native | On | 20 | 24,664,710 | 23,216,115–97,761,333 |
| Native | Off | 20 | 18,505,824.5 | 17,398,189–53,085,661 |

These are descriptive whole-consumer measurements with balanced randomized pair order and retained contention. On renders 259,387 bytes; Off renders 184,790 bytes. They are not an isolated hook-cost comparison, a regression threshold verdict, or a JS/TS or Native/TS claim. CPU sampling uses 100 microseconds; heap sampling uses 32,768 bytes and includes collected objects. Sampled allocation is separate from physical allocation and RSS. The finite recording requirement is met by the inspected receipt; the archive and #28 are reviewed in the addenda below. Actual master hooks and CI remain open.

## Same-review portable timing addendum

Timing archive commit `63c25f8e5936b357c2c5afcd05022fc4e2073e91` owns 784 paths under `timing-allocation-v1/runtime-v1/actual-attempt01`. Verified manifest SHA256 `803fa29dcf285c8578a08b4c0a70e3ad002231a8c764582d54bdea6e13391982`. All 405 archived measurement members match the previously reviewed live raw logs, receipts, profiles, and generated artifacts byte-for-byte. Four separate plain correctness prerequisite roles remain explicit. The retained verifier also checks generated Native ELF objects separately from installed external ELFs and preserves the blocked original unexecuted plan. The retained offline verifier passed on CPU 8: 145,656 measurement pin joins, 98 commands, 197 guards, 88 timer outputs, four profiles, and four focused negative controls. All four plain complete independent model observations were regenerated. The package contains 1,038 bindings, 780 objects, and 22 external ELF identities. No backend replay occurred. Original telemetry shadowing and the repaired global binding are checked separately; the original blocked plan remains unexecuted.

## Same-review default regression addendum

The actual combined integration completed `.artifacts/trace57-regression-v1/receipt.json` with NO_CONFIRMED_REGRESSION, SHA256 `980cc973372467249119ed4ad0b8641848c65a154d040f68a1c8b401bc4a697b`. The contract SHA256 is `c0e13575f6e4d25ca8ca669936eef39c93a66b57ac1e4bfa42186f6f2d58bb6a`; runner, decision function, and contract remain byte-identical to `947ad64a7`. No provider variant or injected slowdown was selected. Tool versions recorded are Bend 2.0.35, Node 24.20.0, and clang 19.1.7.

Independently checked 339 root input pins, 383 staged source pins, 12 generated artifacts, and all 123 successful command exits. All 340 staged candidate ECS files match the root integrated source. The 110 retained stdout observations match their command hashes and each contain ten complete canonical Workshop observations; the runner's existing approved foreign-collision-reference exclusion remains unchanged. Recomputed the exact paired sign tests and Holm decision from all twenty pairs per backend.

| Endpoint | Slower pairs / non-ties | One-sided p | Median paired ratio |
| --- | ---: | ---: | ---: |
| JS | 9 / 20 | 0.7482776641845703 | 0.916189499257817 |
| Native | 5 / 20 | 0.9940910339355469 | 0.8543858291861305 |

This passes the unchanged #28 decision for its frozen Workshop whole-process workload, including startup/output. Retained contention and broad sample variation preclude a speedup claim; these ratios do not qualify full trace-feature scaling or the final JS/TS and Native/TS goals. Those goals remain under #21/#23/#24. Master hooks, commit/push, CI, and the governing-issue delivery report remain open.

## Same-review portable regression assurance

Portable #28 commit `2c68de6e56b42f787842ed01bdf541e9ab5fdae1` owns six files in `regression-v1`. Verified MANIFEST SHA256 `274041ff9fb9011d96d627da4bc63c1deff79e7dfec999cf502110e90c8343c4` and EVIDENCE.zip SHA256 `bfdb92efdb004c12dc71e146860b0c0f27e277dbd7386efa586f14c97aa8ee49`. The archived receipt equals the previously reviewed live receipt. All 508 archived cohort files match their live counterparts byte-for-byte.

Ran the retained offline verifier on CPU 8: PASS, without backend replay. It verifies all 882 archive members, 123 successful commands, 110 complete compressed outputs containing 1,100 applications with 22 checkpoints each, and twenty balanced pairs per backend. It joins 339 current-source bindings, 33 reference bindings, 29 baseline and 354 candidate staged-source bindings, twelve artifacts, and two archived generated Native ELFs. All four fixture migration files and five syntax edits reconstruct exactly. The archived decision function recomputes NO_CONFIRMED_REGRESSION with the previously reviewed endpoints. The coordinator contention note remains explicitly an observation, not measured host telemetry or a per-CPU quiet claim.

No blocking code or evidence defect remains in this review's supplied subject. Actual master hooks, commit/push, CI, and the governing-issue delivery report remain delivery requirements. Final delivery inventory must omit the ignored generated Python bytecode identified during staging; the immutable archived execution plans and receipts retain their original bytes. This inventory correction does not change the reviewed executable subject.
