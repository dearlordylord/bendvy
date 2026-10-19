# Parity measurement resolution — current source audit and unaccepted comparison protocol

No batching permission, numerical margin, timer change or evaluator transition is inferred. This is a source audit and minimal proposal; no benchmark was executed for it.

## Current status — 2026-10-18

The source audit below describes the historical evaluator; its fixed deadlines and expired experiment budget are historical. New execution budgets follow [limits](../limits.md), including recorded increases. No renewed Autoresearch budget or numerical uncertainty margin is inferred.

Motion and Health B1 method pilots for all five families now retain complete warmup/sample role streams and common scalar tuples. Their accepted packets are linked from the [delivery report](../reports/delivery-process-expectations.md). These correctness pilots do not implement the proposed enclosing batch. Original authored observation work stays inside its interval. Added TS observations, Sparse strategy differences and Lifecycle foreign lookup/footprint differences are retained limitations: matching shared tuples alone does not qualify equivalent timed work.

The ordinary fixtures now use the accepted common nanosecond clock seam. Before comparative sampling, resolve the common timed-work correspondence and the numerical uncertainty/decision margin. Seven rotations, separate fresh warmup/sample owners and independently reset child RSS remain existing requirements. Historical B16, 1%, noise/keep rules and deadlines below are not current approval. Final targets remain JS <= TS and Native <= 0.5 * TS.

## Current five-family source reconciliation

This audit binds integrated source `5789949776d05012f1807e5e3f75ad8a33e1284b`. All five families retain separate fresh warmup and sample worlds, complete role streams and full common tuples. Bend `Clock.begin/end` and TS `process.hrtime.bigint()` supply integer nanoseconds. FORCE output acceptance remains inside each interval; full tuple transport follows it. These accepted semantic fixtures are not seven-rotation comparative qualification or independently reset child-RSS evidence.

| Family | Current timed work and remaining correspondence |
| --- | --- |
| Dense | `dense-motion64/method/pilot.bend:53–54` runs the original updates, then `common.bend:captured_rows/capture_view` reads final logical rows and Ledger before encoding and FORCE. TS `reference.mjs:72–73` runs Update, Dump and the same common fields. TS `validate()` starts after end at `:109`; Bend final physical `Observe.state` rendering is also after end at pilot `:67`. Do not classify those final validations/renderings as timed extra work. |
| Sparse | Bend `consumer/s-perf/canonical-api-v1/sparse-runtime-v1/motion-scans.bend:run/first/second/third` executes three logical-row queries and filters their rows. TS `reference.mjs:64–68` executes optional, present and absent queries and records full scans. The observed selection/score obligations match. Different query/filter strategies and traversal costs alone are not extra semantic work. |
| FailedTxn | Pilot `:31–32` includes loops and `Program.method_final`. Original Local/provider before/after String renders remain reached at `consumer/motion-systems.bend:99,107,125,141`; `motion-program.bend:67` retains full world/owner snapshots and the boundary captures. TS `reference.mjs:62–97` retains expected-state assertions, debug observations, row SHA and clones inside its interval. Matching the common records does not establish correspondence for all this diagnostic work. Enumerate its public payload/status/rollback observations before adding only genuinely missing checks or captures. |
| Lifecycle | Pilot `:19–21` forces both common and foreign tuples before end. `method/method.bend:78` encodes foreign identity plus numeric lookup kind; TS `reference.mjs:70,88` can encode a full receiver-local collided row. Both satisfy the actual-result obligation for the 192 probes: retain query provenance and actual lookup kind, plus the complete returned row when the actual result is Found. Approved namespace divergence makes Bend MissingEntity and permits TS receiver-local Found. No row is invented for MissingEntity, and different valid result sizes do not require equal carrier size or row-processing work. |
| Readers | `method/finish.bend:24–33` preserves Stream.state, Ledger, the original Logical.rows query/text renderer and afterLogicalWorld before pilot `:33` reaches FORCE/end. TS `reference.mjs:53–87` retains the real query/event/removal reads plus assertions, SHA, clones, debug checks and final Dump. Distinguish these observer obligations from implementation strategy. TS `:91–92` labels final unread arrays as logical post-Drain expectations and explicitly says subsequent empty reads are not performed. They are not actual public empty-read evidence or Bend private cursor/occupancy evidence. |

