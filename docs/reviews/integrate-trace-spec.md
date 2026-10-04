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

## Concrete E trace review — 2026-10-04, `d6adf30` (author `bab0083`)

**Substantive trace coverage is appropriate; two sequence/API clarifications are required before freezing execution.** Reviewed the trace against #19/SPEC, the actual pinned TS dispatcher, transaction, stream and lifecycle-log code, existing seam limits and the freshly executed scalar X. No full E trace was executed during this review; every E expectation remains source-derived.

The E0–E9 progression is coherent with the inspected source: committed changes are stamped at the run tick, events publish at a later tick, failed runs preserve reader boundaries and lexical captures, skip advances only the message boundary, and explicit barriers apply pending FIFO. This supports B observing its own successful event on the next run but not its same-run changed stamp. Independent Fast observations detect B's leaked marks/publications. The listed capture/tail counts, optional/flag membership, overwritten/reinserted Main values and command-order removal/despawn sequences are consistent with those operations. They still require actual reference execution, including empty-frame retention behavior.

Two corrections remain:

1. E10 must name public `runtime.tryTick` for missing Ledger/Audit provisioning. `Runtime.ts` exposes `tick` with statically validated requirements; `tryTick` performs the runtime preflight and returns `MissingRuntimeRequirements` before frame advancement or invocation. Freeze the exact `{kind,name}` entries for each absent descriptor. A generic instruction to run E2 does not select this necessary boundary.
2. In both E11 overflow lanes, make B's **first post-drop read fail**, then let the same instance retry successfully. An initial successful “B reads” followed by a failing read would already have advanced its boundary and would not replay the same retained sequence. Keep the comparison Fast read and late registration at explicit positions in that sequence.

The capacity distinctions match source: message trimming drops whole batches; lifecycle trimming can drop individual records within a same-tick group. Lag uses dropped-through versus both prior boundary and registration time. Old surviving component marks are distinct from expiring logs. Internal small-capacity probes are correctly separate from the unexecuted public 65536-capacity lanes and cannot satisfy them if runtime budgets fail.

Two same-schema worlds plus two nominal schemas correctly distinguish runtime namespace isolation from compile-time misuse. Full Type-array/metadata observations, genuine retained-owner inverses, reconstruction/consumption negatives and targeted compiling mutants preserve the intended integration scope. Foreign-command outcome and unrestricted destructive recovery remain explicit gates. No source-derived expectation is promoted to actual evidence or an owned/runtime theorem.

The final measurement draft now specifies failure/retry before the first barrier, FIFO successful-spawn application, then disposal at a second barrier; this resolves the prior repeated-workload queue/membership ambiguity. Detailed frozen benchmark values and fresh parity checks remain required.

Reviewed SHA256: trace `d241c71db43cc3a081676f8f6266e26c369a70b4dd18a69680401557253353b0`; measurement `73c676dc7433a7887f321ad88248a193ee3bf5d846bb94590cb44ccbcb89855d`. This review does not pass the Bend implementation gate or close #19.

### Concrete trace corrections resolved — 2026-10-04

Both reported freeze clarifications are resolved at trace SHA256 `2f8a8d7940ca2b9b16e645d4e0f19af8d74d95152dd92a7ce6c7c8b572f03b7c`. E10 now explicitly selects public `runtime.tryTick`, holds Mode On and every other requirement present, and specifies exact missing Ledger/Audit requirement records and B/code7 failure output consistent with the pinned dispatcher. Both E11 capacity lanes now make B's first post-drop read fail and the same instance's subsequent retry succeed with identical sequence/lag, preserving the intended cursor witness.

No remaining blocker was found in these corrections to accepting the document as a concrete source-derived trace plan. Historical findings/hashes remain above. Main E execution, fresh backend parity, ownership/semantic controls, dependent policy decisions and the integrated implementation gate remain outstanding; this wording review supplies none of that evidence.

## Fresh public E11 retention review — 2026-10-04, `891370b` (author `ecda958`)

**PASS for the ten public TS retention invocations.** Reviewed adapter, report and coordinator-refreshed evidence, including the current trace's lifecycle-lag observation clarification. Independently replayed `--all` in a temporary copy: all ten schema/case invocations passed their separate five-second limits, and all evidence matched root exactly after excluding wall timings. Root evidence and reference files were preserved.

The executed public operations distinguish 65536-capacity whole-message-batch dropping from individual lifecycle-record dropping. Fast reads lifecycle deletions in the same dispatcher tick as Delete+D, before frame trimming; B's first post-drop attempt actually fails and the identical B system retries. Independent Fast and late-registration observations are real dispatched reads. Unheld expiration and old surviving added/changed marks also execute for both nominal schemas. Exact dispatcher failures and per-instance invocation counts are checked.

Every returned ID/message sequence is deeply compared in order. Every Q/added/changed row's complete Main array and metadata, Aux fields and Flag are checked before compact encoding. Encoded ranges derive from actual values; fixed metadata/formulas are emitted only after equality checks. The slot0 override preserves and verifies the other fields. This supports the claimed lossless successful-result encoding, not a count/checksum substitute or fabricated query result.

