# Next copied-only candidate: indexed graph closure (proposal)

No implementation or compiler child has been run for this proposal.

The retained full profile has 697/18682 samples inside `graph_close` (549 self, 148 anonymous child), called directly by `compile_book`. It is measurable but not the majority; this does not establish that fixing it completes compilation within the existing deadline. GC has 1667 self samples, without attribution to a particular allocation source.

Source: copied `optimized/comp.ts:627–631` scans every edge for every reached node, adding destinations to the same live Set iterator. At line 2826 it closes the current iteration’s lending graph. Later calls at 2839/2864 close segment reachability/fork graphs. All current callers use string keys.

One candidate: construct an invocation-local ordered adjacency map from edges once, then for each key in the original live Set iterate only that key’s ordered destination list, adding to the same Set. Preserve duplicate edges and first-insertion order. This changes O(reached×edges) scans to O(edges+reached outgoing edges). Do not cache across invocations or emission iterations. The generic current function uses strict equality; a Map uses SameValueZero. Therefore either restrict the copied helper to the actual string callers, or explicitly preserve the NaN non-match case before lookup. No other equality change is acceptable.

Required differential controls: exact returned Set identity and insertion order for empty, disconnected, duplicate, self-cycle, mutual-cycle, multi-seed and newly reached nodes; strict NaN behavior if generic type is retained; full C byte equality for the eight previous fresh books. Full consumer must remain unchanged and whole semantic oracle remains 1f54. No claim of installed compiler causality or speedup.

Repeated emission cannot simply be skipped: compile_book:2800–2835 retains monotonically discovered own/hot/stat facts, clears iteration-local lend/spun/clos/tabs/lits/consts/BRWS and generated segment/image state, then re-emits all definitions. Lending closure and BRWS add ownership facts after emission; facts_hot:1431 onward discovers specialization/closure facts during emission. Those facts affect later emission choices. Any per-definition reuse needs explicit dependency invalidation and regeneration of iteration-local artifacts.

Retained iteration data contains only aggregate fact cardinality, not the exact sets. Iteration 1 ended at 6264 facts; iteration 2 began at 6264 and was interrupted. There is no retained iteration-2 final count or exact added-fact inventory to compare. Do not infer stable facts from this partial evidence. The adjacency candidate leaves this fixed-point algorithm intact.
