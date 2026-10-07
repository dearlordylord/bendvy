# #53 owned events: observed reference and remaining decision

Preparation only. No Bend publication/projection/retention/disposal policy is selected, no owned-event implementation is adopted, and no laws/proofs or performance acceptance are claimed.

## Observed pinned TypeScript behavior

`reference.mjs` executes 14 complete checkpoints for each of `OwnedAlpha` and `OwnedBeta`. The one-Node five-second preflight passed on the first attempt against an independently authored complete literal (`oracle.mjs`, and byte-exact `expected-001.stdout`). Receipt: `reference-001/receipt.json`; full raw stdout SHA256 `99e4e17ca69deb8aadcd39fdbd1e877fcff509efb6b926b9c16ecf6c281df77e`.

The payloads here are ordinary JavaScript objects containing ordinary JavaScript arrays. They are not Bend affine owners. Actual identity checks establish that both registered readers receive the same payload object, the same nested cells array, and the same nested object retained by the publisher. A publisher-side mutation after successful publication is visible to both fast and delayed readers: payload 1 changes from `[11,12]` to `[11,99]`, and its nested text becomes `publisher-mutated`.

A failed registered reader sees complete payload 2 `[21,22]`; successful retry sees that same object with the same nested identities and full contents. A successful fast repeat returns an empty batch. An activated slow reader whose condition fails discards that backlog; its resumed run is empty. Reusing the same registered system definition in a newly created same-schema runtime observes no peer publications, demonstrating independent runtime reader state for this trace.

Repeated `all()` calls return the same single-batch array in the tested readings. This is not a claim for multiple-batch flattening: upstream source allocates a new array when more than one batch is visible. The returned read view has no `emit` method; a system without the event grant has no declared `ping` view. An Inspector does not retain events: after publishing payload 3 and three empty ticks using the default frame window, it reads no events and reports lag.

The actual runtime has no public `dispose`, `unregister` or `clearEvents` methods. This does not demonstrate garbage-collection timing, reader removal, one-time payload destruction or a TS disposal operation. The source exposes internal stream clearing but not the public reader-disposal contract required by the Bend task.

The final checkpoint has the frozen historical label `erased-cross-schema`, but actually constructs an undeclared `Foreign` descriptor alongside `Ping`, not another nominal schema. Its erased JavaScript undeclared-descriptor access returns an empty reading. This is neither an actual foreign-schema operation nor a TypeScript compiler-negative control. The original fixture label/comment and receipts are retained unchanged; this report corrects their terminology. TypeScript's schema-bound event access is constrained by its generic descriptor types; actual compiler-negative controls remain separate. No same-world entity handle policy is inferred from these event observations.

## Primary source explanation

References match `.references/sources.json`:

- bevy-ts `3040a3b2a3f28fa8554d856f9ccb6bf5433fa334`.
- Rust Bevy `ad678262ce53b5d142fe49ee5e08caff6f00ab60`.
- Bend source `a950fd683c0d76f09794078e6174fe98a1492876`; installed compiler guide was read separately, without assuming the checkout and installed compiler are identical.

Pinned `Runtime.ts:1080` enqueues the exact published object; `Runtime.ts:1030` commits those values as a batch without cloning. `internal/streams.ts:127` returns the original single batch, or flattens multiple batches while retaining each payload reference. Reader cursors belong to actual registered system slots (`Runtime.ts:1360`); successful runs advance cursors, failed runs retain them, conditions advance activated stream cursors (`Runtime.ts:1380–1430`). Retention combines the frame window, registered cursors and the default capacity, rather than requiring every slow reader to run each frame. Existing #35 governs those Data-event retention/cursor semantics; this study adds object identity evidence without another 65,537-event overflow run.

Rust Bevy's buffered messages are distinct from immediate entity events. `message/messages.rs:125` moves each `M` into `Messages<M>`. `message/message_reader.rs:38` combines `Local<MessageCursor<M>>` with shared `Res<Messages<M>>`; `message/iterators.rs:13` yields `&M`. Independent readers therefore borrow one retained payload instead of duplicating ownership. Mutable message access is a separate `MessageMutator`, using `ResMut` and conflicting scheduler access. `messages.rs:193` swaps two buffers and clears the oldest; Rust cursor state does not make its default retention identical to bevy-ts. These are source-backed architecture findings; no Rust executable comparator was run here.

Bend's pinned Base declares `Array<T>` as `Type` (`base.bend:70`). `Array.swap` accepts arbitrary `Type` and threads the array back; `Array.get` and explicit `Array.clone` require Data elements (`base.bend:2284–2400`). The guide's affine quantities do not permit reusing a Type owner as two independently held event payloads. Existing `event-runtime.bend` uses Data event batches and already has conditional skip, failure cursor and registry disposal mechanics; that API must remain available. It does not establish arbitrary Type fan-out.

## Concrete decision to approve before implementation

A recommendation, not a chosen contract: transfer a Type payload once into a typed event-log owner; perform registered read-only access through a closed owner-preserving projection/visitor that returns the same payload owner and a declared observation. Keep per-reader cursors and lag separate from payload storage, preserve the established TS retention/cursor behavior, and release the storage owner exactly once when its record is actually removed. Arbitrary Type payloads remain supported; restricting every event to Data is not the proposed solution.

The approval must decide exactly what readers may retain. A detached Data projection cannot preserve the observed TS object identity or later publisher mutation. An explicit fresh affine clone is another contract and may require user-authored cloning for arbitrary Type payloads; it must not be inserted silently. Opaque scoped read access could be closer to Rust Bevy's borrowing but still must prevent a payload owner or write authority escaping the callback. Any departure from TS aliasing must be explicit and approved under #53/SPEC before implementation.

The decision must also specify failed publication ownership (return the unpublished owner or consume/release it), whether reader failure leaves a retained owner untouched, explicit reader disposal versus record disposal, and what happens to any reader-held projections after trim. Internal RC release is not evidence of a public destructor callback. #31's composed public schedule contract is still a prerequisite; exact laws and production integration remain separately gated.

## Limits

This finite trace covers two independent schemas, useful object payload contents, actual alias identity, independent readers/runtimes, repeat/fail/retry/skip and default frame trimming. It does not qualify owned Bend events, cloning policies, capacity overflow, GC/destructor timing, rejected disposal, TypeScript compiler negatives, source-current Bend confinement negatives, Native execution, general refinement or performance. No core source or dependencies changed. The private environment map is local only and must be excluded from delivery; its hash is retained in the receipt.
