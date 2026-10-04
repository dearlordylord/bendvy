# S-PERF Standards review

Independent review of `a976667...d95f83c`, including the subsequent clean-checkout
`owned-storage-run.py` repair (SHA256
`02d50b146f3b50d61b013bfc1db1f3875d7e22b4127f7b418c8542aae3e676ba`).
Standards: AGENTS.md, issue-tracker.md, SPEC.md, indexed-storage/API/design review,
bend-ldd and live #20. Delivery artifacts require the closing
review supplement below.

**Hard standards violations: none found in the reviewed implementation.**

- `candidate/storage.bend`: SPEC requires affine ownership and forbids an
  unapproved Data-only restriction. Main/Aux remain Type arrays; extraction uses
  `Array.swap(...,None{})` and returned owners are restored. `Array.get` reads
  only Data metadata. Trusted restoration and finite domain bounds are explicit;
  universal root authority/destructive recovery are not claimed.
- Access/owned controls: AGENTS requires undeclared-access, cross-schema and
  write-through-read negatives. Actual provider controls retain intended
  diagnostics, including affine Audit duplication. Independent CPU11 replay of
  the repaired owned runner exits0: 39 Native/JS observations, three compiler
  negatives and three compiling semantic mutants. Checker/runtime5s,
  codegen30s/clang120s; no overlapping owned runtime was observed. Output SHA256
  `7bced8798616cfeee6e40487942d55b0852aac3f64fa34bf622ed8c1139ac52d`.
- Evidence/build artifacts: retained deadline failures are separate from semantic
  kills. Baseline/reference pins match actual sources; Bend2.0.34 and guide were
  checked. No new ECS proof/law, dependency, numerical threshold, reference edit
  or Tower Defense change appears in this diff. Product performance remains
  failed; finite traces/inspector controls supply no universal refinement.

**Heuristic observations, not hard violations:**

`access-run.py`, `occupancy-run.py`, `candidate/owned-storage-run.py` duplicate
process-group deadline cleanup: `os.killpg(p.pid,signal.SIGKILL)` followed by
`communicate()`. Fowler DuplicatedCode suggests a shared bounded-runner shape
when these experimental scripts become maintained tooling. No extraction is required now.

`failure-indexed-prepare.py` names historical `/tmp/bendvy-indexed-final2` and
an absolute repository path. Fowler MysteriousName suggests naming this as a
historical construction helper. Replay uses committed frozen overlays; recreating that snapshot is unnecessary.

## Delivery supplement

Reviewed `c838719` and `eb1c066`: no additional hard violations. The TS physical
diagnostic adapter copies pinned reference sources, records actual state and
checks unchanged full callback observations; first failed attempts remain
retained. The clean owned replay now documents its three semantic mutants.
The README supplies fresh-overlay commands. The provisional completion report
explicitly marks evaluation incomplete, rejects production adoption and records
missing workload/diagnostic gates and concrete return conditions. Final quiet
FailedTxn and the closure decision still require review.

Readers supplement `397a6e8`/`19f3746`: no hard violations. Independently verified
all twelve gzip hashes, 14352 records, Native/JS record equality, physical/cache
consistency, recomputed checkpoint maxima and retained final records. Hooks return
actual World/registry/Run owners without invoking readers or trimming. Missing
active-Tx/setup/RSS cells remain explicit. The report distinguishes single-world
diagnostics from failed measurement children; #21 retains performance, timer
resolution and actual transaction-meter return conditions. No duplicate runtime
was run for this review.
