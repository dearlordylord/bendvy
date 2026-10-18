# Readers Health64 independent model

Run from the repository root:

```sh
python3 test-fixtures/connected-performance/readers-health64/model/seal_gold.py --output /tmp/readers-health-gold-fresh
```

The destination must not exist. The source-derived model first reproduces the qualified original canonical stream, then derives fresh namespaces 1 and 2 and both full role streams. Large outputs remain outside the repository. `SOURCE-BASIS.json` pins recovered inputs and the byte-identical shared physical model. `EXPECTED.json` records the independently reproduced result.

Each world retains 280 common records: seed actors, 84 actual reads, 194 stage outcomes and final state. Original 192 Local calls and 193 transaction facts remain in the complete Bend canonical stream. Ping includes its actual lagged flag; removed/despawned common views contain values only because the TS API exposes no lagged flag. Raw Bend contexts, cursors and all three lagged flags remain lossless in its canonical stream. There is no foreign workload.

This finite model reproduces observations and identity correspondence; it does not establish equal observer costs or comparative performance. No subject output is an oracle input.
