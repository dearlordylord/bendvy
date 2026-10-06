# Source handoff observation seam

`observe.py` consumes a prospectively frozen plan and runs five roles sequentially
on CPU11: pinned TS, baseline JS/Native, handoff JS/Native. Ten rotations place
each role in every position forward and reverse. Dense256 uses64 iterations,
one fresh warmup world and64 fresh measured worlds; every role must match all65
complete TS observations, including rows and retained world fields. Setup and
serialization remain outside the authored update bracket. Runtime children have
five seconds; Native is one worker with GPU disabled. Interpreters and consumed
inputs are pinned before and after execution. The child environment is explicit.

Before each launch, independently verify the prospective plan's actual
source29 closure, complete original driver/setup/callback bodies, build commands
and caps, generated artifacts and every JS recipe/catalog/input-output join.
Pin all those files, the reference core, measurement helpers and runtime binaries.
JS argv must be exactly `node program`; Native must use `--threads 1 --gpu off`.
Old source4baa receipts cannot establish candidate correctness. Require fresh
candidate ownership/access/transaction controls and actual hot-path reachability
before interpreting any transformed JS. A dormant transformation is not a
candidate optimization.

These are direct raw diagnostics, with no canonical packet, noise qualification,
keep, production adoption, full workload matrix or universal refinement claim.
The exhausted canonical20/20 budget is unchanged. Failed and adverse observations
must remain in the eventual evidence archive.

## v7 delivered raw cohort

`prepare-plan.py` enrolls exact source v7 only. The first 705-file plan was
rejected before execution because producer/tool recipe bindings were missing.
The corrected 709-file plan was independently replayed and admitted; its SHA is
`02e689a5385d8b0a1e2370be9bc83ae724d665d2546a45cfe531d0dd71ebdd86`.
All twenty fixed schema/rotation attempts matched every field of all65 worlds.
[`v7-summary.json`](v7-summary.json) retains every clock and range. The decoded-SHA
archive contains exact plans, observer/launcher bytes, outputs and receipts.

| Schema | TS median ms | JS median ms | Native median ms | JS/TS | TS/Native |
| --- | ---: | ---: | ---: | ---: | ---: |
| Motion | 192.665410 | 193.5 | 93 | 1.004332 | 2.071671 |
| Health | 188.668197 | 198.5 | 98 | 1.052112 | 1.925186 |

The v7 Native median regressed19.23%/22.5% against the previous source4baa
baseline. Both requested thresholds were not jointly achieved. v7 is not adopted.
Candidate JS uses freshly reached row/pool/Tuple transformations; baseline JS
uses its historical selective/swap composition. The latter guards correctly
reject v7, so these clocks cannot isolate the source change's causal contribution.
Own heavy workers were idle during the sequential cohort; unrelated processes
were preserved. No noise qualification or per-child RSS measurement is claimed.
`summarize.py` reproduces ratios from all ten complete rotations per schema.

## v8 fused source and RSS

`prepare-plan-v8.py` enrolls the coherent v8 source and fresh producer recipes.
The independently reproduced 742-file plan SHA is
`2acbe3b5ae83c4feeb8018c6cc961efed039fd868cdb31f04237690e55d6758c`.
`observe-v8.py` retains all twenty complete65 matches and fresh child peak RSS.
[`v8-summary.json`](v8-summary.json) records every clock and sidecar. Motion/Health
raw JS/TS medians are0.943504/0.967062 and TS/Native2.218352/2.262005.
v8 Native is8.86%/10% slower than the unchanged-source baseline.
These Dense256 observations are unqualified; no keep or adoption follows.
[Fresh Dense64/1024 observations](../source-handoff-dense-sizes/README.md) show
Native2x failure at1024 in both schemas. The overall performance goal is unmet.

The nine-world diagnostic in `profile/` observes complete outputs and samples
CPU/GC with perturbing flags. It is separate from comparative timing/RSS.

`v7-evidence.tar.xz` and `v8-evidence.tar.xz` retain all exact logical evidence
bytes in SHA256-addressed blobs; adjacent manifests map original paths to blobs.
Run `python3 verify-archive.py ARCHIVE` to check every decoded SHA and length.
`archive.py` recreates this lossless format from the documented capsule roots.
Initial refused enrollments, adverse timings and failure controls are retained.
Executable binaries are hash-pinned and reproducible from separately tracked
source/build evidence; they are intentionally excluded from the capsules.
