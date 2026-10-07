# Source-current isolated equality change: diagnostics

Full staged public state semantics pass87 commands, including complete normal owners/arrays/errors/stamps and five compiling reached mutants in both JS/Native. The independent three-scale timer subject passes32 commands with full62/124/248 rows matching actual TS byte-for-byte. Exact root patch adds one helper and replaces only the two World access/name String.eq calls. No live src change.

Eight changed diagnostic profiles pass all full outputs with identical baseline protocol (CPU100us; allocation512bytes, collected minor/major included; separate fresh processes for modes, JS/TS, scales1/4). Baseline profile receipt and changed executable/source/tool receipts are bound in comparison-bindings.json. Archives retain all exact profiles and outputs; generated artifacts/compiled binary hashes remain source-bound.

| Scale | Before JS estimated sampled allocation bytes | After | Observed reduction |
|---|---:|---:|---:|
|1 lifecycle/62 rows|3,518,184|2,436,752|30.7%|
|4 lifecycles/248 rows|11,547,664|7,531,000|34.8%|

These are weighted single-profile allocation-traffic estimates including inspector overhead, not physical/RSS/live-heap quantities, statistical acceptance or speedup ratios. TS diagnostic samples were941,880→921,648 and2,608,472→2,613,384bytes. Their stability is useful context but does not calibrate sampling uncertainty.

The prior dominant String.cmp+cmp.fin allocation path disappears from the leading samples. Scale4 now shows closure dispatcher run_clo770,280bytes, slice687,272bytes, new equality_walk267,568bytes; sliced string traversal remains. Generated equality_walk is an explicit loop with continue, without recursion or reconstructed Tuple/Cmp nodes. Full generated JS files at scales1/2/4 are identical after normalizing only the repetition literal. No short-circuit claim.

CPU ranks are diagnostic hypotheses: scale4 JS174 samples, watcher_inner3,139us, GC978us, U32.show617us, state.apply521us; inspector post9,359us excluded from application interpretation. Baseline scale4 GC1,572us and String.cmp3,993us are not a matched timing experiment. No stable percentage attribution or cold-compilation conclusion.

The changed subject is ready for the unchanged20balanced pair protocol/scales1/2/4 in a separately admitted quiet window. Until those observations and default #28 regression complete, this is an isolated semantic/profile candidate, not production delivery or #47 closure. Existing backend-specific surrogate observations remain explicit; no compiler/runtime/Base/domain policy change, laws or proofs.
