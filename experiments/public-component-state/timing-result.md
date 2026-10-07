# #47 complete application timing observations

**JS parity remains unmet; #47 must remain open for its performance gap.**
The admitted complete cohort finished without source/cache drift, selective
restart or discarded samples. This reports operation-region observations, not a
new statistical acceptance rule or full-core qualification.

| Complete lifecycles | Full rows | Median JS/TS | Median Native/TS | Native speedup from paired ratio |
|---|---|---|---|---|
| 1 | 62 | 3.0341 | 0.08376 | 11.94x |
| 2 | 124 | 2.9936 | 0.10891 | 9.18x |
| 4 | 248 | 3.2279 | 0.15720 | 6.36x |

All 60 JS pairs are slower than TS (ratios 1.2683–6.9407). All 60 Native pairs are
below 0.5 (ratios 0.04543–0.34389). Native observed results exceed the existing
2x target at these scales; this does not repair JS or qualify other workloads.
The complete public lifecycle includes both schemas, state/Array snapshots,
registered updates/readers, deferred barrier, failure rollback, stale transitions,
exact raw errors and same-value writes. Startup/import/compiler/stdout flush are
excluded from the region and separately recorded as whole-process observations.

Receipt: `.artifacts/state-timing-observations-v1/receipt.json`,
`COMPLETE_APPLICATION_TIMING_OBSERVATIONS_NO_VERDICT`, 290 guarded commands,
120 paired observations: 20 balanced AB/BA pairs per backend per scale, all samples
and warmups retained. Receipt SHA256:
`12166cc6f92dd634936c7a45158b0d826c3afe5cc7bd7ad0c165bbfcb2a5b0e5`.
Exact stage-v1 and semantic receipt2f3a28 remained bound; the reviewed CPU5→CPU11
change is explicit. Native uses threads1/GPUoff; limits5/30/120/5 remain unchanged.

Quiet admission: `.artifacts/state-host-quiet-window.json`; selected CPU11idle100%,
global85.42%, swapOut0 and swapIn62pages during the initial5sec assessment.
These limits remain visible; per-pair load/selected CPU/frequency/pressure records
must be assessed with the integrator context. Quiet SHA256:
`eec254bfbad7b216c7ee4db3b1e244eb227ef1b8a5121e875c24544b5faa3062`.
The retained admission copy matches the original byte-for-byte after terminal.

Portable evidence is in `timing/evidence-observations-v1/`: compressed full receipt,
all 580 exact stdout/stderr logs in `logs.tar.gz`, original stage, semantic receipt,
quiet admission and `qualification.json` binding these artifact hashes. Every log
archive member was independently checked against the receipt's exact SHA256.
The [generated inspection](timing-inspection.md) establishes fresh post-Begin
application execution; no work reduction or cached complete result was accepted.

Next concrete work belongs to #47: profile the actual generated JS complete state
application, identify its call/allocation or cold-compilation cost, then optimize
without weakening the checked status/access API or dropping observations. Capture
before/after JS profiles and repeat current semantics/default regression and the
same admitted feature protocol for any consequential executable change. No new
law, dependency, numerical tolerance or performance baseline is approved here.
