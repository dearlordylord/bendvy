# Public frontier integration review — active

Fixed point:818aca48. Goal: #29/#30/#31/#32/#33/#36. Review is ongoing;
findings and bounded passes are not completion of the six-ticket objective.

## Independent Spec axis — #29

The schedule implementer reviewed the separately authored query slice read-only.
One material finding: initial fixtures used literal Factory namespace roots and
discarded creation-returned factories. The main fixture was revised to retain
actual W.factory lineage, derive its namespace from World and reserve the foreign
handle from the next actual created world. Resolved: source-current root replay passes actual factory lineage and diagnostic entity IDs.
Other inspected count/single/get behavior, payload controls and intended mutant
checkpoints align with the bounded ticket. This is not proof/refinement.

## Independent Standards axis

A separate explorer reviewed additive query/schedule/registration and structural
hooks. One material finding: removal disposal consumes its affine reader even
when a foreign world refuses removal, so the original reader cannot retry and its
registration remains retained. Resolved: rejected disposal returns the same owner. Fresh root JS/Native replay passes foreign rejection followed by legitimate disposal, plus actual retained-log cleanup.

Prepared Column owner recovery and exact selected-source extraction have independent Standards review. The reviewed provider adapter preserves frozen gameplay, declarations, capabilities and full observations; its additional paired cohort retains the same fixed baseline/statistical contract. Final Spec review and root performance receipts remain required.

Independent event review decoded all complete 25-point TS observations and three JS/Native replays, including full capacity-sized retained arrays. No actionable semantic finding remained. Root replay exposed a relative artifact-path bug in the builder; repair and fresh replay are pending. All six issues remain
open until their own criteria, independent review, source-current observations,
unchanged #28 gate and direct master delivery are verified.

## Ordinary-view regression repair

Independent Standards review of Column05b19e3d passes exact bounds, complete affine owner/project/restore, unchanged stamps and unchanged Prepared path. Its unchanged paired gate nevertheless confirms Native regression, so source equivalence is not performance acceptance. A nonempty recursive Type carrier is selected next to prevent flattening Prepared fields into every ordinary Store/World; its runtime costs require actual emitted-code inspection and replay.

## Recursive carrier compiler evidence

Pinned Bend a950fd68 `bend2/comp.ts:930–952` makes recursive ADT layouts BOX;
`969–980` otherwise concatenates constructor fields. BOX materialization/reuse
at1047–1066/2273–2290 has allocation/indirection costs. JS2939–2977 emits direct
objects, so this mechanism only explains Native layout opacity. The selected
Owned(State)/Wrapped(Self) carrier has no empty ownerless case; unseal structurally
threads actual Type owners. Installed exact emitter source is unavailable; fresh
emitted C must verify the installed binary's behavior. This is design evidence,
not performance or runtime-recovery acceptance.

## Local independent review

Separate Spec and Standards reviewers find no actionable #36 source findings
at Local8cc5b3c9. Retained worker replay covers all19 full explicit-TS-adapter
observations, independent actual four-cell owners, retained Local/rolled-back
World failure, actual namespace/registration collision, returned affine arguments,
retry and rejected/valid disposal. Four intended negatives and a reached compiling
namespace mutant pass on both backends. No upstream dedicated Local API or new
exact-law approval is claimed. Final global Column binding/performance/delivery
remain necessary; previous Local receipt predates later storage edits.

### Direct component store transport

Independent Standards review passed component `f37aa4e8758b8f4f4082744f902740d78c9ba8e02616141f8aa1b1be2735d34d` against World `7d394b623b8bb60a3fef7b160bb69af135719edd3008126ee186e190047708f8`. Each of the five helpers expands the previous `with_store` call exactly: same field order, unchanged store operation and `with_store_finish`. Validation, clock advancement, rejection paths and inverse journal closures are unchanged. No source findings; executable controls and performance remain separate gates.

Independent Spec review also passed Component f37aa4e8 against World7d394b62: all five helpers reproduce previous closure application, including unchanged validation/clock/rejection/owner recovery/stamp restoration and World fields. This source-equivalence verdict does not pass the subsequently failed prepared performance cohort.

### Fused transactional stamp/replacement

Independent Spec source review passed Component `4a378ec4aee020d06d04c0ff883911063c75f3a6afe9e278f6969e60d20dfb98`. Invalid handles return MissingEntity and the incoming owner without column/clock access; maximum clock rejects without increment/growth/swap; permitted writes advance before swap, including rejection. Lifecycle precedes ensure/swap and unchanged tx_written captures complete previous owner and original stamp. World/queues and rollback remain intact. Equivalence uses the documented trusted schema-lens contract, not arbitrary non-lens provisioning functions. Runtime controls and regression remain independent.

