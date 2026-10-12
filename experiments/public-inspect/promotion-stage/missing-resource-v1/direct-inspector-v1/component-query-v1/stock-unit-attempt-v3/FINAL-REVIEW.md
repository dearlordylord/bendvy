# Stock Unit v3 final Spec/Standards review

**Subject:** retained stock consumer packet at commit `a22d1e0af9f2b638e6cf1aeaac473d30eb319039`
**Packet:** `stock-unit-attempt-v3`
**Verdict:** **PASS for bounded read-only retention; INCOMPLETE for Native/backend acceptance.**

The packet is correctly scoped as a stock component-query diagnostic. It does not claim compiler/core/API adoption, proof, performance, or closure of #54. The retained result is `INCOMPLETE_STOCK_NATIVE_EMIT_THIRD_DEADLINE`, which is the correct terminal status for the observed backend boundary.

## Evidence and source joins

- `EVIDENCE.zip` has exactly 132 unique members. Its SHA-256 is `19b76760da8fbf4c1a8f7cdc937c9dac3a1769f21adba335b2a63f40435728b9`, and every declared member byte count and SHA-256 matches. `DELIVERY.json` also matches the archived `RESULT.json`, `FREEZE03.json`, and `SOURCE03.zip` digests.
- The current `SOURCE03.zip` contains 53 bodies. After the archive's leading-slash path normalization, all 53 paths and hashes match `FREEZE03.sourceInventory`. Source, JS, and Native plans carry the same 53-body inventory and import closure. Each current receipt's `planSHA256` matches its archived plan.
- The source-to-source successor audit is appropriately narrow: SOURCE02 and SOURCE03 have the same 53 paths, with exactly five changed Unit-repair modules (`format.bend`, `runtime-named-declarations.bend`, `retry-driver.bend`, `execution.bend`, and `check-execution.bend`). The archived predecessor/source01 and runtime01/runtime02 histories remain separate and intact. The owned manifest limits this packet to retention artifacts.
- The independent oracle chain is bound to source-only model commit `9180a7a7a238bb8bfc486ae103ba6d809ef77990`. The successor-v3 checks retain the exact source freeze/archive bindings, five-file audit, 14 query kinds, nine check kinds, and 11 physical checkpoints. `runtimeOutputInputs` is empty; the model and regenerator explicitly state that no Bend JS or Native output is read. The model is a finite Workshop/Garden trace, not a universal theorem.

## Stage results

- The source check passed with Bend `2.0.35`, CPU 3, and the unchanged five-second cap. Its archived receipt is `COMPLETE_SOURCE_CONTROL_PASS`, with empty stderr.
- The stock JS path used the pinned `bend-2.0.35`, Node 24.20.0, taskset CPU 3, and the existing runner. Emit exited 0 under 30 seconds; the consumer exited 0 under five seconds with empty stderr. Its complete 207,834-byte stdout has SHA-256 `14565a3635124edb3ba8ef53b76e2030c3b3698e5d7c4a31989bc3ca9fb54a2d`, equal to the source-derived successor-v3 oracle. The packet retains the actual main entry, physical state, owners, pending command, registry cursors, query/check rows, retries, and schedule observations within the declared finite scope.
- The Native path reached only the 30-second `emit` command. It exited null with `child deadline`; stdout and stderr were both empty, no C artifact was produced, and build/runtime were not started. The wrapper's `Owned child failed: emit` is consistent with that child deadline. All four Native guards are unchanged and `guardFailures` is empty, which establishes restoration/boundary integrity only; it does not establish Native semantics.
- The three retained stock attempts all record the same full JS oracle digest and the same Native emit deadline. That repeated result is useful diagnostic evidence, while remaining a deadline observation rather than a compiler-performance claim.

## Standards decision and remaining gates

This is a bounded evidence packet with matching source, oracle, tool, environment, command, receipt, and guard bindings. The absence of expanded authority/error/reached controls is appropriate for this retained stock rerun: no public API or core contract changed, and Native failed before an emitted artifact or runtime callsite existed. Adding wider controls would not resolve the actual blocked stage. Any future backend-qualified or compiler-candidate result must use its own source-bound oracle and then cover the affected semantic callsite and relevant controls before adoption.

Remaining gates are explicit: Native emit must complete before C build/runtime or Native output comparison can be assessed; the incomplete Native stage provides no Native acceptance, proof, or performance credit. The stock consumer remains a bounded fixture/diagnostic and does not close #54 or authorize source/core changes.
