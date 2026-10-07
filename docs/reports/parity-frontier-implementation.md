# Public parity frontier implementation — active

Objective: implement #29, #30, #31, #32, #33 and #36; the objective has not been
reduced to completed subsets. Baseline master:818aca48. Work is direct on master;
no issue is closed while its acceptance gates remain incomplete.

| Issue | Active ownership / reached state | Required next evidence |
| --- | --- | --- |
| #29 | Pre-repair root replay PASS: exact reference diagnostics, full Type payloads, intended negatives and JS/Native mutants | Serialized feature timings, final review, #28 and delivery |
| #30 | Prepared provider runs complete Workshop plus aliases/rollback/reverse/growth/refusal controls; original extraction and specialized producer separately checked | Root complete replay underway; independent review, default and prepared-provider #28 cohorts, feature timing and delivery |
| #31 | Complete 25-point reference arrays agree in worker JS/Native replays, including capacity/lag/late activation; independent source/output reviews pass | Fix relative output-path handling, root replay, feature timing, #28 and delivery |
| #32 | Pre-repair root replay PASS: Type families, failure/retry, foreign disposal owner return, cleanup, negatives and both-backend mutant | Final review, serialized feature timings, #28 and delivery |
| #33 | Pre-repair root replay PASS: ordering/conditions/barriers/failure preservation, negatives and both-backend mutants | Feature timings, final review, #28 and delivery |
| #36 | Local persistent-instance policy selected under explicit blanket task preapproval; worker actual 19-point TS/JS/Native replay passes; independent Spec/Standards pass | Final global source replay, feature timing and delivery |

Version/guide read before Bend work: Bend2.0.35; read-only Bevy/bevy-ts/Bend
reference HEADs match the tracked manifest. Checker5s, emission30s, approved
private Clang19 compilation120s, runtime5s. No new laws/proofs/dependencies or
compiler/kernel/canonical-defense changes. Registration canary supplies
infrastructure evidence only, not another issue's acceptance.

Concurrent correctness builds are permitted; performance cohorts will run after
source stabilization without concurrent worker profiling. Existing #28 frozen
Workshop source baseline/contract remains unchanged. Its receipt must bind to the
actual integrated sources; new-feature timing is separate evidence.

Event/removal retention domains must not share an untyped cursor or permit event
trimming to discard removal backlog. Current additive opt-in stream runtimes
must explicitly preserve that boundary; #35 later integrates composed readers.
This does not waive the complete behavior requested by each current slice.

## Initial integrated regression gate

Unchanged #28 cohort fails Native: 19/20 slower pairs, median paired ratio 1.2785579, exact p=0.0000200272 (Holm cutoff0.025). JS12/20, ratio1.0723547, p0.2517223: no confirmed JS regression. Retained complete receipt/output: `benchmarks/evidence/frontier-initial-regression`. This is a failed delivery gate; no baseline/allowance change is made. Diagnose ordinary Column dispatch and tail-safe event append before fresh acceptance.

Copied-stage diagnostic: unchanged full observations with original recursive append produce Native median24.30ms versus current25.07ms and baseline19.63ms (five raw samples each). This implicates other changes; it is not causal proof or an accepted keep. Generated C grows from4,234,989 to8,968,453 bytes; inspect Prepared dispatch/temporary owners. No compiler flags or baseline changes. Receipt: `benchmarks/evidence/frontier-initial-regression/world-append-diagnostic.json`.

First regression repair: ordinary Column.view now takes/projects/restores the affine Array directly, preserving the original ID bounds and stamps. Prepared path remains unchanged. Column SHA05b19e3d is frozen for fresh #28; final acceptance requires replay on this repaired closure, not earlier receipts.

Ordinary-view repair still fails unchanged #28: Native20/20 slower, median paired ratio1.271226, p0.000000953674; JS13/20 ratio1.021934, p0.131588 unconfirmed. Full receipts/output retained in `benchmarks/evidence/frontier-ordinary-view-regression`. Next diagnosis addresses flattened union width; no failed cohort is discarded or counted as acceptance.

Existing #26 scoped API suite independently re-executed: PASS (design/core/system/transaction, provider, fresh consumer, actual TS and JS/Native application). Its source snapshot precedes the final carrier repair; preserve receipts and rerun final relevant gates before delivery.

