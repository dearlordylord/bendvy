# Indexed scalar-array view probe

**Isolated finite prototype; no live schema/core change or performance claim.** `oracle.bend` is the exact current schema structural view/join/prefix extraction. The new view obtains actual owner+capacity through `Array.size`, checks each physical index before `Array.get(U32)`, threads its returned owner and collects all capacity cells. It reverses the scalar accumulator once; logical prefix remains a separate operation after full projection.

Selected inputs are balanced valid runtime arrays with positive power-of-two capacity. The actual generated `array_node` rejects unequal child lengths; this is not refinement of arbitrary mathematical irregular Array trees. Raw helper capacity is caller-supplied and forgeable: checked read assumes it is the size returned for the actual owner. Refusal returns the actual owner and None without indexing. An internal Collected.Refused result preserves the owner and explicitly falls back to the complete structural oracle; exported valid size-derived views never silently return truncated snapshots.

```sh
python3 experiments/public-optimized-compose/array-view-indexed-probe/run.py --output /tmp/unique-array-view
python3 experiments/public-optimized-compose/array-view-indexed-probe/audit.py --artifacts /tmp/unique-array-view
```

576old/new pairs cover capacities1–128, logical lengths0/1/2/9/17/33/65/129, first/middle/last mutation, zero/nonzero/max-U32 offsets and duplicate values. Each checks every physical projected value, logical prefix, complete returned owner after mutation, and persistence of the earlier Data snapshot. Three actual bound refusals check capacity/capacity+1/U32.max with unchanged complete owner. Affine duplication rejects; reached terminal-omission and order-reversal mutations check/emit/run and fail the observations on JS and Native. Checker/runtime5s, emission30s, private approved Clang120s.

Actual generated JS instrumentation validates all original output and counts576new views,18360successful checked reads,3explicit refusals and576complete collections with zero collector refusals/fallbacks. New view helpers contain no structural `.slice` or `.concat`; the explicit refusal fallback still calls the retained oracle, and was not entered by any selected valid input. The collector lowers to a direct loop. Native audit retains the checked block-read and same actual array word threaded through the result; standalone WL_RESW2 is not application-layout qualification. Counts are not allocation bytes or a timing result.

`evidence/files.json` maps compressed full stdout to original hashes. Receipts bind source/runner/live-schema oracle extraction; generated audit binds exact emitted code and instrumentation. These are finite observations, not proofs or universal raw-helper safety. Promotion requires independent review, complete frozen application/authority/ownership regressions, unchanged paired gates and source-bound before/after CPU/allocation profiles. Arbitrary Type component APIs and gameplay are untouched.
