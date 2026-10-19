# Closed-provider compiler candidate

These patches preserve the isolated compiler11typed candidate; they do not select it as the project's default compiler. Qualification scope and remaining gates are recorded in the [existing delivery report](../../docs/reports/delivery-process-expectations.md).

Apply to Bend commit `a950fd683c0d76f09794078e6174fe98a1492876` (2.0.35). Before applying, `bend2/comp.ts` must have SHA256 `32fb66e09f608ce9e4b173384bcfeec453db8c5bc96650e26ad861bef815a8d9`.

1. Apply `01-closed-provider-optimization.patch`. It retains the bounded closed-factory evaluator, typed field preservation, guarded projection/eta contraction, backend placement, usage accounting and diagnostics from private source commit `d07df8f13f29c16496c70126b15069524942f5e5`. It also permits exact-arity extraction of a closed function field and bounded recognition of typed closed-function environments after strict constructor evaluation. Live partial-application arguments retain their established types; erased arguments remain unchanged. Runtime variables, captured owners, unknown or unsupported cases retain the original path. Arbitrary affine `Type` owners remain supported.
2. Apply `02-private35-js-runtime-text-adapter.patch` separately when reproducing the qualified source/private-binary JS correspondence. It embeds the verbatim private35 `f32_round` function text instead of interpolating the source host's function formatting. It changes neither F32 arithmetic nor Native emission and does not normalize generated artifacts.

Use `git apply --check` before each patch. After both, the complete `bend2/comp.ts` must have SHA256 `b80d85e2a7344e67d466ddf7a3650882ea4e7018b2e1f7a6cb1267ae6ad92256`. Both patches were applied to a scratch copy and that result matched frozen11typed byte-for-byte. All 97 files under `bend2` match original35 except `comp.ts`; no private absolute-path wrapper is needed.

Optional compiler12 candidate:

3. Apply `03-js-string-length.patch` after both patches above. It changes only the JS `String.length` intrinsic and adds a runtime helper that counts Unicode codepoints by UTF-16 index, without a spread array or suffix strings. The helper preserves the previous JS string-iterator count, including raw JS lone surrogates. Public Bend controls use valid Unicode scalars. Native emission is unchanged.

Patch 03 expects the compiler11typed hash `b80d85e2a7344e67d466ddf7a3650882ea4e7018b2e1f7a6cb1267ae6ad92256` and produces `fbf47961d1db636b1e1993b48a1be7154443300b9133832cfe88cd4faed9bbc6`. Its isolated source is commit `6f8b70cbab50650ecd9dd4f50355f76b69aa078b`. Keep patches 01/02 intact. This optional candidate is not adopted by preserving its patch; source-bound semantic and comparative evidence remains subject to final review in the existing report.

For reproduction, invoke the unchanged upstream `bend2/main.ts` with pinned Bun `1.3.14`. Retain the exact 70-file Bend35 Base/resource set used by the qualified source and private compiler; `base.bend` SHA256 is `c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661`. Do not substitute the mutable installed compiler's library. `bend2/bend.ts` resolves the source CLI's library beside its own source, so pin the complete resource membership as well as the entry file.

This is a source-review artifact, not tool adoption or a universal effect proof. Compiler execution follows the existing launch-review workflow. Installed tools, execution limits, public ECS contracts and production defaults remain unchanged.
