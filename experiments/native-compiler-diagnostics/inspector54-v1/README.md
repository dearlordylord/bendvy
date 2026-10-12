# Inspector #54 Native emission investigation

Owning issue: [#54](https://github.com/dearlordylord/bendvy/issues/54). This is compiler research, not accepted ECS delivery. [Retained findings](RESULT.md) distinguish copied-compiler diagnostics from installed-tool acceptance.

`diagnostic-evidence.tar.gz` retains the complete frozen53-source snapshot, copied/compiler candidates, raw attempts, CPU profile and summaries. Input/output paths were relocated; environment/tool differences remain explicit. `CANDIDATE.json` pins archive, pristine2.0.35 source and proposed patch. No experiment here closes #54 or #46.

## First candidate — bounded optional tail inlining

`optional-inline-budget.patch` permits at most64 optional once-tail inline decisions per top-level emitted definition/pass. A counter is shared with nested emitted specializations; mandatory flat/template calls bypass it. The next definition resets it.64 is an experimental implementation setting, not a performance gate or agreed default. Full disabling remains diagnostic history, not the proposed permanent implementation. The original copied compiler can be recovered from the archive; patch applies to its exactSHA.

Preparation status (retained historical metadata in CANDIDATE.json): source candidate prepared, syntax checked. The subsequent reviewed run below supersedes its unexecuted status; candidate is not installed or adopted. Risks for review: layout/ownership fact convergence, nested spin-cache/order sensitivity, lost runtime optimizations and correctness of tail/return conversions. No new public contract or erased-argument handling is introduced.

## Required next steps, in order

1. Independent launch review binds exact candidate, frozen ordinary consumer/full oracle, existing runner/tools/environment, serialized heavy ownership and existing source5/emit30/build120/runtime5 caps. Side investigation postdated earlier diagnostics; it is not retrospective launch approval.
2. Execute complete JS/Native consumer against the independent oracle, retain all owners/checkpoints/query kinds and failure/retry observations. A deadline remains inconclusive; do not lower coverage or raise acceptancecaps.
3. Only after complete output passes: affected authority/error/reached controls, independent final review and source-current regression/runtime CPU/allocation evaluation. Candidate compiler output equality and runtime performance are not yet established. Keep installed2.0.35 authoritative until explicit adoption.
4. Follow up separately with [upstreamPR1386](https://github.com/bendlang/bend/pull/1386): repeated full passes are measured after suppressing first-pass inlining. Pin a patch; do not assume an open PR is shipped or compatible with2.0.35.
5. Follow up separately on DAG-aware `lay_eq`/type keys. Verify cached-layout immutability, equal distinct layouts and multi-compilation reset before adoption. Existing layout identity fix from#1270 is already present.

Boxing remains a reserve candidate because it changes data layout. Heap tuning did not unblock the subject; mat_lits was not reached. Do not change ECS APIs or sacrifice parity based on these diagnostics. Related#46 may benefit but has no source-matching execution credit from this#54 investigation.

## Reviewed complete-consumer attempt — 2026-10-12

The [candidate packet](../../public-inspect/promotion-stage/missing-resource-v1/direct-inspector-v1/component-query-v1/compiler-candidate-v1/README.md) preserves prospective launch review, full 53-source consumer/oracle, raw attempts and restoration. Source check and complete 207,834-byte JS output pass. Native emit hits its unchanged 30-second deadline without C; build/runtime are unstarted. [Independent final review](../../public-inspect/promotion-stage/missing-resource-v1/direct-inspector-v1/component-query-v1/compiler-candidate-v1/FINAL-REVIEW.md) accepts this partial diagnostic only. All five temporarily activated source bodies were restored exactly; installed Bend and shared ECS source remain unchanged. No identical retry, Native acceptance, compiler adoption or performance credit.
