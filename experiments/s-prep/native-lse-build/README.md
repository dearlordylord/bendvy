# Unchanged-C LSE build probe

Both Native variants compile the exact existing C bytes: Motion direct-v1
`84b808cee2c1a657569888229241dd95ae59f314025512c20159d951f4a1db2c`
and Health concrete-v3
`a4672d110446195e3ac92911c6f41166b62025811df8816878356d0eafd08a55`.
The compiler/link command changes only `-march=armv8-a+lse` and the output path;
exact-flag-join.json in the archive verifies that relation to original builds.
No C/Bend, compiler/kernel, atomic ordering, dependency or source artifact changed.

Actual Linux aarch64 libc.getauxval(AT_HWCAP) returned800325631, with
HWCAP_ATOMICS bit8 set. The header definitions, host capability and tools/includes
are prospectively pinned and checked before/after compile and execution. Artifacts
are restricted to this verified LSE-capable host scope; no portable/non-LSE claim.
Fresh nm/objdump inspections also pin their resolved shared libraries and verify
source/cache and original/new binary bytes unchanged.

Both original binaries have50 static outlined atomic call sites; the LSE variants
have zero and no outlined-helper symbols. New binaries contain inline ldadd44,
ldaddl3, casal1 and swpa3 sites. These are static ELF observations, not dynamic
counts. Existing C atomic memory orders remain compiler inputs unchanged.

Both exact Clang19 builds pass (CPU6, cap120s). Fresh actual TS/full65 Dense1024
observations pass for each variant (130 worlds, runtime5s, same-process warmup).
Execution receipts pin reference preparation, TS core, supervisor, tools, source
and program bytes before/after. Clocks are diagnostic outputs only. No timing or
speedup is claimed; no product build configuration is adopted.

Complete evidence is deduplicated by content hash in complete-lse-evidence.tar.xz.
files.json maps every logical evidence file to a decoded blob; all decoded bytes
were independently re-hashed after archive creation. Native binaries remain in
/tmp/bendvy-native-lse-build-v1 with their exact hashes retained in evidence.
No failed build or runtime checkpoint occurred in this bounded probe.
