# T07 candidate buffered-event obligations — unapproved

Executable subjects are `streams.bend` append/read/trim/complete/skip, and the
explicit system/frame wrapper in `runtime.bend`. Admissible states have ordered
batch timestamps, nonnegative capacity, stable U32 message values, monotonic
non-wrapping clock and cursor timestamps originating from reader registration/
completion. Native/JS/TS traces are finite evidence, not universal refinement.

| Candidate | Exact obligation and motivation |
|---|---|
| Reader completeness/order | Read returns every retained value whose batch tick is strictly after the reader's previous successful run, in batch/value order; empty/single/multiple batches are distinct cases |
| Reader independence | Reading through one cursor leaves the log and another cursor's observations unchanged; a globally consuming read is invalid |
| Failure / success | A failed reader leaves its old cursor unchanged and retries retained messages; success advances only that cursor to the start tick of its run |
| Skipped messages | An already registered skipped reader advances its message cursor to current tick and discards earlier publications; a never-run skipped system does not register a holder |
| Retention | Trim first removes expired batches only through min(window boundary, registered cursors); a slow registered reader holds batches; a new reader receives still-retained earlier publications |
| Capacity | After retention trimming, oldest whole batches are removed until retained value count <= capacity; a batch larger than capacity may be dropped entirely, including at capacity zero |
| Lag | Lag is exactly droppedThrough > max(lastSuccessfulRun, registeredAt); failure retains lag until success, and pre-registration drops do not mark a new reader lagged |
| Publication commit | Failed emission publishes nothing; committed events reach later readers without structural markers; empty emission creates no batch |

Public Runtime scenarios establish the wrapper's observed behavior. Small capacity
boundaries separately run the pinned internal Streams implementation at capacity
3/0; they do not change the public Runtime's fixed 65,536 capacity. A model proof
requires an explicit runtime-to-model mapping and correspondence obligations.
This package does not cover added/changed/removed/despawned readers, transition or
relation streams, generic keys/payloads, arbitrary closures or clock exhaustion.