Boxed carrier319747b0 + empty-publication World7d394b62 + frozen Local8cc5b3c9: unchanged default #28 PASS (`NO_CONFIRMED_REGRESSION`). JS8/20 slower, median paired0.991487, p0.868412; Native12/20, ratio1.019137, p0.251722. Full receipt and every output: `benchmarks/evidence/frontier-boxed-default`. This clears the ordinary frozen-workload guard only; prepared-route cohort, feature-specific timings and final exact-source correctness remain required.

Boxed prepared provider fails the same reviewed baseline comparison: JS20/20 slower, paired ratio1.212958, p0.000000953674; Native18/20 ratio1.072811,p0.000201225. Retained in `benchmarks/evidence/frontier-boxed-prepared-regression`. Direct same-current Prepared projection is the next scoped repair: removes two swap/temporary-state passes while preserving exact existing bounds/owners/metadata. New Columnca25da42 requires fresh source-bound controls and both default/provider gates.

Direct same-current projection ca25da42 still fails reviewed provider gate: JS20/20 slower, paired1.198270,p0.000000953674; Native17/20,1.056763,p0.001288414. Retained in `benchmarks/evidence/frontier-direct-prepared-regression`. Actual source-bound constructor instrumentation identifies745 intermediate State evaluations and406 restoration wrappers per complete Workshop, suggesting a direct seek/project/restore path. These counts are not bytes or performance acceptance.

### Immediate component callback repair

The cohesive prepared cohort remains rejected: JS median ratio 1.166645 (19/20 slower) and Native 1.062192 (18/20 slower). Its receipt and complete output archives are retained in `benchmarks/evidence/frontier-cohesive-prepared-regression`. The next bounded repair replaces five immediate `World.with_store` runtime closures with direct owned World destructuring and the existing `with_store_finish`; validation, clock order, column operations and journal inverse closures remain intact. The component checker passed under the five-second limit. Fresh integration controls and independent review are pending; no performance acceptance is inferred.

Direct component transport passed fresh six-case JS/Native observations, finite producer equivalence, reached recovery mutation and independent Standards/Spec source reviews. Runtime closure entries fell 4625 to 3262, with unchanged complete observations. Its prepared paired cohort still fails: JS ratio 1.1605769 (20/20 slower, p=9.5367e-7), Native 1.0361297 (16/20, p=.00590897). Complete receipts/output remain in `benchmarks/evidence/frontier-component-direct-prepared-regression`. The next scoped repair fuses transactional lifecycle lookup and replacement while preserving error precedence, clocks, affine previous payloads and the existing inverse journal. No acceptance gate is waived.

### Fused transactional write transport

Component `4a378ec4aee020d06d04c0ff883911063c75f3a6afe9e278f6969e60d20dfb98` preserves public helpers/journal and removes a redundant lifecycle/replacement World/provider round trip. Seven source-bound cases pass JS/Native, including full paired old/new foreign+maximum-clock, maximum-clock and capacity-rejection observations; producer equivalence and compiling recovery mutation pass. Independent Spec/Standards reviews pass under the existing trusted lens contract. Source counters show 17 fused writes per Workshop and 238 fewer constructor-literal evaluations; runtime closure counts are unchanged. The prepared statistical cohort is pending, so no speed acceptance is inferred.

Fused-set prepared cohort remains rejected: JS median ratio1.1630706 (20/20 slower, p9.5367e-7), Native1.0331001 (18/20, p.0002012253). Complete output and receipt retained in `benchmarks/evidence/frontier-fused-set-prepared-regression`. Generated candidate JS has506372bytes/10156lines versus baseline327960/7031; code-growth analysis is next. This size observation alone does not assign timing causality.

Copied-generated-JS phase diagnostic retained at `experiments/public-optimized-compose/evidence/root-js-phases`: five full-output samples each, baseline compile median2.705ms/execution82.810ms, candidate3.630ms/95.780ms. Wrapper exposes require and intercepts zero exit to observe final timing; these exploratory samples are not the regression contract. Parsing alone does not appear to explain the difference. Generated Column accounts for138583bytes (~78%) of total178412byte growth, preserving five legitimate Type-family specializations. Fresh CPU-profile analysis precedes another source mechanism repair.

