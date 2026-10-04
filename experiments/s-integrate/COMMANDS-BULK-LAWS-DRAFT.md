# SI-CMD-FIFO: bulk-application implementation variant

This unproved draft retains the existing SI-CMD-FIFO semantics and the public
`commands.apply(world,tick)` signature. It precedes the cursor implementation.

For every reachable world with unique ascending logical IDs, a well-formed
reverse pending list and valid issued spawn IDs, applying the actual queue must
produce the same complete live component/resource/Mode/allocator observations and
chronological lifecycle Change sequence as the independent left-to-right model.
The pending queue becomes empty. Every retained Type owner and every untouched
array element/metadata field survives; deleted owners transfer to disposal once.
No physical traversal cursor appears in the observation contract.

The implementation candidate keeps an affine reversed prefix and remaining suffix
while applying the FIFO. A target not below the previous target continues from
the current cursor. A lower target rejoins the prefix/suffix and restarts from
the logical beginning. Fresh monotonic reservations extend the prefix without
scanning earlier entities. Change records accumulate in reverse and reverse once
at the end. This changes private traversal work, not world layout or ECS policy.

The intended bound is linear in commands plus rows traversed for nondecreasing
target batches (including 65,537 sequential spawn/remove/despawn commands).
Arbitrary alternating low/high targets may still rescan the list and remain
quadratic. No numerical production performance threshold is selected or passed.

`commands-bulk-contract.py` implements an independent complete-field model and
perturbed observation checks for both schemas. Its mixed sequence targets
4,1,3,1,2,4,4,1,1,7: E8-style lower-ID reinsertion and repeated overwrite, a
same-world stale no-op, remove/reinsert, despawn/stale insert, then a newly reserved
spawn. Expected live IDs are 3,4,6,7; lifecycle events remain in command order.
Every scalar/null/empty-list observation path is perturbed; additional controls
reverse FIFO, row order and lifecycle order. These are model-contract tests, not
runtime mutants or owner-identity proofs. Runtime tests must use actual factory,
reservation, queue wrappers and apply, plus genuine nominal Type arrays.

Premises exclude forged namespaces, duplicate/reused spawn IDs, unsorted fabricated
world rows, malformed pending commands and counter overflow. The bulk fixture
uses 65,537 successful reservations below U32 max, four-slot arrays, scalar values
whose fixture arithmetic does not wrap, and valid Main slot indices. Actual
foreign commands retain their existing MissingEntity/payload-return boundary.
General root authority, reuse/exhaustion, arbitrary Type restoration and complete
E11 reader retention remain separate gates.
