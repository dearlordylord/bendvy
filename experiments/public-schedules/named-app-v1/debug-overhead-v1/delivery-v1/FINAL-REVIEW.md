# #56 debug-overhead-v1 final Spec/Standards review

**Verdict: PASS for the bounded 37-path delivery and its stated experiment scope.** This does not close the full #56 acceptance or establish a performance win.

Reviewed producer tip `9bbdd31891066c0f1dbdf93336061c7668c44191` against base `1c73c4eb4bba761ed2dfd6a19798380eb703fddb`. The commit has exactly 37 changed paths, matching `delivery-v1/OWNERSHIP.json`: six opt-in benchmark harness scripts and the 31-path experiment/delivery leaf. The existing 15 wrappers and production/core implementation are unchanged. The candidate two-file core patch is retained as archive evidence only.

The source model and harness agree on the bounded question: run fresh Workshop/Garden scenes for complete, enabled, and disabled modes at scales 1/2/4, with disabled mode returning before schedule-name/debug-description work. The six script changes preserve existing default choices and fail closed unless named schedules were staged explicitly. Exact source-derived output files are kept separately for each mode and scale. Receipts retain complete stdout/stderr, argv, source and tool bindings, ordered guards, paired comparisons, and the distinction between semantic runs pinned to CPU 5 and diagnostic profiles pinned to CPU 11. The retained zero-child profile attempt is correctly marked incomplete; its variable-ASLR `ldd` comparison produced no child artifacts.

The portable verifier independently checks the archived source models and full output oracles, all manifest/member/source-path joins, the 1,157 command and 1,065 complete-output records, eight profiles, and nine malformed controls. I ran:

```text
taskset -c 0 python3 experiments/public-schedules/named-app-v1/debug-overhead-v1/delivery-v1/verify.py --selftest
PASS_RETAINED_NAMED_MODES 2892 members; 1157 commands; 1065 completeoutputs; 8 profileoutputs; 9 malformedcontrols
```

A fresh copied/relocated 37-file packet also passed the same selftest. After changing a relocated owned source file, verification rejected it with exit 1. No compiler, Bend, Node, backend, or benchmark was run for this review.

The evidence and the three root documentation updates (`docs/parity/debug.md`, `docs/parity/README.md`, and `docs/reports/delivery-process-expectations.md`) use consistent limits. Baseline JS remains about 2.07–2.45× TS across the reported cells; Native exceeds 0.5× TS in four reported cells. The candidate aggregate cohort has no consistent timing benefit, and its Native scale-4 result misses the stated target. Sampled allocation counts/sizes are whole-process samples, not exact allocation totals, RSS, or operation-only measurements. The core candidate remains unadopted, the 23-file #28 closure is explicitly bounded rather than a fresh overall gate, and full #56 timing/scaling/feature acceptance remains open.

The packet bindings checked here are `DELIVERY.json` SHA-256 `e3674433a70ddf03ef81a650f982429bf947abe00ed7a2b2d9d410d40754989f`, `MANIFEST.json` `baec886c2af4d951daaf28e17521838a13c7f683c85d9b2dda0f3354f5bd3435`, and `EVIDENCE.zip` `5f72c00592881994c7c03ecd631edffc8ab983f8b7de898537d0aec893dbe1af`.
