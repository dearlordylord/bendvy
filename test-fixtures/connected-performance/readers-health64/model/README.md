# Readers Health64 independent model

Run from the repository root:

```sh
python3 test-fixtures/connected-performance/readers-health64/model/seal_gold.py --output /tmp/readers-health-gold-fresh
```

The destination must not exist. The source-derived model first reproduces the qualified original canonical stream, then derives fresh namespaces 1 and 2 and both full role streams. Large outputs remain outside the repository. `SOURCE-BASIS.json` pins recovered inputs and the byte-identical shared physical model. `EXPECTED.json` records the independently reproduced result.

Each world retains 280 common records: seed actors, 84 actual reads, 194 stage outcomes and final state. Original 192 Local calls and 193 transaction facts remain in the complete Bend canonical stream. Ping includes its actual lagged flag; removed/despawned common views contain values only because the TS API exposes no lagged flag. Raw Bend contexts, cursors and all three lagged flags remain lossless in its canonical stream. There is no foreign workload.

This finite model reproduces observations and identity correspondence; it does not establish equal observer costs or comparative performance. No subject output is an oracle input.

Count expansion: `seal_gold.py --count 64|256|1024 --iterations 64 --output FRESH` retains the original operation model and independently derived complete shared records. Every invocation first reproduces qualified64 canonical/world and full Bend/TS hashes; those full streams contain every common scalar. Count affects initial actors/payload/physical state and transient key/ID offset, while iteration-bound generation0..63, 84reads, 194schedules, 192Local,193TxFacts and280records stay fixed. Larger outputs are generated outside the repository. Historical wider canonical controls apply only where the same physical representation is qualified; old Plain Motion256 is not an Indexed256 anchor.
