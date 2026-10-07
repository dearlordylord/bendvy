# Exact optimized public Compose integration

Issue #30: public provider implemented; final review/performance gates pending.

`src/ecs/optimized-compose.bend` executes the existing arbitrary-Store/arbitrary-Ops
public Compose API against prepared per-family affine columns. Schema declarations
prepare selected/accessed families once, and recover every current/past/remaining
owner after transaction finish. Current row aliases avoid repeated Array transport;
reverse access and growth recover complete storage before ordinary fallback.
The ordinary Column constructor and existing public consumers remain supported.

Selected route is concrete-v3 closure
`a4672d110446195e3ac92911c6f41166b62025811df8816878356d0eafd08a55`.
`freeze.py` verifies all29 module hashes. The source-derived minimal DAG is recorded
in `extracted/extraction.json` and copied to the public owner-handoff module.
The Required/all-live producer specializes those exact definitions to eliminate
unused synthetic metadata/Aux arrays; recovery uses the extracted original helper.
It does not substitute a fake single-row public World or fixed Main/Aux gameplay.

Commands:

```sh
python3 experiments/public-optimized-compose/run-seam.py
python3 experiments/public-optimized-compose/run-equivalence.py
python3 experiments/public-optimized-compose/run.py --output /tmp/compose-observations-FRESH
python3 experiments/public-optimized-compose/mutation.py
python3 experiments/public-optimized-compose/profile-js.py /path/to/generated.js
```

`run-seam.py` compares archived-original and extracted generic handoff through a
real public Type Array Column on Bend/JS. `run-equivalence.py` compares original
and Required/all-live specialization with three complete Type Array owners, a hole
and ascending IDs on Bend/JS/Native. Both are finite controls, not universal proofs.

`run.py` retains all source hashes before/after and complete JS/Native observations:
Workshop22 exact actual-TS checkpoints plus the approved foreign-world difference;
prepared-owner aliases, complete old-payload restoration, ascending access,
reverse-access fallback, actual prepared growth and incoming-owner refusal.
The frozen original Workshop is untouched. The copied Workshop changes provider
selection declarations only; gameplay and full observations are unchanged.
Fresh public confinement controls10/10 and actual TS observation are retained.

The compiling recovery-omission mutation changes a reached active-owner return.
Its actual runtime emits an invalid complete observation (empty duplicate-result
field), detected by complete JSON validation after actual JS and Native execution; checker, both emissions and Native compilation succeed.
No syntax failure is counted as a killed mutant. The full actual transcript remains.

Current JS function-entry diagnostic counts: prepared_swap1352, recovery140,
selected evacuation1176/evacuation continuation1036, backward fallback0 in Workshop.
Actual Array-rmw entries1920 versus2236 on the ordinary current provider. These are
transport proxies, not physical allocation bytes or elapsed timing. The earlier
un-specialized all-five preparation diagnostic3074 entries remains as history.

No production selection, product speed acceptance, universal refinement or full
five-by-three matrix follows. Current no-confirmed-slowdown paired timing and
independent final Spec/Standards review remain delivery gates.