Paths in the table are relative to `test-fixtures/connected-performance/<family>-motion64/`; Health retains the same boundaries with its genuine payload fields. A new actual empty-read probe would add callbacks, transactions and schedule work, changing the fixed Readers counts. It needs an explicit consumer/model successor rather than a fabricated empty result or an unnoticed observer addition.

No Lifecycle foreign-carrier rewrite is required by this audit. The original TS source already checked the full collided row on Found, while the original Bend observer retained the actual lookup kind. FailedTxn and Readers still need an explicit inventory of original diagnostic observations and their public semantic counterparts. Preserve original business callbacks, checks, physical observations and owner returns. Do not require equal traversal counts, algorithms or allocation costs. Any change to what is inside the interval must be stated in the existing comparison protocol; this audit approves no deletion, batching, numerical margin or new contract.

Current entry hashes, with paths under the fixture prefix above:

| Fixture | `method/pilot.bend` SHA256 | `reference.mjs` SHA256 |
| --- | --- | --- |
| dense-motion64 | `4a2bcb0c769d3375859eb27579523b37d45edfac3f8aeeed2fe32d45843ede02` | `6dbaf0a4c262fcf3089664d3237044452ae7e3f9e7b36a80edbc130a77360cbe` |
| dense-health64 | `b2f9995e7edfccf10bd1f59e1b48f6a4c5a019fb14061efb4310825d2ea43c3e` | `515d9e067aa97980aa3250d24f67a58002980951e73b5c14218175f93cb40730` |
| sparse-motion64 | `eb313f8e5f6d05d47ba8c554d0425b3aae7e311ee85a4d2f358b8dcdd8324b01` | `11bd82b4014bbd52269fffe07c46c494d3691006f21cf4229cbe611e90977a74` |
| sparse-health64 | `d391050c6284ff38fb73fd7afa150e3eabe7e7b4fa49fa6fe3737dd698dec102` | `d80dc6e4fca2682cec8de1e3fc8852106f108b0189b9161622b3973b5b27e18f` |
| failedtxn-motion64 | `658a429ad2224bb4780f894059baa12535b9fb55ccea3933e196ee3bbed6eb34` | `9f1ee934e7d1157abdfd1d0bea05fb869ab1ffedb26c43eba7b0f429ac4bee43` |
| failedtxn-health64 | `abfa562d4e7c2b39f7fe3348122986e61e4e9c82bf8b3329ead5335a22be37d8` | `8916ab9c0a8606dca09c27c04991f99d08282c4979dcfc572cf87eee8a6c5ff9` |
| lifecycle-motion64 | `64ced91407939b2c7b829750850a854c5ce429cc44e142f2fbb38c2246b03909` | `cf3fa3c3436405c5b0276a68f3a1ba8174903be5686d892a794ba5bd32ec7a80` |
| lifecycle-health64 | `0a86910f17f5ccc66cc5860331b1c9eb2cb6b854996cfe6c2cb46f985e0f1d91` | `3d0a54f0d1737e8a326951f357d041be2a819537dc36005f03181f4c9a38732c` |
| readers-motion64 | `312879cb56a8f8e38ca03565c1331fbba0d22b1797df7ee42047852767ef5674` | `21e81b4bea3bf59ed0a683bb09d85ca91dbafc7f38e9fd2adf55f04aef461e22` |
| readers-health64 | `1f1d1ec1ee7e83b201e34ea32195498b64959a30cf173f7947d18aa97c8404b0` | `e99938079fca6634651cdf2bacefd895b631c102ab9bfa7ce4422f1ef3b5e851` |

## Comparative boundary — agreed direction, adapter qualification pending

Keep the accepted 90-role semantic consumers and their complete checks unchanged. Prepare a separately versioned comparative adapter that reuses the same business callbacks, declarations, schedules, barriers, inputs and actual public reads. It must preserve all operation counts and the complete common observations, including actual outcome variants and payload fields. Approved foreign-world divergence remains explicit.

Time the business execution and the agreed common observation/forcing on all three backends. Do not include expectation generation, independent assertions or role-private diagnostic formatting in that comparative interval. Preserve those diagnostics in the unchanged semantic consumers; do not invent TS private queues or Bend collided rows. Snapshot/capture work needed to retain intermediate common observations still belongs to the comparative work and must be traced to the original operation. Full output transport and independent validation follow the clock. A new adapter must first match full independent gold on JS, Native and TS before any comparative cohort.

