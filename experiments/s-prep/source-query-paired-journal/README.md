# Exact source composition: identity query and paired journal

This bounded experiment composes two disjoint source changes. Paired journal input `/tmp/bendvy-paired-journal-v2` has29 source files and coherent cache metadata, closure `a72494c68499f96732c88c9e65a14a00443c972fd82c7de593aa632bb95fcc82`. It changes only held-adapter/transaction relative to the joined flatjournal/Health-ledger source. Frozen identity-query v3 changes only query/two measurement registrations. The overlapping source inputs are byte-identical, so no helper merge or callback rewrite is needed.

The local `materialize.py` is byte-identical to the verified v3 recipe; its explicit input catalog pins the paired29 source bytes. `expected-output-pins.json` independently fixes the exact union. The paired held-adapter/transaction bytes remain unchanged, and the resulting query/measurement bytes equal frozen v3. Every original input function/type header line remains. Authored callbacks, general client/getter path, arbitrary affine Type payloads and existing fallback paths are preserved. No compiler/kernel/reference/dependency/law/proof change occurs.

Output `/tmp/bendvy-query-paired-journal-v1` closure: `1d0c79682ac1d77ab700900d81ada2d4347fb714a60634a126b5cd3daa763067`. Both cache maps and their digests pin actual29 sources; embedded and standalone cache metadata match.

## Fresh composed-source observations

Motion and Health each pass checker15, JS/C emission30, approved private Clang19 O3 build120, and independent fresh TS full65 comparisons for both JS and Native under runtime5. These are finite field observations, not executable-function proofs or universal runtime refinement.

Both schemas also pass fresh quiet and counted nine-world comparisons. Executed JavaScript constructor and object property initialization deltas are exactly zero against actual paired-only builds. Site metadata instrumentation generates byte-identical runtime JS to the root instrumenter. Property slots are not physical heap bytes.

Independent composed Native counts are pending. The separate identity-query and paired-journal count/gate results do not establish additive savings or composed acceptance. Separate v3 query control package0ed4f35 and paired-journal controls remain source-specific; transaction/inverse/true-old/access/authority/fallback and owned-shape gates must be observed on this exact composition before broader use. No elapsed qualification, adoption, canonical keep or cap reset is claimed.

## Reproduction

```
python3 materialize.py --input /tmp/bendvy-paired-journal-v2 --output /tmp/FRESH
python3 build.py --schema Motion --core /tmp/FRESH/experiments/s-integrate --output /tmp/FRESH_BUILD --receipt /tmp/FRESH_BUILD_RECEIPT.json
python3 counts.py --schema Motion --output /tmp/FRESH_COUNT
```

Health uses the corresponding schema argument. CPU7 and original5/15/30/120 bounds are recorded; diagnostic15 does not replace proof/default5. Build receipts record actual commands/exits and artifact pins; they do not fabricate standardized BUILD_PASS metadata. Paired baseline build paths/pins are explicit: original pairedv1/v2 differ only repaired cache JSON, with identical29 source bytes.

Source composition inputs, all29 expected/output maps, readable patch, header/callback preservation receipt, full65 receipts and count receipts are included. All29 files/manifests reproduce identically; four fresh fail-closed materializer controls reject existing output, changed source, stale embedded cache and a supplied stale specialized digest before creating output.