Message lag comes from the actual event view's `lagged()`. Lifecycle views lack that method; their missed-record evidence comes from public `runtime.debug.observe` system traces, selected by reader name. The updated trace correctly identifies this different surface, matching `Runtime.ts:1250–1265`. It must not be described as a new lifecycle read API. Debug observation here supplies actual dispatcher evidence rather than inspecting private log/cursor state.

No semantic blocker was found for these public E11 lanes. The trace's supplementary internal C3/zero-capacity diagnostic remains unexecuted; it is neither required to replace these passing public lanes nor counted as passed coverage. E0–E10, Ledger/Audit/Mode integration, Bend affine ownership, Native/JS parity, semantic mutants and performance remain open. The adapter's fresh TS record objects establish no Type-owner restoration guarantee.

Reviewed SHA256: adapter `8d0b2788872cf7460da5ebfbf36e9b8b1af15ffd373feb3330043d447349baa9`; refreshed evidence `36d718f4637a37dbbd2117f5c6d8bcf87d3e7b4ac43ee19e71048006656ee297`; clarified trace `af1aeae55f11acb64210382b869829420dbb24b950bd8d1ca3145e06cc10db9b`.

## Fresh main E0–E10 and internal supplement — 2026-10-04

Reviewed main reference commit `b2ba594` and internal supplement `e00d1eb`, with coordinator-refreshed evidence. **Executed main assertions pass; one current-trace diagnostic coverage gap remains. Internal supplement passes at its explicitly internal scope.** Independent temporary-copy main execution under `timeout 5s` matched the complete root JSON exactly for all four schema/capture lanes, each with 34 α/β snapshots. Independent internal `--all` passed five cases and matched evidence excluding wall timings. Root evidence was untouched.

Main uses the same actual Fast/B base systems and nested dispatcher, with real state-driven skip and failed/successful retries. Complete Main/Aux/Flag/Ledger checks, own-write observations, unchanged β snapshots, raw consumed q/fresh r IDs, FIFO publication, stale handles and disposal membership are tied to public operations. Audit effects occur during the callbacks and survive B failure. Separate same-schema foreign collisions are recorded as TS behavior, not normalized to approved Bend divergence. Missing-provisioning `tryTick` uses the actual A/Fast/B/Tail objects on fresh runtimes with other requirements present; exact failures, zero new invocations, unchanged tails and no service effects are asserted.

**Required correction:** main currently records removed/despawned lag as `unavailable-public-api` without enabling debug or attaching a listener. The current trace explicitly requires the public `runtime.debug.observe` system `missed` diagnostic for those readers. E11's separate overflow observations do not execute that surface during E0–E10. Add passive reader-trace capture and expected no-missed assertions for main reads, or retain this narrow coverage gap and qualify “complete E0–E10” claims. The direct lifecycle callback API indeed lacks `lagged()`; that fact does not remove the specified public diagnostic path.

The internal supplement actually exercises C3 batch overflow, oversized and C0 messages, and both schemas' C3 same-tick removal/despawn record truncation. It verifies all seed fields and exact retained sequences, repeat reads, caught-up and late-registration boundaries. Direct internal records/cursors and repeated reads are honestly labelled; they establish neither public capacity configurability nor dispatched failure/retry. This closes the previously unexecuted *supplementary internal* lane only.

Neither package establishes Bend affine captures/owners, inverse-order implementation, Type destruction, access negatives, relocation, runtime/backend parity, semantic-mutant gates or performance. Those #19 obligations remain open.

Reviewed SHA256: main adapter `9945ed4348552154e787d9fe456e88f8c30328b7966a41c86e050c09110123df`; main evidence `ddf71856fd6013a813be17f718120f28884c552b84e39fc88fc33223b44850e4`; internal adapter `973069e74c486ddf4e895812917899ca0bdcd085767aac869c46c044206726d3`; internal evidence `48a1087be6d9f6ab73694d3b5ebec4ebb3712098e7f717f47e17a166bbe1edd2`.

### Main lifecycle diagnostic gap resolved — 2026-10-04, `ad54e14`

**The previous main-trace diagnostic coverage finding is resolved.** Reviewed `0f5fe32...ad54e14` (author `3a5e0be`). The runtime now enables public debug observation; each Fast/B system event is associated with its actual callback by step, system name and an as-yet-unassigned diagnostic. Coverage checks require exactly one attached diagnostic per read. All 76 reader invocations across four lanes record deterministic frame/tick, outcome and `missed`; eight actual failed B invocations report `failed`, all others `ok`, and every main-fixture `missed` list is asserted empty. Callback event lag remains separate. No timing fields or private cursor inspection are used.

Independent temporary-copy execution under `timeout 5s` exited0 and matched the coordinator's complete JSON exactly. Reviewed SHA256: adapter `c70208fe453ca9809bc2a947a0209425100b352554e7d0d5dbab6eacfac65e39`; refreshed evidence `53f202b0496bb2187534e2f5026c30a6a0c43f2b834ad78c5413c15cfbd4c3a7`. Root evidence was preserved. No remaining blocker was found for the reviewed public TS main reference coverage; prior findings remain historical. This resolution establishes no Bend ownership/runtime, backend parity, semantic-mutant or performance acceptance.
