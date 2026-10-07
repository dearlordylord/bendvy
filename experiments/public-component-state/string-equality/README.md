# Isolated exact string-equality candidate

`equality.bend` consumes two Bend String constructor streams and carries a Boolean accumulator through tail recursion, using Char.is_eq. It performs no ordering or reconstructed String pair. Generated JS emits a for-loop with continue, not recursive calls. It still scans full equal-length inputs; no short-circuit or allocation-free claim. The scalar String traversal still produces backend slices. Ordered access lists and exact registration ID/name/access matching are preserved; this helper is not yet installed in World.

Current finite evidence:

- `state-equality-controls-v2`: PASS27 commands;324 original String.eq/new pairs on18 strings including empty/prefix/NUL/case/combining/supplementary/max scalar plus9 exact ID/name/access/order rows. Normal333 full outputs equal golden; always-true and equal-prefix mutants compile and reach true:false in both JS/Native.
- `state-equality-long-v3`: PASS21 commands;128-codepoint original/new mismatch and20000 supplementary-codepoint equal/early mismatch/late mismatch/prefix cases in both backends. Generated equal_walk is a loop. No application performance measurement.
- `state-equality-native-surrogate-v1`: PASS13 commands;7 Native-only existing surrogate-representation equality pairs match original String.eq, including distinct high/low surrogates and a two-surrogate sequence distinguished from one supplementary scalar.

Important existing Bend boundary: checker and emitter accept an isolated surrogate literal. Actual JS printing rejects55296 as not a Unicode scalar, while Native prints ED A0 80 LF. This is retained as backend-specific observation, not a universal scalar domain claim or new UTF16 policy. The candidate does not repair Bend or change the #46 UTF16 Data carrier.

Historical failed evidence is retained: controls-v1 C emission exceeded arity247 (333-row constructor; repaired by18-row chunks); long-v1 incorrectly expected checker surrogate rejection; long-v2 incorrectly expected Native rejection. These are harness/setup/oracle failures, not credited Native equality execution. Exact old receipts remain unchanged.

Erratum: original controls-v2 and long-v1/v2/v3 receipts inherit the shared Harness sourceScope sentence naming the full62-row application. Their actual command inventories and scope fields establish only these isolated equality controls. They are never full-application evidence. Prospective runners now override sourceScope; no cohort was repeated solely for metadata correction.

Run bounded replay using `run.py --output FRESH` (finite/mutants), `long-run.py --output FRESH` (long/backend canary), or `native-surrogate-run.py --output FRESH` (native representation), on coordinated CPU5. Five-second checks/runs,30-second emission, approved Clang19 compile120, Native1thread/GPUoff; reviewed supervisor and current source/tool/config/ref guards reused read-only. Evidence archives preserve all logs, receipts, copied subjects and generated sources; executable hashes remain in receipts, large binaries stay task-local.

Promotion plan: independent review of candidate/control/source semantics; isolate only the two World String.eq calls for access/name matching (no Base/compiler/runtime edits); run actual full owner/API application source-current semantics and before/after profiles on the same workload; default #28 regression and equivalent complete feature pairs remain required before production delivery. No proof, approved law, threshold, new registry architecture or performance acceptance is asserted.