The user explicitly confirmed the pending #36 contract: Local retains changes on error; World transaction rollback is independent. This now supplements blanket task preapproval with an exact policy answer. Existing implementation matches it; final-source replay and shared regression/delivery gates remain pending.

### Owner-only selected recovery

Column `32a81f541e475af8be98528431f6e83990b978490c48afbb751b096a250b79c5` keeps H91f7 unchanged and partially evaluates only the discarded recovery ID-list projection. The erased Type helper retains every ascending affine Array.set. Seven JS/Native controls, extended archived original-recovery full-cell/hole/order comparison and compiling omission mutant pass in `experiments/public-optimized-compose/evidence/owner-only`. Constructor-literal evaluations fall80489 to79939 on identical Workshop observations. The paired gate is pending; counts do not establish speed.

Owner-only prepared paired gate rejects overall: JS ratio1.1518230,18/20slower,p.0002012253; Native1.0329713,14/20,p.0576591 is unconfirmed in this cohort. No causality/equivalence is claimed from nonsignificance. Receipt/fulloutputs retained in `benchmarks/evidence/frontier-owner-only-prepared-regression`. Next isolated probe shares carrier decoding through erased Type binders while preserving the public template wrapper; Native generic representation requires emitted-code inspection and both-backend controls.

### Isolated erased carrier decoder

Column `a4ab24d229590296c85940dc95de78d960c215a29e7c8811cf81b44ed0263cf2` preserves public unseal template signature and routes internal uses through one erased Type decoder. Seven full/deep-Wrapped JS/Native cases, extended original equivalence and reached mutation pass; evidence is `experiments/public-optimized-compose/evidence/erased-unseal`. JS1373decode entries now share one function instead of five; constructor count unchanged. Native generatedC adds332lines: generic return8Terms versus previous10, with explicit3-cell payload unpacking. This is a representation cost, not free optimization. The unchanged paired gate is pending; exact32a81f54 rollback source is retained.

Erased decoder rejected: paired JS1.1662887(19/20,p2.0027e-5), Native1.0434265(15/20,p.0206947) both confirmed. Retained in `benchmarks/evidence/frontier-erased-unseal-prepared-regression`. Exact owner-only Column32a81f54 is restored; erased decoder is not selected. Function deduplication alone did not pass the unchanged workload contract.

### Owned seek phase verification

Column5eed33d4 retains exported oldseek and uses a typed Ready/Compared internal phase to move row fields instead of rebuilding the same HandoffCon. Eight JS/Native cases include48paired old/new full-owner fuel/comparison observations; extended archived equivalence, reached omission mutation and ten intended public negatives pass in `experiments/public-optimized-compose/evidence/owned-seek`. HandoffCon evaluations fall1035to550; total79939to79454. Native global43/maxregister51/maxspin71 remain unchanged. The unchanged paired prepared gate is pending.

Owned seek fails unchanged pairedgate: JS1.1648432(20/20,p9.5367e-7), Native1.0660018(18/20,p.0002012253). Completeevidence retained in `benchmarks/evidence/frontier-owned-seek-prepared-regression`. Isolatedphase is withdrawn to exactowneronly32a81f54; fewer constructor evaluations did not pass performance. Next source research targets index-by-index Array evacuation transport while preserving actualselectedownerchains, arbitrary Type owners and old partial-fuel fallback.

Read-only structural Array producer hypothesis rejected before implementation. Primary emitted-runtime inspection shows size/blockclass and swap/directoffset operations are O(1), while structural node matching splits/copies arrays and rebuilding joins them. Base interpreter size uses leftdepth/maskedindices; emitters require equal childblock sizes. Therefore source-tree O(nlogn) indexing is not the actualbackend cost, and directstructuraltraversal is not selected. No workload/baseline/corechange follows from this rejected proposal.

The direct computed tuple-destructuring loop was rejected by the unchanged checker; diagnostic and candidate hash remain in `experiments/public-optimized-compose/evidence/direct-evac-rejection`. No patch or acceptance followed. The next candidate carries an already-computed swap result as a loop parameter, processes pending ownership in its single head match, and decreases future fetch fuel directly. This can preserve the same descending source indices without Fetch/Taken objects or dynamic continuations; checker/runtime controls precede selection.

### Direct pending-swap producer verification

