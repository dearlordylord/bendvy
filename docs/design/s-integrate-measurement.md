# S-INTEGRATE measurement contract — draft for review

Prerequisite plan for #19; not implementation, production layout selection or
approval of numerical performance thresholds. The complete operation trace must
pass fresh TS/Native/JS semantic checkpoints before measurements are accepted.
Both owned-list and indexed candidates remain eligible; results may reject either.

| Workload | Exact authored work per iteration | Required final observation |
|---|---|---|
| Dense | In each separate nominal schema lane, required primary-payload query; read all four cells, add 1 to cell 0 through a declared write, increment the lane resource by 1 per updated row, retain the returned owner | Ordered logical handles and every payload cell; resource total |
| Sparse | Same operations in each schema lane, primary payload on every eighth logical entity; separately present/absent/optional selection of that lane's optional component | Complete ordered membership and optional-presence flags, full selected payloads |
| Lifecycle/churn | Reserve one entity, verify pending lookup/query, explicit flush, remove a component and despawn a rotating first/middle/last live entity, explicit flush | Pending versus live boundaries, sorted surviving handles, stale/foreign results; actual map/relocation work if used |
| Readers | Reserve one transient entity and flush; update its primary payload and publish the iteration number; Fast reads every iteration, Slow every fourth; after reads remove its primary component, despawn it and flush; finish with both readers draining retained observations | Each reader's ordered deliveries and observable unread/lag state; retention follows the separately verified trace policy |
| Failed transaction | A increments entity a cell 0 and resource by 1, publishes message A(i) and reserves a spawn; B reads retained messages, writes entity b cell 0 old→old+10→old+30, resource +100, reserves a spawn, stages message B(i), then fails with code7; the same instance retries identical operations successfully | A's commit, B's restored full payload, discarded failed publications, replayed message, consumed reservation ID and distinct retry handle, capture count |

Use initial live counts 64, 256 and 1024, payload width four, and 64 authored
iterations. These are experimental inputs, not capacity/reuse policy. Begin with
one count if compilation or an actual capability blocks the others and report
that coverage gap. Lifecycle input values are iteration numbers; select the
first/middle/last current live logical entity cyclically to avoid a head-only
churn benchmark. Keep logical labels for cross-representation comparisons, but
retain raw reservation IDs at allocation checkpoints so normalization cannot
hide counter rewind, exhaustion or escaped-handle reuse.

Run these workloads separately for Motion and Health worlds, using their own
nominal descriptors and resources; their names never denote a joint cross-schema
query. Initialize each measured resource to 0. Register both reader instances
before publication; keep them identical across invocations. The transient reader
entity is live during reads and removed only afterwards, so added/changed checks
are nonvacuous and retained removal/despawn records are read after deletion.
For the transaction workload, observe immediately after B failure, after the same
B instance succeeds, and before any barrier. A's and successful B's spawns remain
pending across those observations. Then one explicit barrier applies both in FIFO
order, full membership/payloads are observed, and both newly live entities are
despawned at a second explicit barrier before the next iteration. Initial live
count is thereby restored; allocator consumption is not. Failed B's escaped handle
must remain Missing throughout. Spawn payloads are `[i,20,30,40]` for A and
`[i,200,300,400]` for successful B, using fresh owners in each schema lane.

Capacity/retention configuration and exact registration clocks must be frozen
against the reviewed reference trace; no benchmark claim is valid before that.

Implementation must freeze exact setup and field values alongside the reviewed
trace. The two nominal schemas have separate actual callback/provider instances;
sharing an observation helper does not substitute for either schema's runtime.
No query bypass, materialized constant answer, raw-array shortcut or standalone
numeric loop may stand in for the integrated dispatch/owner/transaction work.
All backends perform the same authored operations and observe the same fields.

## Timing and memory

- Pin compiler/Base/reference hashes, Node/clang versions, CPU affinity, worker
  count, flags and inputs. Use one CPU worker, GPU off; initial native flags are
  the existing `-std=c11 -O3 -lpthread -lm` configuration. Record actual commands.
- Separate checker (always <=5 seconds), code generation, C compilation, setup,
  JS warmup, steady-state execution and final observation. Every timed invocation
  has an explicit recorded runtime limit and task-owned process cleanup.
- Warm up TS/JS with the same authored operation sequence on separate fresh
  worlds. Setup/registration and final dump stay outside the measured interval.
  Intermediate observations that are part of the operation trace remain timed.
  State whether dispatch and barrier costs are included; they must be included
  for these integrated workloads.
- Perform seven measured repetitions per workload/backend/candidate, each with
  fresh identical initial state. Alternate backend order. Report median, min/max,
  raw samples and native/TS and JS/TS ratios; retain regressions individually.
  If the duration is too short for stable timing, increase the same iteration
  count for every compared backend and repin inputs before collecting samples.
- Validate ordered observations before timing and verify a compact checksum after
  every repetition. A checksum supplements, not replaces, full semantic traces.
  Failed/mismatched samples are not timing wins and cannot be silently discarded.
- Record process peak RSS by the same method and its scope. Process/startup/setup
  memory is not exact per-component allocation cost. Report retained live count,
  payload width, command/log occupancy and reader lag beside memory samples.

Native must substantially outperform bevy-ts and JS must be at least comparable
for eventual product acceptance. Numeric thresholds remain unapproved; this
research publishes evidence and regressions without declaring that requirement
met. Representative larger scaling, parallel execution, production retention,
allocator exhaustion/reuse, arbitrary recoverable Type mutations and final layout
adoption retain their explicit follow-up gates.
