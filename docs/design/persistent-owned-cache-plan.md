# Persistent owned caches — proposed scope v2, not implementation approval

## Candidate

Use private `Cache<Raw:Type,View:Data>{raw,cached}` wrappers as Main and Ledger
payloads in a new experimental world alias:
`S.World<Schema,Cache<M,V>,A,F,Cache<L,LV>,Mode>`.
Raw arrays remain primary affine owners; cached complete views remain observers.
Keep wrappers in storage across systems/ticks, not recreated at query entry.
Reuse generic Rows/World ownership and existing rank-2 callback/token interfaces.
Concrete trusted world/provider types change; public application callbacks do not.

Prefer wrappers to extra cache columns: Rows currently has M/A/F parameters, no V;
a typed extra column requires adding V throughout Rows/World/Row or a closed tagged
view with extra schema checks. It also adds capacity, membership and extraction
synchronization. Wrapping M/L lets existing generic columns/growth carry both
owners together. This is feasible by inspected types and the finite cache probe;
it is not yet a checked connected world/provider implementation.

## Exact integration seams

1. **Creation:** `identity.create_checked` invokes initial_ledger once; a trusted
   cached initializer observes and wraps it. `storage.rows_empty` remains empty.
   Initialize only actual present components; preserve optional Ledger/Main cases.
2. **Growth/reservation:** `storage.slots_empty/grow` creates empty wrapped slots
   and moves existing wrappers intact. `identity.reserve_id` never fabricates a
   component/cache or changes committed membership. Capacity/ID guards stay exact.
3. **Spawn/insert:** cache raw incoming Main through the original complete getter
   before entering internal `Bundle/Command<Cache<M,V>,A,F>`; preserve raw caller
   payload on rejected staging. Account for wrapping/refresh in measured work.
   `commands.spawn/step/main_effect` and `storage.rows_replace_main` move initialized
   wrappers; replacement never inherits the removed component's cache.
4. **Point get/swap:** typed providers supply cached getters and original swap0
   adapters to `storage.with_main/with_ledger` and `transaction.storage_set_*0`.
   Patch cached head0 only for the four verified original scalar writers; retain
   their exact old-scalar inverse and mark positions. No coalescing.
5. **Rollback:** `transaction.unwind/storage_restore_*0` must use those same cached
   swap adapters. Reverse every actual inverse in order; raw and view agree after
   each restoration. Failure publication/stamps and previous commits stay exact.
6. **Arbitrary transformations:** generic `with_main/with_ledger` transforms cannot
   silently retain a previous view. Either expose only reviewed cache-aware
   transforms in this alias, or refresh through the complete original getter at
   the trusted return boundary. New raw writers/replacements require refresh;
   an invalid cache must refresh before any cached observation. No unsafe casts.
7. **Extraction/queries:** `rows_extract/rows_restore`, `take_rows/put_rows` and
   query traversal move whole wrappers. Required/optional queries and lookup keep
   MainNone, foreign/stale guards and schema capability checks. Snapshot's
   `observations.rows/world` receives cached getters but returns wrappers intact;
   independent uncached full-field validation remains a protected check.
8. **Removal/commit:** `rows_remove`, RemoveMain and Despawn drop raw plus view
   together; Aux/flags and added/changed metadata keep their original semantics.
   `transaction.storage_commit` retains actual pending FIFO, pings, marks and
   explicit applyDeferred barriers. Reader epochs are not cached component views.

## Implementation order and gates

First create/check the private cached world and raw↔cached staging boundary, then
creation/growth/structural edits, point/query/snapshot operations, rollback/commit.
Test both schemas and absent branches, two ticks of repeated reads/writes, growth,
replacement/removal/despawn, rejection owner return, mixed inverse failure and
independent readers. Validate every checkpoint with original uncached getters and
fresh bevy-ts payload/effect observations; record epoch differences explicitly.
Mutate raw cell3, stale/wrong cache, growth association and restore order; rerun
actual provider access/reconstruction/schema/affine negatives before measurement.

## Assumptions and scope transition

The minimal domain is complete four-cell views and four original index0 writers.
A generic invalidation policy and destructive rollback remain follow-ups. Trusted
world aliases, command/identity/payload/provider/transaction adapters and candidate
closure declarations must be editable; storage/query-only body edits are insufficient.
Propose a separately reviewed v2 capability/evaluator scope, preserve authoritative
reference/fixtures/checks, and re-freeze equivalent work before any measured keep.
No numerical threshold, dependency, law/proof, speedup or product adoption follows.