The user endorsed this direction on 2026-10-18 and requested an Astra review, which agreed with the boundary above. This changes the comparison boundary, not ECS behavior. Existing diagnostic-heavy intervals remain semantic evidence; their raw timing ratios do not establish equivalent-work performance. Each comparative adapter still needs source-bound correspondence and complete independent-gold acceptance through the existing review. Numerical uncertainty and decision margins remain a separate unaccepted choice.

### First qualified comparative adapter: FailedTxn Motion64

The entry `test-fixtures/connected-performance/failedtxn-motion64/diagnostics/comparative-v1/` passes complete independent gold on JS, Native and TS. Packet `1a9cb33d…` binds subject `5bba172c4`, independent model `bce64e415`/`3bc69a40`/`db82a4ac6`, current source correspondence02 and separately preserved model-pinned historical correspondence01. Original callbacks, operations, registration/invocation sequence, error/continuation policy, transaction outcomes, owner and cursor behavior remain reached. The accepted semantic fixtures are unchanged.

All 965 common records and 3,504,864 cells per world remain exact. Complete own-role public snapshots additionally retain first and repeated public reads, actual schedule descriptions and Dispose results on Bend; TS retains public reads formerly embedded in assertions and the listener supplying actual outcomes. Both carriers are fully forced before end; complete transport follows. Private Facts capabilities/capture and verification-only expected-state generation are absent. Integration through `5aef0a2a4` matches the reviewed complete leaf.

This establishes finite Motion64 semantic correspondence for the adapter. Health, wider sizes, the remaining families, seven rotations, numerical uncertainty/decision margins and clean child RSS still need qualification; no timing ratio, performance acceptance or #28 waiver follows.

## Clean child-RSS launcher control — 2026-10-18

Recovered the unchanged launcher from `871ace3bb:experiments/s-integrate/measurement-samples-rss-launcher.c` (SHA256 `eaef512a2c5e25c571f846fa5ddb5bf2075f2dda71c33ad29cb270639f05f977`) and built it with the existing Clang19.1.7. Its small exec image forks the measured child; exec alone does not clear the launcher's inherited highwater. Three controlled invocations validate this isolation, not ECS memory use:

| Parent allocation / child allocation | Parent highwater (KiB) | Launcher highwater (KiB) | Child highwater (KiB) |
| --- | ---: | ---: | ---: |
| 8 / 8 MiB | 22,364 | 22,536 | 16,888 |
| 192 / 8 MiB | 210,812 | 210,984 | 16,876 |
| 8 / 96 MiB | 22,388 | 22,560 | 106,992 |

Every child independently reports the same own-process highwater as the launcher obtains from wait4. All three exit0 with empty stderr. Temporary source/control/raw output and `ISOLATION-CONTROL01.json` remain under `/tmp/bendvy21-clean-child-rss-reuse/`; launcher binary SHA256 is `0b7dd07b73129fbbd3037d2515bf1c0ec0f393c0204244bb32987463ea3be5d5`. This supports reuse of the existing measurement seam. It is not an ECS, allocation, phase-only RSS, maximum bound or comparative qualification. A real child measurement still includes startup, warmup, setup and output; do not subtract the parent or launcher highwater.

## Historical evaluator and proposal

Everything below describes retained historical sources or an unaccepted comparison proposal. Its millisecond clocks, fold-only warmup example, fixed batching, limits and expired global budget do not describe the accepted current fixtures or override current limits. The accepted ns seam and complete current warmup streams resolve those particular historical gaps, not equivalent timed work, uncertainty, seven rotations, reset child RSS or the final performance targets.

Source audit of the retained Dense single-plan artifacts: JS `io_now` floors
`performance.now()`; Native `io_now_run` divides `CLOCK_MONOTONIC` nanoseconds by
1,000,000. The Dense TS adapter records the fractional `performance.now()`
difference. This identifies the existing clock representations; it approves no
new uncertainty rule or comparison protocol.

## Existing Dense/Sparse batch semantics

The fourth Bend argument is the **number of fresh measured worlds**, after one fresh warmup. `measurement-samples-bend.bend:5–15` calls the complete `M.choose` once per world. Every call prints a full JSON record: all rows/payload fields, namespace/next/pending/Ledger/mode, read sum and dispatch counters (`candidate/measurement-bend.bend:353–355,373–375`). Native/JS stdout therefore retains **warmup plus every measured world**, not merely the last world or a checksum.

