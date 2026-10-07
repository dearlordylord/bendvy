# Public hierarchy TS reference — partial #44 evidence

Receipt `evidence/reference-1791383596927418665/receipt.json` is
`PUBLIC_TS_HIERARCHY_OBSERVED`: five successful commands, 40 pinned sources,
46 complete checkpoints over two nominal schemas. Receipt SHA-256:
`e21ea93f96fce2593cf8b70fead7f70a1ca41b52f69e4098692bed2f17d71705`.
Raw outputs and all three observed reference heads match the tracked manifest.
Independent Spec/Standards review reconciled every declared source and raw log
hash and found no material reference-scope defect.

Initial order is depth `[2,4,5,3,6]`, breadth `[2,3,4,5,6]`. Reorder and
reparenting preserve pre-barrier visibility and change exact post-barrier child
and traversal order. Six refused hierarchy mutations publish their actual error
objects after the barrier and preserve complete payloads and traversal results.
Deleting subtree 3 removes `[6,4,3]`; repeating it removes nothing. Deleting
root 1 then removes `[5,2,1]`, leaving unrelated entity 7. Ordinary Link from
entity 7 to the deleted subtree is detached; lookup returns the exact
`MissingRelation` error.

The first attempt `reference-1791383580491759405` remains INCOMPLETE with raw
diagnostics: an authored assertion incorrectly expected null for absent Link.
Only that assertion was corrected to the actual `MissingRelation` result.

No Bend hierarchy API, affine owner disposal, foreign-world behavior,
negative/mutation/backend gate, proof or performance qualification is accepted.
#42 remains a prerequisite and #44 remains open. This observed public trace is
the comparator for subsequent Bend implementation, not a replacement for it.
