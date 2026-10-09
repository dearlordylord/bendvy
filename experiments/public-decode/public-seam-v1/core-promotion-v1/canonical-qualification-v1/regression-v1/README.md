# Canonical staged regression

Unchanged #28 gate on integration/ordinary-snapshot `b9c7f63a`: NO_CONFIRMED_REGRESSION. All twenty paired observations per backend preserve the complete frozen Workshop oracle. Median paired candidate/baseline ratios: JS 0.906786; Native 0.993896. Same-cohort descriptive candidate/TS ratios: JS 0.400471; Native 0.092789. These describe the protected Workshop, not full-feature performance or causal speedups.

All 267 output members are losslessly archived with exact byte/hash joins in MANIFEST.json. receipt.json retains every pair, source/artifact hash, command and decision. The initial attempt stopped before compiler/workload execution because the private worktree lacked its bevy-ts binding; its ERROR receipt is retained separately. Read-only reference bindings were then established, followed by one fresh successful cohort. Baseline, workload, numerical criteria and caps were unchanged.
