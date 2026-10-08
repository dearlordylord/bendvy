# Captured systems — ownership decision draft

Status: proposed for discussion and explicit #50 approval. No law, proof or implementation approval is inferred.

## Proposed public behavior

1. A capture pack is an arbitrary affine `Type` owner, separate from the reusable closed runner definition and from World-specific registration. Every actual run consumes and returns this same pack on success and system failure. The runner cannot copy a closure or discard the pack to report failure.
2. Capture changes survive a failing system invocation; the ECS transaction still rolls back its component/resource/command/event changes. Capture state and Local remain distinct APIs. A skipped or refused invocation never calls the body and returns the capture pack unchanged.
3. Independently created packs remain independent. The same pack can be threaded sequentially through valid registrations in two compatible Worlds, preserving its updates across those runs. Registering or scheduling the closed definition does not implicitly copy an affine pack; explicit fresh packs create independent instances. Registration authority stays World-specific.
4. For invocation and disposal, the registration and capture pack are paired affine owners. Explicit detach returns them separately; reattachment can move the pack to a compatible runner/schema registration without moving registration authority or reader positions. Successful disposal consumes both owners exactly once. Release is a caller-supplied reusable closed finalizer `Capture -> Unit`: it consumes the pack, returns no capture owner and has no recoverable-failure result in this API. Rejected disposal returns both owners unchanged and does not call release. A disposed owner cannot be reused or disposed again. Mutable capture aliases are not exposed. Exactly-once finalization means one invocation and consumption of the pack; physical cleanup is the caller finalizer's responsibility, not an implicit runtime destructor guarantee.

The cross-World case preserves the observed shared-capture behavior through explicit ownership transfer. It does not permit simultaneous aliases or transfer a registration into another World. Public refusal and reader-cursor behavior must preserve the existing System contract; captures must be returned even when execution refuses before entering the body.

## Source basis and acceptance

The actual [TS reference](../../experiments/public-captures/README.md) observes failure persistence, condition skip, independent callbacks and the same callback shared by two runtimes. Pinned Rust Bevy stores the persistent function/parameter state in `FunctionSystem`; pinned Bend permits at most one call to a closure, including Data captures. Explicit affine pack threading reconciles those constraints. TS does not establish Bend release semantics; disposal above is a proposed ownership-visible decision.

