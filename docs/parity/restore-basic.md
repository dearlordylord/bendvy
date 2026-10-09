## Parent

#1 — full Bend-native bevy-ts core parity.

Remaining-core specification: #37.

## What to build

An application loads a basic save, rejects invalid input before mutation and resumes normal entity/lifecycle operations.

## Acceptance criteria

- [ ] Observe pinned parse/version/path/duplicate/name/value validation precedence and allocator restoration. Stage all validated payload owners before modifying the live world; failure releases staged owners and preserves every live field.
- [ ] Execute successful restore as observed despawn/spawn lifecycle, queue/event clearing and allocator restoration; retain transient resources and omitted resource entries according to the reference.
- [ ] Resolve and approve stale pre-restore handle semantics if not already covered by the identity contract; preserve approved foreign-world rejection. Restore is not a new Runtime or an automatic reset of system/Local/capture slots.
- [ ] Test malformed saves, pending commands, slow reader positions, earlier systems and retry, detecting a reached partial-restore/incorrect-allocator mutant. Basic restore does not close graph/machine save coverage.

## Blocked by

- #58

## Delivery and evidence

- Apply the [SPEC reference order](../SPEC.md#implementation-decisions): Rust Bevy architecture and ECS semantics first; Bend types, affine ownership and runtime constraints second; bevy-ts feature inventory and porting inspiration third. Record exact reference commits. Execute bevy-ts comparisons for shared agreed scenarios, not as a blanket behavior authority; preserve approved contracts and record reference differences explicitly.
- Verify through independently authored public application operations, complete JS/Native observations and an actually executed Node TS reference. Test two nominal schemas where composition/authority is extended, and actual independently created same-schema worlds for foreign-handle operations. Preserve arbitrary component families and affine Type payloads; reject undeclared access, cross-schema misuse, writes through read and owner duplication at their actual boundary.
- Freeze exact sources and retain command/input/output receipts, intended negative diagnostics and at least one reached compiling semantic mutant. Earlier task evidence does not substitute for this task's source-current acceptance. Finite traces are not universal proofs/refinement.
- Run the unchanged default #28 paired regression gate before delivering executable core changes. Keep its workload/baseline/statistics unchanged. Add equivalent complete feature-specific TS/JS/Native observations and timing/scaling evidence without dropping work. No new numerical tolerance or baseline is approved by this ticket. During CPU contention defer comparative measurements, not semantics investigation; a timeout is inconclusive.
- Use before/after JS call and allocation profiles for a consequential performance change; report allocation sampling separately from physical/RSS memory. Optimize demonstrated bottlenecks while completing features. The scoped #30 amendment is not a global gate waiver; full performance remains under #21/#23/#24.
- Specific new laws require drafting, falsification with planted defects and human approval before ECS proofs. New dependencies and unresolved contract changes require the existing SPEC approvals. Checker default remains five seconds; retain separately approved diagnostic scope without generalizing it.
- Commit verified work directly on master, obtain independent Spec/Standards review, push and post an English governing-issue completion report before closing. Preserve unrelated edits/processes, read-only references and canonical jev. Document any remaining limitation with a concrete owning task; do not close on a feasibility report or silently narrow this acceptance.

## Source-only readiness checkpoint (2026-10-08)

This appendix refines the existing #59 dependency; it introduces no contract,
law, wire format or second plan. Existing [snapshot readiness research](../research/basic-snapshot-readiness-v1.md)
was checked first. Inspection used root `13347b242909ad86600960ab94caf5c3ceca46da`
and the exact bytes below. References remain bevy-ts
`3040a3b2a3f28fa8554d856f9ccb6bf5433fa334`, Rust Bevy
`ad678262ce53b5d142fe49ee5e08caff6f00ab60`, Bend
`a950fd683c0d76f09794078e6174fe98a1492876`. GitHub #59/#38 still mark restore
stale-handle/reuse decisions unresolved. No checker, backend or Node comparator
was executed for this source-only checkpoint.

### Ordinary constructor/admission dependency

The integrated experimental ordinary declaration has one nominal identity,
a retained `Codec`, and a closed `P -> P & Raw` projection. Its `prepare`/`validate`
call Complete.decode_owner and return `Receipt<P>` with the incoming actual P.
The ordinary admission caller inserts that existing P only after Accepted;
Rejected retains it before column insertion. `Context.admit` retains owners in a
transport list: it is not a world restore. These are concrete owner-preserving
seams, **not constructors from detached save data**.

Confidence is high: Codec validates/canonicalizes Raw; neither it nor the
retained projection provides `Raw -> P` for arbitrary affine Type. Rust Bevy's
ReflectComponent insert provider uses registered type data/from-reflect fallback;
this supports explicit per-type providers, not reflection invented for Bend.
Bend's affine arrays/closures prohibit copying live owners into staged payloads.
Trusted schema callback truthfulness is not established by the affine type alone.

The established policies available to reuse are constructed/transient/plain
eligibility, trusted declaration-bound providers, complete Raw validation, and
accepted/rejected incoming-owner preservation. Snapshot save does not validate
at export. `bundle-construction.bend` labels its reversible constructor receipts
experimental; it does not approve a generic saved-data inverse. A restore factory
for each persisted P still needs the explicit constructor/error/owner contract
owned by #46/#58/#59. Do not declare Restore callable merely because Save's
projection-based eligibility is True.

| Required seam | Actual module/interface to reuse | Exact remaining responsibility |
| --- | --- | --- |
| Descriptor identity and retained recipe | ordinary canonical declaration; `public-adoption-v1/declaration.bend`, `schema.bend`, `leaf.bend` | Extend the same declaration/product traversal with an explicit saved-data construction provider; no second name registry or fixed-demo payload substitute. |
| Complete input validation and owner admission | `complete-v1/decode.bend:decode_owner`, `public.bend:request`, `admission.bend:insert` | Current APIs accept existing P. Stage constructed heterogeneous P owners before any live-world mutation; do not infer an inverse or promote transport admission to ECS restore. |
| Basic envelope and validation precedence | `Snapshot.ts:parse`, `Runtime.ts:restore`; experimental `export.bend:Snapshot` | Parse/version/path checks precede duplicate entity/name/value checks. Walk entities/components then resources in authored order. Basic Bend Snapshot currently has four fields; TS requires relations/machines envelopes too. #60 owns graph/machine meaning; no silent dropping or new rejection policy selected here. |
| Apply and preserve Runtime ownership | current World/column operations plus runtime queues/readers/registrations | Apply observed despawn/spawn lifecycle only after complete staging; retain transient/omitted resources and existing system/Local/capture slots. Validation failure drops/releases staged owners and preserves every live field. Whole lifecycle/runtime apply path is not implemented by the snapshot diagnostics. |
| Allocator and handles | `internal/world.ts:setNextEntity`, current `World.Handle`, #38 | Keep allocator progress at least the prior counter and `max(saved.nextEntity, maxSavedId+1)`: TS's setter itself takes max with the existing counter. Numeric-domain/exhaustion mapping and same-world restored-ID freshness still need their existing contract decision. |

### Stale handles: covered decision versus missing decision

Approved: a foreign world's handle returns MissingEntity even when its local ID
matches; creation-derived world identity must remain. This does not decide the
same-world restore case. Current Bend Handle contains namespace and ID, with no
per-entity generation. Pinned TS despawns then recreates saved numeric IDs; its
lookup uses the numeric value. Thus an old same-world handle whose ID is restored
can resolve the recreated entity (source inference, not an observed new trace).
An absent old ID stays missing. Rust Bevy invalidates freed generations; adopting
that behavior here would need a recorded parity/identity decision, not an
automatic architectural port. SPEC explicitly leaves reuse/generation unresolved.
Do not create a new Runtime/namespace or reset Local to evade this decision.

Before implementation crosses those gates, the minimal missing decisions are the
explicit per-type detached-data factory protocol and same-world restored-ID
handle semantics. Everything else above is a source-backed implementation map,
not permission to change the ticket's validation, error or rollback contract.
No #59 acceptance box or delivery gate is satisfied by this appendix.

### Exact inspected source pins

`A` below means
`experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1/`;
`T` means `.references/bevy-ts/packages/core/src/`.

| Source | SHA256 |
| --- | --- |
| `T/Snapshot.ts` | `249f57c429d97e57088ebb1e959b6258dd97ca71c9cc66a0a4ed6ac35ad04a3b` |
| `T/Runtime.ts` | `c744aa5c52845bd3323358c5085161b40a452c6802a1653e3851bfd34c69f5b4` |
| `T/Descriptor.ts` | `03e7339516d9f6bd455763a8dcdf7244d0c11f7165e493aa895aaa64225acab7` |
| `T/internal/world.ts` | `e71b4b060fec85fae690957104c14051e4bea0d857bacd648993ea69a6fe27d7` |
| `.references/bevy/crates/bevy_ecs/src/entity/mod.rs` | `4acf9bdf352ae2a925ea0a22d2f8ceb7542a8ea1fde164b2efe6c48a1ba3f0ab` |
| `.references/bevy/crates/bevy_ecs/src/reflect/component.rs` | `314bf24e2e2f96c4244da6814a1f21227e70af3546d08554c74c5878bb44db06` |
| `.references/bend2/guide/GUIDE.md` | `9001a4ac112e92dc0c069c8b9d5812e114c2557427d9f962cddeef1ef6c292b6` |
| `experiments/public-decode/public.bend` | `563db044319e174032e8b7127220073992ff36b402f1d0f6172bec1f41529fc4` |
| `experiments/public-decode/typed.bend` | `bbba271bff35d94e564c0b33f994737c8698942c3d05f9ffc71697c5c8185d26` |
| `experiments/public-decode/complete-v1/decode.bend` | `c2fbeaeff1cdf4a9ec47f8d924de0340c80b0b238e53927599259ba42f095b47` |
| `A/declaration.bend` | `51d22a4cc20ac95a25c1f09843b10d0b01f0b9be36c1190799f858fdccee239a` |
| `A/admission.bend` | `879af42914ded6b2c72471f06461f2ba82f831c33c23de87082585eef3511030` |
| `A/schema.bend` | `45a167ed964a9b28696f3ef58e6b770b1a2f50f896b94c169aa6b7563ac8ef37` |
| `experiments/public-snapshot/persistence-gate-v1/basic-world-v1/export.bend` | `8b01d09dc623f9d52d34114c5e0ffec9c2680b7bd5a0581a1fd424db5c12cdc8` |
| `src/ecs/world.bend` | `f03b45d2349b24467a4b5b604a9416ca1a504bba36fddcb75d06fb8146d9f310` |
| `docs/SPEC.md` | `71b2744f51a218790bfe75255e64250627d82f9d780006bd9edbe232d00abd0d` |

## Pinned TS development observations

[reference-v1](../../experiments/public-restore/reference-v1/README.md) now retains
one actual Node24.20.0 run against the pinned bevy-ts source, with an independent
pre-execution oracle and complete raw receipts. Workshop/Garden each execute20
rejection/precedence cases without live/pending/reader changes, followed by
successful lifecycle/queue/event/transient/omitted-resource/allocator observations.
The old allocator7 remains7 despite saved next2; the next spawn is7. Old same-world
id1 resolves its restored entity, while removed id2 and canceled reservations3–6
are MissingEntity. These are TS observations, not approval of Bend's stale-ID
policy or arbitrary Type restore factories. No #59 checkbox is closed; failed
system/Local/capture, Bend, negatives/mutants and full backend/performance gates
remain due. Full graph/machine restore stays #60.

## Detached constructor transport prototype

[provider-v1](../../experiments/public-restore/provider-v1/README.md) source-checks
a minimal extension of the existing ordinary `Constructed` declaration and
`standard-owned.Reply`. A closed schema-author callback receives the declaration's
retained Codec and **original** detached Raw, returning affine Context and either
arbitrary Type payload or owned rejection input/issues. Accepted payload and
refusal context/issues are instantiated with actual Array types; duplicating an
accepted payload is refused by the checker. This is transport preparation, not
World admission or an implemented restore API.

Original-input delivery and error precedence are already fixed by pinned TS:
Descriptor.decoderOf selects decode before result, Runtime.validate invokes that
selected decoder directly, and restore wraps its first opaque failure in entity/
resource position order before live mutation. Decoder-specific transformations
belong to that callback; framework canonicalization before arbitrary callbacks
would change the contract. These mechanics need no new user decision.

The prototype deliberately leaves partial-success recovery, release of replaced
live owners, stale same-world identity, events/captures and multi-entry transaction
ownership to the existing approval package and owning tickets. It supplies no
Raw-to-arbitrary-Type inverse, law/proof, backend or #59 completion claim.

The provider prototype additionally has an actual trusted Boolean-cell
constructor: original detached Raw is completely decoded under the retained
Codec before creating an affine Array payload; acceptance then consumes that
payload through the same declaration's save projection and complete validator.
Refusal carries original Raw, unchanged affine Context, exact decoder error and
owned Issues sentinel. Both paths source-check; this is concrete constructor
preparation rather than transport of a prebuilt owner. Executed application
controls, transaction recovery/release and public restore remain outstanding.
