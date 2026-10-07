# Unapproved survivor-order candidates

These are draft laws for the narrow graph stack repair, not approved laws or proofs.

1. `remove_edge(edges, descriptor, source)` equals the original-order subsequence of edges whose descriptor key/source pair differs. Every surviving descriptor field, target and duplicate occurrence is preserved.
2. `inverse_remove(entries, descriptor, target, source)` preserves the original order and fields of unmatched inverse entries; matching entries remove every requested source occurrence while retaining source order, and an emptied matching entry disappears.
3. Removal never creates an edge, inverse entry or incoming source. Component owners are outside these Data graph functions and are untouched.

The source consumes each original list head, prepends its unchanged survivor to an accumulator and reverses once at exhaustion. The inverse path uses the same existing matching-entry helper, so it changes traversal stack shape rather than removal semantics. Exact generated execution, independent chronological/literal observations and reached wrong-order/drop-survivor mutants are required in addition to finite Python falsification. No universal stack-safety/progress/performance claim follows.
