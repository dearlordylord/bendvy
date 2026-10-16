# #53 independent final Spec/Standards review

Verdict: PASS for the frozen owned-event implementation and delivered evidence. No unresolved Spec or Standards finding. This is the single final review assignment; the six oracle findings below were repaired within it.

Reviewed against AGENTS.md, docs/SPEC.md, docs/agent-workflow.md, docs/check-policy.md, CODING_STANDARDS.md and docs/parity/affine-events.md. Final source is edc8fb566d36f841fb1602d27a7f426adc40d1de, building on bd57fde16, 3c9533f0b, e1b1023b5 and 21ddb0860. API/scope documentation db7210c21 and TS applicability cfd0cfcbc are included. No implementation, observer or model was authored by this reviewer. No backend/compiler or comparative performance run was launched during this review.

## Spec

Canonical ordinary constructors couple resource log paths, typed publication routes and actual stream selections; standalone publication works without query rows. The ordered journal preserves global cross-family FIFO and per-family abort recovery. Same-payload families retain distinct indexed paths/selections, and nested affine payloads remain arbitrary Type. Gameplay bodies receive rank-2 capabilities, not raw World or payload owners. Access metadata derives from declarations. Explicit erased callback/type indices are verbose Bend forwarding requirements; they do not constitute application-authored runtime access lists or cursor/rollback adapters.

Readers retain independent cursors, failure/retry and explicit skip rules, capacity/lag observations, disposal, complete payload observations and owned retirement/shutdown receipts. Reader/query projections restore the log owner before row grants execute; one canonical transaction covers all current-call events and rows. Late failure rolls back component/resource changes while retaining actual affine Args and observation owners, preserving earlier committed calls and failed reader/query cursors. These are the selected existing Data-event rules, not a claim of identical Bevy update-window semantics.

Source inspection confirms retired owners are returned once through typed catalog traversal; shutdown drains remaining rows and clears all shared publication state. Affine typing alone does not prove preservation or physical finalization. Raw descriptors, providers, lenses, Frames and administrative constructors remain a documented trusted provisioning boundary. No automatic IO finalizer, arbitrary extraction of transactional owners, memory improvement or universal refinement is claimed.

Independent application adoption and complete current ordinary consumers cover the public contract. Existing Data-event implementations are unchanged. Reused TS executions have exact original reference/receipt scope: publication, failure/retry, skip and retention overlap is applicable; TS alias identity, owned recovery/retirement and shutdown are explicitly different or unavailable. No invented TS disposal or whole-wire equivalence is claimed.

## Evidence verified

Read-only verification checked archived compressed/raw SHA-256 and lengths, committed/archived source identity, plan/receipt hashes, exact command arguments/caps, complete raw outputs/stderr, guard hashes and actual source pins for the selected final packets:

| Packet | Subject | Complete output |
| --- | --- | --- |
| 0a5475f3b | Three-family publication/query | JS and Native equal corrected f44e063d75 oracle, 21,529 bytes, SHA 18bda7fe152ff0c00f74bf13f5c9df6fa8907574b0203fee5a2357545e0c7cf3 |
| 68a1d9f3f | Independently authored canonical-family application | Both first-pair COMPLETE, 10,193 bytes, SHA ea241c813038c75124f8492f31cc18445a572b2ff607f511bbfea4f562982e17 |
| a4561ad39 | Reader/query transaction and affine observations | Both first-pair COMPLETE, 48,711 bytes, SHA d0d879bb551c40a4d1d71c9a0e6b368aa85b91b01d9f341c2c7d4325a968c07f |
| 022650a66 | Independent fast/slow/skipped/failed readers, retention and disposal | Both first actual executions COMPLETE, 90,973 bytes, SHA 98107a0f330aeae49e55ac96403f8bb2462791206b61d3b9afb60c8884049e30 |
| 0a18bc0597d790312d3cde3502fef9f8ba198e4d | Reached retirement-owner-loss mutation | Both COMPLETE, 90,719 bytes, SHA ac8fb3f9415a3c4b29e7eace6fb9bf6f802de67bf9f943da9dc2ca19e79e900e; both reject the complete normal oracle |

Archive member counts independently checked were 528, 454, 523, 549 and 508 respectively. The family publisher's original JS receipt remains INCOMPLETE against its original incorrect formatting oracle; retained JS and Native bytes equal the independently corrected source-derived oracle. No historical verdict was rewritten.

The retirement mutant is exactly the sole Log.partitioned False-arm replacement in 66150ce05. Its counter 465683a9038d3c66c08683076ef178ddba99cf80 independently models empty frame retirement receipts; complete state and shutdown observations stay equal. The actual public frame path reaches it on both backends. Complete comparison detects owner loss, rather than merely checking a compiler canary.

Authority controls 4538fedbe and cc2fa3125 use actual ordinary registration/run boundaries. Final combined controls have two positives and eight intended negatives; source/raw hashes and diagnostic reasons match. They reject cross-schema runtime use, writes through read/filter-only grants, undeclared resource/event capabilities, opaque World/Frame access and affine Observation duplication. Prior reader controls cover duplicate reader/Registry/Args and wrong same-payload-family selection. Reuse of Request/projection/payload confinement follows the unchanged Storage.read → Log.read → Scope.provide chain; no provider-purity inference is made.

## Resolved findings

Before any normal-reader backend execution, review found six defects in the initial 53ce7a6d9 oracle: capacity counted batches instead of values, read lag was hardcoded false, nested Crates projected an inner Array instead of scalar 900, observed boundary used held cutoff instead of old frameStart, snapshots added an absent LF, and post-disposal rendering omitted derived statuses. Corrected successor 1a117f417 preserves that history and fixes all six from frozen source. Independent source matrices and in-memory whole-model/raw/gzip checks passed before execution. Held plans 09a0d6173 were not executed; no failed normal-reader JS run is invented. Actual JS/Native then matched the corrected complete oracle without candidate changes.

## Standards and scope

All 24 #53 src/ecs additions versus 1bf6b8595 are additive. Independently recomputed #28 literal import closure is exactly the 23 paths in experiments/public-captures/ordinary-owner-v1/regression-reuse-v1/APPLICABILITY.json; every final-source hash matches its protected identity. New owned-event modules are outside that closure. Reuse therefore preserves the unchanged protected workload/artifact subject, not feature performance. Comparative full-feature qualification remains under #21/#23/#24, with final JS <= TS and Native <= 0.5 * TS unchanged under the approved delivery-cost amendment.

No new law, dependency, numerical tolerance or approval contract is introduced. Finite executions establish their exact consumer scopes; universal proofs, physical cleanup and full-core performance remain outside this verdict. Coordinator integration, configured CI, commit/push and governing-issue reporting remain delivery actions for the root integrator, which must preserve the reviewed source/evidence bindings and unrelated workspace edits.

## Integration packaging addendum

Reviewed the narrowly scoped retirement-loss-control-v1/.gitattributes addition: it disables only blank-at-eof whitespace diagnosis for the exact frozen source/src/ecs/owner-handoff.bend copy. Independently verified that file remains byte-identical to 66150ce05, SHA 91f7e7f40877da928bb64e64a87ffd218a15e982afbc24199b8778cd4e7effec, including its original terminal blank lines. git check-attr resolves exactly whitespace=-blank-at-eof for that path. This preserves immutable evidence bytes; it changes no source, runner, hook or numerical check. Packaging adjustment accepted within this same review; PASS unchanged.