Independent Standards review also passed Component4a378ec4 under the trusted lens contract: affine incoming/previous owners, lifecycle capture, maximum/advanced clock cases, unchanged ensure/swap/mark and exact World/journal reconstruction. No capability widening or payload duplication. No timing or executable acceptance follows from this review.

### Owner-only selected recovery

Independent Standards review passed Column32a81f54 against unchanged extracted H91f7. The erased Type recursion consumes each owner once through the same ordered Array.set operations; it removes only unused ID accumulation/reversal/projection. Extended equivalence observes four actual physical cells (three complete two-cell Type payloads plus a hole), retaining original ordered IDs separately. Current/past recovery and stamps are unchanged. No speed acceptance follows from this review.

### Owned seek comparison phase

Independent Spec review passed Column5eed33d4: Ready corresponds to old Inspect and Compared retains the actual row fields formerly reconstructed for Choice. Fuel consumption, Nil-before-exhaustion precedence, equality/before/advance and full refusal owners match; history moves each owner once. Current/stamps/remaining and `2*capacity+1` gas remain intact. Old exported seek/SeekPhase are unchanged. Execution controls and measured acceptance remain separate.

### Pending-swap producer

Spec review passed the transition semantics at Column9562d0ff: zero public fuel skips fetch, the first positive fetch supplies pending ownership, zero remaining fuel drains that owner, and each future fetch decrements fuel/ID once. Old phase gas2fuel+1 behavior, initial rows and modulo indexing match. An actionable compatibility finding remains: exported binder changes `+fuel,id` to `fuel,+id` alter quantified argument quantities. Preserve the original exported function type through a wrapper; fresh controls must bind the corrected source. No proof/execution acceptance follows from inspection.

Quantity finding resolved at Columnaca582fa: independent Spec/Standards reviews pass the exact original reusable-fuel/affine-ID wrapper. Positive fuel fetches once and processes precisely its remaining fetches; zero initial fuel skips swap and zero pending fuel drains the last owner. Physical preparation bounds, actual holes/owner chain/stamps and old phase API remain intact. The original explicit function-type client and42paired partial traversal cases are executable gates, not proofs. Fresh current-source backend results/performance are still separate.

### Dense-profile next repair decision (Astra)

Special-case read-only Astra review recommends the bounded view-specific seeker: project the actual selected C and assemble final carrier once, retaining old writer seek, exact fuel/Nil/exhaustion behavior, current-to-past movement and backward recovery. This targets406 temporary Accepted/State/Owned/Prepared transitions per Workshop, grounded by200-app full-output profiling; no performance promise follows. Component.has must retain its admitted family projection invocation: `C -> C & V` does not enforce identity of returned C, and trusted-provisioning documentation contains no universal projection-identity law. Bypassing projection can change later payloads, so direct Col.has substitution is not selected.

Bounded view fusion source reviews pass at Column869091a8: independent Spec and Standards preserve found-only single projection and its returned owner, Nil/fuel precedence, current/history/remaining, invalid/same-row/backward/wrapped behavior, stamps and writer/public APIs. Worker nine-case executable evidence, including51 paired full-owner view observations with legal mutating projection, producer/recovery equivalence, reached omission mutation and ten intended public negatives, is source-bound in `experiments/public-optimized-compose/evidence/view-fusion`. Performance remains a separate gate.

### Getter validation/store fusion

Independent Spec/Standards reviews pass Component36969e29 against World7d394b62 and retained `get_allowed(W.valid(...))`. Exact metadata checks precede live Array.get at index id; only live=True invokes unchanged family lenses/projection. The returned live/component owners and all World fields remain in original positions. Public signatures/quantities and abstract authority are unchanged; no validity caching. The get fixture has48records forming24old/new pairs, comparing full recovered component cells, access and World metadata across handle states/storage/projection variants. Event/command counts are finite observations; unchanged actual owner identity is additionally checked in source. Performance remains separate.

## Shared Bool-array reader scoped review

Independent Spec and Standards reviewers report no actionable findings at Component `0e41557cc6b8101490eaa7f4bf5fbdf896a2646e9b2359d7daf41db6de45988c`. Exact metadata rejection precedes Array access at `id`; the actual returned live owner and unchanged projection-returned component owner are retained. Public quantities and signatures remain unchanged. The source-bound bool-read receipt passes with24 old/new pairs (48 records), matching JS/Native output and a detected recovery mutant. No reviewer builds or timings were run; final regression and full-frontier review remain separate gates.