[#50](https://github.com/dearlordylord/bendvy/issues/50) requires: “Obtain approval for any new ownership-visible decision before implementation.” This draft is the concrete approval subject, separate from the already approved Local behavior.

After approval, implement the generic reusable runner and actual two-Array consumers, preserving closed-template callers. Verify repeated runs, failure, skip, refusal/retry, sequential two-World sharing, independent packs and one-time release in two nominal schemas on JS/Native. Include undeclared access, cross-schema, writes-through-read and owner-duplication negatives, a reached compiling lost-capture defect and a double-release refusal; complete equivalent feature performance and unchanged production regression remain required. New proofs require their own specific law approval.

## Consolidated decision packet — #50/#53/#38/#59

**UNSELECTED; prepared for one user discussion.** This extends the existing drafts/studies, not their acceptance criteria. Source base `be3235f7`; no implementation, law, dependency, numerical performance change or user approval follows. Five observable choices below are the approval subjects. Confidence expresses confidence in the recommendation, not permission to adopt it.

### 1. #50 — captured owner across failure, transfer and disposal

**Trigger:** a registered system modifies two captured Arrays, then fails; later it runs again or the capture is moved to another compatible World.

**Current evidence:** the [actual TS capture trace](../../experiments/public-captures/README.md) has eight complete checkpoints in each of two schemas. Failure retains both host capture changes while the Ledger write rolls back; false condition leaves captures unchanged; the same callback in a second runtime advances the same host captures. Rust FunctionSystem retains function/parameter state. Bend closures are single-use even with Data captures. Neither TS nor approved Local semantics supplies a public capture disposal contract.

**Recommended choice:** approve the four proposed public-behavior clauses above as one capture lifecycle contract: reusable closed runner plus affine capture pack; return the actual pack on every success/failure/refusal; entered-body changes survive ECS rollback; skip/refusal before entry preserves it. Explicit detach/reattach moves one pack sequentially across compatible registrations without moving World registration or reader authority. Fresh packs are independent. Disposal consumes the paired registration/pack once through a caller-supplied closed `Capture -> Unit` finalizer; rejected disposal returns both untouched. Confidence **high (0.94)**: matches observed persistence/sharing through explicit ownership; disposal is the new part needing consent.

**Alternative:** bind capture permanently to one registered instance and refuse detach/cross-World transfer. This simplifies lifetime pairing but does not expose the observed shared-callback use case. Failure-persistence versus rollback is still a separate observable contract; generic capture rollback would require an explicit caller journal/clone, since arbitrary Type cannot be copied automatically.

**Core changes/dependencies:** generic runner consumes/returns Capture; paired registration owner and explicit detach/release operations; #36 Local remains distinct, #35/#48 reader cleanup remains World-local, #51/#52 retain their own transaction/recovery contracts. No arbitrary host IO rewind or physical destructor guarantee.

### 2. #53 — notifications and recoverable transferred data

**Updated direction (2026-10-08):** the user prefers returning data after failure
for reuse, with simplicity and elegance taking precedence over elaborate policy
machinery. See [the owning requirements](affine-events.md#business-requirements-and-current-direction).

A failed operation must not deliver any staged notification. Ordinary one-shot
notifications can be recreated on retry; expensive prepared data or reusable
buffers should remain recoverable. Distinguish these needs in the application,
without requiring runtime event classes or separate publication frameworks.

**Current candidate:** one log owner; scoped abstract read capabilities; explicit
snapshots when useful; immediate refusal returns the payload; commit retains it
in the log; abort returns staged payloads in an owned recovery result. Callers
may reuse or discard recovered payloads. No copy, reader-mutable alias, automatic
reinsertion into Resource/Local/capture, or mandatory pure finalizer is implied.
Required ECS rollback retains its ownership guarantees: an owner needed to
restore transactional storage cannot also be returned in the event receipt.
Coordinate any such transfer with #51/#52 before exposing it publicly.

Astra's source review found that Rust Messages lends payloads and can drain
removed owners. Bend's existing abstract-capability pattern is a candidate for
scoped reads; mandatory detached Data views are not a demonstrated language
constraint. Rust direct message writes do not determine Bendvy's transaction
abort contract. The previous indivisible proposal of Data views plus mandatory
abort release is superseded, not selected.

The recovery result's concrete typed transport and effectful cleanup remain to
be validated. Returning ownership may permit buffer reuse; it does not itself
prove fewer allocations or lower retained memory. No law/proof or full #53
acceptance is inferred from this design direction.

### 3. #38 — independent world identity domain and canonical creation seam

**Trigger:** two modules independently call a world creator, each creates live entity1, then one sends its handle into the other.

**Current behavior:** existing pure `world.factory()` returns `Factory{1}`. The [actual independent-root controls](../../experiments/public-identity/README.md) confirm both roots create namespace1 and foreign handle acceptance on JS/Native; this is retained as EXPECTED_IDENTITY_FAILURE_CONFIRMED. Shared-Factory controls reject the foreign handle. The [checked host allocator experiment](../../experiments/public-identity/host-namespace/README.md) and [canonical candidate](../../experiments/public-identity/production-candidate/README.md) demonstrate independent creator calls with distinct namespaces and real lookup/command MissingEntity refusal. Rust WorldId uses a checked process-local atomic source and does not reuse dropped identifiers. TS foreign-ID acceptance is already an explicitly approved Bend divergence; do not reopen that choice.

**Recommended choice:** one checked IO creation seam owns namespace allocation for all canonical independent-world calls in one emitted application/process identity domain. Successful allocations are never reused within that domain, including after disposal; exhaustion refuses without wrapping and returns incoming owners. Existing pure Factory/raw constructors remain explicitly trusted scoped/admin construction, not independently safe canonical roots or language-wide secret constructors. Separate emitted programs/processes are separate domains; no IPC/save-file global identity is promised. Confidence **high (0.93)**: already executable experimental architecture, aligned with Rust WorldId and Bend's effect boundary.

**Alternative:** require one affine application allocator explicitly threaded into every world-creation call; independently restarted allocators are separate unsupported domains. The core remains pure, but applications must coordinate the allocator and cannot treat free-standing fresh Factory calls as globally independent safe worlds.

**Core changes/dependencies:** promote/migrate the checked creator effect versus expose an explicit application allocator; actual lookup/commands must preserve receiver queue and all owners on refusal. Legacy administrative construction remains documented. Concurrency, numeric/storage/clock exhaustion and production gates remain #38; schema confinement #45; restore entity-epoch behavior depends on this decision but must not dispose/recreate Runtime registration authority.

### 4. #38 — numeric entity reuse and failed reservations

**Trigger:** reserve an entity ID, fail before its queued spawn materializes, or despawn an entity, then reserve again while an earlier handle still exists.

**Current TS basis:** retained local `experiments/public-identity/reference-notes.md` (outside the pinned Git base, explicitly not a delivery receipt) records immediate reservation, pending absence until a barrier, no reuse in the tested despawn/cancel/failure sequence, and failed reserved3 followed by successful4. Pinned `internal/world.ts` allocates before queueing and does not rewind nextEntity in rollback; these source facts independently explain that trace. The committed [identity candidate](../../experiments/public-identity/production-candidate/README.md) qualifies separate-root lookup/command refusal, not failed reservation. TS's Number allocator has no safe-integer exhaustion guard in the inspected source; this is not a recommendation to copy its unchecked numerical domain. Rust normally recycles entity indices with generations (generation wrap is documented). Current Bend prototypes vary; their reservation-state proposals are not production policy approval.

**Recommended choice:** monotonically allocate logical entity IDs within an entity lifetime epoch; reserved IDs remain consumed after failure/cancellation/despawn and are not silently reused. Refuse checked numeric/storage exhaustion with complete owner/queue preservation, without wrap or accidental masked Array access. Restore may start a new entity epoch only according to choice5. Confidence **high (0.96)**: matches actual TS observations and keeps stale ordinary handles from naming later entities without requiring a new per-slot generation policy.

**Alternative:** recycle slots with checked generations included in handles and every lookup/command/relation/decoder path; define generation exhaustion before reuse. Recycling alone without generations can make a stale handle operate on a different entity and is not recommended. Physical storage reuse can still be an internal optimization under monotonically unique logical IDs.

**Core changes/dependencies:** unify reservation/activation/cancellation/FIFO and rollback ownership around the selected logical policy; current prototype state laws are not approved by selecting this prose. #38 owns domains/exhaustion, #41 pending activation and #59/#60 restored allocator/handle behavior. No new numerical limit, error precedence or specific law is silently selected here.

### 5. #59/#38 — handles held before successful restore

**Trigger:** keep a live handle for entity7, successfully restore a save containing numeric entity7, then perform lookup or queue a command using the old handle. A failed restore is a distinct case and must preserve all current identity/owners.

**Actual current comparison:** the subsequently integrated [TS restore reference](../../experiments/public-restore/reference-v1/README.md) at `ad751731` retains a complete 47,826B two-schema report, SHA `f1cdcad7…`, against an independently authored whole oracle. Old pre-restore EntityId values are converted to Handles **after** restore: id1 resolves restored `Name`, id2 and canceled reservations3–6 return MissingEntity; saved next2 does not rewind prior allocator7, and next spawn is7. The fixture does not literally retain a Handle object created before restore; source equivalence is narrower than another executed case. Pinned TS handles have no generation/restore-epoch, and Runtime validates before mutation then clears pending/events, despawns old entities and respawns saved IDs in the same runtime. Those source facts support the same-ID result, while the exact pre-created-handle-object case remains an explicit reference follow-up. Rust normal despawn/reallocation generations avoid ordinary stale-index reuse; they do not supply an automatic snapshot policy. Existing #59 explicitly asks to select Bend stale pre-restore semantics.

**Recommended choice (pending explicit divergence review):** successful restore invalidates all previously held live entity handles, even if a saved number coincides, by changing an entity-lifetime epoch distinct from stable Runtime/registration authority. Restore failure leaves that epoch unchanged. Internal saved references are validated/reconstructed to the restored entity epoch through explicit codec/constructor operations; this is not an automatic Raw-to-arbitrary-Type rewrite. System registrations, Local/capture owners and reader authority remain the same Runtime owners. Confidence **moderate (0.82)**: prevents accidental old-handle actions on replacement entities; it is stronger than the observed TS old-ID resolution and needs explicit user selection; retain the exact pre-created-handle case as a reference control.

**Alternative:** same-root numeric handles remain valid whenever the restored entity exists and satisfies their intent, matching the source-derived TS behavior. Applications must then understand restore replaces payloads while old handles can continue naming the saved ID; numeric collision is deliberate, not a liveness proof.

**Core changes/dependencies:** add/check separate entity epoch in handles, commands, lookup, relation/handle codecs and saved-reference reconstruction versus preserve existing numeric handle identity. Coordinate with #38 creation/reuse and #46 typed constructor callbacks, #58 export, #59 staged validation/lifecycle and #60 graph/machine references. Do not rotate the sole World registration namespace and thereby invalidate registrations/capture/reader owners; restore is not a fresh Runtime.

## User answer to collect once

1. #50: approve the existing four-clause capture lifecycle, or choose instance-bound capture without cross-World detach?
2. #53: business direction is now recorded above: soft preference for recoverable data with a simple API. Validate scoped reads and the smallest owned recovery transport before asking about a concrete remaining observable choice.
3. #38 creation: checked canonical IO allocator per emitted-program/process domain, or one explicitly threaded application allocator?
4. #38 IDs: monotonically consumed logical IDs including failed reservations, or checked generational recycling?
5. #59 restore: invalidate pre-restore entity handles while keeping Runtime owners, or deliberately preserve same-root/same-ID handle resolution?

The #53 business direction has been supplied; other concrete contracts remain under discussion. Historical recommendations in this packet are not approvals and must be checked against the updated Bevy/Bend-first specification and Astra consultation. Exact laws, feature observations, source-current two-schema/type/refusal/mutation checks, JS/Native production and unchanged regression gates remain after a user choice; this source-only packet does not close any owning issue.

## Exact source/evidence pins for this packet

Root source base `be3235f78e7487745537d083b7494084267cb2cc`; later restore observation is explicitly pinned to `ad751731`, not rebound to the earlier base. Reference commits TS `3040a3b2a3f28fa8554d856f9ccb6bf5433fa334`, Rust Bevy `ad678262ce53b5d142fe49ee5e08caff6f00ab60`, Bend `a950fd683c0d76f09794078e6174fe98a1492876` were checked against the tracked manifest. Existing raw/receipts were read, not rerun. Local identity notes are separately classified; inspected source is not new executable evidence.

| Source or retained evidence | Availability/scope | SHA256 |
| --- | --- | --- |
| `experiments/public-captures/reference.mjs` | Git base be3235f7 | `f6fc7a92bdabb8144602e7cb69d35a7c7912227f204af164a46fb91dcdf9ff13` |
| `experiments/public-captures/expected.stdout` | Git base be3235f7 | `17752376a322e5283a17a99add4d606b613d0f54c1f397cd5d8b7f3c85400c1e` |
| `experiments/public-captures/evidence/reference-001/receipt.json` | Git base be3235f7 | `f61f0ad5ed6cceeb2a2e897755c494c548a5bf686058a617e87c9d8381b584af` |
| `experiments/public-owned-events/reference.mjs` | Git base be3235f7 | `1613800a7e15f539d019b6af7253c18779a8bd7acc4d461be5ea5ed00f5ec2b3` |
| `experiments/public-owned-events/reference-001/reference.stdout` | Git base be3235f7 | `99e4e17ca69deb8aadcd39fdbd1e877fcff509efb6b926b9c16ecf6c281df77e` |
| `experiments/public-owned-events/reference-001/receipt.json` | Git base be3235f7 | `9e95a2f3122ea7540d38a6a63b28d9516adcf733a850f2c0f5b89409dcf910d5` |
| `experiments/public-identity/production-candidate/README.md` | Git base be3235f7 | `94d31f1ff2b5ff5439a6dc10ff32b847dfdf559854368ccbea12168942add281` |
| `src/ecs/world.bend` | Git base be3235f7 | `f03b45d2349b24467a4b5b604a9416ca1a504bba36fddcb75d06fb8146d9f310` |
| `docs/parity/identity.md` | Git base be3235f7 | `c9c90efa5bee6d5cd35ec571b68c1ab534af843d46d34298614a7e4c0f90c3bf` |
| `docs/parity/restore-basic.md` | Git base be3235f7 | `d169b6f4b560f74d3149fb5207d4c2e744cb3d4d6ce488a5346a14f433481235` |
| `experiments/public-identity/reference-notes.md` | Local retained study; untracked, no new execution | `74aac784dd18a72b5566c59559c9f87871326bc618f17cfb0b4fc855ee2ed5fd` |
| `experiments/public-restore/reference-v1/README.md` | Later Git ad751731 | `8a894ef09f78efd063de6452c2c3d2f7963983c6a73fde871c80e984b5065b6d` |
| `experiments/public-restore/reference-v1/reference.mjs` | Later Git ad751731 | `b290880f5e47f89023eb01340f85c2100df333d641b2afdace25f388f586f70d` |
| `experiments/public-restore/reference-v1/expected.json` | Later Git ad751731 | `0261d40fbde06a75e32287fefc45f06b9533650286daf32bfd76730d2271678f` |
| `experiments/public-restore/reference-v1/evidence/attempt-1/receipt.json` | Later Git ad751731 | `e1fae47142580d8e514e5066e1dc3b6d89fad3ab0f41b25197d87a491bd55c5c` |
| `experiments/public-restore/reference-v1/evidence/attempt-1/restore-reference.stdout` | Later Git ad751731 | `f1cdcad71dac9cb4331c0e330cf6c97854a8c0f088a31ab35ad206edac502f56` |
| `.references/bevy-ts/packages/core/src/Runtime.ts` | Pinned reference 3040a3b2 | `c744aa5c52845bd3323358c5085161b40a452c6802a1653e3851bfd34c69f5b4` |
| `.references/bevy-ts/packages/core/src/Entity.ts` | Pinned reference 3040a3b2 | `05d724f241b2d662a7a03ce82da5f133c4b587df92e5e22fdfdb7484edbca68e` |
| `.references/bevy-ts/packages/core/src/internal/world.ts` | Pinned reference 3040a3b2 | `e71b4b060fec85fae690957104c14051e4bea0d857bacd648993ea69a6fe27d7` |
| `.references/bevy-ts/packages/core/src/internal/streams.ts` | Pinned reference 3040a3b2 | `3e817555dddf937c51b51014ceb6422f068aeca4a40328281dbb774b8880168e` |
| `.references/bevy/crates/bevy_ecs/src/world/identifier.rs` | Pinned reference ad678262 | `a34a461acfe349d6975f9f0bd1bd9be78aaa5239fb6dbf816ae4d541a02b82be` |
| `.references/bevy/crates/bevy_ecs/src/entity/mod.rs` | Pinned reference ad678262 | `4acf9bdf352ae2a925ea0a22d2f8ceb7542a8ea1fde164b2efe6c48a1ba3f0ab` |
| `.references/bevy/crates/bevy_ecs/src/system/function_system.rs` | Pinned reference ad678262 | `e4090247301cc611c7289f2f5c105a6121390fcacf7920cb25f43b5a2f1eaf77` |
| `.references/bevy/crates/bevy_ecs/src/message/messages.rs` | Pinned reference ad678262 | `32186c29d0c71e82420d631e779ca1309418d476bfb9a3ca0da01b78e21efc15` |
| `.references/bevy/crates/bevy_ecs/src/message/message_reader.rs` | Pinned reference ad678262 | `0784d874bb912b03d746f28c5804387a3377f2f12ee6e745f923ec259004c292` |
| `.references/bend2/guide/GUIDE.md` | Pinned reference a950fd68 | `9001a4ac112e92dc0c069c8b9d5812e114c2557427d9f962cddeef1ef6c292b6` |
| `.references/bend2/bend2/base.bend` | Pinned reference a950fd68 | `c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661` |
| `.references/bend2/bend2/bend.ts` | Pinned reference a950fd68 | `1d133151652b597a1a035c77c172475e6de096da37f3b9e3adc23c2f75bdfe49` |
