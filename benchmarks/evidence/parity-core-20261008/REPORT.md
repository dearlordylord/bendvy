# Prospective parity core: unchanged Workshop regression

The unchanged #28 workload completed all twenty adjacent pairs per backend on
CPU11. Each measured process produced the ten complete applications and all
twenty-two expected checkpoints per application. The separate reconciled decision
is `NO_CONFIRMED_REGRESSION`: median paired current/baseline ratios JS0.88695,
Native0.98262; slower pairs6/20 and8/20 respectively. The baseline remains
`327bec49`; workload, sign test, Holm correction and numerical contract are unchanged.

The original runner ended with `ERROR`: its initial inventory included
`scripts/task_runner.py`, while its final inventory omitted that same file.
Actual source hashes and membership were unchanged. The independently reviewed
fix adds the file to the final inventory. The original receipt and original
runner bytes are preserved. A separate reconciliation verifies complete raw
observations, randomized command order, command/timing/pair joins, both source
stages, generated artifacts and pinned reference contents, then applies the
unchanged statistical decision. These post-execution checks are not relabeled as
historical passes. Statistical tests passed4/4; no measured process was replayed.

Same-cohort descriptive whole-process current/TS time ratios are JS0.39314 and
Native0.08741. These protect only the frozen Workshop workload; they establish
neither complete parity nor the separate full-core product performance targets.
No comparative feature-specific timing, hot-path floor, universal proof, #48
stream semantics or pending ownership contract is qualified by this receipt.

The lossless archive retains the original error receipt, derived reconciliation,
raw warmup/timed outputs, both source stages and generated JS/C. Native binary
hashes remain in the receipt; binaries are excluded. Bundle and handler core
drafts must additionally match their respective source-current semantic gates.
