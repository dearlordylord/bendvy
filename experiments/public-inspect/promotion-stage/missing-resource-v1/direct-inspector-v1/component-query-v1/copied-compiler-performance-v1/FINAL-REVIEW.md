# Final review: copied-compiler-performance-v1 profile slice

**Verdict: PASS for this bounded runtime-profile slice.** No launch, compiler, benchmark, or test execution was performed during review. This does not close #54.

The reviewed commit is `16f1c0c5bc1032ed13d07bdc2ade18265c4b0ad4`; it adds 44 files under the owned `copied-compiler-performance-v1` child. The launch review, FREEZE, three plan hashes, receipts, and profile artifacts join exactly. CPU and allocation each have four recorded guards, all `unchanged: true`. Both consumers exited 0 with empty stderr and matched the full 207,834-byte oracle (SHA-256 `14565a3635124edb3ba8ef53b76e2030c3b3698e5d7c4a31989bc3ca9fb54a2d`).

The raw CPU profile has 1,134 samples; recomputation matches the summary, including one signed `-2 µs` delta and a signed sum of 219,518 µs. The heap profile has 426 samples; recomputed sampled-record bytes total 7,154,560. These are single-run whole-process diagnostics, not before/after comparisons, total allocation, or RSS. Every mapped generated-JS line and call-frame name matches the pinned current `scenario.js`.

`DELIVERY.json` binds `EVIDENCE.zip` at SHA-256 `7979f823f5d0d0146eacb8930d8dab95b130a4e127076f76f0fa8ad297d13cbc`. All 305 archive members match the manifest with no missing, extra, or digest-mismatched entries. The archive contains no ELF/executable payloads; installed-tool bytes remain hash-only. It records the required environmental process names and paths for the contention observation, without process contents or credential values.

The unchanged regression cohort is explicitly `NOT_RUN_DEFERRED_CPU11_CONTENDED`. The just-in-time record shows CPU11 busy for its first eight intervals; `cpu11Allowed` records availability, not quietness. No benchmark, speedup, installed-compiler adoption, Native-performance, or #54-closure result is claimed.

One portability limit remains: both profile plans pin the prior inline-layout31 Unit JS receipt (`862c310e…`), and its live workspace content binds the same JS digest (`ff4b2ef0…`), but the receipt body is hash-only excluded from this archive. The current JS, full oracle, profile outputs, and run receipts are included and verified; an archive-only reader cannot inspect that prior receipt's fields.
