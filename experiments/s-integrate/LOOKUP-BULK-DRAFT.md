# SI-Q-LOOKUP traversal implementation variant

This unproved implementation variant binds the existing SI-Q-LOOKUP observation
contract to actual `query.lookup`; it changes neither provider capabilities nor
lookup classification. Domain: reachable worlds with unique ascending logical
IDs, actual issued handles, four-slot nominal Main/Aux/Ledger payloads, valid
schema tokens/getters, and bounded arithmetic. The count fixture uses 3..65,537
live rows plus one genuinely reserved then despawned spare row.

A successful lookup returns the complete selected row and actual retained World;
foreign or absent handles return Missing, while a live row lacking Main or failing
Flag selection returns Mismatch. Namespace, allocator, row order, all payload
fields, marks, pending queue, Ledger and Mode must survive. Calling lookup again
on the returned owner must produce the same observation until an explicit command
barrier changes membership. Removing Main must retain Aux; reinsertion makes the
same issued handle readable again.

The private candidate traversal carries a reversed affine prefix. Unmatched rows
move to that prefix; the matching actual owner is read and immediately rejoined
with the untouched suffix. Missing reverses the complete prefix. Recursion is
structurally decreasing and tail-positioned; retained Type values are never
reconstructed from views. First/middle/last, repeated owner return, Flag mismatch,
Aux-only mismatch, stale Missing and same-factory foreign collision are checked on
both schemas, with complete world checks before/after and perturbed independent
full-field observation oracles. The baseline precedes this repair.

Excluded premises remain forged/duplicate IDs, malformed world rows, arbitrary
Type restoration, unbounded metadata arrays and counter overflow. No proof,
production layout adoption, numerical performance acceptance or general root
authority is inferred. This is a lookup execution prerequisite, not E11 reader
retention or universal runtime refinement.
