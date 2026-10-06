# Fresh typed-cursor protected Tx controls

Finite source-bound matrix on frozen `/tmp/bendvy-private-id-query-v4`, closure `bdf6b2fc46d2a89615d0e9eb48d44f4a3e8c8f2ff5b8268d7ca50463e6bfbe94`. No earlier d437 matrix receipt is transferred.

`run.py` verifies the actual 29 source hashes, embedded/standalone cache equality, both closure maps and digests before materialization. The fixture adapter constructs `Q.PrototypeIdCursor{namespace,[id]}` from the incoming selected Handle and invokes the reached `HA.prototype_cursor_flatfold_motion/health`. It packs/unpacks the complete Tx context through the actual paired route. Original authored callback bodies, generic point-reference work, scenarios and normative protected oracles remain unchanged. Slot-aware raw observation preserves all owned cells and cache metadata while observing nominal raw values.

Eight fresh cached/raw × Motion/Health × normal/suppressed subjects passed checker, JS/C emission, Clang19 and both runtimes. Each produces 72 full records: **576 per backend, 1152 total**. Normal cached/raw outputs satisfy the unchanged independent oracle and agree. Suppressed outputs agree with the unchanged `expected_noop` oracle computed from this fresh normal baseline, differ from normal, and agree between cached/raw and backends. The local suppression deliberately retains raw and cached Main values in the reached private setter while preserving true-old reads, journal and mark work; its changed held-adapter source hash is explicitly separate from baseline hashes.

`decoded-validation.json` independently re-reads source, generated artifact and output hashes, re-runs protected record oracles, and checks the original callback numeric values. `controls.tar.gz` contains the baseline source closure, all fresh fixture extras, suppressed source variants, emitted C/JS, command outputs and accepting receipt. `manifest.json` verifies every independently decoded archive member SHA256. Native executables are hash-bound in the receipt but omitted from the archive; rebuild them with the approved explicit Clang19 wrapper.

Reproduce (fresh output directory):

```sh
python3 experiments/s-prep/source-private-id-query-tx-controls/run.py --output /tmp/bendvy-private-id-query-tx-controls-replay
python3 experiments/s-prep/source-private-id-query-tx-controls/validate-records.py --input /tmp/bendvy-private-id-query-tx-controls-replay --output /tmp/bendvy-private-id-query-tx-validation.json
```

Executed limits: CPU9, checker15s, each emit30s, Clang120s, runtime5s. Existing project oracle files and compiler are not modified. This receipt covers the single incoming selected-ID cursor adapter under the protected matrix; multi-ID ordering, cursor capability negatives, arbitrary-Type owners, public factory/provider gates and full65 benchmarks belong to separate source-bound receipts. No new semantic mutant, universal refinement, proof, performance qualification or production API approval is claimed here.
