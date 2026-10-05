# Executed allocation map and source-level point fusion

Bounded diagnosis delivered; full core/performance acceptance remains incomplete (#21/#24). The accepted actual candidate is unchanged. A separate 29-module source candidate and reproducer implement private point-dispatch fusion. No compiler/kernel, dependency, law/proof or read-only reference change.

## Where construction happens

AST counters bracket the same eight-world Motion execution (64 ticks ×256 entities); full nine-world fields match fresh pinned TS. **11,656,768 literal/closure constructor expressions execute**, amortized88.934 per131,072 point updates. These counts include query/mark/tick work around the updates. Instrumentation changes escape analysis and adds calls, so they are not exact materialized heap allocation counts, bytes or timings. Arrays created by runtime constructors are not covered by literal counts. The earlier GC interval estimate454MB is separate evidence.

| Attributed module | Executed constructors | Share |
| --- | ---: | ---: |
| held-adapter |4,063,232|34.9%|
| storage |2,621,952|22.5%|
| query |1,313,792|11.3%|
| base/runtime |1,088,168|9.3%|

Tuple literals alone account for2,763,776 executions; arrow closures1,210,465. Repeated unchanged-wrapper transport is spread across the full point path:

| Point-path function | Constructors per update in this bracket |
| --- | ---: |
| measurement motion_select |1|
| held motion_row |3|
| held motion_checked |1|
| held motion_taken |3|
| held motion_get |4|
| held motion_set_fused_done |5|
| held motion_ledger |4|
| held motion_setledger_fused_done |4|
| held motion_return |7|

This is a partial, non-overlapping function attribution table, not the entire89-constructor path. Journals, marks, changed component values and returned observations also have real semantic obligations; they cannot simply be removed. Dense invokes required handle selection; the three extra view queries exist only on sparse and are not covered by this count.

## Implemented source candidate

[point-frame-fusion.patch](point-frame-fusion.patch) removes an intermediate World+Handle+Tx reconstruction in motion_row/health_row before namespace/ledger validation. New private fields_checked helpers receive affine fields directly. Successful callbacks use the same abstract owner/provider boundary and original callback algorithm; foreign/no-ledger fallback reconstructs the owner only when needed. Component types remain affine Type; no raw owner is exposed to the callback.

The complete candidate checked in15s and generated JS in30s. Uninstrumented and counted Motion diagnostics both pass every full field of nine worlds. Counts fall to11,263,552 (85.934/update), **exactly393,216 fewer =3 ×131,072**. All other module counts are unchanged. This is source-level construction reduction, not a demonstrated performance improvement; it removes about3.37% of counted construction, leaving most allocation pressure unresolved. GC interval estimate was445.5MB vs historical453.7MB; neither this nor profiled timing qualifies a speedup.

Additional exact-current-source checks: all8 original static-provider controls (two positives/six intended negatives), including undeclared authority, cross-schema and write-through-read, pass. The explicit **JS-only** adaptation of the original static-world fixture observes8 programs ×8 full records =64, across Motion/Health × cached/raw observers × static/original point callbacks. Same/foreign factory origins with coincident localID1 preserve expected command rejection, owner fields, journals, pings and marks. It does not substitute for the original16-program two-backend gate. Ledger-absent runtime cases, failed-publication/cursor/rollback mutations, Native and remaining full22 gates are untested for this candidate. No adoption/keep/product gate is claimed.

## Language constraint and next targets

[Primary-source language/compiler research](../../../docs/research/js-owner-reuse-language.md) found generic JS constructors emit literals; the current language has no documented generic record-borrow/update facility. Native spare-block reuse is a separate compiler path. Do not solve this by treating arbitrary Type owners as Data or shipping hand-edited generated JS.

Next source targets, in order: fuse metadata_live/read/mark continuations to avoid intermediate columns/tuple wrappers; carry query column fields through its row loop and rebuild at the query boundary; then assess a trusted unpack-once point session preserving getter-after-write cache coherence and opaque callbacks. Each candidate requires full-field, fallback, rollback/journal/stamp and negative-authority checks. A general compiler record-reuse pass needs separate authorized compiler work and affine/Data alias reasoning.

## Reproduction and evidence limits

Node24.20.0 includes Acorn8.18.0; instrument.cjs accesses its bundled parser via --expose-internals, with no project package/dependency installation. The parser validates rewritten syntax before output. It wraps generated literal expressions only in a diagnostic copy and activates counters at the execution marks. Source/core/reference files are unchanged.

```sh
node --expose-internals instrument.cjs /tmp/original-batch.js /tmp/count.js
python3 ../js-profile/run.py --no-gc --generated-js /tmp/count.js --output /tmp/fresh-count
python3 summarize.py --sites /tmp/count.js.sites.json --profile /tmp/fresh-count
python3 point-fusion.py --input /path/to/pinned-JS-overlay --output /tmp/fresh-fusion
# Derive batch.bend with the existing fivehour-measurement/prepare-bend.py recipe,
# check15s and JS-generate30s, then profile/count with the same commands.
python3 point-js-controls.py --overlay /tmp/fresh-fusion --output /tmp/fresh-world --cpu 11
```

[evidence-index.json](evidence-index.json) retains hash-verified counters, profiles, type negatives, world outputs, emitted source provenance and executed/delivered recipe versions. The delivered materializer adds input-pin validation and coherent specialization pins; its29 runtime modules were verified byte-identical to the executed candidate. Initial method instrumentation syntax failure and GC-trace interleaving failure are retained. The latter mixed GC trace output into JSON; the counted rerun disables GC tracing and validates all fields. Profiling codegen/runtime/checker bounds remain30/5/15s for these authorized executable diagnostics. No canonical loop cap reset or qualified comparative metric.