Columnaca582fa keeps the original exported quantities and oldphaseAPI. Eight JS/Native cases,42paired producer partial-fuel/ID/initialrow observations through the original explicit function type, archived extended equivalence, reached mutation and ten intended confinement controls pass in `experiments/public-optimized-compose/evidence/pending-wrapper`. It removes2212Fetch/Taken constructions (79939to77727total) on identical Workshop results. Five emitted JS loops directly tail-iterate without per-slot continuations; Nativeglobal43/reg51/maxarity71 stay unchanged. Spec/Standards source reviews pass. Final paired prepared gate is running; this is not speed acceptance.

Pending-wrapper prepared gate still rejects: JS1.1680920(20/20,p9.5367e-7), Native1.0316315(15/20,p.0206947), retained in `benchmarks/evidence/frontier-pending-wrapper-prepared-regression`. The semantic/source mechanism verification does not pass performance. Next diagnostic must explain the persistent JS difference rather than treating constructor-count reductions as measured speed wins.

### Profile-backed prepared view fusion

Column869091a8 projects advancing-read owners directly and assembles the final carrier once; writers and backward recovery remain intact. Nine-case JS/Native controls,51paired partial-fuel/identity-or-mutating projection observations, archived producer/recovery equivalence, reached omission mutation and ten public negatives pass. Independent Spec/Standards reviews pass. Same Workshop counters fall: prepared_swap584to20, unseal1373to967, constructors77727to74817; recovery140 and array_rmw1920 stay unchanged. Native width bounds remain intact; generated JS grows17115bytes. Source-current evidence is `experiments/public-optimized-compose/evidence/view-fusion`. Paired prepared gate is pending; no speed acceptance follows from counters.

The view-fusion paired cohort still rejects: JS median ratio 1.1364655 (20/20 slower, p=9.5367e-7), Native 1.0278109 (16/20, p=.00590897). Complete output/receipt are retained in `benchmarks/evidence/frontier-view-fusion-prepared-regression`. The profile-backed fusion is retained while a distinct common-provider getter transport repair is investigated: preserve metadata/live validation and projection, but build the final World once rather than reconstructing it through metadata/live/store round trips. No cached validity or changed membership semantics is selected.

### Getter metadata/live/store fusion

Component36969e29 preserves public quantities and exact namespace/ID/live validation, threads the actual live owner, and invokes unchanged get_store only on valid live entities. Ten JS/Native cases,24old/new getter pairs (48records), archived equivalence, reached mutation and ten negatives pass; independent Spec/Standards source reviews pass. Full component cells/access/metadata are observed; pending/event counts are not described as full queue-payload traces. Same Workshop constructor count falls74817to69795, World4403to1893. Column869091a8 remains unchanged. Evidence/get-fusion is current; the prepared paired gate is pending.

Getter-fusion paired gate rejects JS: ratio 1.1194935 (16/20 slower, p=.00590897). Native ratio .9989071 (10/20, p=.588099) is unconfirmed. Complete outputs/receipt remain in `benchmarks/evidence/frontier-get-fusion-prepared-regression`. Fewer constructors and Native nonsignificance do not establish JS acceptance. The next diagnostic separates cold code/JIT overhead from remaining warm Column transport on this exact source.

Fresh exact getter/view cold-warm profile validates200complete applications per role with the five-second cap. One exploratory pair has first iteration137.950ms baseline/145.123ms candidate and later19 totals912.900/909.720ms; this does not prove a warm win or assign all regression to JIT. Column sampled execution remains elevated. Candidate generated JS524167bytes/1083functions versus327960/857. Five metadata/live helper copies transport all World fields. Next bounded repair shares only metadata-gated Array<Bool> reading; no schema/Store/C/project or generic owner representation enters that helper. Frozen gate is unchanged.

### Shared live-array reader

Component `0e41557cc6b8101490eaa7f4bf5fbdf896a2646e9b2359d7daf41db6de45988c` shares the metadata-gated Bool-array read without passing schema, store, component or projection arguments. Column869091a8 remains unchanged. Ten JS/Native cases,24 old/new getter pairs, archived producer/recovery equivalence, reached recovery mutation and ten confinement controls pass in `experiments/public-optimized-compose/evidence/bool-read`. Independent scoped Spec/Standards reviews pass. Generated JS contains one three-argument live reader; Native return width remains unchanged. The unchanged prepared paired gate is running; these results do not establish performance acceptance.

