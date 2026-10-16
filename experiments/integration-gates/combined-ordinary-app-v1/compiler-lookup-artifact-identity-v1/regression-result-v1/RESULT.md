Both protected comparisons completed with `NO_CONFIRMED_REGRESSION`. Each used the unchanged 20 balanced pairs per backend, two warmups, seeded order, exact complete observations and paired sign tests with Holm correction and zero allowed slowdown. All 220 complete output streams passed.

| Comparison | JS median paired ratio | Native median paired ratio | Meaning |
|---|---:|---:|---|
| Default #28 | 0.9240136253 | 1.0085250658 | Frozen project baseline/current both rebuilt under candidate compiler |
| Targeted compiler | 0.9920699782 | 0.9596713279 | Old/new compiler artifacts of the same current23 Bend bodies |

The default Native result has 10/20 slower pairs (p=0.5880985260); the targeted Native result has 7/20 (p=0.9423408508). These are bounded non-regression results under the existing decision rule, not proofs that slowdown is absent or universal compiler improvement. Identical JS artifact roles were actually measured in the targeted comparison. Its generic outer wrapper status does not make it a default #28 source-baseline comparison.

`evidence.tar.gz` retains both entire run trees, plans, admission observations, commands, full output streams, staged source, generated artifacts and receipts; shared inputs retain runner/statistics/contract/guard/tool-resource snapshots, compiler source, TS source, adapter and source/artifact joins. `manifest.json` lists every member by bytes and SHA-256. An offline readback verified all 946 member hashes, both receipt links, all command exits, and all 220 decompressed command-output hashes. No new runner or verifier was introduced.

Source and artifact applicability: candidate graph+lookup compiler SHA `6abc2118b1800451f380a59f2f04b4f58a6b9ad2a8d37f1841234ed2c5c5b675`; protected generated JS is byte-identical to the qualified historical JS. Native lookup C differs by the two reviewed host-dispatch anchors; whole ELF differs, so Native performance was measured rather than waived. The same lookup/compiler implementation is the #54 candidate, while the protected source excludes its two inspector-query module changes. This qualifies the protected workload route only.

Both admissions were fresh qualitative five-second CPU11 observations with serialized heavy execution; they do not establish sustained isolation of the entire host. No #54 full-consumer performance, private compiler adoption, global campaign, or final JS≤TS/Native≤0.5TS acceptance follows. Historical failures and prior artifact results remain unchanged.
