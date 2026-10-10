# Prepared read traversal delegation

Parent format-envelope-v1 retained full source and5077477-byte JS oracle; stockNative30 failed. Candidate changes only two definitions in core/column.bend, with exact old/new block and47 source hashes in DELTA. Public signatures, all callers and typed projector indices remain. Recursive traversal now uses existing seek/indexed_seek with incomingNone; existing prepared_view_taken projects the returned actual owner once and reconstructs the terminal carrier. No runtime affine callback, owner copy/drop or disposal operation is added.

| Existing case | Delegation result and restoration |
| --- | --- |
| Any fuel, HandoffNil | Writer seek accepts same target/current carrier with ownerNone, unchanged arrays/history/stamps and nil remaining; terminal returns same column/None. Nil precedence over zero is preserved. |
| Zero fuel, HandoffCon | Writer rejects same current0/ownerNone carrier, unchanged remaining/past plus incomingNone; terminal returns same column/None. |
| Positive Inspect | Writer decrements fuel and computes identical equal/before Choice; owner/remaining untouched. |
| Positive Choice equal | Writer accepts target carrier with incomingNone and returns original owner separately; prepared_view_taken unseals only that carrier, projects actual owner once, and places returned owner into current slot with identical rest/past. |
| Positive Choice before | Writer accepts same target/None carrier and unchanged HandoffCon; terminal no projection. |
| Positive Choice after | Writer decrements fuel, moves original owner once into HistoryCon and recurses with rest/Inspect; all physical owners and order preserved. |

Indexed variant uses identical metadata/capacity/current/remaining/past in IndexedPreparedState and the existing indexed_prepared_view_taken_state terminal. Ordinary Column plain_view_* direct Array projection paths are unchanged. Low-fuel rejected temporary incoming is literallyNone, containing no hidden discarded affine payload. Matching projection accepts arbitrary C:Type and returns that C once; V remains Data. Existing prepared_view_taken supports other constructors but the delegated seek here only returns Prepared/PreparedIndexed.

The change removes V/project from these recursive traversal keys by sharing existing S/C traversal. It introduces SwapOutcome transport and may change compiler ownership/fusion cost adversely. The generated-JS family inventory is structural evidence, not Native timing or compiler correctness proof. Whole47/5077477 oracle and unchanged source5/emit30/build120/runtime5 controls remain required. No query partition, workload/output reduction, cap raise, new law, contract, shared core or installed compiler edit.