`measurement-samples-run.py:35–36` invokes the original full-field validator on every line, requires exactly batch+1 records, and sums measured-world durations. `measurement-bend-run.py:44–47` removes only milliseconds, compares the complete record to independent expected fields, then compares normalized final SHA256 against fresh bevy-ts. Thus Dense/Sparse warmup **already has a full-record oracle**. This must not be confused with the separate FailedTxn preparation warmup that emits only `WARMUP-FOLD` (`s-prep/warmup/prepare.py:18–24,33–34`); that diagnostic forces the full tuple but discards the raw warmup tuple and does not independently validate its full record.

TS `measurement-samples-reference.mjs:96–98` likewise executes one warmup plus batch fresh worlds. Every execution locally compares the full final object against independently authored expected rows/Ledger (`:71–77`) and checks work sum (`:87`). Transport retains each world's final SHA256, first/last sample, full Ledger and counters (`:88–92`), **not all raw rows**. The outer validator checks every warmup/sample status/hash/work sum (`measurement-samples-run.py:28–33`). Full TS comparisons execute, but the raw complete row object is not archived for independent replay. The TS adapter currently accepts only batch **1 or 4** (`reference.mjs:94–95`). The Bend driver accepts any parsed U32; it does not itself restrict the count.

The focused evaluator fixes batch=1 in evidence, all three commands and validation (`s-prep/focus-run.py:37,64–67,76`). Passing a different fourth argument to a copied process does not version that evaluator or grant a comparison-protocol change.

## Resolution consequence

Existing batching sums **separate inner intervals**. Each Bend world independently calls IO.now before/after its 64-step loop (`candidate/measurement-bend.bend:383–389`). Summing B quantized intervals does not reduce the conservative endpoint-error bound per world: a 2 ms bound per interval becomes 2B ms on the sum, then 2 ms after division by B. Cancellation is possible but cannot be assumed for acceptance.

At a roughly 13 ms TS control, hypothetical Native 2×/5× targets correspond to about 6.5/2.6 ms. A conservative 2 ms interval uncertainty would then be about 31%/77% of the Native interval. These illustrative arithmetic values establish a protocol concern; they do not approve a Native factor, noise rule or confidence margin. JS parity near equality likewise needs an accepted uncertainty-aware rule, not a raw rounded ratio alone.

## Minimal versioned proposal

1. Preserve the old evaluator and raw evidence. Propose a separately versioned evaluator with one shared fixed B for Native/JS/TS, unchanged 64-step body per fresh world, one full-record warmup and identical public work. Select B only after the exact target, uncertainty policy and five-second feasibility are accepted; do not silently enable existing batch=4.
2. To amortize endpoint quantization, prepare B fresh owners before timing, retain them separately, then use **one enclosing clock interval** around execution of all B bodies. Preserve each returned owner and every full world observation; capture/serialize/validate each after the clock ends. Native must thread affine owners without duplication; TS must keep worlds/descriptors/counters local. Define which inter-world orchestration is inside the bracket equally on all backends. Memory/retention changes are explicit protocol changes, not free equivalence assumptions.
3. Archive each TS world's complete final object as well as the existing per-world digest. Keep full-field assertions and the independent reference/hash comparison for warmup and every measured world. A versioned full-record FailedTxn warmup is a separate required repair before including that family; retaining only a fold is insufficient.
4. Publish source/artifact/compiler/clock pins, batch semantics, warmup count, per-world records, one-bracket total and per-world descriptive value. Freeze the new evaluator/check closures separately. Numerical success/noise/keep rules remain unapproved; do not reinterpret the withdrawn 10% improvement or 5% regression rules as parity acceptance.

An alternative high-resolution common clock or a longer operation sequence in one world also requires explicit versioning/approval and equivalent work. Neither is authorized or implemented here.

## Deadline and matrix limits

Checker/runtime limits stay 5 seconds, codegen 30 seconds and clang 120 seconds. Preparing retained worlds and transporting B full records can increase whole-process time/RSS even when setup and validation are outside the inner bracket. Preserve deadline failures; do not raise limits or drop observations. Existing large-case runtime and validation timeouts remain blockers.

The historical full family matrix contains 5 families ×3 sizes ×2 schemas ×7 repetitions ×3 backends =630 children per cohort, before checks/warmup/paired cohorts. A two-hour global budget does not establish complete-matrix feasibility. A focused protocol can supply focused evidence only; it cannot close the parent matrix gates or establish full-product performance. The global deadline remains 2026-10-05 01:58:17 UTC without reset.
