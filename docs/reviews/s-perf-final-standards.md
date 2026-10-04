# S-PERF Standards review

Independent review: `a976667...d95f83c`, supplements `c838719`, `eb1c066`,
`397a6e8`, `19f3746`, final quiet package `b2e8d12` and closure ledger `1525208`.
Sources: AGENTS.md, issue-tracker.md, SPEC.md, indexed-storage/API/design review,
bend-ldd and live #20. **No hard Standards violations found.** Bounded negative
research delivery is supported; product performance/adoption remains failed.

- `candidate/storage.bend`: SPEC requires affine ownership and prohibits an
  unapproved Data-only restriction. Main/Aux remain Type arrays; extraction uses
  `Array.swap(...,None{})`, then restores returned owners. `Array.get` reads only
  Data metadata. Trusted restoration/domain bounds and unresolved root authority
  are explicit. Actual provider negatives cover undeclared access, cross-schema,
  write-through-read and affine Audit duplication, as AGENTS requires.
- `candidate/owned-storage-run.py`: independent CPU11 replay exits0:39 Native/JS
  observations, three intended compiler negatives and three compiling semantic
  mutants. Runner SHA256 `02d50b146f3b50d61b013bfc1db1f3875d7e22b4127f7b418c8542aae3e676ba`;
  output `7bced8798616cfeee6e40487942d55b0852aac3f64fa34bf622ed8c1139ac52d`.
  Clean dependency materialization works. Checker/runtime5s, codegen30s/clang120s;
  no overlapping owned runtime was observed.
- Readers diagnostics: independently checked twelve gzip hashes,14352 records,
  Native/JS equality, physical/cache consistency, recomputed maxima and retained
  final records. Hooks return actual owners without invoking readers/trimming.
  Active-Tx/setup/RSS unavailability remains explicit; fixture peaks never replace
  workload peaks. TS instrumentation modifies a pinned private copy only.
- Quiet FailedTxn: source/codec hashes match executed evidence. Actual complete
  event/effect projection and fold precede the end clock; full lossless decoding
  validates observations after execution. Two compiling JS mutants retain four
  exit0 field/reader counterexamples. All126 repetition attempts remain:120 pass,
  six actual deadlines, five complete groups. Cold-VM warmup and timer resolution
  are explicit partial gates, with same-child warmup/recollection return conditions
  in #21. Closure claims bounded negative delivery, not performance acceptance.

Baseline's nine evidence hashes/reference commits independently match. Bend2.0.34
and guide were checked. No new law/proof, dependency, threshold, reference or Tower
Defense edit appears. Finite evidence establishes no universal runtime refinement.

**Heuristics, not violations:** DuplicatedCode in access/occupancy/owned runners:
`os.killpg(p.pid,signal.SIGKILL)` then `communicate()` suggests a shared bounded
runner when tooling matures. MysteriousName in `failure-indexed-prepare.py`:
`/tmp/bendvy-indexed-final2` suggests labeling historical construction explicitly;
replay uses committed frozen overlays. No extraction or historical snapshot
reconstruction is required for this delivery.
