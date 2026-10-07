# Receipt inventory control

Before executable core delivery, use:

```sh
python3 scripts/check-receipt-sources.py --require-core-inventory RECEIPT.json
```

The existing hash check verifies recorded files only. The optional inventory
check additionally requires the recorded `src/ecs/*.bend` set to match the
current core, detecting newly added modules and removed files. It changes no
benchmark workload, baseline, statistics or numerical acceptance criterion.
Receipts for intentionally bounded subsets can still use the default hash-only
mode; neither mode establishes semantic or performance acceptance.

Executed controls:

- The previous default regression receipt has 37 matching hashes. Hash-only
  check passes; inventory check exits 1 and reports unrecorded
  `src/ecs/state.bend`. Its original performance result remains historical.
- A temporary receipt naming every current core file passes inventory checking.
- Replacing the state hash with zeroes exits 1 (changed-source control).
- Recording a nonexistent core file exits 1 with that file in `removed`.

These are checker controls, not a new paired performance run. The next core
delivery must retain a fresh unchanged regression receipt covering its complete
source inventory.
