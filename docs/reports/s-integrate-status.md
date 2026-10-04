# S-INTEGRATE status — 2026-10-04

**Incomplete: #19 remains open.** The joined experimental ECS now passes the
functional trace and mutation gates. Current measurements reject performance
acceptance; remaining exact workloads and corrected memory evidence are pending.
This is a progress record, not a completion report.

| Governing criterion | Status | Direct evidence / remaining gate |
| --- | --- | --- |
| Reviewable exact inputs/order/barriers/failures | Passed, bounded | Reviewed `docs/design/s-integrate-trace.md` and pinned fresh reference records |
| Actual nominal access, read/write and owner-return controls | Passed, bounded | Source-current access controls plus actual foreign and structural gates; trusted-lineage confinement remains explicit |
| Joined three-backend stages 2–4 | Passed, bounded | `host-source-current-evidence.json`: ten channels/four lanes, Native O3/JS/fresh TS; E11 twenty originals retain separate source-current pins |
| Intended compiling semantic mutants | Passed, finite | `host-mutation-source-current-evidence.json`: twelve mutations, both backends; E11 ten pipeline mutations and separate namespace/structural controls |
| Compiler/Base/reference pins, bounded execution | Passed for delivered records | Each record pins its own closure/tools and limits; no new dependencies, ordinary checker/build/runtime failures remain failures |
| Equivalent integrated measurement | Partial | Dense/Sparse and Readers timing delivered; exact historical-stale Lifecycle and dynamic repeated FailedTxn still in progress |
| Seven repetitions, ratios and variability | Partial | Completed verified Dense/Sparse/Readers sizes retain raw samples; failed larger prerequisites are excluded with explicit deadline failures |
| Memory method and limits | Failed original method; corrected gate pending | Parent RSS contamination independently reproduced; old values explicitly withdrawn, small clean launcher controls pass |
| Native substantially faster, JS comparable | Failed current evidence | Dense/Sparse regress on both backends; JS Readers regresses; Native Readers faster on completed sizes does not establish overall acceptance |
| Two-axis review and capability disposition | Partial | Current main/mutation pins reviewed; remaining measurements and final negative-result disposition need review |
| Useful research-negative alternative | Pending | Reviewed concrete redesign follow-up #20 is published; finish remaining observations or exact bounded failure evidence before reporting completion |

Primary files are under `experiments/s-integrate/`;
[execution ledger](../design/s-integrate-capability-ledger.md),
[Spec review](../reviews/s-integrate-final-spec.md),
[Standards review](../reviews/s-integrate-runtime-standards.md) and
[performance follow-up #20](../tickets/19-integrated-performance-redesign.md)
retain the exact scope. No universal runtime refinement, new law approval or
production layout adoption is inferred. Full-core tracker #1 remains open.
