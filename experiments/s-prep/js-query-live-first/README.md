# Live-first query flag lookup — bounded source probe

Profile-directed follow-up under #21/#24. **Not production adoption, full22
acceptance, a universal proof or qualified performance.** All29 runtime modules
and arbitrary affine Main/Aux components remain.

`struct_cols_live` branches on the returned live bit before reading flags.
Dead rows return every original column and accumulated value; live rows use the
unchanged metadata/selection/callback path. Capacity/ID guards, ascending traversal,
final reversal, stamps, ownership restoration and public headers remain unchanged.
The pinned Base `Array.get` preserves array contents and returns a copied Data
value; the original dead branch discarded that value. No unsafe array access,
Data-only component restriction, law/proof/compiler/kernel changes are introduced.

```sh
python3 experiments/s-prep/js-query-live-first/materialize.py \
  --input /tmp/bendvy-direct-raw-swap-worker --output /tmp/fresh-live-first
python3 experiments/s-prep/js-query-loop/sparse-run.py \
  --original /tmp/bendvy-direct-raw-swap-worker --candidate /tmp/fresh-live-first \
  --output /tmp/fresh-sparse --cpu 9
python3 experiments/s-prep/js-query-live-first/sparse-count.py \
  --built /tmp/fresh-sparse --output /tmp/fresh-count --cpu 9
python3 experiments/s-prep/js-query-live-first/sparse-heap.py \
  --built /tmp/fresh-sparse --output /tmp/fresh-heap --cpu 9
```

The inherited fail-closed recipe verifies29 actual source pins, both coherent
cache manifests, exact query revision and one-module patch before creating a fresh
output. Its receipt uses the historical `query-loop.json` filename, but records
the actual `js-query-live-first-v1` variant. No CPS transport is added.

## Observed evidence

- Motion batch checker15 / JS generation30 pass. Uninstrumented and counted CPU9
  profiles each match all nine full worlds against fresh pinned bevy-ts.
- Dense Motion remains9,955,904 construction expressions, exactly unchanged from
  its direct-raw source input. This is not evidence of timing parity.
- Aligned all-dead high65538/capacity131072/depth17 query returns empty on both
  original/candidate under Node's default stack and runtime5. Whole-program
  constructor counts include equal setup:721,066 to655,528, exactly65,538 fewer
  Tuple constructions; all other constructor-kind counts remain equal.
- One collected-object heap sample brackets query entry/return helpers after
  setup, at32KiB sampling intervals. Original6,635,128 versus candidate6,237,992
  sampled self bytes; profiled clocks6.009 versus4.430ms. These short, instrumented
  single observations establish no stable heap/speed result or TS comparison.
- Actual query/command lifecycle passes40 literal checkpoints for each of JS-one,
  JS-two, Native-one and Native-two. Compiling order and flag-membership mutants
  are detected at their intended independent witnesses on every subject. The
  order mutation includes the reached `struct_idx_finish` reversal.

Two initial query-run invocations used incorrect candidate directory shapes and
failed before checking the candidate (missing staged storage.bend). The runner
requires `ROOT/{JS,Native}/experiments/s-integrate`; the corrected role tree passed.
Failures remain archived. The shared JS-source overlay was compiled for both
backends in these query controls; the separate boxed Native overlay is explicitly
distinct and has no acceptance transferred from those controls.

Independent read-only agent review found no blocking semantic issue within the
existing aligned runtime domain. It verified pinned Array.get semantics, actual
query hashes in all four receipts and active mutation anchors. This is a source
review and finite observation, not alias/refinement proof.

All commands, full batch outputs, source book, profiles and failures are retained
in [evidence/index.json](evidence/index.json). Executable checker15 follows explicit
user approval; default/proof5, generation30, clang120 and runtime5 remain.

Follow-ups: exact-role full22, generic owned payload/access/authority controls for
any adoption, complete two-schema performance families/sizes and qualifying JS
parity / Native>=2x. Sparse output is a finite return check, not a complete metadata
oracle; the separate literal query controls cover their authored field observations.

## Exact Native role follow-up

The recipe also applies to `/tmp/bendvy-boxed-direct-native`, yielding a separate
boxed Native overlay `/tmp/bendvy-live-first-native`. Static Motion64 Native
checker15/Cemit30/clang-O3-120 pass. One raw CPU11 full65-world observation validates
both actual JS/Native roles against fresh TS: TS389.164ms, JS776ms, Native443ms.
Neither target is met in that observation; no stable comparison or attribution to
this source change is established. The exact-role full22 runner is being exercised
separately; this raw observation does not pass its incomplete gates.

Current validation handle: root exec session66232, output `/tmp/bendvy-live-first-full22`. It is a live exact-role gate run, not a passed receipt; do not restart from a missing final evidence file while its process remains live. Archive terminal evidence separately when it finishes.
