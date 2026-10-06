# P-REGRESSION — protect the measured public API baseline

GitHub #28. Status: delivered and independently reviewed. Parent #1; existing #21/#24
performance qualification remains separate.

User approved **no statistically confirmed slowdown**. Protect the existing
Workshop whole-process benchmark with an immutable source baseline, rather than
comparing new timings against historical CPU conditions. Compile baseline and
current core with the same toolchain and frozen workload; run adjacent pairs on
one CPU with balanced randomized order. Validate every complete observation.

Use one-sided exact paired sign tests against zero slowdown, Holm correction
across JS/Native and family alpha0.05. This is a statistical confidence choice,
not a five-percent slowdown allowance. Retain all measured samples. Exit nonzero
for confirmed regression, execution/observation failure or source drift. Absence
of a detected regression is not proof of equivalence.

Return conditions: current-source run completes, planted real slowdown is
detected with unchanged observations, decision controls pass, exact inputs and
commands/results are retained, independent review addresses actionable findings.
The baseline is explicitly versioned in Git and never automatically advanced.
Scope covers this workload and `src/ecs`; it does not qualify the old optimized
Dense workload, full five-by-three matrix or product performance. Existing
JS<=TS and Native<=0.5TS targets remain separately labelled descriptive outputs.

[Completion and actual detection control](../reports/performance-regression.md).
