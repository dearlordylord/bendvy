# Concrete-v3 Motion LSE build

New probe uses unchanged concrete-v3 Motion1024 C and source closure
`a4672d110446195e3ac92911c6f41166b62025811df8816878356d0eafd08a55`.
It preserves the earlier direct-v1 LSE files as separate history. Root selected
concrete-v3 after the direct source's measured Native regression despite fewer
words; no earlier direct-LSE artifact is adopted here.

Same Clang19 -O3 compile/link command adds only `-march=armv8-a+lse` plus output
path. Actual getauxval HWCAP_ATOMICS is true before compile/run. Exact command/C
join, tools/resolved libraries/includes, source29/cache and baseline/new binary
bytes remain prospectively bound and stable. Fresh nm/objdump confirms outlined
atomic calls removed and inline LSE instructions. No C/Bend/kernel/dependency
or existing frozen experiment changed. Artifacts require an LSE-capable host.

Fresh actual TS/full65 Dense1024 comparisons pass for both this LSE binary and
the unchanged default Motion binary. Each new receipt explicitly binds v3
source29 and closure, reference/execution/tool/program bytes before/after.
Commands use CPU6, compile120s, runtime5s. Clock output is diagnostic only;
root owns any comparative timing and acceptance.

Build/artifact: /tmp/bendvy-native-lse-concrete-motion-v1/evidence.json and
motion-native (SHA f44da4a0fbaf321db33604ee85c07fdf85289c1f94621ed4bc3c501af6194742).
Fresh checkpoints: /tmp/bendvy-native-lse-concrete-motion-{default,lse}-full65-v1.
Complete deduplicated evidence archive verifies every decoded logical file hash;
Native binary hashes are retained. No failed checkpoint occurred.
