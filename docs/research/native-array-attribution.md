# Native array attribution — source evidence only

The installed lowering hypothesis that Native `Array.get/swap/set` lacks direct indexed intrinsics is rejected by pinned Bend2 source. `bend2/comp.ts:1737` (`arr_op`) lowers these operations through `blk_at`; `lay_arr` at1008 selects word/boxed layout and stride. Existing generated C uses mask/shift indexed addressing. This is explanatory source evidence, not profiling or a performance result.

Remaining candidate costs include boxed metadata fields and flag retention, whole affine Cache/Held owner reconstruction, scanning logical IDs through high-water holes, result reversal, one undo/mark record per write, repeated publication of duplicate marks, and rollback/command/ping traversal. Source identifies operations but does not establish runtime dominance.

The smallest subsequent structural hypothesis is a separate `Array<Bool>` live-membership column consulted before fetching metadata. Broader primitive added/changed columns could reduce metadata stride and publication writes. Either change requires exact source binding, affine payload/identity/order/rollback controls and complete equivalent-work measurements; neither is selected here.

Current optional joined-mark candidate is isolated at `/tmp/bendvy-dispatch-next-mark`: only three private storage helpers and `mark_main` change, with original headers and all other bodies preserved. Its58 module checker passes are readiness evidence only. It has no full22-gate result, measured keep or product acceptance. No compiler, kernel, dependency or law change is proposed.
