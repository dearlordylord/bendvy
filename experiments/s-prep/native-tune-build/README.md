# apple-m1 scheduling probe — rejected before compilation

Root authorized a sole `-mtune=apple-m1` addition on unchanged concrete-v3 C,
conditional on actual Clang19 -### generic target CPU and identical target-feature,
triple and ABI lists. No native CPU model identification was claimed.

The first Motion preflight failed the feature-list guard. Baseline features:
+v8a,+fp-armv8,+neon,+outline-atomics,-fmv. Candidate adds +zcm,+zcz.
Target CPU stays generic; tune CPU becomes apple-m1; triple/ABI are equal.
The exact stricter feature identity requirement is therefore unmet. No compiler
frontend, Native compilation, runtime, compression during the previous cohort,
comparative timing or artifact enrollment occurred. Health was never attempted.

Complete actual driver commands/output and prospective source/C/tool/host pins
are retained in the rejected-preflight archive. Tool bytes were rechecked stable.
Any interpretation of zcm/zcz as scheduling-only would require a separate
source-backed review and explicit new gate; this report makes no such waiver.
No source/compiler/kernel/reference/dependency or frozen earlier experiment changed.