Shared-live paired gate rejects: JS median paired ratio1.1032570 (19/20 slower,p=.0000200272); Native1.0141897 (15/20,p=.0206947), both confirmed under the unchanged Holm contract. Receipt and every full output are retained in `benchmarks/evidence/frontier-shared-live-prepared-regression`. #30 remains open; this small-process cohort does not qualify product targets.

### Direct Carrier view decoding

Column `b742477e821b3e7807d36bfbe46dc38ef89142dece5c2517d5cb28b64d32070b`, Component0e41557c unchanged, passes ten JS/Native cases including deep Wrapped carriers and mutating projection, archived equivalence, reached mutation and ten negatives. Independent scoped reviews pass. Evidence: `experiments/public-optimized-compose/evidence/carrier-view`. JS prepared_view_state calls745to0 and unseal967to222; literal evaluations69796 unchanged. Native width43/register51 remain, but old helpers were already inlined and the new carrier adds dispatch entries: no separate Native State-return removal is claimed. The unchanged paired gate is running.

Carrier-view fusion is rejected: JS1.1089706 (19/20,p=.0000200272), Native1.0232939 (15/20,p=.0206947), both confirmed. Full receipt/observations retained in `benchmarks/evidence/frontier-carrier-view-prepared-regression`. Restore prior Column869091a8; candidate/evidence remain historical. Fewer JS helper entries did not satisfy performance.

Fresh root shared-live closure replays now pass #29/#31/#32/#33/#36; retained root-current receipts identify that exact closure and do not transfer to future provider changes. Full-frontier Standards review corrected event/removal skip wording. Special Astra architecture review accepts an additive row-owner provider for #30, retaining original selector and traversal-wide World inverse journal. A checked bounded prototype is next; no performance gate is waived.

### Source-bound Node CPU and allocation profiles before owned integration

The user explicitly requested call-stack and memory profiling. Built-in inspector runs now retain separate CPU and collected-object allocation profiles for the exact shared-live generated JS, with200 complete applications validated per run. Quiet before evidence: `experiments/public-optimized-compose/node-profiles/evidence/before/`. A forced-collection canary distinguishes retained-only sampled attribution1792bytes from collected-inclusive4301824bytes; this validates instrumentation, not an ECS law or exact allocation total.

Exploratory inclusive sampled attribution (overlapping stacks): Column404.4MB, Component375.1MB; self hotspots include schema.array_view133.9MB, declarations.work_plan76.4MB, Column.seek_view48.8MB and Component.get28.8MB. CPU sampled GC is73.9ms; asynchronous GC event durations sum58.6ms in the CPU run. These different metrics are not interchangeable. Mandatory projection/observation work remains included. Initial unflushed-GC and canary-overlapped diagnostics remain in .artifacts with explicit limits; the quiet third run is the before comparison. After integration, use the identical runner/settings and unchanged paired gate.

Default-provider paired gate passes on the frozen shared-live core with additive owned helper modules: JS median paired ratio.9492325 (2/20 slower,p=.999980), Native1.0118986 (13/20,p=.131588), no confirmed slowdown. Full receipt/outputs: `benchmarks/evidence/frontier-shared-live-default-regression`. This does not replace the failed #30 prepared-provider gate, imply Native equivalence or apply to subsequent changed source.

## First owned-provider measured checkpoint

The reviewed owned-row provider passes finite correctness but fails the unchanged prepared comparison. Retained `benchmarks/evidence/frontier-owned-provider-prepared-regression/receipt.json` and all110 complete outputs: JS median paired ratio1.310019 (20/20 slower; p=9.536743e-7), Native1.047771 (17/20; p=.001288414); both confirmed after Holm. No acceptance or baseline change.

Matched before/after Node profiles validate200 complete applications separately for CPU and collected-object allocation sampling. Retained `experiments/public-optimized-compose/node-profiles/evidence/after-first/`. Summed sampled self attribution rises from934.3 MB to1172.9 MB; inclusive rows must not be added. Work-plan self attribution rises76.4→155.0 MB, run_clo32.4→66.0 MB. Generated JS repeatedly constructs the whole Plan at select/enter/leave/caps access, including repeated capability extraction inside gameplay. This is the next source investigation, not a causal proof or exact physical allocation total. Observed CPU-run GC events97→110 and total observed GC duration58.6→66.9 ms. Feature gates remain bounded passes pending final common-source delivery.

