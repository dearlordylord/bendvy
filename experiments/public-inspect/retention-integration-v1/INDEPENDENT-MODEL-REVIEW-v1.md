# Independent retention model review

Status: scoped PASS for immutable author commit `a7c358e56afcf0e03c393ff576a2676dc7631647` (author hook12552 terminal0). No subject outputs or backend executions were read or run by this reviewer.

Scope is the complete declared thirteen-Snapshot DTO, not full World preservation or completion of #54. Source authority is canonical event-runtime/system/world and reader-domains, the detached Inspector candidate, and pinned Bend/Rust references. TS helper algebra supplies no contract.

## Independent derivation

| Stage | Event tick | System positions (id:cursor/registeredAt) | Inspector cursor | frameStart/boundary | retained batch/dropped |
|---|---:|---|---|---|---|
| registered | 0 | [] | None | 0/0 | []/0 |
| published | 1 | [] | None | 0/0 | tick1:[31,32]/0 |
| slow-failed | 2 | 2:0/1 | None | 0/0 | tick1:[31,32]/0 |
| inspector-success | 3 | 2:0/1 | 3 | 0/0 | tick1:[31,32]/0 |
| frame-one | 3 | 2:0/1 | 3 | 3/0 | tick1:[31,32]/0 |
| fast-read | 4 | 1:4/3, 2:0/1 | 3 | 3/0 | tick1:[31,32]/0 |
| fast-skip | 4 | 1:4/3, 2:0/1 | 3 | 3/0 | tick1:[31,32]/0 |
| inspector-failed | 4 | 1:4/3, 2:0/1 | 3 | 3/0 | tick1:[31,32]/0 |
| frame-two | 4 | 1:4/3, 2:0/1 | 3 | 4/3 | tick1:[31,32]/0 |
| slow-read | 5 | 1:4/3, 2:5/1 | 3 | 4/3 | tick1:[31,32]/0 |
| frame-three | 5 | 1:4/3, 2:5/1 | 3 | 5/4 | []/1 |
| frame-four | 5 | 1:4/3, 2:5/1 | 3 | 5/5 | []/1 |
| direct-leaf | 5 | 1:4/3, 2:5/1 | 3 | 5/5 | []/1 |

Namespace1, nextReader3 and capacity16 remain unchanged. World nextId1/highWater0/capacity1/depth0 and nextSystem3 remain unchanged. Raw registrations are **slow(id2), fast(id1)**, each access `[events:read]`, because registration prepends. World clock is0 through slow failure; successful Inspector alone advances it to1, which remains thereafter. Event tick is a separate Nat clock. Inspector registeredAt is2 internally; its cursor3 is not a System position.

Readers return full `[31,32]` with laggedFalse on slow failure, Inspector success, fast success and later slow success. Failed Inspector returns empty reading/laggedFalse. Other steps are NoRead. Final direct-leaf explicitly creates a fresh I.Frame cursor0/registeredAt0, invokes I.read directly without run completion, and returns empty/laggedTrue for normal versus [31,32]/laggedFalse for the retainer countermodel; metadata, World clock and persistent Inspector instance stay unchanged. This is a fresh direct frame, not the existing cursor3 Inspector instance. No rejected reader path is reached.

The artificial retainer bridge invokes Ev.activate(positions,0,0n) at actual Inspector reattachment. It inserts exactly one id0/cursor0/registeredAt0 position on first success and preserves it on later failure. Fast activation prepends id1. All normal fields/outcomes remain equal until retention: frame-three/four keep batch1/events31,32 and dropped0 because hold_boundary sees cursor0. This exact whole countermodel tests nonparticipation; it does not simulate an accepted Inspector registration policy.

## Authority and limits

Canonical event-runtime.bend: register creates Reader+Registry without activating a position; run_position increments event tick; run_outcome activates failed readers without advancing cursor and advances successful readers; skip updates cursor without runner invocation; frame rotates frameStart/boundary then trims against minimum active cursor and capacity. Detached reader-domains retains the actual metadata owner and restores original event stream. Inspector success advances World clock and event-domain tick without registering/advancing System positions; failed Inspector preserves its cursor/tick.

Pinned Rust Bevy `message/messages.rs:193` swaps and clears the old buffer independently of reader cursors; `message/message_cursor.rs:126–145` provides independent cursor, missed count and clear. Rust supplies the independence distinction, **not** an assertion that this native hold-boundary retention is identical to Rust's double-buffer lifetime. Existing native retention and Inspector nonparticipation requirements govern this fixture. Pinned Bend Base Array.new uses depth and has 2^depth leaves; affine owner threading does not itself prove identity or exactly-once cleanup.

Unobserved: World live/store/pending payloads; Reader/Registry owner representation and Registry cursor; Inspector registeredAt; disposal/finalization; wrong authority/refusal; capacity overflow; repeated publication/removal stream interaction. These remain outside this bounded fixture, and all broader #54 acceptance remains open. Snapshot metadata includes every Runtime metadata field, full batches/positions/order and full event list. Corrected depth2 Array has exactly four physical leaves, all projected by A.project_resource indices0..3; the model retains all four 21 values in every snapshot. Type owner returns through W.observe_resource/A.project_resource, without alias or mutation claims beyond this observation.

Pre-output review caught two issues: raw registration model order was fast/slow rather than slow/fast; resource depth4 allocation had16 leaves while the projector exposed4. Both corrections are present in the reviewed immutable freeze.

Approved adaptation provenance: docs/archive/recovered/reviews/laws-source-research.md:31–33 and laws-decision.md:35 explicitly distinguish failure/skip and reader-aware retention from Rust; this review preserves those established native semantics. No new laws, proofs, ownership policies or dependencies were proposed.

## Exact reviewed boundary

- main.bend: `277c741ff1807cbbe1d57a6feb6e7d3a705a4f3ee1a001a2038bca19f7ac4e45`
- bridge.bend: `955552895ee820a0ff247fd8a72649ce57ff3737d2dbbd8bd43e6fe9bdc3bcff`
- leaf.bend: `6ff53dbfa665ab1c0197c8191e38e58e1e9a2ea6dda8f22fc9cb858432c380e9`
- expected.py: `684a86633430b87011e0b33081af2c849e69ce4f27015cc4dbe90bf32d0bb688`
- normal expected.json: 16522 bytes, `d0216f1445e8d17736fb1f3f13b2bb763af8cb0017dc52ade47f325d548801a3`
- artificial expected-retainer.json: 18222 bytes, `3b89e9fe8f966731de2ff65d0b75e08439f74b6ecbcf29c10b36272f9bfe86b1`
- SOURCE-BASIS.json: `fb3143e87190de80e5bf421fd190873c9f3c92d0fdaceae64255dc601716e067`; every listed file pin independently rehashed against current source.

Every declared field and ordering was reviewed against the consuming source, including completion discriminants, full metadata and scalar distinctions. Source-authored test-model checks are finite author controls, not universal proof; backend admission must use a type-sensitive entire DTO comparator and original nominal stdout where applicable. This report admits the model boundary only, no executable backend plan or delivery/performance acceptance.
