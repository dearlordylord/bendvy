# Matched JS diagnostics — actual, not benchmark

All four original five-second processes exited 0 with the entire 5,077,477-byte independent output (SHA256 `810259f78227f2b3d158c02644978b6c7ecf58b40a4b2fb398a816005b2867e2`) and empty stderr. No emission, retries, or changed budgets. Original handles: before CPU 62896, before heap 5975, after CPU 99115, after heap 37819. Exclusive target queue was released after the last terminal receipt.

| Diagnostic | Before | After |
|---|---:|---:|
| CPU leaf samples (unweighted) | 2573 | 2802 |
| Signed raw delta sum, µs | 552488 | 647669 |
| Negative raw deltas observed | 0 | 0 |
| Heap sample records | 718 | 661 |
| Sum of heap sample sizes, bytes | 9230240 | 8792304 |
| Sum of heap node selfSize, bytes | 9188904 | 8739456 |
| CPU subprocess-subtree peak RSS, KiB | 169828 | 174176 |
| Heap subprocess-subtree peak RSS, KiB | 132316 | 129460 |

These are whole-process diagnostics under external contention, including startup, module loading, ECS execution and full output. Sample counts are not CPU cost percentages; raw delta sums are separate observations, not benchmark intervals. Heap samples describe retained sampled allocations at profile end, excluding collected garbage, and do not measure cumulative allocation traffic. Different heap sample-size/selfSize sums are retained without normalization. Linux ru_maxrss includes the reaped supervisor/Node subtree; it is not Node-only RSS, live heap, or region-specific memory.

## Reached generated source

Before JS SHA `966be54023ed850ebfeed0e18823c0c611f6c2a295129e57d3fd42910090fe1b`: output-adapter main at lines 188–199 concatenates complete driver/retry Strings with JavaScript `+`. The original Bend adapter builds records/boundaries/lines recursively using `++`.

After JS SHA `0f94b283499e9b2a7e34574db4e01a4db52a8fbf643c994eb605bc64e2e73364`: output-adapter main at lines 188–193 constructs four complete chunk lists and calls String.concat. The emitted String.concat at lines 270–278 recursively returns `head + String.concat(tail)`. Chunking changes the serializer assembly structure and preserves every leaf string/field/order; JavaScript concatenation remains present in the final assembly.

Neither CPU profile contains a named String.append frame. List.append has two before samples and one after sample. JavaScript `+` is not an independently named String.append call, so absence cannot establish absence of concatenation cost or attribute a speedup. Both profiles contain substantial startup/GC/string-equality/ECS work; no dominant serializer CPU conclusion follows. Heap top individual nodes include readFileSync (2327816/2328984 bytes) and wrapSafe (1657840/1731960 bytes), consistent with whole-process loading being retained in these diagnostics, not a serializer-only measurement.

`PROFILE-ANALYSIS.json` retains exact frame identities (URL, scriptId, function, line, column), unweighted leaf samples and signed deltas separately, plus complete heap node ancestry/selfSize. Original profiles and all stdout/receipts/guards are losslessly archived by hash in FILES.json; source/tool provenance remains in admitted plans. No benchmark speedup, allocation-traffic reduction, compiler adoption, or whole #54 completion is claimed.
