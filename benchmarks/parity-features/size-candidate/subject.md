# Proposed event size equivalence subject (unapproved)

For every Data event type E and finite list of Batch<E>, counting the concatenation of batch payload lists equals tail accumulation of each actual payload's cardinality, starting at zero. Empty payloads, arbitrary ticks, repeated values and batch order do not change the count. Nat arithmetic is exact; no U32 truncation or wrapping is introduced. This subject is drafted for review, not an approved law or proof.

The candidate changes only size: values, batch order, trimming/drop boundaries, cursors, owner threading and observations remain unchanged. The complete existing reader application including 65535 publications must still pass. Finite falsification compares the old actual size and candidate over varied empty/nonempty batches, and a reached wrong-count mutant must be detected. Such controls do not establish universal refinement. No live core change or performance claim is authorized by this subject alone.
