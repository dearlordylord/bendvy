# Two-hour performance preparation

The user authorized a cumulative two-hour budget: start **2026-10-04 23:58:17 UTC**, deadline **2026-10-05 01:58:17 UTC**. Preparation and investigation consume this global budget; changing tools or experiments does not reset it. Stop earlier if the accepted target is achieved.

The former incremental targets—10% improvement over previous Bend→JS and no more than 5% regression versus previous Bend→Native—are withdrawn. The actual target is **Bend→JS no slower than pinned bevy-ts**, and **Bend→Native substantially faster than pinned bevy-ts**, on equivalent authored work. The exact Native factor remains unanswered: 2× or 5×. No numerical approval is inferred. No Autoresearch loop/session contract has been accepted or started.

During this turn the installed Bend compiler changed externally from 2.0.34 to 2.0.35. No agent installed it. Proposed new compiler SHA256: `f77417474ded314ad5d1a68fa3ebbe214c2124bf04d56a59b05bc17be6b0327a`. Re-pinning is proposed, not silently accepted; old and new compiler artifacts must not form a mixed comparison cohort.

The 2.0.35 baseline construction control at `/tmp/bendvy-twohour-tool035-baseline-control/evidence.json` passed all original finite full fields for Health/Dense256. Its single samples were Native 19 ms, bevy-ts 13.504942 ms, JS 90 ms: descriptive ratios Native/TS 1.407 and JS/TS 6.664. These are unqualified one-shot observations, not noise-qualified baseline medians or keep evidence. Native artifact SHA256 `34b7a964c2d79fe22531a524045ce19264f0acaecf9a2064792eeced7f7bc528`; JS artifact SHA256 `6172a1236c12729831aa0a427959d47f539a619f331c763b5e1429017c4cbbe6`.

Experimental candidates are committed separately:

- `93b93ca`: fuse checked affine Main point hook; semantic/access/ownership controls are retained in `experiments/s-prep/integrated-main-fusion/`.
- `df7f23b`: bounded affine structural query candidate with connected controls in `experiments/s-prep/integrated-query/`.

These commits are experimental semantic work, not measured keeps or product acceptance. Missing, failing or partial gates remain explicit in their individual reports. Candidate benchmarking requires a single agreed compiler pin, protected full-field evaluator, complete comparison/check scope, and accepted stop/keep rules.

Operation diagnostic `50d3df3` independently validates the old retained JS artifact against freshly executed bevy-ts. Each HealthDense256 world performs 16,384 extract/restores and 32,768 Main take/hook/put entries; warmup and measured worlds match. Counts are not timing attribution. JS already lowers Array get/set/swap to direct mutable native-array operations, so structural traversal alone does not establish a source-supported 6× JS gain. See `experiments/s-prep/operation-counts/README.md` for exact evidence, negative counter control and replay.

## Current implementation frontier

The reviewed fused indexed query (`8b3e81e`) replaces the copying structural variant as the preferred semantic candidate. Combined with Main fusion on isolated `s-loop23/fusion-review`, fresh Main traces match all fields/effects on both schemas/capture styles, and current-tool owned-storage controls pass. Combined E11 and actual-host mutation replay remain in progress. Equivalence is bounded to trusted equal-shaped Worlds; malformed Flag-filtered/Main-absent columns can change failure behavior. No universal refinement/adoption is inferred.

One combined HealthDense256 construction control is full-field PASS: Native 13 ms, TS 12.951976 ms, JS 70 ms, descriptive Native/TS 1.004 and JS/TS 5.405. It is unqualified and cannot establish causal improvement or target achievement. Exact evidence is retained on the candidate branch under integrated-indexed-query/combined-focus-control-evidence.json.

Pure parity/scope/evaluator proposals now compare candidate with actual TS, include tiny-positive ratio numeric rejection, exact private declaration allowlists and repository-bound paths. The evaluator is dry-run-only; execution is blocked until canonical acceptance and protected source/tool/check/deadline bindings exist. No accepted session or benchmark packet has been created.

The isolated Ledger journal prototype (`3014093`) passes concrete disjoint-storage fixtures but rejects generic Tx equivalence through a cross-dependent restoration counterexample. The direct owned write-query proposal and capability prototype preserve every inverse/mark, retaining selected Main/Ledger across callbacks. Production transaction/provider integration, full matrix, numerical acceptance, simulation and copied-TD validation remain open.

Combined E11 now passes 20 actual joined cases with no failures and all compiling retention mutants detected. The combined actual Host replay passes all twelve compiling mutants on Native/JS, including the retargeted active indexed query-order path. Raw results remain on the experimental branch with exact source/artifact/oracle bindings.

The selected-owner capability prototype (`febc9d6`) delivers both original callback bodies, Type owners, held lookup/snapshot, every-write inverse order and actual commit/unwind/FIFO controls. Independent review found a replay provenance gap;2456b3b repairs it with pre-execution reference HEAD/33-file import closure validation and runner-generated receipt fields. Fresh bounded replay passes, including rejection of a wrong reference commit before execution. A derived actual Dense integration is being prepared separately, preserving callback bytes and original commit path. No performance acceptance follows from these capability checks.

The cached-array backend capability probe (`ebfb889`) passes explicit frozen operation-template Native/JS variants and applicable wrong-leaf/lost-owner controls; cached-capacity mutation applies to Native only. JS keeps flat Array intrinsics; Native uses local cached-capacity traversal. Direct frozen-Bool and direct Base `.go` approaches retain checker/codegen failures. This is finite trusted-shape capability evidence, not measured improvement or an accepted backend protocol.
