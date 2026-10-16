# Retained TS applicability to ordinary owned events

The selected ownership boundary in [affine-events](../../../docs/parity/affine-events.md#selected-ownership-boundary--2026-10-16) governs this implementation: Bevy architecture, Bend affine constraints and the approved Data-event lifecycle take precedence over TS alias identity. RESEARCH.md's historical request for a separate alias-divergence approval is preparation history, not a remaining approval gate. This note adds no contract or execution.

## Exact executed reference

The original [reference.mjs](../reference.mjs) SHA256 `1613800a7e15f539d019b6af7253c18779a8bd7acc4d461be5ea5ed00f5ec2b3` and [oracle.mjs](../oracle.mjs) `beb62cf46c9e3764b9c7d3cecf38756b8a420b7b7bfd6b6f5ca81637246345a7` are pinned by [reference-001/receipt.json](../reference-001/receipt.json), SHA `9e95a2f3122ea7540d38a6a63b28d9516adcf733a850f2c0f5b89409dcf910d5`. Status PREFLIGHT_PASS, actual Node exit0/no failure, five-second cap. Plan-001 SHA `2a281a416336694fd4ceaba0c33d94f32a68e856e9baa665a497cbd8fdbbab71`. Complete raw reference.stdout is 4,785 bytes SHA `99e4e17ca69deb8aadcd39fdbd1e877fcff509efb6b926b9c16ecf6c281df77e`, byte-equal expected-001.stdout; raw stderr is empty.

All 33 pinned bevy-ts core source files still match the recorded inventory and membership. Selected source manifest `.references/sources.json` SHA `5d4d89ca984a2eb21e21715344219bb9caa022b6bebca0c9f8959584cceb8b8f` selects TS `3040a3b2a3f28fa8554d856f9ccb6bf5433fa334`; Node24.20 identity is `23a5637c2470fde09fcc1acc77c1b92e04e3d7e3e6e80ff7df6f5831958d1477`. Historical SPEC and task_runner pins differ from current files; this is reuse of the original source-bound execution, not a new current-runner preflight. Its private environment remains historical (receipt binds hash); no environment contents are copied here.

## Shared operations and explicit differences

| Existing actual checkpoint | Reusable observation | Scope for ordinary Bend |
| --- | --- | --- |
| registered-empty; fast/slow independent | Two real registered readers begin empty; each gets its own visibility position | Match projected payload contents/cursors, not runtime clock encoding |
| fast-shared-payload; slow-independent | Publication FIFO, complete nested values and later delayed reading | TS retains publisher alias and both readers see mutations; Bend transfers one owner and exposes scoped requests/Data projections, with no duplicable alias |
| fast-failed; fast-retry; fast-repeat | Failure preserves unread publication; retry observes it; successful repeat is empty | Does not establish arbitrary custom projector purity or rollback of TS object mutations |
| slow-condition-skipped; slow-resume-discards | Activated condition-false reader discards backlog and resumes empty | Reuse the selected existing Data-event skip rule; do not silently substitute Bevy iteration semantics |
| other-runtime-empty | Same registered definition in another runtime sees no peer publications | Not a genuine same-schema foreign World handle/refusal operation |
| default-window-trim | Inspector does not hold retention; actual three empty ticks yield empty values and lag | Finite default-window observation, not affine retirement/destruction or capacity proof |
| undeclared; erased-cross-schema | No undeclared event grant; undeclared Foreign descriptor returns empty in erased JS | Last historical label is not another nominal schema or a TS compiler-negative test |
| public-disposal-api | dispose/unregister/clearEvents are absent | No TS disposal, owned retirement, shutdown drain, finalizer or exactly-once cleanup evidence |

This trace executes 14 checkpoints in each of OwnedAlpha/OwnedBeta (28 complete records). Repeated all() identity is only the observed single batch; upstream multi-batch flattening allocates a view array without cloning payload objects. Pinned Runtime.ts publication/commit retains values; internal/streams.ts all() returns original single batch or flattened multiple batches. None of this licenses copying Bend Type payloads.

## Publication failure and capacity reuse

The owned-object reference has no failed publisher. The already executed Data-event [public-event-readers/reference.mjs](../../public-event-readers/reference.mjs), SHA `00528f0d5436e383e8e96b2ba14658b0ac715289bace88dcb050eadcaf92a7b2`, explicitly covers failed-publication of999 followed by retry21 and both readers, failed read/retry, false-condition skip, retained payloads, actual65536 capacity/whole-batch overflow and lag. Its [evidence/receipt.json](../../public-event-readers/evidence/receipt.json) SHA `b9e9b23a2ebb883f3dc4cc7e074f1255fa379c9dc6bd0524209e2bc7d8c52e2a` is PASS and binds that exact reference source; full ts.json.gz SHA `23c5a1230bb450e6fd12724e3f07d0d6c10236b9ec21f889b614d456202ea1c6` decompresses to SHA `076b4ee955f33e3bd3d626863461a763f59ee65b9b0deacbbf91927983a57443`. This supplies existing shared publication/cursor/retention inventory, not fresh source-current Bend owned-event qualification. Disposal and registration-swap observations there are explicitly Bend extensions.

No missing TS execution is established for the shared lifecycle operations above: reuse these complete historical observations with their exact scope. A new TS adapter would be needed only if final ordinary Bend acceptance claims exact operation-for-operation shared traces not represented here (for example a new nested-object failed-publication timeline); do not invent TS equivalents for owner recovery, retirement, shutdown drain or scoped Type confinement. The new ordinary Bend consumer, complete independent JS/Native oracle, real foreign-world controls and affected authority/mutant evidence remain separate gates. No Node/backend run was performed for this audit, and no whole-wire TS/Bend equivalence, affine alias rollback, public TS disposal or performance claim is made.
