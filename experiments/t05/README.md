# T05 — bounded lifecycle probe: PASS

[Issue #6](https://github.com/dearlordylord/bendvy/issues/6), [SPEC](../../docs/SPEC.md).
Delivered directly after the user authorized bypassing Dalph. The old failed
Dalph attempt and its candidate remain retained and unaccepted. Its actual
reference adapter is reused; its incomplete fixed-slot resolver is not promoted.

`lifecycle.bend` adds world creation, reservation, pending FIFO commands, explicit
flush, component insert/remove/despawn and typed lookup around R-C1's abstract
read provider. World/rows/auxiliary component cells are affine Type values;
copyable handles are identifiers, not read/write capabilities. User-facing labels
are payload metadata; internal row keys derive from entity slots, so equal labels
cannot alias distinct entities.

## Acceptance and evidence

| Required observation | Evidence / result |
|---|---|
| Pending, live, stale, foreign; storage safety | Ten lifecycle phases; MissingEntity vs QueryMismatch partition; unknown slots 4/U32 max; colliding same-schema worlds; no array access occurs in this list-backed identity/query implementation |
| Schedule completion preserves pending; explicit marker applies it later | `tick` preserves the owned World, including its pending queue; replay calls tick twice before flush; pending and next-schedule observations remain empty |
| Insert/remove/despawn and order | FIFO Spawn/Insert/Remove/Despawn; b-then-a tag insertion preserves a/b row order; stale insert after despawn cannot revive a; empty marker leaves observations unchanged |
| Native/JS/reference | 80 ordered checkpoint lines from ten phases and eight observations per phase match freshly executed public bevy-ts core; native and JS agree |
| Approved foreign-world divergence | Reference resolves a foreign colliding ID to local value 7; Bend returns MissingEntity. Asserted separately, never normalized into parity |
| Reuse/exhaustion policy | Experimental monotonic U32 slots/world IDs; no reuse, reject at max before arithmetic wrap; c gets slot 2 after despawn; world/entity max return None with counter unchanged |
| Candidate laws, no proofs | [CANDIDATE-LAWS.md](CANDIDATE-LAWS.md) identifies executable subjects, admissible states, rationale, controls and missing universal obligations |

Seven extra scenarios cover unknown IDs, allocation exhaustion, no reuse,
identical display labels, and rejected foreign structural commands. Two paired
checker controls reject cross-schema handles and raw writes through an abstract
read handle at the intended type boundary.

Four compiling native/JS mutants are detected: missing lookup world check yields
local value 7; reversed FIFO changes spawn order; auto-flush exposes pending rows;
missing command world check mutates the receiving world's colliding entity.

Each observation fixture replays the actual ordered operations from fresh setup
through its target checkpoint, carrying the same owned World through those
operations. Observation binaries reconstruct those prefixes separately; they do
not establish integrated multi-system execution, failures or reader transactions.
Within each prefix, commands survive tick and are consumed only by flush.

## Reproduce

```
python3 experiments/t05/run.py
# Optional Linux affinity under unrelated concurrent workloads:
BENDVY_CPU=11 python3 experiments/t05/run.py
```

Bend 2.0.34, pinned Base/compiler/reference identities from T01/reference manifest,
clang 14.0.6, Node 24.20.0. Runtime does not need npm packages. The runner checks
ordered output and exact differences; fresh temporary output prevents accidentally
executing an older build after a failure. Each child process has a five-second
limit and timeout cleanup kills its owned process group.

Native build is explicitly two bounded stages: Bend emits C under five seconds,
then clang uses Bend's default CPU flags (`-std=c11 -O3 -lpthread -lm`) under five
seconds. JS generation is separately bounded. A combined native build initially
exceeded five seconds; no timeout was enlarged. This is runtime validation, not a
performance benchmark or a proof verdict. Both schema and capability controls
were also checked independently after their final edits.

## Remaining production obligations

- Factory IDs distinguish Worlds created from one trusted affine Factory lineage.
  Raw constructors and bootstrap are trusted; independent Factory roots can
  collide. Production runtime-owned creation/namespace isolation remains required.
- The component schema here is Position+optional Tag. General bundles, affine
  payload command transfer, T09 scheduler integration and structural declaration
  authority remain separate obligations. R-C1 provider confinement is reused;
  application callbacks receive abstract handles, not this World.
- Linked lists and decimal slot keys are a transparent experimental layout, not
  the intended scalable storage. No array bound masking is involved here; any
  future array layout must validate bounds before access and re-run invalid-ID
  controls. Traversal/churn costs and numeric performance targets remain open.
- No reuse avoids stale-ID generations but exhausts finite space; a production
  reuse/generation or wider-ID design must preserve the approved identity contract.
- Candidate laws are unapproved. No ECS proof, universal authority/refinement,
  rollback, production API or full-core completion is claimed.
