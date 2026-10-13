Bounded final review — 846a word-spine CPU profile

Verdict: PASS for retaining this diagnostic packet, not for compiler/native acceptance.

Reviewed commit 955bc9e2675414cac5007f18bf3864f9dbf2fc5d (21 owned paths). DELIVERY SHA-256 b728c0d7c6551be8dd7cedb4b4db29fca5f0081d285b285723bf98e25d5bc035; archive SHA-256 0a7de4c57a79ab279bd7dfe63dcad8cdb5f5f72964efc226b8b45a3620036fe1; result SHA-256 941827e7a0fe95ed7c668286a316eb95e001f9404d579364b86cfc5c61bcd5e0. The retained verifier passed for 153 archive members.

The plan/freeze/launch bind candidate 5bbf17d66e20937aca42246bf1dc3e189d36dbed91c9e12f7a01a7028993443c to the unchanged 846a source hash. The instrumentation diff only adds guarded startup/phase markers and cooperative-stop polls, including at lay_match_word entry; no layout, ABI, cache, or budget logic changed. The existing outer sequence remains byte-identical. Its prelaunch check recorded the profile path absent under the separate profile lock; plan pins (194) and outer pins (196) match, and the 63-source inventory plus full 226,096-byte oracle remain pinned.

The child exited 77 at the cooperative cutoff, after 20.067517 sampled wall seconds, covering setup, complete passes 1–2, and partial pass 3. The raw profile is valid (13,127,682 bytes; 1,747 samples; 30,813 nodes). I recomputed key summary values from the raw samples: stringify self 2,947.514 ms, with 2,583.458 ms under lay_of; virtual word-spine 43.037 ms across four samples; val_box 79.046 ms across seven. These are overlapping sampled-wall attribution, not CPU totals or causal comparisons.

The collector remains INCOMPLETE, guards are clean, and no C/native artifact, build, runtime, or numeric result exists. This is diagnostic evidence only; it supports no performance, optimization, or adoption claim.
