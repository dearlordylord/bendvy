# Bounded same-slot owner-store elision

This generated-JavaScript diagnostic starts from the exact four-stage composed baseline, SHA256 `a9e530c46235989f6ca6d59cc036382da76fe0a22d3946463816e87960275c9d`. It removes only assignments that write a unique affine owner's original value back to the same slot. Original recipes, source/compiler/kernel/reference/dependency/law/proof and shared runners remain unchanged. No universal alias/FFI legality proof, source adoption, canonical cohort, metric keep/cap reset or performance acceptance.

Candidate `/tmp/bendvy-js-owner-store-elision-controls/baseline.js`: SHA256 `177539ce9da582ed602d1a5638385ac63ae9012a3e044d34b8ef15c7a619c267`. Root owns fresh full65/profile comparisons; no speedup is claimed here. The preceding composition reduced construction expressions but had adverse adjacent raw timing, so this probe addresses an observed emitted cost without treating counts as speed evidence.

## Guards and exact edits

[input-pins.json](input-pins.json) admits only nine exact composed programs and pins each actual29 source closure, including affine Type declarations for Tx/World/Rows/Held/Cache. Arbitrary affine raw components are retained. The exact composed input and source pins are essential to this bounded argument; the recipe does not infer universal ownership from syntax alone.

[rewrite.cjs](rewrite.cjs) verifies the reached fields_checked → boxed taken → invoke/return → return_world chain, plain emitted Held/World constructors, unique done caller/receiver, unique plain local scopes, recognized assignment-only suffixes and **all const evaluations before stores**. It traces RHS bindings back through the unique caller's original owner projections and checks an exact ordered list of removable same-slot assignments. Main Array.set must still use the owner's original plain array and return that array. Every original const/RHS expression remains byte-for-byte in place, including Array.set, fresh cached patches, inverse/mark nodes, Some ledger, Handle and total. Only complete assignment statements are deleted; constructor expressions and changed-slot assignments are untouched.

Accessor properties, Proxy/Reflect/eval and owner shape reflection reject. Selected setter receivers cannot be observed for identity or passed to unknown FFI; restore has no calls/captures. These are finite closed-program structural guards plus exact source/input pins, not an all-JavaScript effect/alias proof. Existing runtime IO support is not rewritten or claimed generally pure.

Each reached callback removes **24 stores**: World/Rows11, main Held6, ledger Held7. The original Array.set still executes; World ledger is still updated, both Cache raw/cached slots are still updated, and changed inverse/mark slots are still assigned. Selected-Tx mutation remains. Nine necessary owner stores remain versus33 in the preceding composition. Suppressed-main fixtures retain their original observer/cached/result expressions; Cache writes are deliberately retained even where a fixture could permit additional elision.

## Fresh evidence

- CPU8, five-second per runtime: quiet and counted profiles each match all fields of nine Motion256 worlds against fresh pinned TS (warmup +eight measured worlds,64ticks).
- Construction expressions remain **7,333,952**; every normalized kind, including closures, equals the exact composed input. No count reduction is invented for store removal.
- Eight cached/raw Motion/Health and suppressed-main cached/raw Motion/Health controllers compare fresh original, composed and store-elided outputs:72 full JSON records each,576 total, all equal.
- Eight composed/elided ×Motion/Health ×Held/Cache-or-World/Rows helper witnesses preserve frozen old Data snapshots, new raw/cached fields, true-old inverses, journals and affine container identities. Original-baseline versus elided Motion selected-Tx witnesses preserve full fields, cached Data and old Handle. These trusted helpers are not public owner exposure or full-world/universal alias tests.
- Eight synthetic mutations reject before output: getter, Proxy, shape reflection, setter owner FFI, owner identity, early-store ordering, restore FFI and wrong same-slot identity. They use test-only copied catalogs to exercise structural guards beyond initial hash refusal; shipping has no bypass.

[Counts](evidence/counts.json), [recipe receipt](evidence/baseline.recipe.json) and [archive index](evidence/archive-index.json) retain exact hashes, quiet/count observations, triple controllers, retained-view witnesses and rejection diagnostics. No prior task's result is relabelled as this task's acceptance.

```sh
node --expose-internals rewrite.cjs /tmp/bendvy-js-composition-four/baseline/pool.js /tmp/fresh-store-elided.js
python3 run-controls.py --output /tmp/fresh-store-controls
node --expose-internals guard-controls.cjs /tmp/bendvy-js-composition-four/baseline/pool.js /tmp/fresh-store-guards
python3 /workspace/formal-proofs/bendvy/experiments/s-prep/js-profile/run.py --cpu 8 --no-gc --generated-js /tmp/fresh-store-elided.js --output /tmp/fresh-store-profile
```

Further gates: timing/heap evidence, Health full-world performance, arbitrary affine layouts/external aliases/interleavings, general source/compiler lowering, Native and full22. Existing ownership/access/performance requirements remain open.
