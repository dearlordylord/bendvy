# Isolated indexed seek-view prototype

Experimental seam for #30; performance acceptance remains pending.
The original isolated receipt below predates the subsequent minimal core promotion.

The private Inspect-entry path consumes two Nat fuel steps directly. Nil precedes
fuel exhaustion; nonempty fuel 0/1 restores current=0 and retains every owner.
Found projects exactly once and stores the actual returned affine payload.
Advance retains ordered history without rebuilding the inspected HandoffCon or
constructing Choice/Inspect. A recursive Type Decision transports real owners;
Wrapped is consumed without a depth limit. Only Nat/U32 Data is reusable.

This is a trusted adapter helper, not new gameplay authority. Public raw Decision
constructors admit states unavailable from step: four wrapped/raw controls record
that behavior explicitly. An eventual promotion must preserve the original
public indexed_seek_view signature and arbitrary Choice-entry semantics, using
the new helper only at the existing internal Inspect-entry seam.

Reproduce correctness (no timings):

```
python3 experiments/public-optimized-compose/indexed-seek-view-probe/run.py --output .artifacts/seek-replay
python3 experiments/public-optimized-compose/indexed-seek-view-probe/audit.py .artifacts/seek-replay
```

[evidence/receipt.json](evidence/receipt.json) records frozen source hashes,
commands/caps and 27 passing operations. Every copied source inventory is checked
before/after each operation and before intentional mutant edits. Root sources are
also guarded. JS and Native agree on 972 complete legacy/indexed/new triples:
targets 0–5, fuels 0–8, empty/one/two remaining owners, three history orders,
identity and legal mutating projections. Observations include remaining/history,
physical recovered cells, lifecycle stamps, projected snapshots and payload call
counters. Four wrapped/raw controls additionally match exact independently
specified complete observations. The affine duplicate negative is rejected;
head omission, owner-preserving history reorder and premature fuel-1 projection
mutants check, emit and execute, and are detected on both backends. Full outputs
are retained compressed; these are finite comparisons, not universal proofs.

[evidence/generated-audit.json](evidence/generated-audit.json) binds actual emitted
JS/C. JS uses direct tail loops and removes Inspect/Choice literals from new
helpers; normal Advance has no HandoffCon reconstruction. Terminal/refusal paths
still reconstruct retained owners. Native passes Decision as one tagged Term,
with real heap-backed nodes and boxed Payload; each loop has ten owner/scalar
arguments, including five metadata fields. This does not establish an allocation
or speed improvement. No benchmark or profiler ran for this prototype. Actual
application integration, full provider/authority gates, matched profiles and the
unchanged paired performance gate remain required before selecting it.


## Actual-core promotion checkpoint

Column `dd7ead147396f13f464fdca8f48fff9c0b185872d9a09548d92bf13529f2f0ab`
contains the reviewed helpers with `IndexedView`/`indexed_view_` prefixes. Only
`indexed_prepared_view_different`'s forward branch calls the new Inspect-entry
helper. Public `indexed_seek_view` definition bytes are identical; same-row,
bounds, backward, old phase/capture helpers and schema/gameplay remain unchanged.

`core-run.py` copies the frozen closure, verifies the complete copied inventory,
then records exactly two client rebases (fixture and affine negative) to actual
Column helper names. Every operation guards the resulting normal/mutant stage.
[core-current/direct/receipt.json](evidence/core-current/direct/receipt.json)
retains a fresh actual-core replay of all 972 triples, four full wrapped outputs,
affine negative and three compiling/reached mutants on JS and Native.
[core-current/direct/generated-audit.json](evidence/core-current/direct/generated-audit.json)
binds the emitted actual-core helpers. The original isolated receipt is retained
separately and is not relabeled as actual-core evidence.

[core-current/provider/receipt.json](evidence/core-current/provider/receipt.json)
records the unchanged application gate: 14 old/new transaction pairs, complete
23-checkpoint Workshop observations and reached restoration omission on both
backends. No statistical performance or allocation claim follows from these
finite controls. Parent integration owns the unchanged paired gates and matched
profiles before selection/delivery.

[core-current/replays/receipt.json](evidence/core-current/replays/receipt.json)
records the terminal source-current serial correctness queue: 60 prepared pairs,
legacy and indexed 2,430-case phase/capture matrices, six owned and six indexed
confinement checks, and ten complete public closure cases on JS/Native. The latter
includes partial-fuel view/get, mutating projection, wrapped recovery, producer
fuel and refusal observations. These guards bind Column `dd7ead`; they do not
change the public old phase semantics or provide performance acceptance.
