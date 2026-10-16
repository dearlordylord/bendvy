## Parent

#1 — full Bend-native bevy-ts core parity.

Remaining-core specification: #37.

## What to build

Systems perform recoverable operations on caller-owned affine component/resource payloads and preserve exact state after failed ECS transactions.

## Acceptance criteria

- [x] Specify an explicit recoverable operation/inverse interface for destructive Type operations; identify which external IO effects remain outside rollback. Obtain approval for unresolved public contracts before implementation.
- [x] Exercise affine elements, complete Array replacement and captured payload operations through actual public systems, with multiple writes, refusal, earlier commits and failed retry. Return every original/replacement/inverse owner exactly once.
- [x] Reject irreversible operations from any API that promises rollback rather than silently accepting incomplete recovery; retain supported unrestricted Type storage without a Data-only component rule.
- [x] Detect a reached incomplete-inverse/owner-loss mutant and retain existing scalar/Array rollback consumers. Record supported and unsupported effect domains explicitly.

## Dependencies

- #50 — accepted; normal capture persistence remains unchanged.

## Semantic acceptance reconciliation — 2026-10-16

All four semantic criteria pass the [independent joined review](../../experiments/public-recovery/mixed-v1/FINAL-REVIEW.md).
Integration `d38025142` and CI38865825685 pass. The independently authored
[application](../../experiments/public-recovery/independent-app-v1/successor-v2/README.md)
now executes present-component removal through None, rollback and commit on stock
JS and Native. Both complete 2,276-byte observations match a separately authored
oracle (`364251ef221f6089fe7e1dfba37f98b54b8d2e8de4a2317469d271803fa5f822`).
The first fixture’s ID/index error and failed JS attempt are preserved. [Independent review addendum](../../experiments/public-recovery/independent-app-v1/successor-v2/FINAL-REVIEW.md)
passes. Integrated at `8b80a21ba`, CI38868650606 PASS; [English acceptance report](https://github.com/dearlordylord/bendvy/issues/52#issuecomment-6210619998) posted and #52 closed.

The ordinary API composes canonical Component, Resource and explicit Capture
operations with `ordinary-recovery-declaration.both`, then registers/runs them
through `ordinary-recovery-system`. One global LIFO journal spans all leaves;
recovery is a statically typed product. Arbitrary affine Type payloads remain
supported. Commit returns displaced originals; rollback restores old payloads
and stamps and returns displaced replacements. World clock stays monotonic,
failed/rejected calls preserve the registered cursor, and normal #50 captures
retain their existing persistence behavior.

| Evidence | Stock JS / Native full oracle | Scope |
| --- | --- | --- |
| [Resource](../../experiments/public-recovery/ordinary-array-v1/runtime-v1/README.md) | 6,951 bytes each | Whole replacement, affine elements, refusal, earlier commit and retry |
| [Component / opt-in capture](../../experiments/public-recovery/component-capture-v1/runtime-v1/README.md) | 13,009 bytes each | Payload/stamp restoration, returned owners, absent component and foreign entity |
| [Unlike families](../../experiments/public-recovery/heterogeneous-v1/runtime-v1/README.md) | 13,523 bytes each | Ordinary product Store, two different payload types, shared journal |
| [Mixed](../../experiments/public-recovery/mixed-v1/runtime-v1/README.md) | 16,673 bytes each | Nine interleaved component/resource/capture operations, complete owners, both schemas/worlds |
| [Reached owner-loss control](../../experiments/public-recovery/ordinary-array-v1/owner-loss-mutant-v1/runtime-v1/README.md) | 6,631 bytes each; normal 6,951 rejected | Actual commit inverse omits recovery append; failure inverse unchanged |

[Final authority controls](../../experiments/public-recovery/mixed-v1/authority-v1/README.md)
retain one actual mixed-run positive and ten intended type/affine negatives,
including nested identity/grant boundaries and raw World/Frame/mutation refusal.
Unchanged scalar/Array rollback paths and the protected 23-source #28 workload
retain their reviewed source/artifact applicability; the new modules are additive.
[Executed TS comparisons](../../experiments/public-recovery/ordinary-array-v1/TS-APPLICABILITY.md)
cover shared value semantics, not Bend affine inverses. No comparative timing,
universal law, physical identity or automatic finalization is claimed.

Raw Declaration constructors, custom Builder/Ops, direct engine runners and
Family/Frame/Journal provisioning are trusted engine administration. The rollback
promise covers the canonical leaves and their library-derived composition, not
arbitrary custom inverse builders. Gameplay receives only opaque H and declared
grants. External IO and arbitrary destructive callbacks are outside these grants.

Ordinary callback shape: declare erased capability specialization with template
parameters, then pass the callback through the runner's erased body index:

```bend
def body(~S:Data,~H:Type,~caps:Ops(~S)(H),args:Args<S>,owner:H) -> H & (T.Outcome<Error> & Output):
  ...
```

Keep runtime Args/owner affine. Replacing ~H/~caps with ordinary erased -H/-caps
makes them runtime parameters that cannot be passed to canonical ~H/~cap calls.
The runner supplies the closed Frame and grants before executable materialization.

Pinned references: Rust Bevy `ad678262ce53b5d142fe49ee5e08caff6f00ab60`,
Bend `a950fd683c0d76f09794078e6174fe98a1492876`, bevy-ts
`3040a3b2a3f28fa8554d856f9ccb6bf5433fa334`. Bevy supplies the architectural
reference, Bend the ownership/runtime constraints, and TS the shared subset.
Bevy component ownership does not imply an automatic transaction rollback API.

## Delivery and evidence

- Apply the [SPEC reference order](../SPEC.md#implementation-decisions): Rust Bevy architecture and ECS semantics first; Bend types, affine ownership and runtime constraints second; bevy-ts feature inventory and porting inspiration third. Record exact reference commits. Execute bevy-ts comparisons for shared agreed scenarios, not as a blanket behavior authority; preserve approved contracts and record reference differences explicitly.
- Verify through independently authored public application operations, complete JS/Native observations and an actually executed Node TS reference. Test two nominal schemas where composition/authority is extended, and actual independently created same-schema worlds for foreign-handle operations. Preserve arbitrary component families and affine Type payloads; reject undeclared access, cross-schema misuse, writes through read and owner duplication at their actual boundary.
- Freeze exact sources and retain command/input/output receipts, intended negative diagnostics and at least one reached compiling semantic mutant. Earlier task evidence does not substitute for this task's source-current acceptance. Finite traces are not universal proofs/refinement.
- Run the unchanged default #28 paired regression gate before delivering executable core changes. Keep its workload/baseline/statistics unchanged. Add equivalent complete feature-specific TS/JS/Native correctness observations without dropping work; keep boundary and capacity correctness checks. Comparative timing/scaling is qualified on the combined feature workload under #21/#23/#24 and is not a prerequisite for individual semantic delivery. Consequential hot-path changes and detected regressions still require targeted performance investigation. Final JS <= TS and Native <= 0.5 * TS goals remain unchanged. No new numerical tolerance or baseline is approved by this ticket. During CPU contention defer comparative measurements, not semantics investigation; a timeout is inconclusive.
- Use before/after JS call and allocation profiles for a consequential performance change; report allocation sampling separately from physical/RSS memory. Optimize demonstrated bottlenecks while completing features. The scoped #30 amendment is not a global gate waiver; full performance remains under #21/#23/#24.
- Specific new laws require drafting, falsification with planted defects and human approval before ECS proofs. New dependencies and unresolved contract changes require the existing SPEC approvals. Checker default remains five seconds; retain separately approved diagnostic scope without generalizing it.
- Commit verified work directly on master, obtain independent Spec/Standards review, push and post an English governing-issue completion report before closing. Preserve unrelated edits/processes, read-only references and canonical jev. Document any remaining limitation with a concrete owning task; do not close on a feasibility report or silently narrow this acceptance.

## First ordinary resource slice

Source `ea3383ab1`, plans `f2e5f4fe8` and independent oracle `692e42caa`
qualify canonical whole-resource Array replacement and affine element exchange
through a registered public system. Stock JS and Native -O3 both match all 6,951
bytes, including earlier commit, rollback, failed/successful retry, invalid-index
refusal and a genuine colliding foreign registration on two nominal schemas.
Displaced originals on commit and replacements on rollback are returned in authored
order; every nested affine owner is observed before caller release.

See the [retained backend packet](../../experiments/public-recovery/ordinary-array-v1/runtime-v1/README.md)
and [actual authority controls](../../experiments/public-recovery/ordinary-array-v1/authority-v1/README.md).
The ordinary constructor derives its canonical inverse and recovery collector; raw
World, Frame, journal and Lens helpers remain trusted engine administration.
The positive actual run checks; seven negative programs reject misuse. These are
finite checks, not approved laws or universal runtime proofs.

This does not complete #52: component payload/stamp recovery, explicit opt-in
captured recovery, reached semantic mutation, shared TS reconciliation and joined
acceptance remain in this issue. Normal #50 capture persistence is unchanged.
Empty pending queues and zero clocks in this resource fixture do not qualify
deferred effects, external IO rollback or component lifecycle restoration.

The resource slice is integrated at `c8f5b4c5c`; CI38861304008 passed.
[Shared executed TS applicability](../../experiments/public-recovery/ordinary-array-v1/TS-APPLICABILITY.md)
records the qualified value-level comparisons and their ownership/runtime limits.

## Component and explicit capture recovery slice

Source `f7e221791` with canonical component primitive `931cb3b86` executes a
registered component/capture system on two nominal schemas. Stock JS and Native
-O3 match the independent complete 13,009-byte oracle `404dd9de8`, including
multiple writes, earlier commit, failure/retries, rollback of an absent component,
actual foreign-entity refusal and colliding foreign registration refusal. The
observer preserves every affine payload, returned record and capture; it reports
component stamps, monotonic World clock and success-only system cursor.

Opt-in capture operations restore their payload on failure; normal #50 capture
persistence is unchanged. Component inverses restore the old payload and stamp
and return the displaced payload with its actual pre-undo stamp. The journal
runs every action on both outcomes. The closed ordinary runner always uses a
successful transport envelope so semantic failure cannot discard recovered owners.
Its defensive TransportFailed case is unreachable through that closed runner,
not a general guarantee about arbitrary trusted transport code.

See the [complete packet](../../experiments/public-recovery/component-capture-v1/README.md)
and [affected authority controls](../../experiments/public-recovery/component-capture-v1/authority-v1/README.md).
The first resource [owner-loss control](../../experiments/public-recovery/ordinary-array-v1/owner-loss-mutant-v1/README.md)
drops displaced owners in the actual commit inverse. Both backends match the
independent 6,631-byte counter-oracle and reject the complete normal 6,951-byte
trace. This establishes reached finite owner-loss detection, not physical memory
identity, automatic finalizers or a universal proof.

The current component entry uses a canonical single Column. At that checkpoint, ordinary
heterogeneous-family composition and joined review remained; the reconciliation
above records their subsequent completion without narrowing the obligation. External IO and arbitrary
destructive callbacks are outside the recoverable grants. The unchanged protected
23-source #28 closure retains its existing reviewed stock applicability.
