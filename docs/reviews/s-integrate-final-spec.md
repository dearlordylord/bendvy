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

## Focused mutation and renderer follow-up — `fc0896b`

The twelve recorded full-Host mutations use Native `-O0` for correctness and ordinary JS code generation; no performance inference is valid. Every recorded import hash independently matches retrievable `de73116` bytes. The original compares all ten public channels/four lanes before mutation. Eleven retained witnesses are consistent with their intended public defects: reordered query rows, omitted setter, incorrect LIFO restoration, failed/other/skip cursor routing, reset capture, noncommuting command FIFO, premature structural visibility, failed changed marks, and actual q/r handle reissue. The reissue path parses actual reservation events after the explicit decoder rejection; it does not count an arbitrary decode error. Initial checker/quantity failures and the 120-second O3 compiler failure explicitly remain unsuccessful attempts.

**Publication-specific witness gap:** `failed-publication-leak` changes commands, Pings and marks, but its runner accepts any `reads` difference and retains only changed-row length. That same observation is produced by the separate failed-change-stamp mutant. The recorded witness therefore establishes combined state corruption, not specifically leaked publication. Require an actual message or applied structural-publication difference before accepting that targeted mutation gate. This was sent to the coordinator for correction.

Independent representative replay command: `python3 experiments/s-integrate/host-mutations.py --only inverse-order --optimization O0 --cpu 4 --output /tmp/astra-inverse-order-evidence.json`. Both the current `fc0896b` worktree and a separate exact `de73116` archive with the recorded runner exceeded the unchanged 30-second original C-codegen limit before mutation. Neither is a reproduced semantic detection. Recorded author witnesses remain source-audited evidence; this review does not claim independent successful mutation execution. Source/runner provenance: mutation evidence SHA256 `efce03377df143f2c13d0bdd8b7925c2ac9e7de5b9230312f820c77c3e881484`, runner `ce492a87474c7f96bcd8b1fa23928c00153624de940ed2133eec452698070692`.

Independent compact-renderer source audit confirms that `CompactCell` retains both schema metadata fields and `CompactAux` retains all four cells plus the Motion Bool/Health grade; optional Aux and Flag presence/value are compared. Every original row is inspected before a template/range is emitted. No expected fixture constants replace these fields. Conservative rejection of some otherwise compressible patterns remains documented, and this codec does not establish world-handle authority.

An additional independent executable `/tmp/astra-renderer-fields/fields.bend` passed Native O3 and JS: two valid nominal-schema pairs plus nineteen second-row field corruptions. The controls cover namespace, ID order, all four Main cells, all four Aux cells, Motion frame/moving, Aux/Flag presence, both schema Flag values, Health reserve/class/grade. Each corrupted pair returns `unrepresentable` at index1; both original pairs encode successfully. Five-second checker/runtime limits and 30/120-second codegen/clang limits were retained. Fixture SHA256 `13c10075543e7e75b7956d7c178f31fe3ead216a77a757398f10b0cb3371140e`; identical output SHA256 `76141faf2223329212dba323dcac41334fc7d96f95aafb1622f37e455cf8f1ca`. This is actual bounded Data-codec evidence, not Type-runtime execution or universal refinement.

Full-size independent replays also pass on CPU4: `renderer-bulk-run.py` compiled/executed the original and all six corruption fixtures on Native/JS, validating every expanded field of 65,537-row lists (three Motion lists and one Health list in the original), with the untouched Health lane preserved for each Motion corruption. Isolated replay evidence SHA256 `595db18ffcbd2b3e191c48393e552e3244b93c98c476318b59db4a00b09d3ea7`. `renderer-handle-run.py` independently passed both backends for all 65,537 actual Data handles and three last-handle corruptions (namespace, duplicate ID, wrap). These passing compact codec controls do not erase the separately retained full-JSON JS timeout or substitute for E11 runtime comparisons.
