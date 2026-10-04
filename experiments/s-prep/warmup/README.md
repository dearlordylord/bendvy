# Same-process FailedTxn warmup preparation (#22)

Frozen input: master `56b72f6`; historical #20 quiet package is unchanged. This repairs process placement, not storage or a performance optimization loop. All six inputs are the original two schemas × 64/256/1024 entities × 64 failed/retry iterations.

## Actual implementation and checks

`prepare.py` copies the pinned historical quiet closure into an isolated materialization. One shared Bend setup/ready/loop body runs twice: the first fresh runtime executes the complete workload and common full-field fold, consumes its actual affine owner, then a distinct fresh runtime executes the measured workload in the **same Native or JS process**. The TS adapter similarly calls its actual public-runtime body twice within one Node module process. Actual rank-2 callbacks, services, Type payloads, inverses, reservations, readers, queries, barriers and Audit effects are retained. No expected-state guard was added to timing.

The common modular U32 fold and one small forcing print remain inside each measured interval. Lossless measured tuples and retained capture observations are transported after its end timestamp. Warmup retains/forces every original field/effect through that same fold, then consumes its tuple; its records are not transported. Warmup fold agreement is a forcing control, **not** independent full-record warmup validation. Measured records receive complete field/effect comparison against fresh actual TS and the unchanged original full-field oracle.

Both roots use freshly initialized private factories with namespace 1. This is two sequential confined factory lineages, not globally unique namespaces. No warmup handle, world, registry, reader or Audit owner is supplied to the measured root. TS descriptors, handles, closures, counters and output arrays are function-local to each run; only the schema/count inputs and pure codec are shared. The Bend warmup owner is consumed before the second `*_start` invocation. This does not establish isolation between arbitrarily escaping independently initialized roots.

## Results

- Five-second checker PASS; C/JS codegen PASS within 30 seconds; Native O3 build PASS within 120 seconds.
- **16/18 complete measured-record gates pass:** all six TS, all six Native O3, and four JS cases (both schemas at 64 and 256).
- Motion1024 JS and Health1024 JS each hit the actual **five-second runtime deadline covering both worlds together**. Neither is decoder failure or a passing gate. No retries, deadline increase, reduced observations or successful-subset timing ratio were substituted.
- Two compiling actual decision-path mutants pass checker/codegen and execute JS successfully in both schemas at 64. Changing the fourth reserved payload cell yields the intended `Reserved` full-record mismatch. Completing the failed reader yields the intended `FailureRead` mismatch. Four semantic counterexamples; no compilation/deadline failure counts as a kill. Audit effects remain identical.

The repaired protocol is consequently **partial**, not ready for all six cases. Return condition: make equivalent complete warmup + fresh measured worlds fit the unchanged five-second JS limit at 1024, or obtain a shared reviewed workload/protocol repin. Independent full-record warmup transport/validation is also an explicit additional validation seam if required before freezing a future evaluator. No product performance qualification or seven-rotation loop ran here.

## Reproduction and provenance

From this worktree:

```sh
bend version
bend guide
python3 experiments/s-prep/warmup/prepare.py
python3 experiments/s-prep/warmup/run.py
python3 experiments/s-prep/warmup/mutate.py
```

All runner descendants are pinned to CPU7; the historical command helper kills only its own process group on a deadline. Checker/runtime/reference/decoder limits are 5 seconds, codegen 30, clang 120. The runner reports every actual bounded failure rather than treating its own terminal success as all-case acceptance. Temporary mutation copies are task-owned.

`pins.json` pins the complete materialized closure; `driver-generated.bend` and `reference-generated.mjs` preserve reviewable generated entry points. `evidence.json` records current compiler/Base and original reference hashes, actual artifact hashes, stage output and per-case full-validation results. Raw lossless tuples are at `/tmp/bendvy-prep22-warmup/{schema}-{count}-{backend}.txt`, with hashes recorded. They are reproducible task-local artifacts, not required pre-existing input. `mutation-evidence.json` records each full first difference. Initial affine duplication and duplicate-body checker-deadline negatives remain separate artifacts; the final implementation shares the body. No core/reference/TD/dependency/proof/law change is part of this package.
