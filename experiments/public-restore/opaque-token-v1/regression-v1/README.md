# Restore integration regression gate

The unchanged default `benchmarks/run.py` passed on CPU11: 20 balanced adjacent
pairs per backend, 123 successful commands and 110 complete checked outputs.
The original baseline, workload, observations, statistics and zero allowance
remain unchanged. Result: `NO_CONFIRMED_REGRESSION` for JS and Native.

`EVIDENCE.zip` retains the full cohort, baseline/current sources and generated
artifacts, complete compressed observations, reference sources and pre-cohort
host samples. `MANIFEST.json` binds every archived byte. Packaging independently
recomputed the existing decision and checked all110 complete outputs; its exact
source is retained in the archive. Generated Native binaries are archived.

Bend2.0.35, Node24.20.0 and Clang19.1.7 versions are in `receipt.json`.
A private PATH alias selected the existing stock Bend executable; no installed
tool or dependency changed. CPU11 was idle in all ten pre-cohort samples;
background load remained on other CPUs. Balanced adjacent pairs reduce drift,
but no detected regression does not prove equivalence on a noisy host.
This gate protects only the frozen Workshop process workload. Full feature
performance and JS≤TS / Native≤0.5×TS qualification remain #21/#23/#24.
