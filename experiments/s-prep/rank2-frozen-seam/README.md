# Frozen rank2 callback seam feasibility

**Proposed `@~Owner`/`@~get` contract is unsupported by the pinned language. No core rewrite or stronger callback contract was introduced.** Installed Bend 2.0.35 rejects `@~Owner` with expected name / observed `~`, and rejects `client(~U32,~getter,owner)` on a callback variable with expected term / observed `~`. These are intentional grammar feasibility controls, not ECS negative-access witnesses.

[parse_term_all](/workspace/formal-proofs/bendvy/.references/bend2/bend2/bend.ts:2160) uses parse_quant (-,+,default) before a name. Frozen binders are [leading definition telescope binders](/workspace/formal-proofs/bendvy/.references/bend2/bend2/bend.ts:2393), not a function-type binder mode. [Call parsing](/workspace/formal-proofs/bendvy/.references/bend2/bend2/bend.ts:2035) recognizes explicit `~` prefixes only for a known named template head.

The current seam already has a frozen callback (`~client`) and concrete closed provider references. [Templates](/workspace/formal-proofs/bendvy/.references/bend2/bend2/bend.ts:136) allow omission of `~` punctuation; [def_inst](/workspace/formal-proofs/bendvy/.references/bend2/bend2/bend.ts:3739) instantiates known named templates at their closed leading arguments. A tiny exact-shape control (`~client:@-Owner -> @-get -> Owner -> U32`, body with `~Owner/~get`, plain `client(U32,getter,owner)`) checks, emits Native C and returns 42. Its abstract-owner-inspection mutant still rejects expected U32 / observed body~Owner. This confirms the elementary seam, not full ECS authority/refinement.

Actual [prototype boxed invoke](/tmp/bendvy-live-first-native/experiments/s-integrate/held-adapter.bend:47) calls a body with [frozen provider parameters](/tmp/bendvy-live-first-native/experiments/s-integrate/prototype-static-client.bend:23). Existing generated Native read helpers already use flat Held transport (21 values +7 quantities), not one whole-Held term. The nine seal sites found in reached spin_86 reconstruct Position/PositionView/Cache nodes. [Array intrinsic lowering](/workspace/formal-proofs/bendvy/.references/bend2/bend2/comp.ts:2205) also marks boxed element types hot. Therefore attributing those seals solely to erased rank2 Owner/provider syntax is unsupported; this is not proof that every call or packing operation is eliminated. The historical JS curried-provider observation remains separate and is not superseded.

A direct named, concrete-only callback bridge would require a different registration/authority argument and new actual owner-inspection, undeclared-write and cross-schema controls. Keeping old public headers while adding such a private bridge does not by itself preserve the current generic client contract. No bridge is proposed for adoption here; no new full-gate or speed claim is made.

```sh
python3 probe.py --output /tmp/rank2-frozen-seam-fresh --cpu 10
```

CPU 10; checker 15-second diagnostic opt-in, codegen 30 seconds, clang 120 seconds, runtime 5 seconds; proof/default 5 seconds unchanged. Current-seam positive and three exact intended rejection controls pass. Source/reference pins, generated C and complete diagnostic receipts are retained. No compiler/kernel/reference/dependency or core change, new ECS law/proof, canonical cohort or allowance reset.
