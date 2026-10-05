# Parity measurement resolution — unaccepted protocol proposal

No batching permission, numerical margin, timer change or evaluator transition is inferred. This is a source audit and minimal proposal; no benchmark was executed for it.

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
