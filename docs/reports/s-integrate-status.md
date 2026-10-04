# S-INTEGRATE status — 2026-10-04

**#19 completed as bounded research with negative results.** The joined experimental ECS now passes the
functional trace and mutation gates. Current measurements reject performance
acceptance; all workload outcomes and corrected memory evidence are delivered and final reviews support the issue’s bounded-negative alternative.
The [completion report](s-integrate-completion.md) records the accepted final disposition.

| Governing criterion | Status | Direct evidence / remaining gate |
| --- | --- | --- |
| Reviewable exact inputs/order/barriers/failures | Passed, bounded | Reviewed `docs/design/s-integrate-trace.md` and pinned fresh reference records |
| Actual nominal access, read/write and owner-return controls | Passed, bounded | Source-current access controls plus actual foreign and structural gates; trusted-lineage confinement remains explicit |
| Joined three-backend stages 2–4 | Passed, bounded | `host-source-current-evidence.json`: ten channels/four lanes, Native O3/JS/fresh TS; E11 twenty originals retain separate source-current pins |
| Intended compiling semantic mutants | Passed, finite | `host-mutation-source-current-evidence.json`: twelve mutations, both backends; E11 ten pipeline mutations and separate namespace/structural controls |
| Compiler/Base/reference pins, bounded execution | Passed for delivered records | Each record pins its own closure/tools and limits; no new dependencies, ordinary checker/build/runtime failures remain failures |
| Equivalent integrated measurement | Partial | Dense/Sparse, Readers and exact historical-stale Lifecycle delivered with explicit regressions/deadlines; dynamic repeated FailedTxn full diagnostic results and explicit quiet-timing/RSS gap delivered |
| Seven repetitions, ratios and variability | Partial | Completed Dense/Sparse/Readers and five root-current Lifecycle cases retain seven samples; failed prerequisites have explicit outcomes |
| Memory method and limits | Corrected method delivered; partial coverage | Original inherited RSS withdrawn. Clean-launcher run: 284/294 children validated, ten deadlines; twelve complete cases. Root independently audited counts, medians and source/launcher/runner hashes; Readers256 remains incomplete |
| Native substantially faster, JS comparable | Failed current evidence | Dense/Sparse regress on both backends; JS Readers regresses; Native Readers faster on completed sizes does not establish overall acceptance |
| Two-axis review and capability disposition | Delivered | Main/mutation/memory pins reviewed; current Lifecycle/FailedTxn records and final disposition reviewed; Spec and Standards support bounded-negative closure |
| Useful research-negative alternative | Accepted | Reviewed concrete redesign follow-up #20 is published; accepted by final Spec/Standards reviews; observations, failures and concrete return conditions recorded |

Primary files are under `experiments/s-integrate/`;
[execution ledger](../design/s-integrate-capability-ledger.md),
[Spec review](../reviews/s-integrate-final-spec.md),
[Standards review](../reviews/s-integrate-runtime-standards.md) and
[performance follow-up #20](../tickets/19-integrated-performance-redesign.md)
retain the exact scope. No universal runtime refinement, new law approval or
production layout adoption is inferred. Full-core tracker #1 remains open.

The [completion report](s-integrate-completion.md) accounts for every governing criterion and the negative-result alternative.