## Prepared Carrier view scoped review

Independent Spec and Standards source reviews pass Column `b742477e821b3e7807d36bfbe46dc38ef89142dece5c2517d5cb28b64d32070b`. Direct Owned/State matching forwards all seven fields with unchanged quantities, order and bounds/current predicates to existing prepared_view_checked. Recursive Wrapped handling has no depth cap; ordinary view and exported helpers remain unchanged. Projection-returned owners are preserved. No reviewer builds or timing were run; source-current execution and paired performance remain separate.

## Full-frontier Standards checkpoint

Read-only review against master818aca48 found one documentation mismatch: event-reader accepted condition skip advances its cursor, whereas removal-reader skip preserves it. `src/ecs/README.md` is corrected to distinguish them. No new affine ownership/capability/dependency/checker-limit violation was found. Historical task receipts require final common-source replay after repair; no final acceptance is transferred across closures. Reviewed executable inventory closure57f23da8 belongs to the rejected carrier-view candidate, retained as historical source review.

## Special architecture review: cohesive row-owner provider

The third authorized Astra review accepts an additive closed provider seam as the next #30 implementation direction. Existing fixed-Frame Plan capabilities cannot generically convert to another owner context. Preserve old Plan/each and the existing Frame selector first; enter the row context only after selection. Actual family owners and returned projection owners must remain in one shared field per family. Reattach every owner and stamp before the existing World inverse journal runs; one transaction spans the entire traversal. Complete-World operations may use a leave/original-operation/re-enter bridge, but tested optimized gameplay must reach the actual row-owner path. This is reviewed implementation scope, not performance acceptance, universal refinement or production layout selection. Exact source controls and both unchanged paired gates remain binding.

## Fresh feature Spec checkpoint

Independent read-only review finds no new source bug in bounded #29/#31/#32/#33/#36. Their root-current PASS source maps match the restored shared-live closure. Full observations, intended negatives and reached compiling mutants cover their bounded behavior, including distinct event/removal skip and approved Local persistence. Final source freeze/affected consumer replay, unchanged #28 receipt, final integration review, commit/push and issue reports remain required. Feature process timings do not establish product qualification; #33 timing evidence remains limited.

## Owned executor interface checkpoint

Read-only Spec review passes initial owned-compose f90d8b38 against existing each: selector executes before entry, false skips adapters/body, true leaves before error interpretation or tx_finish. Snapshot order, cursor zero, internal error precedence, output clearing and one traversal transaction match. Adapter semantic correspondence (actual owners, journal, error, handle, cursor) is not established by its types alone; fixtures and current-source controls remain required. Production integration must also preserve each_since.

## Finite owned seam source review

Spec review passes fixture2967b853 and executor e6ee80f5: actual prepared/swap route extracts distinct U32-Array and Bool-Array owners; aliases observe3then4 and retain returned owner5. Leave restores both before completion. User failure clears outputs but preserves metadata-neutral projection effects; no write journal is exercised. each_since retains the supplied cursor. Sole ID1/successful extraction remains explicit scope; arbitrary refusal, complete-World bridges, cross-row writes/rollback and broader confinement are pending.

## Owned-plan confinement Standards review

Read-only review passes owned-compose e6ee80f5 and control verifier6448cc0f. Actual closed each instantiations use the positive setup; five negatives target affine duplication, concrete Row specialization, undeclared family access, Read-to-Write and cross-schema Frame mismatch with exact intended type/location diagnostics. Checker limits and final source guards are enforced. Scope remains the finite interface, without generalized runtime recovery or performance acceptance.

## Additive row-column source checkpoint

Spec review passes row-column8b92920b within its low-level scope. Detach retains original lifecycle/swap behavior and distinguishes accepted absence from refusal. Projection retains returned C; every replacement returns the immediately previous owner/stamp. Attach uses its captured ID/column and preserves refusal owners; dirty stamps are restored only on success. Recursive cold wrappers have no depth cap. Required owner/refusal/fuel/replacement controls remain pending, and World validation, clock and journaling remain adapter responsibilities.

## Node profiling methodology review

