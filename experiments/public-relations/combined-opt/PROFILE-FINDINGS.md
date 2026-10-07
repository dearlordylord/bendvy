# Combined observer diagnostics

Baseline and candidate each passed all four JS/TS CPU/heap runs, with600 validated original complete records per run. Sampled collected-inclusive JS heap self totals447.79→343.59MB; project_cells family87.58→7.26MB, anonymous per-cell continuations82.65→0MB. TS totals131.64→61.17MB also reflect its optimized bytewise capture loop. Exact profile/receipt hashes and buckets remain in profile-analysis.json.

Instrumented CPU-profile duration JS508.431→502.940ms, TS208.446→177.245ms. These single-run samples include output flush and20ms observer drain; they are not paired operation timing, physical allocation totals, native results or an ECS-only improvement. Both halves retain all cells, full serialization/capture and original callbacks. No performance/adoption acceptance follows.

A separate prepared1/2/4 complete-equivalence and existing-contract paired timing protocol awaits review and a quiet host window. No scales2/4 gate is credited yet.
