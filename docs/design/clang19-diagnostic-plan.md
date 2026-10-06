# Clang 19 diagnostic toolchain approval proposal

Approve extracting and using the four pinned Debian ARM64 archives below in a new private `/tmp/bendvy-clang19-diagnostic/root`, with an explicit process-local wrapper and the pinned existing Z3 library. Purpose: test the existing Bend generated-C calling-convention path without changing Bend, generated C, kernels, source APIs or default Clang. This proposal does not approve a global package installation, new project dependency graph, product adoption, numerical threshold, canonical cap reset or performance acceptance.

**Status: proposal; extraction/use approval pending.** Only read-only metadata inspection and reversible archive downloads have occurred. No new archive payload was extracted, installed or executed. [SPEC.md:77](/workspace/formal-proofs/bendvy/docs/SPEC.md:77) says: “New project dependencies require approval when their concrete need is established.” The current optimization scope excludes dependency installation, so the integrator must obtain explicit approval for this concrete toolchain exception before the prospective commands run.

## Concrete need and primary evidence

This host is Debian12/bookworm ARM64. Current Clang14.0.6 under `/home/node/.local/opt/dnd-clang14` reports `__has_attribute(preserve_none)=0` and `preserve_most=1` at `-O3`; [recorded existing-tool check](../../experiments/s-prep/clang19-plan/metadata/existing-attribute-check.json) includes command/input/output. Bend's existing [generated-C gate](/workspace/formal-proofs/bendvy/.references/bend2/bend2/comp.ts:3337) requires **both attributes and optimization**; [compiler rationale](/workspace/formal-proofs/bendvy/.references/bend2/bend2/comp.ts:3296) selects Clang19+ for this ABI. The current tool therefore leaves that path disabled.