Independent read-only review passes runner64ff52bd, summarizer04d490cc and canary27371eac for diagnostic attribution. The before generated SHA5617fbf5 matches the exact shared-live benchmark candidate; decompressed profile hashes match receipts. Both separate CPU/allocation runs validate200 complete applications under five-second caps. Collected-object sampling is confirmed by the forced-collection canary. Summaries distinguish sampled attribution from exact physical allocation and label inclusive overlap. The GC drain is observational, not a guarantee of every GC event. These artifacts are the before comparison, not current-provider or performance acceptance.

## Generic owned-family source checkpoint

Independent Spec review passes owned-familydc2de0f5 and row-columnf3846a53: actual live ownership moves on each metadata/live validation; getters preserve projection-returned owners and bridge deferred/mismatched cells. Setters preserve MissingEntity-before-clock, maximum-clock refusal, one successful advancement, every immediate prior owner/stamp and first-error precedence. Public refused incoming consumption matches Q.written. Header/lens round trips, complete reattachment before bridges, exact journal targets/order and attachment-refusal handling remain unestablished until the World consumer and controls execute. No end-to-end or performance acceptance follows.

## Owned-provider benchmark staging review

Independent read-only review passes runner0293eb8b before measurement. Only the listed schema, selected declarations and optional owned-row/reference-declaration helpers enter the candidate stage. Unknown, nested or unmonitored Bend imports reject; exact gameplay/observe imports select archived workload files. Default execution, frozen workload, complete output validation, paired ordering and statistical contract remain unchanged. No performance acceptance follows from this harness review.

## Frozen owned-provider Spec review

Independent read-only Spec review passes current captured-column e7257f7d, restored-row9a1e2535, owned-family1fe504b1, owned-composee6ee80f5, owned-optimized-compose29ed0ce3 and adapters owned-rowsc6867101/owned-declarations49d40e71. The source-bound14pairs,23Workshop checkpoints, restoration mutant and independent2430-pair capture matrix support their finite scope. Raw constructors remain trusted/forgeable; rank2 consumer confinement is separate. The subsequent unchanged prepared gate fails and blocks #30 delivery despite correctness review.

## Matched before/after profiling review

Independent Standards review passes diagnostic methodology. Same runner64ff52bd, Node24.20.0, CPU0,20fresh scopes, settings and five-second caps; all four decoded200-application output sequences match, and decompressed profile hashes pass. After generated578db4f2 matches the failed gate candidate; before5617fbf5 remains exact shared-live. Emitted JS visibly reconstructs work_plan at selector, enter, leave and gameplay capability extraction. This proves construction sites, not physical object materialization counts or causal responsibility. Profiles do not waive either failed endpoint.

## Direct closed-field executor review

Independent read-only source review passes owned-compose1115ffe6, owned-optimized-compose3e651cc4 and owned-declarationsec071b53. Existing Plan implementations are byte-preserved against the first owned-provider source snapshot. New traversal preserves selector-first execution, one transaction, identical recursive fields/cursors, unconditional restoration before success/failure interpretation and final completion. Consumer uses unchanged capabilities, selectors, adapters, preparation/recovery and gameplay, bypassing Plan projections. Fresh checker/runtime/generated-code and measured gates remain required.

## Zero-family and callback-fusion scoped reviews

Read-only source review passes adapterbb0e7362: identity Frame preserves transaction/handle/error/cursor; Empty/Contradictory keep the ID, selector/body and preparation/recovery; hot routes and legacy Plan remain. The subsequent gate fails both endpoints. Separate design/canary review permits runtime read_applied/get_applied/set_applied callback fusion preserving affine owners and exported APIs, with old field helpers retained. Canaryda859df7 matches original returned-owner/mutating projection behavior on JS/Native. Opaque template match is rejected by the unchanged checker. No performance acceptance follows.

## Exact runtime capability-fusion source review

Independent read-only review passes capabilitiesbf94887b against original91c0cdc0. New applied helpers invoke the selected callback exactly once on the actual affine context and return its current owner unchanged; setter consumes incoming once. Closed-template public signatures and old field helpers remain, and the value/send/action/request suffix is byte-identical. Fresh source-bound provider, mutating-owner comparator, legacy/direct/public controls and reached mutation pass. Measurement remains required; no layout/record-allocation improvement is claimed.

## Indexed metadata compatibility decision

Task-local unchanged generic/nominal exhaustive consumers reject added variants; the failure is retained, not waived or called compatible. Independent architecture review permits explicit raw-sum API evolution at this experimental provisioning boundary: old constructor shapes/legacy behavior stay, external exhaustive raw matches require indexed cases, and universal raw-pattern compatibility is withdrawn. Actual archived Workshop and retained public consumers have no exhaustive Column/Prepared matches; unchanged Accepted/Rejected outcomes and all their exact inputs must replay. A separate concrete IndexedColumn conflicts with existing Family/lens/command types and would require broader redesign. Indexed integration must preserve all semantic/profile/scaling/unchanged paired gates; no package/law/proof/threshold approval follows.

