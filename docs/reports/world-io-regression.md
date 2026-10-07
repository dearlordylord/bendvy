# Canonical creator regression checkpoint

Command: `python3 benchmarks/run.py --output .artifacts/world-io-core-regression-v1 --cpu 5`.

Terminal result: **NO_CONFIRMED_REGRESSION**, under the unchanged #28 contract:
20 balanced pairs per backend, all 110 complete output observations retained.
Four statistical harness controls also pass.

| Measurement | Median ratio | Scope |
| --- | --- | --- |
| JS / frozen Bend baseline | 0.9796180231 | Paired Workshop regression |
| Native / frozen Bend baseline | 0.9822796752 | Paired Workshop regression |
| JS / bevy-ts | 0.4072954565 | Descriptive Workshop comparison |
| Native / bevy-ts | 0.0734734352 | Descriptive Workshop comparison |

Both backends have seven slower pairs of twenty; one-sided slowdown p-values
are 0.9423408508. This is not proof of equivalence or speedup. A short unrelated
checker preflight overlapped CPU5 during cohort preparation; all samples remain,
and no claim of a contention-free host follows.

The receipt pins exactly 35 core Bend modules plus five benchmark inputs. The
complete inventory check passes:

```sh
python3 scripts/check-receipt-sources.py --require-core-inventory \
  benchmarks/evidence/world-io-core-regression-v1/receipt.json
```

Receipt SHA256:
`1c432eccb83bb1524706788cace0cea300dee1ed4766c85efddef81d7c8d6257`.
Portable evidence retains the receipt, observations and a hash-verified archive
of all 206 execution files.

The four-file WorldIO addition leaves existing World logic unchanged. Workshop
still uses its frozen legacy creator; this regression receipt does not qualify
the new creator's semantics. Direct live-core identity/owner controls are a
separate #38 gate. Foreign IO effect files require their own source binding.
Full feature performance and full parity remain under #21/#23/#24 and #1.
