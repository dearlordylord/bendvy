# Checked selected-owner Dense integration — isolated experiment

This is an isolated private-adapter capability experiment, **not an accepted
benchmark candidate**, a changed measurement contract, performance qualification,
keep or production API. Protected repository candidate/measurement files remain
unchanged. Held Type Main/Ledger state is an exact copy of prototype commit
`febc9d6`; its SHA256 is recorded. No Data-only restriction, law/proof, dependency,
reference, toolchain, canonical repository or comparison threshold changes.

`prepare.py` derives a temporary copy of the pinned combined overlay. Only that
copy's `measurement-bend.bend` changes: two imports, six private adapter helpers,
and the private per-row call inside `motion_rows`/`health_rows`. All six original
application `body`, `body_read` and `body_ledger` definitions remain **byte
identical**, with per-function hashes; every other original definition is also
identical. Original64ticks, handle traversal, system ordering, full observations,
X.Tx staging, inverse/mark semantics, finish and commit remain unchanged. Adapter
diff and complete source manifest are retained.

## Actual checked opening and original transaction return

Opening checks selected namespace, then uses actual `S.take_rows`: nonzero ID,
capacity, high-water, physical live metadata and Main presence precede affine
extraction. MainNone/Missing uses the unchanged callback on the original X.Tx.
Absent Ledger first restores the extracted Main owner, then uses that same
original callback, preserving its Main write/inverse/mark before absent-Ledger
result. There is no fast-path assumption that invalid handles or optional owners
cannot occur.

For live Main and Ledger, the remaining World holds their temporary absence;
`Held` owns both actual Type payloads. The exact closed application body receives
only its existing opaque Owner and token-specific Main/Ledger methods. Read and
swap use original P payload operations. Each successful write immediately prepends
its actual old-scalar X.Inverse and Main mark; earlier journal/staging is retained.
No write coalescing or snapshot rollback substitute is introduced.

After this closed callback, Main restores to its **begin-checked original index**
and Ledger returns once; the adapter returns original X.Tx fields to unchanged
finish/commit. Direct Array.set restoration relies on the checked binding staying
unchanged: the exact opaque callback and supplied providers cannot access or alter
the remaining World, selected handle, membership or shape. This is a trusted
adapter invariant exercised by finite controls, **not** a new module-privacy claim,
standalone unchecked-join API or universal proof for forged public Held constructors.
General callbacks able to query/alter World while owners are held require a new
provider gate; this implementation does not expose them.

## Delivered finite evidence

One construction child per required schema/backend runs the original same-process
warmup plus one measured fresh world, with64authored ticks and unchanged full-field
oracle against fresh bevy-ts. Motion/Health Dense64 pass NativeO3/JS. No repeated
comparative loop, metric, ratio or improvement is selected from those child clocks.

Nine cases cover selected ID1/ID2, foreign namespace, zero, over-capacity, absent
Main, absent Ledger, tombstone and above-high-water metadata. For both schemas and
success/failure, complete pre/post observations match the unchanged original X.Tx:
Main/Aux/Flag/Ledger four-field payloads and metadata, selected handle, exact old
inverses/order, marks, staged commands/pings, FIFO pending publication and actual
rollback.144JSON records per backend agree exactly. Cases above high-water and
with tombstone payload are explicit malformed/stale constructor controls, not a
claim that those inputs are normal committed worlds.

Four compiling Native/JS mutations detect wrong restoration slot at selected ID2,
foreign-handle bypass, missing immediate Main mark and wrong inverse order. Paired checker controls
reject wrong schema token, concrete write through opaque read Owner, affine Owner
duplication and concrete reconstruction of abstract Owner. These remain finite
capability observations; root authority/universal runtime refinement stay open.

Limits remain checker/runtime5s, codegen30s, clang120s; installed Bend2.0.35,
NativeO3/oneworker/GPUoff. No failed checker/build/deadline counts as a mutation kill.
Development issues corrected before the final runs (earlier source snapshots are not acceptance artifacts): an unmarked reused Data handle in initial join;
two fixture grammar repairs (keyword parameter and mixed record/tuple match);
a diagnostic matcher expecting local `J.Held` instead of emitted `held.Held`.
The intended negative itself rejected correctly; its matcher was corrected.

## Replay

All destination directories must be new. The base overlay is immutable combined
storage/query control source27f6b8aa…/c54c2768…; use the receipt's full pins.

```sh
python3 experiments/s-prep/owned-write-query-integration/prepare.py --base-overlay /tmp/combined-overlay --output /tmp/held-overlay
python3 experiments/s-prep/owned-write-query-integration/run.py --overlay /tmp/held-overlay --build-dir /tmp/held-construction --cpu 8
python3 experiments/s-prep/owned-write-query-integration/controls-run.py --overlay /tmp/held-overlay --output-dir /tmp/held-controls --cpu 9
python3 experiments/s-prep/owned-write-query-integration/negative-run.py --overlay /tmp/held-overlay --evidence /tmp/held-negatives.json
```

## Required follow-ups

Review/accept any protected adapter/measurement scope transition before this enters
an Autoresearch evaluator. Repeat full matrix, large capacities and actual complete
Host access/mutation gates at its chosen combined source. Derivation also changes
the shared Sparse adapter path, but Sparse/Readers/Lifecycle/FailedTxn were **not**
evaluated here. No simplification becomes full capability/performance acceptance.

General cross-entity access, arbitrary live query/snapshot while selected Type
owners are held, arbitrary callback staging, reader registries/stamps, general
capture/provider integration and universal guarded reintegration remain separate
work. No canonical Tower Defense integration or production adoption follows from
this bounded result.
