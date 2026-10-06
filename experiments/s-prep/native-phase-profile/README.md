# Native computation-only profile

Diagnostic evidence under #21/#24, not qualified timing or full22 acceptance.
The generated C copy enables gprof sampling only between the frozen Motion
driver's third and fourth `IO.now` effects (warmup uses clocks1/2).
`main` disables sampling first. Exactly four clocks are required; stderr is
captured separately to prevent markers splitting JSON output.

Both combined and boxed/batched candidates pass all65 full worlds against fresh
pinned bevy-ts. The compiler, runtime modules, authored callback algorithms and
work are unchanged by the C sampling recipe. Whole-process call counts are not
phase-only; the reported flat **sampled self time** is bounded by the clock gate.
Sampling is10ms, with only82 combined /53 boxed phase samples in these runs.
Different CPUs/shared-machine noise prevent a comparative timing conclusion.

| Phase self-time site | Combined (CPU11) | Boxed+batched (CPU10) |
| --- | ---: | ---: |
| term_drop |21.95%|22.64%|
| reached spin75 |19.51%|13.21%|
| motion_row |10.98%|20.75%|
| dispatcher visit continuation |19.51%|11.32%|
| rfc_wrap |3.66%|9.43%|

A separate adjacent unprofiled CPU11 diagnostic validates all65 worlds for each
variant: TS1339.735ms, combined1260ms, batched-only3203ms, boxed+batched986ms.
These are one raw observation each. Batched-only's later profiled run reports831ms
and68 samples, so its3203ms observation does **not** establish a reproducible
regression. Host load was about14 on12 available CPUs; the container reports no
CPU quota/throttling. No process owned by another task was stopped. Keep the
outlier and the uncertainty; do not select an implementation from these clocks.
The initial neighbor summary used an incorrect TS key; retained executions are
independently validated by `validate-comparison.py` using `batchMilliseconds`.

Preparation/serialization is excluded from this sampling window. An earlier
whole-process profile attributed21% to a printing-related helper; that is not a
valid reason to optimize serialization for the measured compute interval.
Remaining targets are affine owner transport, reference-count/drop traffic and
dispatcher continuation context; percentages alone do not establish causality.

Reproduce with an exact generated C and the frozen TS Motion64 driver:

```sh
python3 experiments/s-prep/native-phase-profile/run.py \
  --source /tmp/batch.c --reference /tmp/Motion.mjs \
  --output /tmp/fresh-phase-profile --cpu 11
```

Requires existing clang/gprof/Node; no dependency installation. Caps remain
clang120s/runtime5s. [Archive index](evidence-index.json) pins C, gmon, full outputs,
clocks and receipts. Two runner failures are retained: mixed stderr markers split
JSON, then the receipt used the wrong recipe filename. Both are corrected; fresh
successful executions are distinct receipts. No repeated measured-loop allowance
was renewed.

## Native1024 continuation

The 2026-10-06 source-v8 Linux/aarch64 process-PC diagnostic is recorded separately
in [NATIVE1024.md](NATIVE1024.md). Its sampled clocks are excluded from comparative
timing; this earlier gprof evidence remains unchanged.
