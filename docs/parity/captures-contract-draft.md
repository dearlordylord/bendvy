# Captured systems — ownership decision draft

Status: discussion candidates for #50/#53/#38/#59, reconciled at `753c99c6`.
No unresolved contract, law, width, cleanup protocol or implementation is approved
by this document. Apply the [SPEC reference order](../SPEC.md#implementation-decisions):
Rust Bevy semantics, Bend constraints, then bevy-ts feature inventory/inspiration.
TS observations below describe TS; they do not choose Bendvy behavior.

## #50 — instance-owned captures and explicit recovery

**Trigger:** a registered system changes an owned capture, fails, runs again, or
is unregistered. The [actual TS trace](../../experiments/public-captures/README.md)
observes persistent changes, skipped calls and the same host callback shared by
two runtimes. The sharing is evidence about JS aliases, not a requirement to
introduce cross-World capture transfer.

**Current candidate:** each registered instance owns its capture pack. A reusable
closed runner consumes/returns that arbitrary `Type` pack on an entered call;
pre-entry skip/refusal preserves it. Capture failure persistence remains an
explicit contract candidate coordinated with approved Local and ECS rollback.
Pinned [FunctionSystem](../../.references/bevy/crates/bevy_ecs/src/system/function_system.rs)
(495–503) stores function and parameter state in the instance. Bend's
[single-use closure rule](../../.references/bend2/guide/GUIDE.md) (83–86) motivates
an explicit persistent owner plus closed runner, rather than copying a closure.

Explicit unregister-return is a candidate for recovering an available capture
owner. Whether unregister returns it, consumes it, or exposes a separate
effectful cleanup operation remains unresolved; reader/registration cleanup must
remain World-local. A pure `Capture -> Unit` does not guarantee external cleanup.
No cross-World detach/reattach API is required by the current candidate.
Dependencies: #36, #35/#48 and #51/#52. Repeated success/failure/skip/refusal,
independent instances and complete owner recovery need actual public evidence.

### 2. #53 — notifications and recoverable transferred data

**Updated direction (2026-10-08):** the user prefers returning data after failure
for reuse, with simplicity and elegance taking precedence over elaborate policy
machinery. See [the owning requirements](affine-events.md#business-requirements-and-current-direction).

A failed operation must not deliver any staged notification. Ordinary one-shot
notifications can be recreated on retry; recovery of expensive prepared data or
reusable buffers follows the soft preference in the owning requirements. Distinguish these needs in the application,
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

### 3. #38 — canonical checked World creation

**Trigger:** independent callers create same-schema Worlds with matching local
entity numbers, then exchange a handle. Foreign-world `MissingEntity` is already
approved; allocator representation and creation contract are not.

The pure Factory1 root collision is observed in the
[independent-root controls](../../experiments/public-identity/README.md).
The [checked IO candidate](../../experiments/public-identity/production-candidate/README.md)
demonstrates distinct roots and lookup/command refusal, not full production
qualification. Pinned [WorldId](../../.references/bevy/crates/bevy_ecs/src/world/identifier.rs)
(24–52) uses checked process-local allocation and does not reuse dropped IDs.
A canonical checked World IO creator is the current Bevy/Bend-first candidate;
trusted raw/scoped constructors must not be advertised as independent safe roots.
Process/domain, exhaustion, concurrency and returned-owner contracts remain #38
choices; this document selects neither a numeric width nor a new law.

### 4. #38 — generational entity reuse

**Trigger:** despawn or cancel a reserved entity, then allocate while an earlier
handle survives. TS source and the historical local trace consume IDs
monotonically; that is an observation, not the current recommendation.
Pinned [Bevy entity lifecycle](../../.references/bevy/crates/bevy_ecs/src/entity/mod.rs)
(65–74, 238–246) recycles indices and changes generations, while documenting wrap.

**Current candidate:** generational reuse with stale handles rejected on every
lookup/command/relation/codec boundary. Allocation, cancellation and rollback must
preserve all owners and queue state under the selected contract. Generation
width, exhaustion/wrap policy and reservation failure ordering remain unresolved;
copying Bevy's wrap or TS's unchecked Number counter is not approved.
Dependencies: #38/#41 and restore #59/#60. Physical reuse and complete identity
validation need source-current scenarios, negatives and reached mutations.

### 5. #59/#38 — fresh identities and mapped restored references

**Trigger:** restore a save while an old handle survives. The
[actual TS restore reference](../../experiments/public-restore/reference-v1/README.md)
at `ad751731` reconstructs Handles from retained pre-restore IDs **after** restore:
id1 resolves the restored entity; id2 and canceled3–6 are missing; allocator7
is not rewound to saved next2 and next spawn is7. It does not literally retain a
pre-created Handle object. These are TS observations, not a selected Bend policy.

**Current candidate:** restore constructs fresh live entity identities and maps
saved references to those identities through explicit typed constructor/codec
operations. Old live handles then cannot accidentally name replacements. A
separate restore epoch is not intrinsically needed if the selected generational
identity and mapping enforce this. The exact stale-handle result, atomic failure
behavior and reference mapping remain #59/#38 decisions, coordinated with
#46/#58/#60. Do not rotate stable Runtime registration authority or automatically
rewrite arbitrary `Type` payloads. Restore failure must retain the governing
transactional ownership guarantees.

## Superseded proposals and remaining decisions

The earlier cross-World capture pack transfer, mandatory pure finalizer,
monotonically consumed TS-style entity IDs and separate restore epoch were
historical discussion proposals. They are superseded recommendations, not
approvals or implementation requirements. The indivisible Data-view/mandatory
abort-release proposal for #53 is likewise superseded by the user direction above.

Outstanding decisions are the observable capture lifecycle/unregister recovery,
scoped reader/publication semantics, identity creation/reuse/exhaustion and stale
restore/reference mapping. Do not ask again about incidental implementation
choices or infer approval from this reconciliation. Existing owning tickets keep
full application, mutation, JS/Native, independent review and regression gates;
the detached source-checked recovery prototype does not complete #53.

## Bend ownership and cleanup source basis

Pinned [guide](../../.references/bend2/guide/GUIDE.md) (55–59) defines affine usage
as **at most once**: dropping is permitted. It neither guarantees exactly-once
finalization nor that a returned owner is the original owner. Pinned
[Base File.close](../../.references/bend2/bend2/base.bend) (299–301) consumes File
and returns `IO(Unit)`; effectful external cleanup cannot be claimed from a pure
`Owner -> Unit`. Rust [Messages.drain](../../.references/bevy/crates/bevy_ecs/src/message/messages.rs)
(247) returns removed payload owners, while
[MessageReader.read](../../.references/bevy/crates/bevy_ecs/src/message/message_reader.rs)
(56) lends messages. These motivate recovery/scoped-read candidates without
selecting a Bend fan-out or disposal contract.

## Exact source/evidence pins for this packet

The table retains historical observation pins, not current delivery qualification.
Reconciliation base `753c99c6`; source links use the exact reference commits below.
Historical root source base `be3235f78e7487745537d083b7494084267cb2cc`; later restore observation is explicitly pinned to `ad751731`, not rebound to the earlier base. Reference commits TS `3040a3b2a3f28fa8554d856f9ccb6bf5433fa334`, Rust Bevy `ad678262ce53b5d142fe49ee5e08caff6f00ab60`, Bend `a950fd683c0d76f09794078e6174fe98a1492876` were checked against the tracked manifest. Existing raw/receipts were read, not rerun. Local identity notes are separately classified; inspected source is not new executable evidence.

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
