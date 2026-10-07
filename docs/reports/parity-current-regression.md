# Current parity frontier regression

Command: `python3 benchmarks/run.py --output .artifacts/parity-current-default-regression --cpu 11`.
Terminal status: NO_CONFIRMED_REGRESSION. Twenty balanced pairs per backend use
the unchanged baseline/workload/statistical contract; all 37 current source
hashes, including the three new modules, match after execution.

| Ratio | Median | Scope |
| --- | --- | --- |
| JS / frozen Bend baseline | 0.9967384720 | Paired protected workload |
| Native / frozen Bend baseline | 0.9987585196 | Paired protected workload |
| JS / bevy-ts | 0.4169093249 | Descriptive same Workshop workload |
| Native / bevy-ts | 0.0728693646 | Descriptive same Workshop workload |

Receipt and all 110 compressed observations are retained in
`benchmarks/evidence/parity-current-default-regression/`, with a byte manifest.
The protected workload does not exercise all new feature paths. Equivalent
feature-specific measurement and full-core qualification remain open; this
receipt is not approval of laws or full parity and does not close #34/#35/#39.