## User full-parity performance clarification

The user accepts up to10% aggregate loss after all features/full bevy-ts parity, with final JS at least comparable to bevy-ts. Existing Native>=2× target remains. Recorded in SPEC; no new full-parity comparator is selected and the existing bounded #28 contract is unchanged. The31% intermediate owned-provider regression remains an implementation problem; investigation continues.

## Direct closed-field measured checkpoint

Current owned-compose1115ffe6, owned-optimized3e651cc4 and adapterec071b53 pass fresh14pairs/23checkpoints, both legacy/direct-field confinement controls and reached restoration mutant on JS/Native (`evidence/owned-plan-fields`). Runtime Plan construction/accessors disappear from actual generated provider; capability records remain.

Unchanged prepared gate `benchmarks/evidence/frontier-owned-fields-prepared-regression/receipt.json` retains110complete outputs: JS1.246639 (20/20 slower,p=9.536743e-7) remains confirmed; Native1.000856 (10/20,p=.588099) has no confirmed regression. Overall remains failed. Matched source-bound200-application profiles retained under node-profiles/evidence/after-fields. Summed sampled self attribution1172.9→926.9 MB versus before934.3 MB; run_clo66.0→31.6 MB and Plan construction attribution disappears. CPU GC self73.7→54.2ms within profiled runs. These diagnostics support the eliminated construction mechanism, not physical total bytes or product qualification. Continue investigating residual JS cost; no baseline/contract amendment.

## Zero-family Frame experiment

Adapterbb0e7362 uses identity Frame only for Empty/Contradictory; actual hot-family captured routes remain unchanged. Independent source review, fresh14pairs/23checkpoints, negatives and restoration mutant pass. Retained evidence/empty-frame; opaque capability template-match rejection and legal runtime application-fusion comparator are retained under capability-static-canary. No compiler or capability core edit was used for this cohort.

Unchanged prepared gate `benchmarks/evidence/frontier-empty-frame-prepared-regression/receipt.json` retains110outputs and fails both endpoints: JS1.221333 (20/20,p=9.536743e-7), Native1.025053 (16/20,p=.005908966). This is experimental, not accepted. Matched200-application profiles retained under node-profiles/evidence/after-empty-frame: summed sampled self912.85MB versus926.86MB afterfields; zero-family row entry/leave allocation sites disappear. Lower sampled allocation does not imply passing speed. Next independently reviewed mechanism fuses runtime capability matching with callback application for read/get/set while preserving closed-template APIs, actual owner/projection semantics and old field helpers. No claim that remaining records/indirect dispatch disappear.

## Rejected capability-application fusion

Capabilitiesbf94887b passes exact-source semantics/controls/review but unchanged prepared gate fails: JS1.240217 (20/20,p=9.536743e-7), Native1.018810 (15/20,p=.020694733). All110outputs and receipt retained under benchmarks/evidence/frontier-capability-applied-prepared-regression. Matched200-application profiles retained in node-profiles/evidence/after-capability-applied; summed sampled self917.36MB, no established allocation or speed gain over EmptyFrame. Only capabilities.bend reverted to exact91c0cdc0; rejected source/evidence preserved. Native Empty transport audit binds actual C: ID callback context1→34input words despite overall43-word maximum. This remains an unaccepted intermediate provider.

## User-inspired representation research

Primary NodeStore/Bitlist source research is retained in docs/research/indexed-lifecycle-metadata.md and packed-live-tag-flags.md. Indexed lifecycle is the next major candidate: owned added/changed arrays for1..131072 plus disjoint raw exceptional-ID fallback; preserve legacy list routes/constructors and Type payloads. Independent design review accepts a bounded compatibility-first experiment; old exhaustive consumers must check unchanged before adding variants. Packed liveness remains independent; generic tag presence cannot bypass mutating projections. Neither package is installed/adopted, no speedup or law/proof is approved. Task-local compatibility/metadata canaries begin before any core integration. See docs/design/indexed-lifecycle-metadata.md.

## Indexed ordinary and partial scaling checkpoint

