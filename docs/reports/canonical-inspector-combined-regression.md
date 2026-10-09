# Canonical Inspector combined regression

The unchanged default #28 gate passed on the combined 109-module candidate:
`NO_CONFIRMED_REGRESSION`, 20 balanced pairs per backend. All 110 complete
observations and the execution archive are retained in
[benchmark evidence](../../benchmarks/evidence/canonical-inspector-combined-regression-v1/receipt.json).
Receipt SHA256: `9ff688657db4643839ef2ffb8e889be6f759cdd6d5554ee12f41f805e9e2ba2d`.

| Median ratio | Result |
| --- | --- |
| JS / frozen Bend baseline | 0.87688558 |
| Native / frozen Bend baseline | 0.96188508 |
| JS / bevy-ts | 0.38718728 |
| Native / bevy-ts | 0.09382175 |

The first two ratios use the unchanged paired statistical contract; the last
two are descriptive same-cohort Workshop comparisons. This protects the frozen
API workload, including startup and output, rather than the new composed-query
hot path or full parity. No baseline, tolerance or workload changed. Bend2.0.35
and Node24.20 were selected through temporary aliases to their pinned installed
executables; the approved private Clang19 installation was reused. A five-second
host observation showed CPU5 about8.8% busy before the exclusive cohort.

Canonical full23 JS and its reached reader countermodel are qualified separately.
Full23 Native remains incomplete: the single canonical emission reached30s
without C, so build/runtime and reader Native were not attempted. #54/#56,
equivalent feature timing and full-core qualification remain open.
