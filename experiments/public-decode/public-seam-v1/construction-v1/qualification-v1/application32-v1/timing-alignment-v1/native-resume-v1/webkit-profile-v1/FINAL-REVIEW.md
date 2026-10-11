# #46 WebKit fallback launch review

Spec: PASS for the bounded diagnostic sequence. Standards: PASS, conditional on the prerequisites below. Reviewed immutable preparation 3e655d669 and PLAN SHA256 `4df6141623a807478824f3f6653aee626520b07d71403e4bc411ffefeb8f2cd6`. This is static launch review, not profiler support or Native qualification.

All 109 pinned bodies currently match; actual01 is absent. The Node24 controller uses built-in WebSocket/child_process and asserts its executable identity. Its child receives the pinned stock ELF, original full-format-v3 main, cwd/resources and CPU5 placement. Only the control uses BUN_BE_BUN=1; the compiler receives the inspector-wait option without embedded-Bun mode. No installed compiler or source mutation is introduced.

The retained tagged WebKit protocol supports Inspector.enable, startTracking(includeSamples), initialized, stopTracking and trackingComplete.samples.stackTraces. The controller starts tracking before releasing inspect-wait, schedules stop after 400ms for the control and 24s for the compiler, and retains actual child streams and protocol messages. Runtime protocol compatibility remains unproven until the control. Protocol/raw streams are cumulatively bounded at 32MiB; the separately published profile is also bounded at 32MiB. Their storage bounds are separate, not a 32MiB aggregate across both.

The unchanged collector/task_runner supervises the whole controller/child process tree at aggregate caps1/30, with outer caps15/45 and existing internal lock. Compiler launch requires the actual control receipt to report child deadline and a nonempty schema-valid saved WebKit profile. Missing profile, early exit, malformed frames or failed setup cannot manufacture support; preserve the raw failure and skip the compiler. Async protocol failures remain raw diagnostic records, not successful compiler evidence. Early child termination may prevent complete profile publication; this is an admitted diagnostic limitation.

The Python wrapper retains first failure, attempts unconditional post-bindings and terminal publication, records secondary failures and uses stderr fallback without masking the primary exception. Original stock-profile timeout/no-profile history remains distinct. The official protocol is guidance, not evidence that this embedded runtime implements it.

Launch only after root/owner queue release, fresh verification of all pins/resources and absent raw/profile/receipt outputs. Execute the pinned /usr/bin/python3.11 launcher with the absolute PLAN path and the exact digest above; retain original terminal and fresh outer stdout/stderr. Run one control, then at most one conditional compiler attempt. No retry, cap increase, production-C acceptance, causal attribution, speed claim or issue closure follows from this admission. No child or control was executed by this reviewer.

## Focused control-binding successor

Spec and Standards: PASS for immutable 993b737be, PLAN-v2 SHA256 `788cdd8e7031ddb8201f7e904954fe7ea022418b584ac5b7133f4e5c2b0beebd`. This supersedes only the control binding and fresh output paths; the prior report and failed attempt remain historical.

The reduced control plan binds its actual busy-loop entry, sampler/config, collector/runner/boundary and installed executables/libraries (24 pins). Its one-entry JavaScript closure has no Bend, Clang or Z3 resource dependency, so empty resourceRoots accurately describes this control. All 111 global successor pins currently match; the original compiler plan and full source/tool monitoring remain unchanged. Controller config changes only four output paths. Sampler, launch logic, child argv/env/cwd and aggregate1s/outer15 caps remain exact. actual02 is absent.

Original14930 reached an outer collector deadline before pre.guard, receipt or protocol publication. It provides no evidence that the inspector runtime started or that profiling is supported. The collector acquires its inner lock after preflight publication; absence of pre.guard does not identify the exact earlier phase and must not be called a proven lock wait. No compiler was launched. This successor repairs unnecessary control preflight scope rather than raising a cap.

Admit one exact launch using /usr/bin/python3.11, the existing absolute launch.py path, absolute PLAN-v2.json and the digest above, after root queue release and fresh absent-output/pin checks. The existing actual deadline plus complete valid profile gate still strictly controls compiler admission. Retain fresh outer streams and original terminal. No reviewer runtime execution, causal explanation, profiler-support or Native qualification follows.

## Actual bounded outcome — 94ee8428c

Spec and Standards: PASS for faithful retained diagnostic history, not successful profiling. Both portable archives verify every indexed body length/SHA: v1 13 rows/12 objects and v2 33 rows/28 objects. The final PLAN-v2 remains exact and all111 current global pins match.

Original14930 expired at the outer15s collector boundary before inner receipt/preflight/protocol publication. The successor47998 reached the actual inner1s child deadline, with one command/four guards, INCOMPLETE collector receipt and no guard failures. Raw protocol proves successful Inspector.enable, startTracking, trackingStart and initialized responses. It contains stopTracking request id4 but no response or trackingComplete. No profile was saved. This demonstrates partial protocol connectivity, not usable profiler support or a reason for the missing completion.

The outer terminal0 correctly records TIMEOUT_PROFILE_NOT_AVAILABLE_EMIT_NOT_LAUNCHED and unchanged111 postpins. The emit stage has no receipt; the compiler was strictly skipped. No compiler hotspot, Native result, causal timing or optimization claim follows. Debugger.pause research or any future fallback is outside this report; no new launch is admitted here. Reviewer performed archive/hash/source reads only.
