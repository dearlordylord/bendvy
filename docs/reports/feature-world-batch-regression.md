# Feature and registration batch — current regression evidence

The batch adds generic `Feature`/`FeatureProvision` and tail-recursive string
comparison, and makes registration validation lazy after exact ID/name/access
checks. No schema, namespace, access or ownership policy is changed.

## Fresh actual-source gates

- Default #28: `python3 benchmarks/run.py --output .artifacts/feature-world-batch-regression-v1 --cpu 10`.
  Terminal `NO_CONFIRMED_REGRESSION`, 20 balanced pairs per Bend backend,
  110 complete outputs. Candidate/frozen-Bend medians: JS 0.8939179022,
  Native 0.9704855831. One-sided slower counts 0/20 and 4/20;
  p-values 1 and 0.998711586. Unchanged workload, baseline and statistics.
- `scripts/check-receipt-sources.py --require-core-inventory` confirms all
  43 default inputs and exact **38 core modules**. Receipt SHA256
  `9d425bd1eaefd814d5baa63a0444dbd51c85e46a91d0204590c357d6a03e7d18`.
  [Portable receipt](../../benchmarks/evidence/feature-world-batch-regression-v1/receipt.json)
  and roundtrip-verified archive preserve 209 execution files.
- Affected #35 reader replay: `python3 experiments/public-schedule-readers/replay.py --output .artifacts/schedule-readers-feature-world-batch-v1 --cpu 5`.
  Terminal PASS, 99 commands, 28 backend rows; all 67 pins and exact 38-module
  inventory match. Original assertions and mutants remain unchanged.
  [Portable reader receipt](../../experiments/public-schedule-readers/evidence/feature-world-batch-current/receipt.json)
  SHA256 `2407a7f556f558cc1d9b1ac7896dd1be62ff14c053a7e31d702f581dff69ab58`;
  its roundtrip-verified archive retains all 651 execution files.
- #47 actual-source state replay: `component-state-live-qualified-v1`, PASS
  87 commands, eight intended negatives and five reached mutants on both
  backends; all 61 named source pins match (15 executed core modules).
- #40 actual-source Feature replay: `features40-live-current-v1`, PASS
  61 commands, complete normal observations on JS/Native, six intended
  negatives and four reached semantic mutants per backend. All 94 pins match.

## Limits

Workshop JS/TS 0.3742346617 and Native/TS 0.0711993769 are descriptive ratios
for this named workload, not full parity qualification. The complete state
application retained timing observations still show JS/TS 2.72–2.89 and
Native/TS 0.051–0.075; composed-reader deficits also remain documented in #21.
Feature #40 complete application timing remains pending. Full performance
qualification stays open under #21/#23/#24. Sampled allocation reductions are
not physical/RSS memory reductions or a causal timing guarantee.

No new law, dependency, numerical tolerance or baseline approval is inferred.
Finite controls and mutation witnesses are not universal executable refinement.

Independent [Spec/Standards review](../reviews/feature-world-batch-final.md)
found no blocker for bounded incremental delivery; it did not rerun backends.
