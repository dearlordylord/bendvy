# Scheduled full-capacity reader delivery

This packet retains the v9 scheduled full-capacity consumer, its source-derived expected wire, every recorded command stream and guard, the failed/timeout predecessors, and the later unchanged-binary Native replay. The v9 wire is 67,573,993 bytes with SHA-256 `804d5dbf564e859ece28200e92fe147cdad070b4db4a37392526c2fd5262520b`.

The original v9 JS run completed and matched the independent source-only oracle. Its canonical Native attempt emitted and built successfully but ended at the existing five-second consumer deadline with no output. A later PC-sampled run on that unchanged binary matched the oracle while `LD_PRELOAD` was set; it is diagnostic only. A separate ordinary replay, with `LD_PRELOAD` empty and the same already-built binary, completed and matched the full oracle. The original incomplete Native receipt remains separately archived.

The archive also keeps the v2–v8 source and attempt history, stack diagnostics, both Native PC-sampling records, and the v5 smaller full-output predecessor. These are historical outcomes, not replacements for the v9 evidence. Tool executables and system resource trees are not copied; plans retain their exact hashes and full resource-root hash inventories.

Earlier scoped controls remain separate: the reached wrong-reader mutant (`6c80f3936`), declared relation barrier/failure/retry (`794b3f0a4`), seeded-world disposal (`2be15eedf`), and #42 same-schema foreign-world `MissingEntity` with unchanged queue (`54ce441e9`). This packet does not rerun those controls or claim they are source-current under the V9 closure; it qualifies only the frozen V9 full-capacity scheduled workload. Self-link and remaining acceptance gates stay open unless separately qualified.

The protected #28 Workshop record and its complete evidence archive are retained as a bounded source/artifact reuse audit. Its fresh emitted JS/C identity and its separately qualified archived Native binary do not provide a new timing result or a full-feature performance waiver. No comparative performance claim is made. Full #43 acceptance remains open outside this bounded delivery.

Run `python3 verify.py` and `python3 verify.py --selftest` in this directory. The self-test includes full-path/same-basename stream mismatch rejection and local relocation/drift checks.