Independent ordinary-only review passes Column7b8ed4ad, indexed-lifecyclee997f3b0 and captured-column6260b164. Root unchanged eight-part user API replay passes23complete JS/Native observations and intended negatives. Indexed prepare/capture and candidate provisioning remain pending; no final source or performance acceptance.

After source-binding repair and six five-second checker-only fixture controls, root ran separate dense/mixed equal-work metadata diagnostics. Retained receipts/raw outputs/compressed CPU and collected-object heap profiles: `experiments/public-optimized-compose/indexed-metadata-scaling/evidence/dense-default-stack` and `mixed-default-stack`. Both cohorts are ERROR: legacy1024JS fails the non-tail Base List.show JSON renderer with machine-stack overflow. Sizes64/256 complete both backends and full independent oracles; supplemental frozen-stage inventory/hash audits pass. They do not make the complete scaling gate pass.

Dense indexed/legacy whole-process median ratios are JS.876593/.655708 and Native.886994/.687990 at64/256. Mixed ratios are JS.937379/.700860 and Native.988972/.650124. Five alternating samples include startup, complete JSON construction and output, with no statistical product acceptance. Dense256 summed sampled self allocation is31.41MB legacy versus2.59MB indexed; mixed64 is2.54MB versus7.09MB, exposing high-water allocation cost. One-iteration profiles have limited CPU samples and are attribution diagnostics, not exact physical allocation or retained memory. No JS-vs-TS or final ECS speedup follows.

Root diagnostic-only Node `--stack-size=16384` replay of frozen legacy1024dense output matches all8192observations. This identifies a renderer/runtime stack limit; it changes no regression or profiling settings and is not a timing result. Core source freeze is released for indexed prepared/capture implementation. Both original regression gates remain required after complete integration.

## Integrated indexed provisioning and measured gate

Indexed prepared/capture passes current-source60full comparisons and2430indexed cases/backend; the legacy2430case corpus also passes after explicit raw-sum matcher coverage that rejects unexpected indexed results. Reviewed copied-source binding,14actual transaction/access pairs,23full Workshop checkpoints, intended legacy/direct/public negatives and reached owner-loss mutation pass. Only five initial provisioning calls are activated, schema b09a3978; core Column3fec368b/captured340efc23/Metadatae997f3b0. No nonempty list conversion or gameplay/driver/observer edit.

Complete repaired metadata diagnostics now pass64/256/1024 for dense and mixed scenarios, retained under indexed-metadata-scaling/evidence/dense-complete and mixed-complete. Dense1024descriptive indexed/legacy speedups are JS5.0039×, Native8.3395×; mixed64Native is9.99% slower. These isolated metadata measurements are neither TS comparisons nor integrated ECS qualification. Earlier renderer/postprocessing ERRORs remain retained.

Unchanged prepared gate `benchmarks/evidence/frontier-indexed-prepared-regression` retains all110outputs and FAILS: JS median paired ratio1.297299,20/20slower,p=9.536743e-7; Native1.021101,14/20,p=.057659,no confirmed slowdown. Same-cohort process medians TS243.034ms, candidateJS133.900ms and Native17.915ms; descriptive candidate/TS ratios.550949/.073714 include startup and output and do not qualify the full performance matrix. Default current-core gate `frontier-indexed-default-regression` PASSES: JS.996465,9/20,p=.748278; Native.999347,10/20,p=.588099. No bounded baseline/threshold change. #30 remains incomplete despite correctness and default-core acceptance.

Matched20fresh-scope ×10application after-indexed profiles pass both separate CPU/collected-object allocation runs with the same runner64ff52bd/settings/outputs. Summed node-self attribution930.48MB versus912.85MB at before-EmptyFrame. Schema.array_view remains135.61MB self, slice41.16MB; array_node65.2ms CPU self. Metadata microbench gains do not transfer to this small Workshop. Postprocessing-only iterative summarizer622afd3d preserves attribution maps and fits5s for deep profiles; original failures remain failures. V8 trace diagnostics validate10full applications each and show one run_tail wrong-map bailout in both old/new programs, providing no evidence of added deoptimization storms. Raw diagnostics are retained under node-profiles/evidence/after-indexed and indexed-jit.

