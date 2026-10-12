# Repeated-pass-v1 final bounded review

Packet: `/workspace/formal-proofs/bendvy-worktrees/observable-query-boundaries/experiments/public-inspect/promotion-stage/missing-resource-v1/direct-inspector-v1/component-query-v1/compiler-candidate-v1/repeated-pass-v1`
Producer commit: `108fed88a8637354211fa22c5ad518ccbe1bac1b`

Verdict: **retain as bounded diagnostic evidence**. The packet proves a source control pass and a fresh JavaScript consumer pass for the reviewed 53-source scenario. It records a Native emit deadline after the final compile-loop pass and restores the 53-file activation before unlocking. It does not provide Native, stock, adoption, performance, or #54-closure credit.

The commit contains 31 paths, all under this child packet; `OWNED-MANIFEST.json` accounts for the 30 owned paths plus the manifest itself. `REVIEW-BINDING.json` is `EXACT_PRELAUNCH_BINDINGS_PASS` with all 133 pins and per-role boundary hashes exact. The bound candidate and patch are SHA-256 `64e1b85102f434f32208bfe579dc4cba699a3427183d7f7ba7b3a2482179f88f` and `419e1e5ada9d950eef3b9df40dacc694beb99c9e5e4002cbebcb051779fb1ebd`; source, JS, Native, outer, and launch plan hashes are `f5a35ecae178b31aa9e6375eb26e176ea55b4d00fb7c5139e8a8e6d7264eae6d`, `9ac6581a5f204185fb202c2675667cce5bda8d9850b44f42ca26640d08303ac2`, `933e669e9617cde761a58a3ead98d086e9c97f4bed7871471d0b2608bb65ea64`, `61396fd00fdf6aedb5f7b2299c3e12175248c77b6b6ce5772e63784023b29c8a`, and `249678882b9c75c7a760ee4d67631bdea721dfcc082ea71055776391e16a1e6f`.

The archive is internally exact: DELIVERY declares 90 members, EVIDENCE.zip contains the same 90 members, and an independent path/byte/SHA comparison found zero missing, extra, or mismatched members. EVIDENCE.zip SHA-256 is `229e44d5f35332adc6905bc9aedf31ad222ca947d3aea4df85124dc1a9d89f90`; RESULT and VERIFICATION hashes are `d6e57c8f5c24c580514e6a5c53c63c03abbf27ab4cb116871e3c362d57de0db1` and `e48ed27f6fe4ecebdf35ec484310db80c017aa2fbe37b48d3882e1d9e97a2efb`.

Recorded role evidence is consistent:

- Source check-only exited 0 under the pinned Bun/CPU-3 command.
- Fresh JS emit exited 0 with empty stderr. The fresh consumer exited 0 and produced 207,834 bytes, SHA-256 `14565a3635124edb3ba8ef53b76e2030c3b3698e5d7c4a31989bc3ca9fb54a2d`, exactly matching the independent oracle; consumer stderr is empty.
- Native emit used the same candidate, CPU 3, and a 30-second cap. It exited with `null`/child deadline, produced zero stdout and 1,272-byte stderr, and produced no `scenario.c`. The planned build and Native consumer therefore did not run.
- The outer receipt correctly has exit 1 because the Native collector failed. Its role list stops after source and JS because the assertion occurs before appending the Native receipt; RESULT separately binds the Native receipt. Restore exited 0, and the recorded five activation files plus remaining 48 files all matched their expected hashes before unlock.

The 1,272-byte Native stderr contains exactly 16 phase markers for eight passes. The pass fact transitions are `0→6127→6467→6496→6499→6505→6517→6517→6517`; pass 8 begins and ends at 6,517 facts. In source, `full = traces.size === 0` is set at the start of each pass, stable facts clear traces at the end, and the loop continues while facts change or the pass was not full. Thus pass 7 is the stable selective pass and pass 8 is the final full pass. The last marker reports cumulative process CPU 21.786911 seconds; the 30-second limit is wall time, so this number does not identify the failing stage.

Source order places the unmarked work after the compile loop: reachability/filtering, descriptors and IDs, string assembly, segment rendering, the undefined scan, `runtime_c`/ `c_ids`, then the Native file write. The evidence supports the bounded statement that Native did not complete after the final compile-loop body; it does not identify which postpass operation consumed the remaining wall budget. `POSTPASS-SOURCE.json` is a diagnostic marker proposal only and is not current execution evidence.

Remaining gates are Native C emission, build, Native runtime, and Native whole-output comparison. The candidate remains a retained manual diagnostic adaptation with no stock or adoption claim, no identical retry, no performance claim, and no closure of #54. No compiler/backend/core files or hooks were changed by this review. Validation here was read-only: commit/path inspection, JSON/hash checks, source-order inspection, and independent 90-member archive verification; no candidate or backend command was run.
