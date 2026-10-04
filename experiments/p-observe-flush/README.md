# P-OBS stage 3 — checked partial FIFO/slot toolkit

[GitHub #18](https://github.com/dearlordylord/bendvy/issues/18),
[approved task](../../docs/tickets/17-approved-observation-proofs.md).
**Partial progress: `explicit_flush_independent` remains open.**
The original approved statement/core are unchanged. This package contains actual
universal contextual proofs, not a completed flush theorem or finite-fixture proof.

[PLAN.md](PLAN.md) persisted the contextual inventory before checking;
[subjects.json](subjects.json) froze the exact approved block and canonical
law/type/model/spec hashes. Bend 2.0.34 version/guide were run first. The sole
selected [LAWS.bend](LAWS.bend) statement is mechanically compared with the source
at original SHA256 `e0c607d723ad250a189c096d9fa3fd6a36913f4c72efd3a3be6dacd7fadb2cbc`.

## Checked general links

[toolkit.bend](toolkit.bend) passes both ordinary checker and BendTT kernel.

| Result | Exact scope and argument |
|---|---|
| `application_prefix` | Actual `M.apply_all(prefix ++ suffix,rows)` equals applying prefix then suffix. Structural command-list induction, arbitrary raw rows/commands. |
| `replay_prefix` | Independent per-slot replay satisfies the same prefix composition for arbitrary current observation. Separate structural induction. These two laws alone do not prove the folds agree. |
| `spawn_slot` | Actual whole-list spawn agrees with `S.one` at any observed slot, even duplicates. Comparison cases use the same slot/value/tag constructor. |
| `target_own_slot` | Actual whole-list Insert/Remove/Despawn agrees with independent effect at the target's own slot, for every raw row list. Structural induction includes duplicate target rows and despawn-all; it is not yet cross-slot correspondence. |
| `target_fifo` | Every list of actions targeting one fixed slot has exact actual-application vs independent-replay observation at that slot. Induction generalizes intermediate rows; it does not cover Spawn or mixed target IDs. |

Supporting proof-local helpers are `spawn_case`, `comparison_self`,
`despawn_effect`, `missing_target`, `target_node` and `same_slot_commands`.
`target_node` transports the head comparator and uses the tail hypothesis; the
command projection supplies a concrete same-slot sublanguage rather than assuming
a general interpreter relation. Existing approved lookup proof's
`comparison_sym` is imported read-only, with hashes recorded. No unapproved
catalogue law is filled, assumed or duplicated under an alias. All facts are
contextual links for the approved flush goal, not new production policies.

## Exact residual and dependencies

[RESIDUAL.bend](RESIDUAL.bend) originally persisted these three contextual goals;
the resumed progress below discharges the first two and retains the last:

1. `command_slot`: for every command/rows/observed slot, `S.at(M.apply(command,rows),slot)` equals `S.one(command,slot,S.at(rows,slot))`. Spawn and own-target cases are proved; different target/observed IDs still need comparison coherence and row-search transport.
2. `mixed_fifo_slot`: for every command sequence/rows/slot, `S.at(M.apply_all(commands,rows),slot)` equals `S.replay(commands,slot,S.at(rows,slot))`. Command-prefix induction needs the complete single-command link for every intermediate raw row list. Only the same-slot Target sublanguage is proved so far.
3. `flush_rows_observation`: under the exact independent admissibility premise, sorted applied physical rows equal independent enumeration of `S.materialize(next,0n,rows,pending)`. Requires structural prefix invariants, mixed-slot correspondence, interval enumeration/sorting and observation adequacy of the materialized list. It remains open; the query worker's unfinished bridge is not assumed.

For each `pending = prefix ++ suffix`, the structural prefix obligation is:
initial `S.admissible(limit,T.World{id,next,rows,pending}) == True` implies
`S.rows_valid(applied,applied,next) == True`, where
`applied = M.apply_all(prefix,rows)`; suffix spawn IDs must remain bounded,
unique and disjoint from those applied live rows. These need real derivations
from counted initial admissibility, not the unapproved blanket step-preservation
law. That was the initial partial checkpoint; the resumed counted-prefix proof is recorded below.

Once those links hold, the exact approved endpoint additionally needs metadata
and cleared-queue constructor reasoning and the original conditional proposition
under its unchanged premise. Raw-world equality with the independently sorted
materialization is not required. No `PROOF.bend` fills that endpoint yet.

## Reproduction and mutation evidence

```sh
BENDVY_PROOF_CPU=8 python3 experiments/p-observe-flush/verify.py
```

[evidence.json](evidence.json) records terminal exit0 for this **partial** runner,
source/dependency/Base/runner hashes and exact outputs. Every checker/kernel uses
`experiments/t01/bend-check` with five-second kill limit; the six-second process
watchdog detects a failed wrapper rather than permitting a longer checker.

- Full toolkit checker/kernel and six fresh concrete controls pass. Controls include spawn at own/other slot, duplicate despawn, an untouched survivor, Insert→Remove FIFO and missing target. These ground examples are separate from universal contextual proofs.
- Forced `/usr/bin/false` kernel yields the expected verdict failure.
- Exact selected endpoint reports **1 TODO**; residual package now reports **1 TODO** (originally three). Expected open-law results are explicitly verified, not counted as proofs.
- Wrong spawn-tag mutant still typechecks and rejects unchanged `spawn_slot` at its own definition.
- Reverse actual whole-list FIFO mutant still typechecks and rejects unchanged `target_fifo` at its own definition. A focused copy excludes the earlier independent `application_prefix` theorem to expose this result; all retained definitions are unchanged, and that same copied positive passes the kernel first.

These are meaningful **contextual** proof mutation gates, not a mutation gate for
the still-open flush endpoint. Early rewrite orientation and symbolic Despawn
reduction errors were corrected with equality transport and a case lemma; they
are not counted as killed mutants. The first runner expected plural `TODOs` for
one open law; its diagnostic assertion was corrected, then the entire bounded
runner passed. No approved law/core edit or timeout increase occurred.

## Limits and next handoff

Bounded stopping point: checked FIFO composition and spawn/own-target/same-slot
links, with the precise mixed-slot/invariant/observation residual retained. Resume
those links when the actual query interval toolkit is ready. This tranche does
not complete stage 3/#18, owned-runtime refinement, root provenance, full payload
restoration, reader transactions, backend/host IO proofs or performance. It adopts
no allocator policy, Data-only restriction, production layout or dependency.

## Resumed universal command and counted-prefix progress

The resumed inventory was appended before new checks. [coherence.bend](coherence.bend)
now proves **command_slot for every command/raw row list/observed slot** and
**mixed_fifo_slot for every mixed command list**, including cross-target observations.
Nat equality reflection and comparison coherence prove distinct-target preservation;
no valid-state restriction hides duplicate or malformed rows.

[prefix.bend](prefix.bend) now proves independent counted row validity of the actual
full `M.apply_all` result from independent row/pending validity. At every recursive
command prefix it constructs actual intermediate-row validity and remaining-spawn
freshness: Target tag/despawn preserves zero counts of future reservations; Spawn
moves its unique bounded fresh ID from pending into live while preserving the
remaining guards. The proof uses committed read-only query count/conjunction
helpers; all imported helper hashes are recorded. No blanket step-preservation
catalogue statement is filled or assumed.

The earlier residual items 1 and 2 are now discharged by those general typed proof
definitions. RESIDUAL.bend retains only the final observation bridge. Both it and
the exact approved endpoint report one open TODO each. The runner now additionally
checks coherence/prefix with ordinary checker and kernel, and a compiling Target
application no-op mutant fails unchanged `command_slot` in a focused positive
copy excluding the older `target_fifo` section. Fresh completed verification is
recorded in evidence.json. The universal flush endpoint is still pending the
actual sorting/enumeration/materialization bridge; work continues toward it.
