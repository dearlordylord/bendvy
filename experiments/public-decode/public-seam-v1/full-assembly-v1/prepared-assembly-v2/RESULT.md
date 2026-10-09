# Admitted complete execution result

All five reviewed v2 cohorts ran once, sequentially under the shared lock, with unchanged CPU5 / emit30s / runtime5s caps. All children exited zero; frozen source/tool/environment/log/generated guards passed. No retries or cap increase. Historical v1 cohorts remain blocked/unlaunched.

| Cohort | Terminal result | Complete evidence |
| --- | --- | --- |
| normal JS | `DEVELOPMENT_JS_PASS` | 670799 stdout bytes exactly match independent complete Candidate, typed and raw; runtime stderr empty |
| Local failure JS | `DEVELOPMENT_JS_PASS` | 5391 stdout bytes exactly match independent four-case world/Local/recovery Report, typed and raw |
| skipped validation JS | `DEVELOPMENT_JS_MUTANT_KILLED` | complete strict 816278-byte output differs from correct independent Candidate; intended lateInvalid insertion becomes Replaced rather than ValidationRefused |
| partial write JS | `DEVELOPMENT_JS_MUTANT_KILLED` | complete strict 726151-byte output differs; intended lateInvalid refusal preserves exact outcome/before resource but corrupts after resource |
| normal C emission | `DEVELOPMENT_C_EMIT_PASS` | complete 2782751-byte emitted C artifact retained; compiler streams empty |

`terminal-results.json` records exact admitted plan digests, receipt hashes, child labels/caps/exit/failure. Each original receipt is retained. All raw compiler/runtime streams and generated artifacts are retained as lossless gzip captures outside the original guarded raw/generated directories; `capture-index.json` maps original paths/bytes/receipt hashes to archive hashes. Original executed files also remain unchanged in the preserved worktree. Collector invocation stdout/stderr and exact execution argv/results are recorded alongside preparation evidence.

This establishes the experimental registered application's complete JS semantics, failed Local owner recovery and two reached mutation controls. C emission establishes emitted-source availability only. Native compilation/execution, general shared-core public declaration assembly, immediate spawn and query/write capability integration remain unqualified; #46 is not closed by this result. These are correctness controls, not performance measurements.
