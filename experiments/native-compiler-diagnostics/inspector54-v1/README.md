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

## Repeated-pass and postpass diagnostics

The [reviewed repeated-pass packet](../../public-inspect/promotion-stage/missing-resource-v1/direct-inspector-v1/component-query-v1/compiler-candidate-v1/repeated-pass-v1/FINAL-REVIEW.md) manually adapts the first mechanism from upstream PR1386 to the copied2.0.35 CLI, retaining budget0 and a mandatory final full pass. Source and fresh full JS pass. Native completes eight passes (final cumulative CPU21.786911s), then expires at the unchanged30s wall deadline before C output. This narrows that attempt to unmarked post-loop work; CPU and wall time are not interchangeable.

A subsequently reviewed Native-only marker successor expires during pass3 before any post-loop marker. It does not locate the earlier postpass deadline. All53 activated source files are restored before release. Neither attempt establishes Native acceptance, stock compiler compatibility, adoption or runtime performance. Next: obtain usable compiler CPU/allocation evidence under the existing limits rather than repeat an identical command.

## Usable compiler profile

The [reviewed CPU-profile successor](../../public-inspect/promotion-stage/missing-resource-v1/direct-inspector-v1/component-query-v1/compiler-candidate-v1/cpu-profile-v3/FINAL-REVIEW.md) retains1,726 samples over20.134447 sampled seconds, with cooperative diagnostic exit77 and all53 files restored. The earlier memory-counter exception and missing-profile attempt remain separate immutable packets. V3 uses20s cutoff/10ms sampling within the unchanged30s outer deadline; these are diagnostic settings, not acceptance gates.

`stringify` self samples total3.995362s (19.84%): nearest callers `lay_eq`2.124865s and `lay_of`1.718238s dominate. Logging overhead is material (`writeSync`1.446s, `cpuUsage`0.543s). This profile covers setup and early emission through part of pass3; it does not locate postpass costs or establish workload speedup. Next: test order-preserving layout equality and memoize only finalized pairs, retaining constructor/tag order, recursive BOX handling, WIDE decisions and per-file cache reset. Do not cache mutable term/type keys by identity or change `LAY_IDS` specialization identity.

## Current blocker: generated C build

The [graph-index diagnostic](../../public-inspect/promotion-stage/missing-resource-v1/direct-inspector-v1/component-query-v1/compiler-candidate-v1/layout-equality-v1/graph-index-v1/FINAL-REVIEW.md) follows a later sparse-marker attempt that completed eight passes and stopped after `post-reach-begin`. Ordered adjacency preserves the original closure result and Set order;141 actual-helper differential controls pass. Native emission now completes within30s and produces43,550,580 bytes of C (SHA256 `24b6ef6a560bf170283ae0d8a5c6036a863ccc4a198dd7eeea3b21683cf58465`). The full artifact is retained in the evidence archive.

Pinned Clang19 `-O3` reaches the unchanged120s build deadline with empty diagnostics; runtime is unstarted. Full source/JS evidence remains qualified for its matching scope; all53 temporary inputs were restored before unlock. No Native output, adoption or speedup claim. Next: inspect generated C and compiler-stage costs before choosing a bounded build experiment, preserving the full consumer and acceptance limits.
