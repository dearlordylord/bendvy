# Native source diagnosis and one next delta

Source-only investigation, 2026-10-10. Pinned reference HEAD verified as `a950fd683c0d76f09794078e6174fe98a1492876`. No compiler, runner, consumer or core source was changed or executed. The immutable candidate/result is retained by tag `evidence/inspector54-direct-target-v1` (commit4fcf50989). Its result remains source34659 PASS, stock JS91638 complete 5,077,477-byte oracle PASS, Native13760 emit30 deadline/no C; Native build/runtime remain unexecuted. This note does not identify the executing phase or qualify #54.

## Strongest concrete explanation

**Hypothesis: the declaration-specialized reachable graph is costly specifically under Native's whole-graph emission/fact fixed point.** The mechanism is established; its responsibility for Native13760 is not measured.

Both targets read and validate the same book before output dispatch: [main.ts:299](/workspace/formal-proofs/bendvy/.references/bend2/bend2/main.ts:299), [book_read:801](/workspace/formal-proofs/bendvy/.references/bend2/bend2/main.ts:801), [cli_emit:358](/workspace/formal-proofs/bendvy/.references/bend2/bend2/main.ts:358). `def_inst` checks the telescope and serializes erased arguments before cache lookup ([bend.ts:3739](/workspace/formal-proofs/bendvy/.references/bend2/bend2/bend.ts:3739)); that common frontend cost alone does not explain the backend asymmetry. Separate processes can still differ in time spent there; the stock JS pass does not locate Native's deadline.

JS builds a reachable file and emits each runnable definition once ([comp.ts:3193](/workspace/formal-proofs/bendvy/.references/bend2/bend2/comp.ts:3193)); direct references become calls ([2946](/workspace/formal-proofs/bendvy/.references/bend2/bend2/comp.ts:2946)). Native additionally roots runtime ADTs, then repeatedly emits **all** reachable definitions until the combined `own/hot/stat` size stops changing. Each pass clears generated segments, spins and several caches; each definition clears expression memos ([2750–2792](/workspace/formal-proofs/bendvy/.references/bend2/bend2/comp.ts:2750), [1837](/workspace/formal-proofs/bendvy/.references/bend2/bend2/comp.ts:1837)). This loop is not a changed-def worklist. Native expression emission also folds calls and fuses eligible calls, with flat native variants keyed by definition/layout ([2126](/workspace/formal-proofs/bendvy/.references/bend2/bend2/comp.ts:2126), [2170](/workspace/formal-proofs/bendvy/.references/bend2/bend2/comp.ts:2170), [2373](/workspace/formal-proofs/bendvy/.references/bend2/bend2/comp.ts:2373)). Consequently, removing a forwarding name does not remove the remaining specialization/fact-analysis work. No pass count, allocation count or time share is known for this candidate.

The actual full47 source contains left-nested four-slot products for Inspect and Check, instantiated for Workshop/Garden and generic resource owners ([runtime-declarations.bend:20](https://github.com/dearlordylord/bendvy/blob/evidence/inspector54-direct-target-v1/experiments/public-inspect/ordinary-declaration-v1/direct-target-binding-v1/stage/runtime-declarations.bend), lines 104 onward for Check). The current [pair constructor and target helpers](https://github.com/dearlordylord/bendvy/blob/evidence/inspector54-direct-target-v1/experiments/public-inspect/ordinary-declaration-v1/direct-target-binding-v1/stage/core/inspector-query-projection.bend), lines 88–103, still specialize both target helpers on whole `left/right` declarations. Direct-target binding bypassed only their forwarding helpers. Matching's runtime result type does not depend on A/B; the existing `tree_matches` interpreter specializes only H/S and takes the actual callback tree at runtime (lines 73–83). These source facts establish a removable reachable specialization boundary, without claiming an instance census.

## One recommended source candidate

Preserve a successor of this candidate and change **only the first field expression of `pair` at line 103** from:

```bend
owner => target => pair_matches_target(~H,~S,~A,~B,~left,~right,owner,target)
```

to the existing helper's body, eta-bound directly:

```bend
owner => target => tree_matches(~H,~S,MatchBoth{MatchLeaf{matches_field(~H,~S,~A,left)},MatchLeaf{matches_field(~H,~S,~B,right)}},owner,target)
```

This supplies owner and target once at the stored callback boundary; duplication of the Data handle remains inside the already typed interpreter. It removes calls from `pair` to the declaration-specialized matching target. Keep the unused helpers for this discriminator. Public declarations, H:Type, projection field and left-to-right reconstruction, interpreter short circuit, Check and every full47 consumer/oracle remain unchanged. No new callback-accepting helper signature is introduced. This differs from the prior [four-helper runtime-callback rewrite](/workspace/formal-proofs/bendvy/experiments/public-inspect/ordinary-declaration-v1/canonical-full-consumer-v1/native-fanout-v1/generic-check-wrapper-v1/callback-forwarding-v1/TYPECHECK-DELTA.md), which reached source5 deadline. The expression may increase enclosing closed-term size; source correctness and compile-time improvement are hypotheses, not conclusions.

Freeze the successor's sole source delta and run the existing stock source5 gate, then complete stock JS30/runtime5 against the unchanged independent 5,077,477-byte oracle. Conditional on those passing, run the existing stock Native emit30/build120/runtime5 collector with the same tool pin, environment, four guards and complete oracle. Preserve every terminal receipt; no unchanged retry, new cap, reduced consumer or compiler alteration. A Native pass supports delivery of that exact successor; another deadline only rejects this bounded candidate and still does not attribute a phase. Subsequent affected authority/reader controls and final review remain necessary before adoption.

## Matching-tree result and copied phase diagnostic

The full47 matching-tree successor `ce8b6bcee` passes stock source and the complete
5,077,477-byte JS observation. Stock Native still reaches the unchanged30-second
emission deadline without C; no build/runtime qualification follows.

The independently reviewed copied installed-CLI diagnostic and complete archive
are retained under [evidence/inspector54-native-phase-v1](https://github.com/dearlordylord/bendvy/tree/evidence/inspector54-native-phase-v1/experiments/public-inspect/ordinary-declaration-v1/native54-matching-tree-v1/native-phase-v1).
All191 archive identities and41,911 JSON markers pass final review. Reading
completes; three emission passes each process5941 outer definitions, while fact
counts grow0→8131→8149→8157. The30-second deadline interrupts pass4 after its
entry marker for definition3128. No C is produced.

This localizes the instrumented execution to repeated Native emission. It does
not establish stock phase timing, exclusive cost or a causal bottleneck. Next
work is source-based reduction of declaration/query specialization while
preserving the complete consumer, affine authority and existing compiler caps.

## Pair-return scan result

The next private successor replaces the reached recursive `ScanResult.Link`
construction with an internal owner-and-rows pair scan; the compatibility API
and full47 consumer remain intact. Its reviewed source, receipts and exact
inverse metadata are preserved at
[evidence/inspector54-pair-scan-v1](https://github.com/dearlordylord/bendvy/tree/evidence/inspector54-pair-scan-v1/experiments/public-inspect/ordinary-declaration-v1/native54-matching-tree-v1/pair-scan-v1).
Stock source5 and the complete 5,077,477-byte JS oracle pass. Stock Native
again reaches the unchanged emit30 deadline without C; build and runtime were
not attempted. Removing this reached recursive box did not resolve the bounded
compilation gate. This supplies no causal attribution or Native acceptance;
authority/reader controls and public promotion remain outstanding.
