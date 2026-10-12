# Independent final Spec/Standards review — event-schedule-v1

Verdict: **PASS for the bounded direct Inspector event/Schedule reached slice.** I found no blocking Spec or Standards issue in the supplied packet. This is a finite-slice verdict; it does not close full #54, parity, proof, or performance acceptance.

Reviewed packet commit `b211a7ca8e9b39da3dd379aec7b9180a5e8edce2` (`Qualify public event Inspector around registered Schedule readers`). The packet binds first ordinary pair `18fa00e27`, normal model/oracle commit `d0a60347528d0cfeed839f9057951e947297e171`, and counter-model commit `ecdaea9a73127ce171bbc8464d4cd5285fba427d`. `DELIVERY.json` SHA256 is `1778359ef750f8758efebe26a86a510e87a7178ac73550ced73613bacf556953`; its reached evidence archive SHA256 is `692333ecc2bb405d44252a6bafbeb7f62b13c473ae925a679a34eaec54b1aba2`.

## Spec

The actual workshop consumer calls `Cap.value_read(... Inspection.first(Events.provision()), runtime)` at `workshop/consumer.bend:47-50`. `checkpoint` invokes `peek` twice, and the frozen sequence contains fourteen checkpoints per nominal schema with two inspection calls per checkpoint. The same consumer then calls `Scheduled.run` at lines 86, 97, and 108. `workshop/scheduled.bend` builds the schedule from actual `B.fold4` registration fields and the actual `World.registrations` catalogue, then dispatches `Common.read1`, `Common.read2`, and `Common.read3`; those functions invoke the retained typed `Reader.run` paths for reader IDs 1, 2, and 3. This establishes the public getter and real Schedule boundary in the same complete trace.

The normal getter preserves the retained stream fields and returns the runtime owner together with the detached `Maybe<List<E>>` value. `ValueRead<H,V>` remains the owner-threading capability `H -> H & V`; the getter has no `I.Instance`, Registry cursor, typed Stream.Position, Runtime tick, or World-clock operation. The archived observations cover the physical World, arrays, positions, batches, retention, schema and recipe, reader owners, and Schedule observations for both nominal schemas.

The reached candidate is a genuine semantic mutation at that public getter: `inspector-event-value.bend:18-20` changes `restored` to take a copyable `Nat` tick binder, used both in `Leaf.advance(..., 1, tick)` and in the returned runtime, before returning the owner. The candidate keeps the same entry QNames and the same call graph. JavaScript and Native counter outputs are byte-identical at 211,671 bytes, SHA256 `24cc963db683ca929691cb047dff74b7344bbbf1f87e85db2aad308074358eed`. Both complete normal baselines are rejected at first difference 3,993; normal output is 211,157 bytes, SHA256 `0e6fcb31d1506605b1ce21db020dc657e4fa39abfb51761a824b46a5b69ab4b8`. Stderr is empty and the comparison status is `FULL_COUNTER_EQUALITY_AND_FULL_NORMAL_REJECTION_PASS`.

The normal and counter model commits are expected-model source only. Actual backend output is produced by the actual source entry and compared afterward; no model output is supplied as a consumer input.

The generic collector plus explicit whole-output normal comparison qualifies the actual local typed-reader consumption at the public getter. The packet records `builtinReaderBranchExercised: false`; that is an implementation-detail scope note, not a #54 acceptance criterion.

## Standards and evidence

The packet is source-first and its authority joins are bounded to the reviewed callsite. The reached commit adds sixteen evidence/source-packet files under `reached-v1`; it does not edit compiler, backend, hook, table, infrastructure, or production core files. The reached archive has exactly 56 manifest members and every recorded member length and SHA256 matches. Its source, JavaScript, and Native receipt plan hashes join to the archived plans; the source receipt is `COMPLETE_SOURCE_CONTROL_PASS`, and both backend receipts are `COMPLETE_CONSUMER_DEVELOPMENT_PASS`. All 21 archived pre/post/final guards report `unchanged: true`.

The root mutation was explicitly applied and restored. The archived restore record is timestamped `2026-10-12T08:33:44.630007+00:00`; both provenance records report 105 source files present and exact. Independently checking the current root against the normal inventory found zero missing or mismatched files; the restored getter has normal SHA256 `dba6c756452c4a546d1c167d6066dbcc443f3fbd90d9292f602663737293ac84`. The ordinary first-pair record and the reached delivery record each bind their own archive and source hashes.

The historical reuse is correctly qualified. `SOURCE-CROSSWALK.json` is source-only and names 14 checkpoints, two inspections per checkpoint, actual registration-derived IDs, and the cursor/clock boundary. The public authority reuse has exactly 41 pins and is limited to the prior getter/binder negative controls. `REFERENCE-REUSE.json` is `READ_ONLY_HISTORICAL_REFERENCE_SCOPE_JOIN`; its 112 current pins match, while the historical TS discovery remains limited to its recorded 58 observations and 33 source pins. It grants no new TS Schedule callsite or new consumer acceptance credit. The two recorded historical tooling mismatches (task runner and Bend alias) are explicit rather than silently carried forward. No new law, contract, proof, or performance qualification is claimed; the existing combined-213 PASS remains unchanged.

## Remaining gates

- Full #54/public-inspect parity and broader composition remain open beyond this finite two-schema getter/Schedule trace.
- Universal borrowing/presenter purity, arbitrary-family refinement, and whole-product read-only guarantees remain unproved; trusted constructors and finite observations do not discharge them.
- Full feature performance/scaling, proofs, and any new contract or law remain separate gates. The existing combined-213 result is reused as recorded and was not requalified here.

This review was read-only: I performed archive/member, receipt/plan, guard, source-inventory, commit-scope, and restored-root checks, with no source, compiler, backend, hook, or infrastructure edits.