[Official Clang19 attribute documentation](https://releases.llvm.org/19.1.0/tools/clang/docs/AttributeReference.html#preserve-none) supports `preserve_none` on AArch64 and notes its ABI is unstable. [The same documentation](https://releases.llvm.org/19.1.0/tools/clang/docs/AttributeReference.html#preserve-most) supports `preserve_most` on AArch64. This establishes a concrete tool candidate, not an observed successful build or speedup; both attributes must be checked on the actual approved binary before any workload runs. Keep every generated function in one consistently built ABI domain; do not mix Clang14/19 objects or infer compatibility across versions.

## Pinned package candidate

[Debian's official Clang19 package](https://packages.debian.org/bookworm/clang-19) is `1:19.1.7-3~deb12u1` on ARM64. All four archives were downloaded as data and verified against cached Debian package metadata; [download receipt](../../experiments/s-prep/clang19-plan/metadata/download-receipt.json) records exact URL, bytes and SHA256. [Package metadata](../../experiments/s-prep/clang19-plan/metadata/packages.json) retains versions, dependencies and optional package pins.

| Proposed plain-C payload | Download bytes | Exact archive | SHA256 |
| --- | ---: | --- | --- |
| clang-19 |112,672|[Debian archive](https://deb.debian.org/debian/pool/main/l/llvm-toolchain-19/clang-19_19.1.7-3~deb12u1_arm64.deb)|`afc69199696252641c7bfb39d46c290d4bc9f235e251bf7afbe62143f3a6bdbf`|
| libclang-cpp19 |11,899,592|[Debian archive](https://deb.debian.org/debian/pool/main/l/llvm-toolchain-19/libclang-cpp19_19.1.7-3~deb12u1_arm64.deb)|`d9398ada6c8091669fd4af736fbb9aacaf28e140c309685ab00196625969422b`|
| libllvm19 |23,183,452|[Debian archive](https://deb.debian.org/debian/pool/main/l/llvm-toolchain-19/libllvm19_19.1.7-3~deb12u1_arm64.deb)|`8da27fd815c3feceb5aed709b66e0daf9ef6ea98600778f7fd6b569a9ae1f109`|
| libclang-common-19-dev |739,736|[Debian archive](https://deb.debian.org/debian/pool/main/l/llvm-toolchain-19/libclang-common-19-dev_19.1.7-3~deb12u1_arm64.deb)|`ba6f837294395f6aec7f2177c8e578e1c45cf6a3733b469b659fb08824a35f6e`|

Total: **35,935,452 bytes (35.94MB /34.27MiB)**; Debian declared extracted size198,672KiB (~194.02MiB), before filesystem overhead. Plan space for both archives and payload (~230MB minimum; reserve300MB). Only archives are currently staged in `/tmp/bendvy-clang19-download-staging`; no payload directory exists.

This is a minimal **candidate private plain-C payload**, not a complete apt installation transaction or experimentally verified ELF dependency closure. Official package dependencies also name libclang1-19, llvm-19-linker-tools and Objective-C development support. For plain C without LTO/Objective-C those are not proposed initially; sufficiency remains an explicit post-approval ELF/resource/link check. If needed, stop and present a concrete expanded request. [Optional metadata](../../experiments/s-prep/clang19-plan/metadata/packages.json) pins libclang1-19 (6,821,592bytes), llvm-19-linker-tools (1,091,184bytes) and libz3-4 (6,281,640bytes); none was downloaded or enabled by this proposal.

## Existing libraries and isolation

[Host receipt](../../experiments/s-prep/clang19-plan/metadata/host.json), [installed package versions](../../experiments/s-prep/clang19-plan/metadata/existing-packages.txt) and [loader inventory](../../experiments/s-prep/clang19-plan/metadata/existing-ldconfig.txt) record existing glibc2.36, libstdc++/libgcc12, libedit2, libffi8, libxml2, libzstd1 and zlib, plus libc/GCC development headers and binutils2.40. Those satisfy the recorded version floors for the intended compiler/runtime packages. Transitive system dependencies remain in the loader inventory and must be resolved by the approved ELF check.

System dpkg has no libz3-4, but the current isolated Clang14 bundle already contains read-only `/home/node/.local/opt/dnd-clang14/usr/lib/aarch64-linux-gnu/libz3.so.4`, SHA256 `6a1f171b6a6b040ffa0bf7e8048c50a7a7984720eabb488bf21780d9cdc0738a`. [Existing Z3 receipt](../../experiments/s-prep/clang19-plan/metadata/existing-z3.json) records its size and DT_NEEDED entries; those use existing standard runtime libraries. Reverify this pin before proposed reuse. A self-contained new Z3 archive would add6,281,640bytes and needs inclusion in a separately reviewed expanded request.

The proposed [wrapper text](../../experiments/s-prep/clang19-plan/recipe/clang19-wrapper.sh.txt) invokes the private Clang binary and resource headers directly, uses existing `/usr` GCC/linker support, and sets library search paths only for its child process. It remains a non-executable `.txt` proposal. No PATH/profile/alternatives/ldconfig/system directory change, apt transaction or maintainer script is planned. Inspect symlinks, loader paths, resource-dir and linker trace after approval; unresolved needs stop work. Never copy over or delete the existing Clang14/Z3 bundle.

## Fresh diagnostic gates after approval

[Prospective recipe](../../experiments/s-prep/clang19-plan/recipe/after-approval.md) gives exact gates and limits. First verify archive pins, extract privately without maintainer scripts, inspect ELF dependencies and pin actual compiler/libraries/headers/wrapper. CPU8 preprocessor check must establish both attributes at `-O3`, AArch64 and optimization, then confirm the unchanged generated C enables the existing `PRESERVE` branch. Do not force an attribute/macro or edit C.

Build exact unchanged pinned C with `-O3 -pthread -lm`, clang120. Rebuild source baseline and candidate with the same approved wrapper, one worker/GPUoff; retain C hashes before/after and binary/provenance receipts. Fresh full-field Motion and Health, ownership/access/provider/factory/fallback/rollback/publication controls, exact source/cache manifests and import-prefix bindings remain mandatory. This tool proposal does not pass any source gate.

Only then run bounded fresh Motion256/Health256 diagnostics against fresh pinned TS and same-toolchain source baseline: warmup plus64 worlds,64ticks, all65 full observations. Keep runtime5/codegen30 and existing scoped checker limits, all observation fields/oracles, canonical attempt history, qualification/noise/keep policy and product gates intact. A raw diagnostic can test whether this ABI helps; it cannot qualify timing or close acceptance. Do not compare an old Clang14 baseline with a new Clang19 candidate as a source-only improvement.

Record the exact approval and outcomes. Reversal removes only the verified new task-owned private root and download staging; retain small source/package/command evidence. No global uninstall or external repository modification is involved. Until approval, old-tool source gates can continue independently; nothing in this proposal authorizes new compiler execution.
