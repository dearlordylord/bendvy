# Speculative Apple-M1 scheduling build probe

Adding only `-mtune=apple-m1` to the existing Clang19 `-O3` invocation on unchanged concrete-v3 generated C is conditionally appropriate as a speculative compiler scheduling/cost-model probe. Clang documents AArch64 support for mtune; LLVM's AArch64 target separates CPU, TuneCPU and feature-string inputs. [Clang options](https://clang.llvm.org/docs/UsersManual.html), [LLVM target implementation](https://llvm.org/docs/doxygen/AArch64TargetMachine_8cpp_source.html).

Before building, pin and compare actual baseline/tuned `-###` invocations: target-cpu remains generic, every target-feature/ISA option remains identical, and only tune-cpu changes to apple-m1. Do not add march, mcpu, LSE, fast-math or another flag. Existing special Bend ABI attributes, atomic source operations/memory orders and libraries remain unchanged. Any unexpected target-feature or ABI change rejects this enrollment rather than broadening the probe.

Apple vendor and synthetic MIDR0 do not identify this host as an M1. The flag is a deliberately speculative model selection, not detected hardware matching. No speed benefit or portability conclusion follows from choosing it.

Exact source29/C/build/driver joins, existing compiler/wrapper/libraries, all transitive includes, full command argv and immediate/post-execution binary hashes must be prospectively bound. Both new Native binaries require fresh complete65 comparison against actual original Dense1024 TS observations. Prior LSE/default passes are separate evidence, not fresh tuned-binary passes. Build only after the root's quiet cohort release.

A subsequent five-role balanced raw cohort is a separate prospective admission, with runtime5 failures retained. This design review performs no build, workload or timing and grants no new dependency, threshold, canonical allowance, qualification, keep or product adoption. Actual producer and catalog review remain pending.

## Exact LLVM19.1.7 non-ISA classification

The strict all-target-feature-equality proxy correctly rejected the first preparation before compile: tuning added `+zcm,+zcz`. Primary release-tag source shows these are ordinary SubtargetFeature records, not Arm architectural Extension/FEAT records: FeatureZCRegMove sets HasZeroCycleRegMove (line557); FeatureZCZeroing sets zero-cycle zeroing and implies its GP cost flag (lines560–572). [LLVM19.1.7 feature definitions](https://github.com/llvm/llvm-project/blob/llvmorg-19.1.7/llvm/lib/Target/AArch64/AArch64Features.td#L557).

Actual lowering uses these preferences to choose existing baseline ADD-immediate0/ORR register-move and MOVZ zeroing forms, rather than enabling a new instruction-set extension. [LLVM19.1.7 move/zero lowering](https://github.com/llvm/llvm-project/blob/llvmorg-19.1.7/llvm/lib/Target/AArch64/AArch64InstrInfo.cpp#L4461).

A new explicitly reviewed guard may therefore allow exactly the extra positive tuning flags `+zcm,+zcz`, while requiring the ordered feature list after removing those two to equal baseline, no other extra/missing/reordered features, target-cpu generic, identical triple/ABI and sole argv addition mtune. This refines an overstrict feature-list proxy; it does not waive architectural equality or allow march/LSE. Preserve the original rejection/code and create new preparation evidence. Scheduling/code selection remains speculative, with fresh full65 and prospective producer/catalog gates still required.
