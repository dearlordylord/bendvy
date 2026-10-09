# Generated C compile-cost source investigation

Subject is exact `/tmp/bendvy-inspect54-outline-once01/reference.c`: 32,192,296 bytes, SHA256 `1213c7de4cf2dbf8ba7437ee65cf4b949f44f3fb4966ddfdba7a870908856a33`, 1,091,226 newline-terminated lines. This is the complete consumer; no compiler/build/runtime was launched for this investigation. `/tmp/bendvy-inspect54-outline-native01/receipt.json` preserves original Clang19-O3 cap120 deadline, empty raw diagnostics, no binary/runtime. It contains no optimizer-pass attribution.

A single-pass source scan counts 14,260 emitted WL_CASE bodies (23,333,943 textual bytes) and 2,183 spin helpers (6,995,047 bytes); 2,069 spins are INLINE and 114 FAR. Body boundaries use emitted start/end grammar; their counts include generated continuations, not only user declarations. On CPU, WL_CASE expands to separate noinline preserve_none functions with musttail jumps. They are not one enormous host work_loop switch; that switch is the device branch. WL_SIG passes 66 numbered bank registers plus rp and four control/environment parameters; WL_RESW is65. These declarations are concrete compilation volume, not measurements of optimizer complexity.

Largest emitted bodies (bytes/lines, C line):

| Exact generated identifier | Size | Source authority |
| --- | --- | --- |
| FID_GATE_INSTRUMENTATION_CONDITION_0 / _1 | 40,921 / 1,317 each; 770937 / 743062 | gate-instrumentation:condition~0/~1, gate-instrumentation.bend:41 |
| FID_EXECUTION_RUN_0 / _1 | 37,429 / 1,193 each; 998046 / 991937 | execution:run~0/~1, execution.bend:145 |
| FID_CHECK_EXECUTION_RUN_0 / _1 | 23,146 /745 each; 663956 /660053 | check-execution:run~0/~1, check-execution.bend:115 |
| FID_CORE_V1_SRC_ECS_SCHEDULE_EXECUTE_0 / _1 | 15,520 /479 each; 817393 /794089 | core-v1/src/ecs/schedule:execute~0/~1, schedule.bend:66 |

Identifiers above match the compiler's name_clean/uppercase FID construction unambiguously among actual Book definitions. Their full cost.json mapping joins were independently checked against actual template-instance membership, namespace, pinned source SHA and lexical declaration line; no generated suffix was stripped to infer authority. Largest spin is spin_620, 30,349 bytes/538 lines, FAR. The retained report does not expose the final fl.spun specialization map, so assigning that numeric spin to a source function would be speculation and is deliberately omitted.

Pinned comp.ts pointers: name_id/seg_fid560–570/1495; compile_book C segment construction2796–2882; runtime macros3326–3368; emit_native2167–2195. SPIN_FAR256 chooses INLINE versus noinline FAR according to emitted internal line count. The outline-once copied compiler retains flat_call fusion but suppresses only optional single-site tail fusion. It therefore still produces thousands of inline-helper bodies and the runtime's generic bank signatures, plus per-schema specialized branch dispatch (the largest condition/run bodies). Clang-O3 may perform substantial optimization on this volume and inline call graph, but no pass-cost evidence establishes which transformation dominates or whether inline helpers cause the deadline.

cost.json is complete (compilerCompleted true, 6,077 observed rows). Its largest emitted-line counter is world-observer:joined~0/~1, each435,406 accumulated characters/14,010 pushes across four intervals, exact source world-observer.bend:19. Those counters include repeated/discarded/nested lowering and must not be equated to final function bytes: the final largest body is the condition dispatcher instead. No compiler-cost conclusion follows from ranking these two different quantities together.

Recommendation: preserve exact C and wait for the already prepared O0 full semantic attempt. A successful O0 compile/runtime would establish finite semantics and distinguish basic frontend/code-generation feasibility from this O3 deadline, without identifying an optimization pass. Before another representation rewrite, obtain direct Clang phase/pass attribution on this exact artifact under a separately admitted bounded recipe if root elects it. Do not infer a giant host-switch cause, change the semantic workload, assign unidentified spins, or pursue a timeout ladder from these source counts. No speedup, installed Bend cause or product performance result is claimed.
