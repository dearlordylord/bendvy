# Candidate contract and unapproved law drafts

This isolated candidate replaces only descriptor-local transition metadata. It does not modify original stream.bend, the generic event runtime, the reference, or any affine World/component/resource owner. Reader<S,M> remains affine and threads its actual namespace/id through open/finish/skip. The representation changes from one chronological list to an oldest-first front, newest-first back, and a cached event count. Publication prepends one actual transition batch to back. Empty-front normalization reverses back once. Retention examines the oldest batch and uses cached count for capacity; it evicts whole batches and preserves max droppedThrough tick. The trusted setup starts empty and publishes nonempty singleton batches. Arbitrary forged queue caches are outside this candidate's compatibility claim.

All chronological observations must equal the original complete oracle, including every physical Array cell, world registrations/clock, all 65537 pre-trim batches, all 65536 retained payloads, failed retry, successful retry, and empty repeat. A canonical snapshot converts both physical lists to chronological batches solely for actual observations. A staged observer adaptation will unpack this snapshot without altering expected outputs. No timing claim follows from representation inspection.

Specific proposed subjects for falsification, NOT approved laws or proofs:

- Empty then publications: canonical batches equal the original chronological append, count equals the sum of actual payload lengths, and each event's from/to and tick remain unchanged.
- Frame: canonical queue equals the original past_window followed by at_capacity at65536, with identical droppedThrough and frameStart. Cursor-zero failure retains data until whole-batch overflow; no truncation or reordered payloads.
- Reader: observe returns identical complete values and lagged; activation starts at cursor zero, failure leaves cursor unchanged, success updates only the matching reader, skipped never-activated reader remains absent.
- Foreign capability: original namespace refusal preserves both actual owners and metadata; legitimate capability retry still succeeds.
- Existing-contract supplemental disposal: only matching position removed; payload and other positions remain intact.
- Complete application: two nominal schemas match all literal model fields and all raw owners; no Data-only restriction on component/resource payloads is introduced.

Reached controls must independently corrupt oldest/newest order, cached size/capacity boundary, failed-reader cursor, and droppedThrough. A mutant crash or missing output does not count as reached. Draft properties remain unapproved; no proof code will be written.

Admission sequence: source-only development checks (5s), a small ordinary real application seam and full current Node oracle, then prospective source/model/mutant freeze and sole review before JS/Native delivery controls. Complete65537/default65536 remains mandatory; if it still exceeds5s retain failure/profile rather than changing limits. Profiles before/after describe full-request diagnostics separately from complete correctness gates.
