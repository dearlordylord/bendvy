# Capture placement alignment — source proposal

Draft for review before implementation. The qualified JS/Native no-clock whole IO ledger keeps the same returned owners through 13 setups, 45 operations and 21 checkpoints per schema; its actual full42 physical/common union passes. It observes checkpoints only. The TS adapter instead retains a seed snapshot after every setup and a snapshot after every operation (`reference-ts.mjs:44,72–74`). This instrumentation placement must match before a comparative timing contract is ready.

## Proposed existing-contract change

1. Preserve the actual operation ledger and both nominal families. Do not add/requeue transitions or rebuild applications between operations. Keep all existing 21 checkpoint/common DTOs per family and all six Bend-only controls unchanged.
2. Retain one complete physical capture after each successful setup and each real Queue/Marker/Read return: 13 setup captures plus 45 operation captures per schema. Missing requirements and handler failure still return the original actual owners; observe those returned owners without invoking any handler again. A construction refusal remains a refusal, never a fabricated successful seed.
3. In Bend, call the existing owner-preserving `B.observe` after the returned `C.Timed` constructor/end boundary. Carry its returned batch into the next operation. Retain capture values as Data strings, not cloned affine worlds. At a named checkpoint reuse that same capture for the existing checkpoint row instead of observing again. Rendering, common projection and assertions stay after the entire ledger.
4. TS already captures after `measure` returns. Preserve that exact raw `history` (result, world, streams, hostLocal, attempts, prefix, deliveries), seed activation and same runtime. Add source-authored stable scenario/operation coordinates for comparison outside intervals; do not move `runtime.tick/tryTick` or snapshots into another clock boundary. No TS host counter becomes Bend Local ownership.
5. Keep two retained outputs: unchanged checkpoint rows and the new complete ordered capture ledger. Each capture binds scenario index/name, setup versus operation ordinal, actual kind and optional existing checkpoint name. Check full physical fields and type-sensitive common values; no checksums, output-derived expected fields or lost raw snapshots.

## Independent model before executable output

Extend the independently authored model to emit initial state and every intermediate state for the existing scenario descriptors. Author the full 58 capture records per schema before generating/running the new driver. Specify real handler effects, per-system rollback, Local attempts, state/pending/publication, structural flushes and both reader owners/cursors separately. Project the 21 named records and require exact equality with the already qualified physical/common oracle.

The two new ordered capture ledgers must match their independent models completely; equivalent TS/Bend common fields compare on all ordinary records. Representation-specific affine identity/cursor metadata stays in Bend physical assertions; raw TS debug identity stays actual TS data. Do not claim those representations or allocation work are identical. Preserve all actual TS raw records.

## Bounded implementation and qualification sequence

- Add a separate version of the IO ledger driver/renderer/validator in this experiment; preserve the qualified source, receipts, package and existing oracles byte-for-byte. Root alone owns public core. No API/policy/law changes are required.
- First freeze complete source/model/import joins and obtain interface review. Cheap affected source5 is development only. Then review a minimal no-clock JS emit30/Node5 plan using complete captures plus unchanged42 checkpoints.
- Inspect actual emitted continuation/owner-return order. Whole-schema Native source/C and exact-C compile/runtime groups follow separately reviewed existing caps, with actual A+B full union. Never substitute the thin three-operation diagnostic.
- Clocked intervals, populations, repetitions, scaling sizes, statistics and performance children remain unapproved. Host contention defers comparative measurements. The existing Workshop #28 result remains separate, and no new numerical gate is proposed.

This proposal aligns capture placement, not observer allocation cost. Both capture the same semantic boundaries, but TS debug dumps and Bend full physical observation differ in representation. Disclose that difference when reviewing a future timing protocol.
