# Speculative Apple-M1 scheduling build probe

Adding only `-mtune=apple-m1` to the existing Clang19 `-O3` invocation on unchanged concrete-v3 generated C is conditionally appropriate as a speculative compiler scheduling/cost-model probe. Clang documents AArch64 support for mtune; LLVM's AArch64 target separates CPU, TuneCPU and feature-string inputs. [Clang options](https://clang.llvm.org/docs/UsersManual.html), [LLVM target implementation](https://llvm.org/docs/doxygen/AArch64TargetMachine_8cpp_source.html).

Before building, pin and compare actual baseline/tuned `-###` invocations: target-cpu remains generic, every target-feature/ISA option remains identical, and only tune-cpu changes to apple-m1. Do not add march, mcpu, LSE, fast-math or another flag. Existing special Bend ABI attributes, atomic source operations/memory orders and libraries remain unchanged. Any unexpected target-feature or ABI change rejects this enrollment rather than broadening the probe.

Apple vendor and synthetic MIDR0 do not identify this host as an M1. The flag is a deliberately speculative model selection, not detected hardware matching. No speed benefit or portability conclusion follows from choosing it.

Exact source29/C/build/driver joins, existing compiler/wrapper/libraries, all transitive includes, full command argv and immediate/post-execution binary hashes must be prospectively bound. Both new Native binaries require fresh complete65 comparison against actual original Dense1024 TS observations. Prior LSE/default passes are separate evidence, not fresh tuned-binary passes. Build only after the root's quiet cohort release.

A subsequent five-role balanced raw cohort is a separate prospective admission, with runtime5 failures retained. This design review performs no build, workload or timing and grants no new dependency, threshold, canonical allowance, qualification, keep or product adoption. Actual producer and catalog review remain pending.
