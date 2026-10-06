# Adjacent exact-work diagnostics

One raw TS/baseline/candidate comparison, never a canonical cohort, qualified
metric, keep or acceptance. Verify actual29-module source/cache maps before
execution, pin input artifacts, derive a fresh pinned reference, supervise each
process for5 seconds, and compare every field of warmup+64 fresh worlds.
Motion/Health each use256 entities and64 ticks. Setup/output are outside the
existing measured phase. One worker/GPUoff; explicit CPU affinity.

```sh
python3 experiments/s-prep/cache-box-comparison/run.py --baseline-overlay /tmp/bendvy-live-first-native --candidate-overlay /tmp/bendvy-native-point-cache-boxing --baseline-native /tmp/bendvy-live-first-native-static/batch-native --candidate-native /tmp/bendvy-native-point-cache-boxing-build/batch-native --schema Motion --cpu 11 --output /tmp/fresh-adjacent
```

Optional `--baseline-js`/`--candidate-js` add corresponding JS diagnostics.
Source/binary/recipe/build bindings remain separate required evidence: artifact
hashes alone do not prove compilation/refinement. Preserve each failed receipt;
never change an oracle/limit to turn a preflight failure into a pass.

| Raw adjacent observation, milliseconds | TS | Baseline Native | Candidate Native | Baseline JS | Candidate JS |
| --- | ---: | ---: | ---: | ---: | ---: |
| Cache boxes / Motion |193.714298|239|367|—|—|
| Cache boxes / Health |232.259474|256|354|—|—|
| Data views / Motion |224.370482|256|258|—|—|
| Data views / Health |293.852503|305|271|—|384|
| Token reuse / Motion |1025.277898|1166|932|1553|1513|
| Token reuse / Health |671.646536|647|395|982|481|
| Call-product / Motion |199.011377|271|254*|381|388|
| Four-stage JS / Motion |209.797197|255|253*|341|438|
| Four-stage JS / Health |347.330431|584|527*|746|598|

*These candidate Native roles use the identical baseline binary; their clock
differences represent repeated diagnostics, not a Native implementation change.

All rows pass65 full states per executed backend. Values vary substantially
between diagnostic runs; do not combine them into a speed claim or compare
different rows as if they were adjacent. Mandatory JSparity/native2x and full22
remain open. The token v2 receipt/cache preflight failure is retained in its
experiment; v3 repairs manifests only and preserves all29 Bend bytes, so the
already built v2 artifacts bind to that identical closure.

[Frozen index](evidence/index.json) includes commands, builds, input drivers/C/JS,
raw outputs and reference scripts. Separate source experiments record provenance,
controls and untested follow-ups. The historical canonical attempt cap is unchanged.
