# Affine journal-list kind feasibility

**Type-feasible, but no optimization benefit demonstrated; do not rewrite the core solely on this hypothesis.** Elementary Data/affine list build-and-consume programs emit byte-identical C and both execute 15 heap allocation calls with zero RFC wrapper calls. An explicit retained-snapshot adapter works but executes 37 allocation calls and 9 RFC wrappers in its separate three-element diagnostic. These whole-program elementary counts include IO; they are not ECS bottleneck attribution or speed evidence.

Pinned Bend [Base List](/workspace/formal-proofs/bendvy/.references/bend2/bend2/base.bend:40) declares `List<a,A:Kind(a)> is Kind(a)`. [Kind checking](/workspace/formal-proofs/bendvy/.references/bend2/bend2/bend.ts:196) permits Data elements in Type containers. `List<&1,U32>` checks/runs; duplicating that owner is rejected. There is no implicit `List<&1,U32>`→`List<&2,U32>` conversion: the intended type mismatch rejects it. Both controls retain their diagnostics.

Runtime sharing follows uses, not just the erased kind argument: [bind_pop](/workspace/formal-proofs/bendvy/.references/bend2/bend2/comp.ts:1773) retains earlier uses, [facts_hot](/workspace/formal-proofs/bendvy/.references/bend2/bend2/comp.ts:1398) propagates hot datatype/constructor facts, and [node_fill](/workspace/formal-proofs/bendvy/.references/bend2/bend2/comp.ts:1552) seals hot stored words. Datatype hot keys use names, so a kind substitution alone does not guarantee fewer seals. Actual reached baseline helpers spin_84/97/98 have no seal/keep sites; spin_86's nine sites reconstruct Position/PositionView/Cache. This bounded observation does not identify every runtime wrapper's origin.

Current [Tx](/tmp/bendvy-live-first-native/experiments/s-integrate/transaction.bend:12) and [Held](/tmp/bendvy-live-first-native/experiments/s-integrate/held.bend:6) carry Data undo/pings/marks lists without explicit duplication in the exact 29 runtime source. Rollback consumes undo in order (`transaction.bend:43`); commit reverses pings and consumes marks (`:39`, `:88`, `:115`). Public delivery remains Data (`transaction-dispatch-adapters.bend:118`, `host.bend:288`). Changing these lists cannot discard journals, messages, order or retained observations.

Repeated Tx field observation is concrete: [tx-controls](/workspace/formal-proofs/bendvy/experiments/s-prep/fivehour-connected-gates/tx-controls.bend:58) duplicates undo/pings/marks for rendering while returning the owner. The checked generic snapshot adapter instead consumes affine nodes, reconstructs the owner, and constructs a separate Data snapshot by copying only Data elements. A retained view can be read repeatedly after another snapshot is taken. Runtime witness is `6:6:6:6`; no fake Data cast, weakening to Data-only Raw, or ownership escape is used. This costs O(n) traversal plus up to two rebuilt node chains per snapshot. Conversion at every point-Tx boundary risks O(n²) accumulated-journal work.

## Bounded next candidate, if requested

Investigate **undo only**, across one complete transaction lifetime: change private `X.Tx.undo`, `H.Held.undo`, unwind and their carried signature parameters to `List<&1,Inverse<H>>`; retain Inverse/handle Data, commands affine, and public ping/mark/delivery/view representations. Update transaction, held, held-adapter, transaction adapters, audited-invoker and measurement carry signatures together. Use explicit owner+Data snapshot adaptation only at journal observation boundaries, never each point call. Preserve all journal entries/order and callback/guard behavior; Raw remains arbitrary Type. Require both-schema full Tx/rollback/suppression/access witnesses, compiling inverse-order control and attributable generated/native allocation counts before any speed claim. If emission/counts remain unchanged, stop rather than extending a kind-only rewrite to marks/pings. This is a proposed follow-up, not implemented or accepted.

## Reproduce and evidence

```sh
bend version
bend guide
python3 probe.py --output /tmp/affine-journal-kind-fresh --cpu 10
python3 counts.py --input /tmp/affine-journal-kind-fresh --output /tmp/affine-journal-kind-counts-fresh --cpu 10
```

Bend 2.0.35; pinned reference commit matches the manifest. CPU 10; executable checker 15-second opt-in, codegen 30 seconds, clang 120 seconds, runtime 5 seconds; proof/default 5 seconds unchanged. Final five controls and three counter diagnostics pass. Generated sources, counters, output receipts and exact source/reference pins are retained. Initial U32-decrease/forward-reference fixture errors and a diagnostic-format recognizer mismatch remain as failed attempts, not intended negative controls. No core/compiler/kernel/reference/dependency change, new ECS law/proof, benchmark cohort, adoption or allowance reset occurred.
