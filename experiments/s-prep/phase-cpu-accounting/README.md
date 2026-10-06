# Phase CPU and wall accounting

Private generated-C, JS and reference copies observe process CPU and wall time at the original timed-phase boundaries. Original artifacts stay unchanged. Native uses `getrusage`, JS/TS use existing Node `process.cpuUsage`; no dependency is installed. All runs retain the five-second runtime limit and 120-second private Clang build limit. Boundary instrumentation adds work; these are diagnostics, not qualifying benchmark results.

The first Motion execution failed when JS exceeded five seconds; its failed receipt and captured outputs are retained. It has no aggregate field-comparison pass. Its initial JS recipe reported only on process exit. The revised recipe reports immediately at phase end and preserves the missing-phase assertion.

Health with the revised recipe passes all fields across 65 worlds for Native and JS against fresh pinned bevy-ts. Observed CPU user+system/wall milliseconds: TS 420.297/420.300, Native 412.264/412.332, JS 423.825/423.826. This run gives little evidence of off-CPU delay inside these phases. It does not explain the variability of other runs or qualify parity or a Native advantage.

Run `python3 experiments/s-prep/phase-cpu-accounting/run.py --c GENERATED_C --js GENERATED_JS --reference REFERENCE_MJS --schema Health --output NEW_DIRECTORY --cpu 7`. Evidence includes failures, command limits, exact hashes, raw observations and compressed diagnostic sources/binaries. `archive.json` maps uncompressed content hashes.