## Indexed ordinary checkpoint review and retained consumers

Independent read-only review passes Column7b8ed4ad, indexed-lifecyclee997f3b0 and captured-column6260b164 for ordinary indexed ownership, bounds, disjoint exceptional IDs, metadata growth and projection-returned payload restoration. The ordinary comparisons, affine negative and reached wrong-index/restoration mutations cover this stage only. Indexed prepare is identity and capture returns Unavailable; prepared/capture acceptance and schema opt-in remain pending.

Root reran `python3 experiments/user-api/run-all.py` against this closure without changing authored inputs. All eight suite commands pass, including the fresh consumer, intended negatives and23 complete application observations on JS/Native. `experiments/user-api/suite.json` and source-bound child receipts record this replay. These results do not establish performance acceptance.

Scaling methodology review found a copy-before-hash source-binding race. The runner now snapshots before copying, compares root/staged inventories immediately after copy and before builds, and rechecks generated workload bytes at final acceptance. The first execution is retained at `.artifacts/indexed-scaling-dense/receipt.json` as ERROR: the authored fixture violates Bend match binder order at second_write. No scaling timing or gain is established by this failed attempt.


## Indexed scalar-array projection review — 2026-10-07

Independent Spec and Standards reviewers approved the isolated `array-view-indexed-probe/view.bend` (SHA `a1a75b24aaa61596f7d4b8d9e62b0264f32bda2d995c2c1bce81f4329c6b7d0c`) for selected schema promotion. Both verified retained source/output hashes, 576 complete pairs per backend, three bounds refusals, and reached omission/order mutations. The size-derived path visits every physical cell and threads the actual returned Array owner; logical prefix remains separate. Arbitrary raw helper capacities and irregular mathematical arrays are outside this guarantee. Transaction rollback and factory construction require the separate application gate. No performance acceptance follows.

Standards identified a robustness limit in the isolated runner: normal inputs are built live with only a final inventory guard, and mutant copies lack per-step inventory guards. The frozen-source receipt remains valid; do not reuse that runner with concurrent source writers. The promoted application verifier must retain copied-source inventories and per-step normal/mutant guards.

Promoted-source Standards review passes schema `0903e05d7755c4ede468e2b60da505edf95c5db52b7adf69704ce651b49bb117` and provider runner `9238dd419bc96793f6fd4287fb4cc0d63bbac144203dc5005c298b6ad3527fed`. The collector is textually equivalent after identifier renaming/fallback redirection; separate prefix and exactly five indexed-empty calls are preserved. The runner stages source-current inputs unchanged, checks inventories before each operation/final cleanup, and permits only the recorded restoration mutation. Application results and performance remain separate gates.


## Final bounded-feature Spec review

Independent review of #29/#31/#32/#33/#36 identifies no blocking functional defect and verifies current receipt source hashes for query, events, removal, schedules and Local. Their bounded contracts, exact errors, cursor policies, rollback and affine ownership controls align with the governing issues. Trusted schema/dispatch adapters and separate stream retention domains remain explicit.

The reviewer corrected an initial gate-scope error after inspecting the actual contract: the passing unchanged default #28 gate satisfies these five tickets' shared regression requirement; the additional prepared-adapter gate is specific to #30 and remains failed. All 34 default receipt source hashes match current files. Feature timing and commit/push/issue reporting remain required. This does not waive #30 or full product qualification.

Fresh #29 feature-specific timing validates every full output for five samples/backend: medians TS 86.350711 ms, JS 31.353948 ms and Native 3.461939 ms. Exact outputs/source/commands are retained under `public-query-contract/evidence/indexed-core-timing/`. These whole-process diagnostics are not a qualified hot-path comparison.

Standards supplement withdraws its initial #31 freshness finding: the fresh receipt is nested under `public-event-readers/evidence/indexed-core-current/evidence/`. Current source hashes and all 52 retained hashes match. Three complete JS/Native runs match 18 main plus seven late-registration TS observations; disposal/registration-swap extensions, three reached mutations and ten prior public controls pass. No remaining bounded-feature functional or freshness blocker is identified. Verifier source-freeze limitations remain documented; product qualification and #30 acceptance are separate.
