# S-PERF Standards review

Independent review of `a976667...d95f83c`, including the subsequent clean-checkout
`owned-storage-run.py` repair (SHA256
`02d50b146f3b50d61b013bfc1db1f3875d7e22b4127f7b418c8542aae3e676ba`).
Standards: AGENTS.md, issue-tracker.md, SPEC.md, indexed-storage/API/design review,
and bend-ldd. Live #20 was read. Delivery artifacts require the closing
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
when these experimental scripts become maintained tooling. Separate frozen
subjects currently aid evidence attribution; no extraction is required now.

`failure-indexed-prepare.py` names historical `/tmp/bendvy-indexed-final2` and
an absolute repository path. Fowler MysteriousName suggests naming this as a
historical construction helper. Clean replay should use committed frozen overlays
and documented build/validation commands; recreating that vanished snapshot is
not a prerequisite for inspecting or executing those packages.

## Delivery supplement

Reviewed `c838719` and `eb1c066`: no additional hard violations. The TS physical
diagnostic adapter copies pinned reference sources, records actual state and
checks unchanged full callback observations; first failed attempts remain
retained. The clean owned replay now documents its three semantic mutants.
The README supplies fresh-overlay commands. The provisional completion report
explicitly marks evaluation incomplete, rejects production adoption and records
missing workload/diagnostic gates and concrete return conditions. Final quiet
FailedTxn, actual Bend Readers diagnostics and the final closure decision remain
outside this supplement; they require their own source/evidence review.
