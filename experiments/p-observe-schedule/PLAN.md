# Schedule proof dependency inventory — before proof execution

Approved endpoint: `schedule_execution_exact`, extracted verbatim from the frozen
31-law file at SHA256 e0c607d723ad250a189c096d9fa3fd6a36913f4c72efd3a3be6dacd7fadb2cbc.
`subjects.json` freezes original law/type/model/spec hashes. No core changes,
unapproved catalogue aliases, dependency installation, or timeout increase.
Bend 2.0.34/version/guide and Bend/Bend-LDD skills were read first. Base contains
Equal.cong/sym/trans and Empty.absurd; no installed/project mathlib index exists
in the inspected locations. Existing query/lookup contextual helpers are reusable
with source hashes, but unfinished query/flush endpoints are not assumptions.

## Representation-neutral relation

Use equal namespace/frontier/pending and per-slot `S.at` equality over the finite
logical interval `[0,next)`. `Slots(fuel,start,left,right)` is a recursively
structured conjunction, not raw row-list equality and not a stronger world
policy. Distinct physical row order is permitted. A finite structured relation
also avoids duplicating affine proof-function closures. The exact independent
admissibility premise supplies row bounds/uniqueness when extending the interval
or connecting sorted model observation. Relation is proof-local only.

## Contextual helper inventory / graph

1. `Slots`: interval lookup equality proposition. `slots_refl`, `slots_from_equal`
   construct it; `enumerate_related` transports actual independent enumeration.
   Domains: arbitrary finite rows/intervals; no validity is assumed for transport.
2. `bumped_related`, `materialize_related`: interval induction through the actual
   independent Bump / replay materialization functions, given `Slots`. They yield
   equal materialized row lists, not a claim that either list equals input rows.
3. Reserve/Publish transition relation: constructor/Cmp cases over common
   metadata and related rows. Reserve extension requires actual out-of-range
   missing evidence; no complete raw `reservation_exact`/publication alias.
4. Immediate physical Bump: compare `S.at(M.bump_rows(target,rows),slot)` with
   `S.immediate(Nat.cmp(slot,target),S.at(rows,slot))`, contextual structural row
   induction with comparison coherence. This observes one slot and is neither
   a whole-step theorem nor any catalogue equation. Supporting node/decision
   facts serve this observation only.
5. Bump key-count and row-bound preservation: narrow count and rows_valid links
   over this value-only map, plus pending count checks. No general
   `admissibility_preserved` alias. Reserve's next-bound/append facts and Barrier's
   actual flush-prefix invariant remain distinct obligations.
6. Final list induction: empty schedule needs actual query observation adequacy;
   step induction needs relation preservation and admissibility for the actual
   intermediate model state. Barrier needs the real mixed-slot flush/query
   toolkit. Use terminal observation adequacy, never raw equality with S.run.

Dependency graph:

    lookup/key facts -> Bump point observation -> Bump relation
    Slots -> enumeration/replay/Bump congruence -> oracle observation transport
    initial counts/bounds -> contextual prefix invariant
    actual query theorem -> model observation adequacy
    actual flush links + prefix invariant -> Barrier relation
    non-Barrier links + Barrier + adequacy -> schedule_execution_exact

Only independent checked pieces are delivered until every actual dependency is
available. Completion requires unchanged endpoint, own-section compiling mutant,
true-premise control, ordinary checker and kernel under 5 seconds. Partial helper
mutation evidence is reported separately and never counts as the endpoint gate.

## First implementation refinement and next inventory

`bump_enumeration` factors independent Bump materialization through ordinary
enumeration followed by the actual value-only physical map. Supporting
`bump_emit_decision`/`bump_emit` use the query lane's existing `at_key`. This
reduces Bump inverse lookup to the shared enumeration inverse; no arbitrary
materialization invariant is assumed. This small refinement was checked before
its separate inventory paragraph was persisted, a process-order deviation.

Next, before execution: `slots_extend` extends the interval by one supplied end
lookup equality; its only arithmetic support relates the recursively moved start
to `fuel + start`. `missing_after_bound` derives missing lookup at or beyond a
row-valid frontier from exact per-row bounds, using existing query comparisons.
`publish_count`/`publish_pending` transport independent pending validity through
appended Target (which contributes no Spawn count). `reserve_rows_bound`,
`reserve_spawn_count` and `reserve_pending` transport the counted invariant to a
fresh Spawn at the prior frontier; these concern only this contextual successor,
not the unapproved generic preservation theorem. Final composition uses actual
query/flush dependencies only after they pass their gates.

## Fixed coverage refinement (inventory before execution)

For full schedule induction, carry `Slots(limit,0,left_rows,right_rows)` instead
of extending a next-sized relation at every Reserve. The limit is fixed for the
whole approved schedule; `next <= limit` follows from actual model admissibility.
The relation still compares observations only and accepts different row order.
`slots_prefix` restricts coverage for terminal observation. `Covered` adds the
same metadata equations to this fixed-width interval. `missing_after_bound`
uses actual independent row bounds to show absent out-of-range keys. Bump
successor slots split inside/outside `next`: inside uses the now-checked query
`lookup_inside` and `bump_enumeration`; outside uses query `lookup_above`, actual
model bounds and `bump_point`. Fixed interval structure supplies the one-slot
input equality exactly once. The analogous Barrier link belongs to the flush
worker. No invariant on an unrelated arbitrary oracle world is presumed.

Separate Reserve/Publish/Bump/Barrier contextual branches thread the actual
independent admissibility witness in the final schedule induction. Do not create
a filled or renamed generic `admissibility_preserved` theorem. Imported complete
query/enumeration commits are 8644867 and 53265cb; complete query runner rerun
passed in this worktree after import.

Final composition inventory, before execution: contextual `frontier_bound`,
`live_valid`, `queue_valid` project actual independent guard evidence;
`reserve_success`, `publish_success`, `bump_success` thread it in their individual
branches, and `final_observation` uses completed `rows_complete` plus the covered
interval prefix. `barrier_slots` uses completed materialize inside/above lookup,
mixed FIFO correspondence and actual prefix rows_valid; `barrier_success` clears
pending while preserving frontier/rows. `Continuation` is the explicit induction
hypothesis type. Reserve/Publish dispatch case helpers pass actual successors to
that hypothesis; no evidence argument is assumed or supplied axiomatically.
`schedule_related` structurally recurses on the exact authored Step list. The
approved endpoint enters the true guard with reflexive initial slot relation;
false guard remains the original Unit domain. The induction base uses actual
model query adequacy and performs no flush.

Own-endpoint mutation inventory: keep the universal schedule induction and its
initialization inside the dedicated schedule_execution_exact section of PROOF.bend.
A compiling implicit-final-flush M.tick mutant must fail that unchanged induction
and falsify a successful Reserve/no-Barrier instance whose original admissibility
premise remains true. The failure is the endpoint's own induction, not an unrelated
shared lemma; record its exact location as schedule_related. The final wrapper is
not separately claimed as the failure site. A proposed nonrecursive observation
expansion did not convert under an abstract computed world and was discarded;
no alternate observer or subject change was retained.
