# S-PERF #20 — indexed ECS storage experiment

Implemented candidate; final evaluation/reviews are in progress. Production
performance and layout adoption are not approved.

`candidate/storage.bend` owns affine Main/Aux columns, Data metadata, balanced
capacity and committed high-water. IDs map to checked `id-1`; supported experiment
IDs are 1..131072. Main reads/writes/inverses/structural edits leave Aux untouched.
`commands.bend` preflights the complete queue and applies FIFO commands with a
self-tail loop. Capacity rejection returns all pending owners before any prefix
is applied. Host converts explicit failure to IO failure. Queries remain ordered.

Baseline `a976667` and read-only reference pins are frozen in `baseline.json`.
Generate a fresh runtime copy without changing baseline files:

```sh
python3 experiments/s-perf/overlay.py /tmp/bendvy-indexed-replay
BENDVY_CPU=3 python3 experiments/s-perf/main-run.py --overlay /tmp/bendvy-indexed-replay --build-dir /tmp/bendvy-indexed-main
python3 experiments/s-perf/access-run.py /tmp/bendvy-indexed-replay
python3 experiments/s-perf/e11-run.py /tmp/bendvy-indexed-replay
python3 experiments/s-perf/main-mutations-run.py --overlay /tmp/bendvy-indexed-replay --output-dir /tmp/bendvy-indexed-mutations --cpu 10
python3 experiments/s-perf/candidate/owned-storage-run.py
python3 experiments/s-perf/measure-run.py --overlay /tmp/bendvy-indexed-replay --build-dir /tmp/bendvy-indexed-dense --lane dense-sparse --cpu 2
python3 experiments/s-perf/measure-run.py --overlay /tmp/bendvy-indexed-replay --build-dir /tmp/bendvy-indexed-readers --lane readers --cpu 5
python3 experiments/s-perf/lifecycle-run.py --overlay /tmp/bendvy-indexed-replay --build-dir /tmp/bendvy-indexed-life --cpu 10
python3 experiments/s-perf/ts-occupancy-run.py --build-dir /tmp/bendvy-ts-physical --cpu 4
```

Use fresh destination paths. Run commands on a supported CPU and serialize work
assigned to the same CPU. References must exist at the documented workspace paths;
Node24.20.0 imports the pinned TS sources without added dependencies.

Primary evidence: `main-evidence.json`, `access-evidence.json`, `e11-evidence.json`,
`main-mutations-evidence.json`, `owned-storage-clean-replay-evidence.json`,
`dense-sparse-evidence.json`, `indexed-readers-evidence.json`, `lifecycle-evidence.json`.
`readers-evidence.json` is the separate descriptor-alignment gate, not indexed timing.
FailedTxn has its own `failure-README.md` and frozen replay packages.

Checker/runtime5s, codegen30s, clang120s; Native O3/one worker/GPU off for measured
work. Joined semantic mutations use Native O0 and JS, explicitly separate from
timing. Negative attempts stay in evidence; no timeout is a mutant kill. RSS uses
the small exec-reset C launcher; allocation counts are not inferred from it.

Main/E11/ownership/access/mutations pass. JS timing parity remains failed;
Readers' double-world measurement protocol has bounded larger-case failures.
Quiet FailedTxn and workload occupancy are still being finalized. These results
are finite executions, not universal ECS laws or production acceptance.
