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

## Separately reviewed v2 continuation

Root explicitly approved a new guard after primary LLVM19.1.7 review
(docs/reviews/native1024-tune-build.md, review1a965c0) identified +zcm/+zcz as
non-ISA zero-cycle move/zeroing scheduling preferences. The original strict
refusal remains above and unchanged. New run-v2.py permits exactly those two
additions, in order, with every baseline feature retained in order and generic
CPU/triple/ABI unchanged. Literal feature lists differ; the architecture envelope
join is true under this reviewed classification. No unreviewed feature is allowed.

Both unchanged concrete-v3 Native builds pass; exact argv differs solely by
-mtune=apple-m1 and output path. Fresh default/tuned TS/full65 checkpoints pass
both schemas (260 worlds). Source/cache/tool/include/resolved-ELF-library and
program bytes are prospectively bound and stable. Complete v2 deduplicated archive
verifies every decoded logical file hash. Artifact hashes remain in
/tmp/bendvy-native-tune-build-v2/evidence.json. ISA and flag joins are separate
actual driver-derived receipts. No M1 CPU identification, timing or adoption claim.
