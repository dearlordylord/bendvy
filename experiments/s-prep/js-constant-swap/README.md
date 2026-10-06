# Cursor constant-swap causal probe

This generated-JavaScript experiment removes two executed constant-arrow expressions per update. It preserves the original `array_rmw` function and its fresh Tuple result. It does not change Bend, Native, the compiler, Base, dependencies, proofs, laws, callbacks, query selection, or the array algorithm. Constructor-expression counts are not physical allocation or speed evidence.

The primary source is the exact 29-module typed-Cursor overlay `/tmp/bendvy-private-id-query-v4`, closure `bdf6b2fc46d2a89615d0e9eb48d44f4a3e8c8f2ff5b8268d7ca50463e6bfbe94`. Inputs are the already frozen row-reuse → Data-token pool → direct Tuple → nested Tuple programs, separately pinned here. Actual protected-controller inputs have their own source roots, complete source and fixture provenance, and distinct suppressed-owner source variants. Their source closure is deliberately not relabeled as the normal batch closure.

## Exact transformation

Nine static calls per batch schema satisfy the strict pattern `array_rmw(array, index, () => localConst)`. The binding must be a unique, earlier `const` in the same immediate lexical block and function; shadowing, assignment, nested scope uncertainty, unknown arrows, non-saturated calls, changed runtime bodies, runtime identity/escape, reflection and prototype manipulation refuse. Input and complete upstream/source provenance hashes must match the catalog, and the output must be absent.

The private module-level function copies the exact runtime body, replacing only `f(old)` with a scalar parameter. It still evaluates modulo, reads the true old cell, writes the replacement, and constructs the same Tuple in that order. The caller retains its original array and index expressions and replaces the arrow with its immutable dominating binding. That read is pure and cannot enter its temporal dead zone in the admitted pattern. Original field-expression evaluation, checks, owner references and callback algorithms remain unchanged. Other runtime functions and all original calls outside the admitted pattern remain unchanged. The reserved namespace cannot already occur.

These are exact closed-program guards, not a universal compiler refinement or an affine alias theorem. Source ownership and capability controls remain source-specific. The finite helper witness uses a Proxy only to observe identical read/write/throw ordering; actual Proxy-containing programs refuse enrollment.

## Fresh evidence

All child executions use CPU7 and the existing five-second descendant supervisor. Both schema candidates independently pass all 65 full worlds against fresh TS. Both before/after counter programs pass nine full worlds each. Eight actual typed-Cursor normal/raw/suppressed controller programs produce all 576 identical checkpoint records. Fresh 1/2/4/8-cell full-array, discrepancy, retained immutable Main/Ledger snapshot and pending-pair true-old witnesses pass both schemas. Fourteen refusal cases and 26 retained-owner/modulo/exception-order comparisons pass.

| Schema | Before expressions | After expressions | Difference |
|---|---:|---:|---:|
| Motion | 5,242,944 | 4,980,800 | −262,144 |
| Health | 4,983,360 | 4,721,216 | −262,144 |

Executed arrows decrease from 292,961 to 30,817 in each schema: exactly two per update across 131,072 updates. Tuple expressions stay at 1,060,864 for Motion and 929,792 for Health. No Tuple removal or Native gain is inferred.

Candidate Motion SHA256: `37f20503c58fd715ee60352075424a4d4848962169d7bf962c6e064480a8ddbc`.
Candidate Health SHA256: `cf299788eab7b5eac15c451460f692800a2c0e64ffcaf26f1d5736e1abdd76c3`.
Final programs and their current-recipe receipts: `/tmp/bendvy-constant-swap-controls-frozen/normal-{motion,health}.js`.

## Reproduction and limits

```
node --expose-internals rewrite.cjs EXACT_PINNED_INPUT.js FRESH_OUTPUT.js
python3 controls.py --output FRESH_DIRECTORY
python3 witness-run.py --output FRESH_DIRECTORY
node --expose-internals guard-controls.cjs EXACT_PINNED_MOTION.js FRESH_DIRECTORY
```

`controls.py` pins the runner, final catalog and recipe, invokes the existing literal/closure instrumenter, and compares complete fields and controller outputs. `archive.py` records command/output receipts, frozen generated inputs and outputs, source/provenance files and failures in the small evidence archive. Full65 commands use the unchanged existing source-bound validator recorded in receipts. No proof checker or compiler was invoked because this experiment changes only generated JS.

Retained failures: the first counter harness omitted phase activation and failed with `StopIteration`; it was corrected before any count claim. An initial refusal test changed an unrelated same-named local declaration, so its `let` refusal expectation was invalid; the corrected test targets the actual preceding binding. An initial infrastructure command used unavailable `python`; subsequent commands use existing `python3`. An early count harness subtracted a marker absent from this harness; the final harness reports the exact sum, with unchanged before/after delta. Earlier bounded passing receipts remain separate from final catalog/recipe receipts.

Root profiles establish that `array_rmw` already inlines in the original program. This probe makes no missing-inlining explanation, physical heap claim, elapsed acceptance, canonical reset or adoption claim. Timing belongs to the integrator. Broader array callbacks, unknown identifiers or mutable bindings are explicitly out of scope; no general dead-code or Array optimizer is introduced.
