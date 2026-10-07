# #47 — typed entity-component state delivery

Complete for the governing finite component-state slice; full core and product
performance qualification remain open. Verified delivery is on master at
`26316f52`, with the independent final review and this report completing the
publication steps. The archived integration draft is historical and superseded
by this report; its receipt-bound bytes are preserved.

| Acceptance criterion | Direct evidence |
| --- | --- |
| Pinned State defaults, legal values, matching, constructors and invalid values | 54 actual TS descriptor observations and three complete TS/JS/Native constructor comparisons. |
| Heterogeneous state application across two schemas | 62 complete application rows: independent state families, replacement, change readers, barriers, failed-write rollback and fully returned four-cell affine neighbors. |
| Access/type/schema refusals and meaningful defects | Eight intended negatives and five reached compiling mutants on both backends, including wrong-state endpoint; six independently created same-schema foreign-world controls plus access/raw/clock observations. |

[Portable live evidence](../../experiments/public-component-state/evidence-live-qualified-v1/receipt.json.gz)
retains the 87-command PASS_FINITE_SLICE receipt, SHA256 after decompression
`1219a8ef1bb3c0d5e3eaee56b1c8c577a695afbf3af00ed9f092973005bb4183`.
All 61 consumed-source pins match. The [final independent audit](../reviews/component-state-delivery-final.md)
found no further executable Spec/Standards blocker.

[Batch regression](feature-world-batch-regression.md) passes the unchanged #28
gate (43 inputs, exact 38-core-module inventory) and affected 99-command reader
replay. Complete feature timing retains all 120 balanced pairs at 1/2/4 full
lifecycles. JS/TS is 2.8922/2.8217/2.7233; Native/TS is
0.05104/0.06079/0.07476. The JS deficit remains explicitly owned by #21/#23/#24;
this closure neither waives their targets nor qualifies full product performance.
Before/after profiles show sampled allocation traffic reductions of 34.4%/38.6%
at scales 1/4, not physical/RSS reductions or causal timing guarantees.

Consumer equality, endpoints, decoders and providers remain trusted contracts.
Checked local writes do not imply enclosing transaction commit. General decoding
belongs to #46; global machines belong to #48. New state/equality laws remain
unapproved; finite comparisons and mutants are not universal runtime refinement.
No dependencies, thresholds, baseline or contract approvals changed.

Bend 2.0.35, Node 24.20.0, approved private Clang 19.1.7; checker/runtime
5 seconds, emit 30, compilation 120; Native one thread and GPU disabled.
Exact reference commits, all outputs, profile hashes and failed attempts are
retained in the delivered experiment evidence.
