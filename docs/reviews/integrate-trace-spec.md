# #19 reference allocation prerequisite — Spec review

**PASS for the bounded prerequisite checkpoint.** Reviewed `23ef716...7208946` against [#19's ticket](../tickets/18-integrated-runtime.md) and [SPEC](../SPEC.md), on 2026-10-04. This does not approve an integrated Bend implementation or complete #19's trace-design gate.

The adapter executes actual public `runtime.tick` schedules and declared query/lookup APIs. Reservation IDs come directly from `commands.spawn`, and durable handles from `G.Entity.handle`; no internal allocator inspection, adapter-assigned IDs or normalization hides consumption. Reading internal source files solely for hashes does not substitute internal state for public observations.

A's seed write 10→11 and pending Spawn2 survive B's failure. B observes its own write99, reserves3 and returns a real `Fx.fail`; subsequent observations show restoration to11, tail suppression and missing reserved handles2/3. An explicit barrier makes only A's Spawn2 live. The next actual reservation returns4, distinct from escaped handle3; after its explicit barrier, membership is `[1,2,4]`, while handle3 remains MissingEntity. Empty schedules and observing systems leave pending membership unchanged, exercising the no-implicit-flush boundary. These observations distinguish consumed allocation from discarded publication and earlier committed work from failed-system writes.

I independently ran `timeout 5s node experiments/s-integrate-trace/reference-allocation.mjs`; exit0 output matched the recorded JSON exactly, including all seven checkpoints, pinned source hashes and raw IDs1/2/3/4. The adapter checks the reference commit against the manifest before execution. No dependency installation or reference mutation occurred.

Reviewed SHA256: adapter `f135a0f1d3393f72cb977b9b0cfaf2ec71125860193ad90c3d6f1d3228ba7ee5`; evidence `acef6719b07f13c1ce807c94c48d804ab61d35f51dad58aee4f888f7f6f04b2c`. Pinned bevy-ts commit: `3040a3b2a3f28fa8554d856f9ccb6bf5433fa334`.

No semantic blocker was found. `escapedFailedHandleNeverReissued` must be read as **not reissued anywhere in this finite trace**, not a universal allocator theorem. The report correctly limits evidence to one scalar schema: two-schema/Type ownership, full-payload rollback, resources, events, readers/lifecycle, retry/capture behavior, exhaustion/reuse, Native/JS agreement and performance remain unestablished here. The broader concrete integration trace and seam still require review before their dependent implementation.

## Seam inventory and measurement draft — 2026-10-04

**Seam inventory is sound planning evidence; the measurement draft needs concrete operation definitions before its execution gate.** Reviewed `s-integrate-seams.md` from `7774517` plus its fresh allocation link, and the then-untracked measurement draft. Source checks confirmed abstract callback/returned-owner signatures, distinct R-C1 nominal schemas, T08 Data-row rollback and discarded lag, S-CAPTURE's regenerated one-shot closure and nonstructural barrier, and S-LAYOUT's handle-derived command target. The inventory correctly treats these as separate capabilities requiring integration, not reusable proof of a combined runtime.

Reader routing, retained logs, selected-reader rollback, Type inverse restoration versus consumed-value destruction, and trusted factory lineage versus global authority are explicit boundaries. Full observations do not clone owners. The fresh allocation checkpoint prevents silently rewinding or reissuing escaped failed reservations. No misleading promotion of the six Nat proofs to Type/runtime correctness was found.

Measurement coverage is appropriate: dense/sparse traversal, non-head-only churn, two reader rates and failure/retry; identical authored work, included dispatch/barrier costs, full observations before checksums, separate setup/warmup, fresh repetitions, raw samples and memory-method limits. Numerical thresholds and production layout remain unapproved. However, freeze the following before claiming an executable contract:

- “Required Motion+Health” and optional Health currently blur two nominal schemas with components in one schema. Specify separate concrete provider instances and exact per-schema selections.
- Reader workload authors only messages while expecting added/changed/removed/despawn observations. Add actual lifecycle mutations, barriers, registration/retention inputs and expected deliveries so those checks cannot pass vacuously.
- Specify the resource-total updates, exact A/B publication types, failure point and successful retry sequence. Current prose does not uniquely determine final state or equivalent work.

These are dependent trace/setup gaps, not objections to preparing the plan. The forthcoming concrete trace can resolve them; until then, neither these documents nor the scalar TS checkpoint passes #19's integrated implementation/measurement gate. No runtime, performance or broader capability acceptance follows.

Reviewed SHA256: seams `45ed3f2fe4f2764ca5c0eb89a061a340bf6f30108ae2549b9d77206b11d0add9`; measurement draft `23ef1ba9148cad3c103247f2caff3f54b126bb4145ce36e8b4d251d5b2b51dfc`.

### Measurement wording follow-up — 2026-10-04

The three reported wording gaps are resolved in draft SHA256 `3b9fd4098ac854af993d535823d8879cacd84ef205890edb25ac796082cc0bb3`. Motion and Health now run as separate nominal schema lanes with lane-specific optional selection. The reader workload authors transient spawn, update, message, live reads, removal/despawn, explicit barriers and a final drain; lifecycle checks therefore have actual mutations to observe. Resource initialization/increments and A/B's two writes, publications, failure7 and same-instance successful retry are now concrete at the workload level.

This is still a provisional measurement plan. Freeze descriptor/component choices, all initial/spawn payload fields, optional membership distribution, reader clocks/retention/capacity and expected deliveries in the concrete trace. Also make the failed-transaction workload's barrier placement and fate of successful pending spawns explicit, so repeated iterations have identical membership, queue occupancy and allocation work across backends. These are remaining setup/trace obligations, not regressions in the corrected wording. No frozen executable contract, integrated implementation gate or performance acceptance is claimed. Earlier hashes and findings remain historical records.
