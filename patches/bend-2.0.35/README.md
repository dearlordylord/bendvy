# Closed-provider compiler candidate

These patches preserve the isolated compiler09 candidate; they do not select it as the project's default compiler. Qualification scope and remaining gates are recorded in the [existing delivery report](../../docs/reports/delivery-process-expectations.md).

Apply to Bend commit `a950fd683c0d76f09794078e6174fe98a1492876` (2.0.35). Before applying, `bend2/comp.ts` must have SHA256 `32fb66e09f608ce9e4b173384bcfeec453db8c5bc96650e26ad861bef815a8d9`.

1. Apply `01-closed-provider-optimization.patch`. It retains the bounded closed-factory evaluator, typed field preservation, guarded projection/eta contraction, backend placement, usage accounting and diagnostics from private source commit `510474da36bbdb86cc10cbe1c2fb460b31844feb`. Unknown, effectful, dynamic or unsupported cases retain the original path; arbitrary affine `Type` owners remain supported.
2. Apply `02-private35-js-runtime-text-adapter.patch` separately when reproducing the qualified source/private-binary JS correspondence. It embeds the verbatim private35 `f32_round` function text instead of interpolating the source host's function formatting. It changes neither F32 arithmetic nor Native emission and does not normalize generated artifacts.

Use `git apply --check` before each patch. After both, the complete `bend2/comp.ts` must have SHA256 `db3777dc04aaece18bdffa95f5c6f49e058f7b69de4069ecffb4fe3e7cbc5c77`. Both patches were applied to a scratch copy and that result matched frozen09 byte-for-byte. All other compiler source files match original35; no private absolute-path wrapper is needed.

For reproduction, invoke the unchanged upstream `bend2/main.ts` with pinned Bun `1.3.14`. Retain the exact 70-file Bend35 Base/resource set used by the qualified source and private compiler; `base.bend` SHA256 is `c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661`. Do not substitute the mutable installed compiler's library. `bend2/bend.ts` resolves the source CLI's library beside its own source, so pin the complete resource membership as well as the entry file.

This is a source-review artifact, not tool adoption or a universal effect proof. Compiler execution follows the existing launch-review workflow. Installed tools, execution limits, public ECS contracts and production defaults remain unchanged.
