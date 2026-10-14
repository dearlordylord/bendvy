# Retained Native output review

**Verdict: PASS for a separate retained-output full-observation check.** This
does not change or upgrade the original Native collector receipt, which remains
`INCOMPLETE`.

The original plan is `e4b4d1a985f3b2961640c6daca4cce52010e0b8bfb705f8daab141fe03c2adcc`.
Emit, O3 build, and consumer each exited 0; all ten guards passed; the
consumer stderr is empty. The collector failed only when comparing complete
consumer stdout with its frozen oracle, because that oracle contains the prior
source-root QName presentation. The retained stdout is 228,202 bytes with SHA
`b813d64156ce0d03b9c3e469af8f28a448f89d2dc0585fc4bac351c6f3ba7151`.

The independent rebase derives the old and current QName prefixes from the
original copied `entry.bend`, the frozen current entrypoint, and the same nine
absolute ECS imports. The prefixes have six and nine parent traversals. It
changes only that prefix in each of the two independent source-derived full
oracles, records a reversible mapping, and does not use runtime output to
derive either expected stream. The final rebase manifest SHA is
`22d74ed3486241998e4a13d98a85946223f8fb38b5e4b83efdc481b783f4b0c5`.

I independently checked the full decompressed streams and source mapping. All
2,344 occurrences of the old prefix in the counter stream are QName
constructor paths. Reversing the transformation restores both original
oracles byte-for-byte. The retained stdout equals the relocated 228,202-byte
counter oracle exactly. It does not equal the relocated 234,338-byte normal
oracle, first differing at byte 355. The retained comparison record SHA is
`34387945984f86ca189faf06fdc178431f99ece68d93305446840db507174678`.

The existing check policy supports this as a separately labeled retained
output check: the native commands and guards completed successfully, the raw
complete output is retained, and the corrected comparison is an exact join to
the independently derived full oracles. No compiler or consumer rerun is
needed to establish that observation. Preserve the original plan, raw files,
and `INCOMPLETE` receipt unchanged; report this result as a post-hoc
retained-output match, never as a collector PASS.

The current `docs/parity/debug.md` and `docs/parity/README.md` edits state that
scope accurately: they record the retained counter match and normal rejection,
keep the collector receipt incomplete, and leave full debug acceptance open.
The appended delivery-process note reports the same bounded result and likewise
preserves the original status. These documents make no performance, adoption,
or broader coverage claim.

I also reviewed the current `docs/parity/inspect-extended.md` edit. It describes
the Inspector surface as detached Data with affine owners and does not propose
a held-view API. It distinguishes qualified service status/inventory from
arbitrary service payload exposure, and moves #54 performance and #38 world
identity out of the current #55 read-gap list without closing either gate or
claiming full #55 acceptance. The accompanying source audit reports current
core-body matches for 67/67 ordinary categories, 32/32 ordinary-machine
entries, and 60/60 identity entries. That is consistent with the document's
bounded claim that no additional existing-contract #55 read fixture is
identified.