Next reviewed source candidate is selected-provider U32array projection by bounded indexed traversal. It must visit every physical capacity cell, thread actual returned Array ownership, retain complete left-to-right snapshots/logical prefix and keep the structural oracle. This avoids reached slice/concat reconstruction without changing authored gameplay, inputs or observations; generic affine Type components remain unchanged. Prototype correctness, generated-code audit, matched profiles and unchanged paired gates precede any acceptance.


## Current-core feature replay — 2026-10-07

Fresh root runs on Column `3fec368b` / captured-column `340efc23` / indexed-lifecycle `e997f3b0` pass #29 query contracts, #31 event readers, #32 removal readers, #33 schedules and #36 Local. Complete outputs, diagnostics and reached compiling mutations are retained under each experiment's `evidence/indexed-core-current/`, with source-bound receipts and retention manifests. These checks are finite; timing and final delivery are separate. The eight-part `experiments/user-api/run-all.py` replay also passes, including the complete 23 Workshop observations, fresh consumer and confinement negatives.

The selected Workshop scalar-array projection is now promoted for correctness replay after independent Spec/Standards approval. Schema SHA `0903e05d7755c4ede468e2b60da505edf95c5db52b7adf69704ce651b49bb117` retains the original structural fallback and checks each physical index before Array.get while threading its actual owner. No measured gain is claimed yet. The source-current copied-provider runner preserves initial/per-step/final inventory guards and unchanged full application/transaction/mutation controls.

Promoted application gate is PASS on the frozen schema above: 14 complete legacy/indexed transaction/access pairs and all 23 Workshop checkpoints match on JS/Native; the reached indexed captured-restoration omission is detected on both. Initial staged inventory, each normal/mutant operation and final guards pass. Source-current application evidence is retained in `experiments/public-optimized-compose/indexed-column-integration/evidence/array-view-provider-current/`. This verifies finite integration; the new paired performance cohort is running separately.


### Indexed projection paired gate

The unchanged paired gate remains **REGRESSION**: JS median paired ratio 1.297879 (20/20 slower, exact p = 0.000000953674, Holm cutoff 0.025); Native ratio 0.984415 (8/20 slower, p = 0.868412; no confirmed slowdown). Complete receipt and all 110 output files are retained in `benchmarks/evidence/frontier-indexed-array-view-prepared-regression/`. Descriptive whole-process candidate/TS ratios are 0.548940 JS and 0.072534 Native; these do not qualify the full performance matrix. This cohort does not establish a JS gain versus the prior indexed cohort; both compare against the unchanged frozen baseline. Matched CPU/allocation profiling is running to evaluate the intended mechanism. #30 remains incomplete.

Matched Node profiles validate 200 complete applications per run with unchanged inspector settings and normative output. Summed node-self sampled allocation falls from 930.483568 MB before scalar-array projection to 829.437912 MB after (about 10.9%). Structural array-node/view CPU hotspots disappear; new collector self allocation is 21.511080 MB. These samples include collected objects and are not retained RAM or exact physical allocations. CPU self totals 1,147.728 ms before / 1,102.534 ms after are individual profile diagnostics, not a statistical speedup claim. The unchanged paired gate still fails JS. The next largest application allocation site is indexed_seek_view (49.598864 MB); investigate emitted carrier construction/owner transport before changing semantics. Raw profiles, summaries, complete outputs and retention hashes are in `node-profiles/evidence/after-indexed-array-view/`.

Fresh five-sample whole-process feature diagnostics also pass complete observation checks: removal readers TS 84.340281 ms / JS 19.083537 ms / Native 4.581654 ms; Local TS state-adapter 121.335348 ms / JS 20.410461 ms / Native 4.879656 ms; schedules TS 90.409195 ms / JS 18.681785 ms / Native 4.622696 ms. Receipts and full outputs are retained under the respective `evidence/indexed-core-timing/` directories. These small startup/output-inclusive diagnostics have no historical Bend baseline and do not establish hot-path performance or a statistical speedup.

The #31 main event trace's five complete observations per backend pass at 65,535 inputs: medians TS 94.611475 ms / JS 78.431873 ms / Native 44.647617 ms. `public-event-readers/evidence/indexed-core-timing-v2/` retains the passing receipt/full outputs. The initial diagnostic omitted the required count argument and JS refused before executing work; its ERROR receipt and prior partial TS outputs remain separate. Late-registration and disposal observations remain in the current semantic gate, not this main-trace timing scope.
