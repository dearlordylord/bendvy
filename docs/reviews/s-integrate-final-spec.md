# S-INTEGRATE independent Spec review

Reviewed `9cd750b...8f36a38`, including imported foundations, against GitHub #19 (fetched open), SPEC, the concrete trace, contracts and capability ledger. Reviewer authored none of the implementation. Isolated worktree: `/tmp/bendvy-astra-final-spec`; execution affinity CPU4.

**Bounded semantic evidence is credible; #19 is not yet ready for blanket completion.** No new implementation defect was found in the reviewed ownership/transaction/reader/renderer joins. This is a source audit with the focused replays below, not independent reexecution of every historical probe.

- The requirement “callbacks receive abstract declared schema-specific handles” is implemented by universally abstract affine callback owners and fresh operations. Actual Type arrays are returned after reads and scalar inverse writes, not reconstructed from observations. Fresh integrated checker replay passed the positive and all seven intended access/destruction/service negatives. Public concrete constructors remain trusted adapter representation, not global authority. The destructive negative prohibits the attempted operation; it does not establish arbitrary destructive recovery.
- “Restore the selected reader’s observable position” matches actual registration/completion ownership: failure retains saved positions; success advances the selected base; skip advances only message position. Canonical registry metadata is resolved before preflight/effects. Captures and real Audit IO remain outside ECS rollback. Pinned TS Runtime.ts:1367–1429 and world.ts:316–424 support these distinctions, including consumed failed reservation IDs and commit-only lifecycle marks.
- “Normalize only incidental physical/ID representation” is respected by the examined projection: full declared fields/order remain compared, raw reservation consumption remains visible, and foreign lookup is explicitly divergent. Compact E11 output derives its template from actual rows and validates every cell, metadata, Aux, Flag, namespace and ordered ID before compression; unrepresentable inputs fail decoding. It is a bounded codec, not a general renderer/performance guarantee.
- **Open delivery gates:** current main runner correctly rejects its stale source closure; the combined-source evidence refresh is pending. E11 records 20 actual passing executions with matching current source hashes, but semantic mutations remain pending at review time. Required equivalent-work repeated timing, variability and memory evidence also remain unfinished. Dense1024’s four five-second failures and strengthened lifecycle’s seven failures are real unresolved capabilities, not passing correctness/performance cases. Readers’ twelve full-observation cases are delivered author evidence. Pending work must be completed or explicitly reported as a bounded negative with a concrete follow-up under #19’s “record each capability separately” rule.

Production authority/layout, reuse/exhaustion, general Local/destructive restoration, numerical thresholds and universal runtime refinement remain separate unapproved/unestablished capabilities. No new approval follows from this review.

## Independent evidence and exact pins

Ran `bend version` (2.0.34) and `bend guide`; no new dependency or proof. `taskset -c 4 python3 experiments/s-integrate/integrated-access-run.py` passed, with each checker capped at five seconds. The isolated evidence SHA256 is `93abdb3b55a175024f84b717c18f8af4f7b67a2db3222ed8da36b2c0ba21b3b1` (not substituted into author evidence).

Reexecuted the supplied E0–E10 Motion/Health Native and JS binaries under five-second per-process limits; both reproduced all 685240 output bytes, SHA256 `0eb77b7656ad88ca6ca271a5d5de221307ab4545302733e8db1872259c3bdc32`. Independently ran `trace-decode.py` then `trace-compare.py` against `/tmp/bendvy-host-e10-split/reference-fresh.json`: all ten channels and four lanes match on both backends. `trace-decode-controls.py` passed its eight bounded corruption checks. These supplied artifacts precede the combined storage/query/renderer closure; the strict current `host-run.py --verify-built` replay was rejected for source drift and is not a current-source passing build.

All three actual read-only reference HEADs match `.references/sources.json`: bevy-ts `3040a3b2a3f28fa8554d856f9ccb6bf5433fa334`; Bevy `ad678262ce53b5d142fe49ee5e08caff6f00ab60`; Bend source `a950fd683c0d76f09794078e6174fe98a1492876`. Compiler SHA256 `d4821d04932218216c9dc906223ed0e23dd86726d4357a567fb76ee6c976db4e`; Base SHA256 `c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661`.

Reviewed current source SHA256:

| Subject | SHA256 |
| --- | --- |
| host.bend | b50bc903906cb6a842d0ef88ba84fe0dbf0dd7abdb85c0fa436bccf228b74bb9 |
| dispatcher.bend | 3530c7c20d704ba51a9cdace1f028e507960458b9c0bdcdf0dbc0d546c800b07 |
| storage.bend | 936ee89484a6e58558ab1684d90c16cbf2285ef5027292901dd3d9bf973754ba |
| query.bend | 903af14b5d85d1162df5f872f26f221134a17c772bc82fd17686ce2f4be45759 |
| host-render.bend | 1eef120fa604ba633f06d33a8a3910845293926c36dc9c91cd59d4d5c045a28a |
| host-fixture.bend | 994f041177923cca6e6a3d72f66d433a0044239b90f7a58f5efed8ca16d1f792 |
| host-retention-controls.bend | 408390312f8047a0ae16341ada7295031731fc8da6f919eafcecea9e515cae94 |
| host-retention-run.py | 06bd42efaabc2a31595feb6a19fb9a099cc6e80a641603c49cd3812e60bb0448 |
| trace-decode.py | c93810aae8a63a36e0fe10d20ff5d7fc179632cfd89cc9f98d4e9ab574738496 |
| trace-compare.py | 2cc66b6c15a931f8957b12312794a69fcc3df4fc99ae05cb988f8b8f52b4fb39 |
