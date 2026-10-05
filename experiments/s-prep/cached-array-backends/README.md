# Cached Array access with explicit backend operations

**Finite capability result:** separate Native/JS entrypoints can supply frozen operation templates to one shared fixture. Native uses local structural helpers specialized with `~P: Type/Data` and trusted cached capacity; JS keeps actual `Array.get/swap/set` intrinsics. No benchmark, timing gain, keep, production API or proof approval is claimed.

The proposed direct `~native: Bool` match is **checker rejected** (`expected an annotated term; cannot infer`). A frozen-Bool wrapper around an ordinary Bool choice checks, but code generation fails with `an open Array element type`. Calling Base `Array.get.go/swap.go` directly also checks but fails code generation because its erased internal element types remain open. These exact sources and negative diagnostics are retained; no compiler/Base modification was attempted.

The successful fallback uses explicit `~swapper`, `~getter`, `~setter` function templates. `native.bend` supplies `native-helpers.bend`, whose own frozen-element tree recursion skips `Array.size`. `javascript.bend` supplies `javascript-helpers.bend`, which delegates to compiler-supported Array intrinsics. Both call the same `fixture.bend`; **backend source closures are distinct and separately pinned** in `evidence.json`, together with the installed Base hash.

## Domain and observations

Cached capacity must equal the exact leaf count of a balanced tree and be a nonzero power of two. The fixture authors that shape and guards nonzero entity ID, ID≤capacity, power-of-two capacity and world namespace before access. It does not dynamically certify arbitrary public Array constructors or malformed metadata. There is no claim that a merely power-of-two number certifies actual shape.

The affine Main owner contains an owned four-cell Array and tag. The fixture verifies all cells/tag in every returned slot and extracted owner, replacement of a present slot, insertion into a hole, zero/out-of-bounds/foreign rejection preserving replacement owner and original slots, plus Data get/set over all four cells. Main access uses swap/return; `Array.get` is used only for Data. Native O3/one worker/GPU off and JS produce the same six exact independent expected lines.

Compiling wrong-leaf and dropped-returned-owner controls fail full-field expectations on both backends. Dropping an affine owner is allowed by weakening, so the latter is an observation-contract mutant, not a type rejection. Wrong cached capacity is detected **only on Native**; the JS intrinsic path does not consume cached size for tree descent, so a JS kill is not claimed. A separate attempted Main duplication is an intended checker rejection.

The emitted JS helper bodies contain direct indexing/assignment/`array_rmw`, no slice/concat, and no Native structural get/swap branch. This claim concerns the helper bodies and unreachable Native functions, not every runtime function in the generated file. Exact helper signatures/bodies are recorded in `evidence.json`. The successful Native cached recursion is local code equivalent on this finite domain, not direct Base `.go` calls or a universally proved replacement.

## Follow-ups

A candidate integration would need explicit generated backend modules/entrypoints and a storage adapter capability carrying validated shape/capacity through growth. Full Main/Aux owners, lookup/foreign/malformed-state policy, metadata observations, read-access/cross-schema negatives, rollback/publication and original mutation gates remain binding. The source variants must never be presented as a single universal implementation or a mixed toolchain cohort. New numerical performance acceptance and laws require the existing approvals.

Replay finite checks and compiler negatives:

```sh
python3 experiments/s-prep/cached-array-backends/run.py
```

Limits stay checker/runtime 5 seconds, codegen 30 seconds, clang 120 seconds. Commands, hashes, outputs and retained `/tmp` artifacts are in `evidence.json`.
