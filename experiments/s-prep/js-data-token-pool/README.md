# Four nullary Data token families: emitted-JS pooling diagnostic

Only `T.PositionToken`, `T.MotionLedgerToken`, `T.VitalsToken`, and `T.HealthLedgerToken` are eligible. No generic None/Some, affine Type constructor, raw component/array owner, world, row, handle or other Data constructor is pooled. No Bend/Native/compiler/kernel/reference/oracle/dependency/law/proof change, canonical cap reset, qualified cohort or adoption claim.

## Source facts and closed-program guard

The frozen original 29-module source manifest is in `source-facts.json`; its actual/overlay/both cache source closures were checked coherent when captured. `types-source.bend.gz` contains exact source bytes, SHA256 `c5ce242494b15de3112845fe3da15e394710032173e170c02b65b75bf94a3d56`. The rewrite verifies this revision and the source declaration blocks: each of the four named types is Data, with exactly its original nullary constructor and no fields. The same types revision occurs in live-first, token-reuse and supplied Tx cores. Input JS hashes and exact qualified token tags are explicit in `input-pins.json`. This is source provenance and finite emitted-flow analysis, not a new Bend theorem or generally approved compiler pass.

Every eligible object must have exactly one plain, noncomputed `$` property whose literal tag is pinned to one of those four declarations. Each full tag receives its own immutable module-level `const ... = Object.freeze({$:tag})`; schema/tag variants cannot share a constant. Four families are supported, but a tree-shaken Motion or Health program contains two and creates only two constants outside the measured phase.

Before pooling, the recipe follows the object into a known uniquely bound named receiver, or a unique const local whose complete references follow the same guard. A receiver parameter may be ignored, read only through `$`, or forwarded directly to another recursively proven named receiver parameter. Whole-token returns, unknown calls/FFI, object identity tests, mutations/deletes, arguments/eval/with access, nested captures, shadow/duplicate token bindings, reassigned/shadowed receiver names and unresolved cycles are refused. Binding patterns are collected conservatively. Thus pooled objects do not reach a token write or unknown/FFI call in these transformed closed paths. This is not universal alias safety or authority/refinement. Data immutability and constructor-kind facts do not authorize arbitrary pooling.

One generic curried observation site per batch input has no direct named-receiver proof. It stays unpooled, with its line/tag recorded explicitly. All foreign/missing/owner guards and source callback algorithms remain unchanged. No Raw restriction is introduced.

## Observed finite evidence

CPU9 per-runtime cap5: pooled Motion baseline and pooled Motion token-reuse input each pass all nine full states against a fresh TS adapter, both uninstrumented and counted. Existing root-owned quiet profile runner and Acorn instrumenter were used unchanged; hashes, commands, full outputs and CPU profiles are archived. No physical heap/timing qualification is claimed here.

For the baseline, exactly 524,288 phase token constructors disappear: 262,144 PositionToken and 262,144 MotionLedgerToken, **four per callback**. Canonical program construction total is 10,086,976 -> 9,562,688. The older baseline receipt totals 10,086,977 because its instrumentation includes one additional profile-marker object; raw comparison therefore includes an extra -1 marker difference. Every other program constructor kind and closure count is unchanged.

For the source token-reuse input, exactly 262,144 more disappear: 131,072 of each token, **two per callback**. Total 9,824,832 -> 9,562,688, with no marker mismatch. Both variants have zero phase executions of these two token constructors. Constants are constructed once outside the active phase.

All eight cached/raw Motion/Health transaction controllers, including supplied suppressed-owner variants, match every original observed line byte for byte: 72 each, 576 total. Normal controllers use stored transcripts; suppressed controllers compare fresh original runs because no stored `.js.jsonl` exists. The original semantic mutant effects are preserved. This does not assert source gate acceptance for a generated rewrite. Health baseline/reuse batch JS was materialized and flow-checked, but no Health batch runtime/count claim is made; Health is exercised in the transaction matrix and four-family read witness.

The retained-token witness reads the same-schema token twice, opposite-schema token separately, and both ledger tokens, retaining all original tag observations. Same/opposite comparisons inspect tag strings, never object identity. All four generated constants are frozen. Seven controls refuse without output: extra token fields; an affine Position Type constructor; token write; unknown/FFI escape; object identity; arguments access; nested capture. Generic constructors are outside the whitelist.

## Reproduce and compose

```
node --expose-internals experiments/s-prep/js-data-token-pool/rewrite.cjs PINNED_INPUT FRESH_OUTPUT
python3 /workspace/formal-proofs/bendvy/experiments/s-prep/js-profile/run.py --cpu 9 --no-gc --generated-js FRESH_OUTPUT --output FRESH_PROFILE
python3 experiments/s-prep/js-data-token-pool/run-scope-controls.py --output FRESH_CONTROLS
python3 experiments/s-prep/js-data-token-pool/run-tx-controls.py --baseline /tmp/bendvy-direct-raw-tx-baseline --output FRESH_TX
```

Verified full64 Motion outputs: `/tmp/bendvy-data-token-pool-baseline-tight.js` and `/tmp/bendvy-data-token-pool-reuse-tight.js`. Exact pinned inputs include `/tmp/bendvy-cache-box-js-build/baseline.js`, `/tmp/bendvy-token-reuse-static-v2/batch.js`, Health baseline/candidate JS and eight Tx inputs. Additional composition requires explicit new intermediate SHA/tag/type-source provenance; none of the shape, kind or receiver-flow guards may be weakened. Reserved pool names prevent accidental repeated application. Unproven sites remain unchanged.

Evidence freezes generated inputs/outputs, exact type source/full29 pins, recipes/flow records, current kind counts, full nine-state outputs/profiles, transaction checkpoints and scope controls. Archive hashes describe uncompressed bytes. Physical heap attribution, composed-program full validation, broader workload/schema coverage and canonical performance acceptance remain follow-ups owned by integration.
