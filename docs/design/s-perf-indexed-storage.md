# S-PERF indexed storage design — draft for independent review

Baseline: `a976667`, exact records in `experiments/s-perf/baseline.json`.
One experimental candidate under #20; no production layout adoption, new proof
approval, threshold or allocator policy is implied. Read-only references match
the tracked manifest; installed compiler remains Bend2.0.34.

## Candidate and boundary

Keep the existing six-field World and declared callback signatures. Replace its
list-valued rows owner with `Rows<M,A,F>`: independently affine Main and Aux
columns (`Array<Maybe<M>>`, `Array<Maybe<A>>`) and a Data metadata column
(live, optional Flag, added/changed ticks). IDs map to slot `id-1`. Committed
high-water ID and power-of-two capacity are explicit Data fields.

Start small and grow by doubling columns, transferring existing Type slots once
and creating fresh empty slots. Existing IDs keep their slots; this candidate
uses tombstones and no physical compaction or ID reuse. Ordered queries scan
committed slots in ascending ID order and skip tombstones. A reservation alone
does not install a row or extend committed membership. Failed reservations remain
consumed; pending commands publish/apply only at the existing barriers.

Every indexed operation checks namespace and ID/capacity/live bounds before
Array access: Base Array.swap masks/modulos indices, so its own behavior is not
a bounds check. Extract an affine slot with swap(None), call the opaque operation
once, then restore its returned owner. Array.get is Data-only; never use it to
copy a Type payload. No unsafe fork or Type cloning.

Reconstruct a transient trusted Row only for the existing query/observation
callbacks; do not materialize a whole row list for point reads/writes/rollback.
Main-only operations touch Main and metadata, preserving Aux and Flag owners.
Metadata and Type presence must agree after every returned operation. Missing
entity and missing component remain distinct. A foreign handle returns
MissingEntity and leaves the receiving command queue unchanged.

Indexed mark updates replace a full membership scan per committed write. Keep
the current private inverse LIFO journal and command/ping ordering: the baseline
already prepends inverses and marks, so no journal append redesign is justified
by the source. Automatic inverses cover the existing declared scalar setters;
general destructive Type recovery remains outside this candidate.

## Capacity and simplifications

Exercise dynamic growth through all frozen #19 inputs, including E11 IDs beyond
65536. Powers-of-two and actual compiler element-layout limits are recorded;
maximum exercised capacity is not a public exhaustion policy. A private failed
placement/growth gate must return the original store and rejected owned payload.
Do not silently drop a payload or wrap an index. Any unrepresentable domain is
a failed capability with exact bounds/commands and a return condition.

Direct ID slots can waste capacity after long churn. Tombstones, compaction,
ID-to-physical-slot remapping, reuse/exhaustion, arbitrary recovery and full root
confinement remain explicit #1 follow-ups. This is a bounded experiment, not an
unbounded allocation claim. Dense iteration scans high-water slots rather than
only live membership; report that cost and retain churn scaling.

## Candidate statements to falsify before generalization

These are draft obligations and finite test targets, not approved universal laws.
No new ECS proof is written against them.

1. Bounds: zero, foreign, out-of-capacity and tombstoned IDs cannot alias a live
   slot, alter owners, metadata, allocator or receiving queue.
2. Owned round-trip: indexed extraction/read/reinsertion preserves every payload
   cell and metadata field; exactly the returned owner goes back into its slot.
3. Mapping/growth: each committed ID resolves to its own fields after growth;
   first/middle/last slots and unrelated owners survive.
4. Ordered membership: public queries contain every and only selected live IDs
   in ascending order, independently of holes or command target order.
5. Updates/rollback: repeated writes restore the original complete payload on
   failure, preserving prior commits, consumed reservations and reader visibility.
6. Deferred lifecycle: command FIFO, no implicit flush, tombstone/current/stale
   classification and mark/publication order match the frozen public trace.
7. Authority: actual declared provider negatives continue to reject cross-schema
   calls, writes through read, reconstruction and invalid returned Type owners.

Pair originals with compiling wrong-slot, missing-growth-owner, duplicate/lost
owner, tombstone/order, wrong inverse and visibility mutants. Checker/timeout
failures never count as semantic kills. The owned-index canary is an initial
expressibility gate; independent architecture review precedes candidate core code.

## Integration and validation

Use an immutable copied import overlay to preserve #19 baseline sources. Adapt
storage, identity, commands, query, observations and concrete Host signatures.
Existing Tx/dispatcher/readers/captures retain their operations and identities.
Keep fixture compatibility as explicit adapter work; never convert indexed data
back to lists on every point operation merely to satisfy old signatures.

Repeat main ten-channel/four-lane traces, E11 retention, actual access negatives
and semantic mutations. Then validate/measure all five workloads with fixed
inputs and equivalent work; keep source-current pins, seven repetitions, raw
failures, corrected RSS and actual occupancy/lag instrumentation. Align Readers
preregistration and add the quiet full-field-validated FailedTxn observer.
Checker/runtime5s, codegen30s, clang120s; one native worker/GPUoff. No dependencies
or reference/Canonical Tower Defense changes. Review/decide production adoption
separately after actual evidence.
