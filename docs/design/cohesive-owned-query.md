# Cohesive owned query — DRAFT

Discussion design only: not implementation, production API approval, a new law,
or performance acceptance. Current #30 prepared route still fails the unchanged
regression gate. No baseline, workload, numerical threshold or dependency change
is proposed.

## Source constraint and target

`Compose.Plan` fixes both capabilities and selector to `Frame<S,Store,R,E>`
(`src/ecs/compose.bend:17`). The rank-2 body hides that concrete frame, but does
not let the current executor substitute another owner representation.
`optimized-compose.each` prepares selected columns, runs this same World-based
frame executor, then recovers all selected columns. Each admitted projection
returns its actual owner into another Prepared/Owned/State before another alias
can access it. Frozen Workshop has 967 such states and 140 family recoveries.
Counts diagnose transport, not elapsed cost or sufficient performance evidence.

Explore an **additive closed owned plan**, preserving current Plan and public
helpers. Arbitrary existing fixed-Frame Ops cannot be converted automatically;
this is separate additive provider integration. Its trusted declaration binds a concrete affine H, arbitrary Ops(H),
selector, enter and leave together. Gameplay keeps the existing universal body
shape and receives only abstract H plus declared capabilities. No fixed family
count, Data-only component constraint or schema-specific public carrier.

Conceptual seams (not checked Bend signatures):

- enter consumes the actual Tx and handle/cursor, moving selected current owners
  from the frozen selected handoff route into H alongside the transaction/world
  remainder. It returns all owners on rejection.
- select consumes/returns H and Bool, with existing short-circuit order and
  admitted projection effects. It cannot silently substitute pure membership.
- body operates against the same affine row owners through arbitrary Ops(H).
- leave consumes H and returns the complete actual Tx plus internal access error;
  skipped, successful and failing rows all leave. The executor then preserves
  existing error precedence, traversal order, output commit and tx_finish. One
  transaction spans the full traversal: leave reattaches owners, never commits
  a row or publishes its pending effects early.

Actual extracted producer/recovery provenance remains binding. This is not
permission to replace it with unrelated direct Array access or skip preparation
for a small workload. The first prototype must expose how its enter/leave join
that exact owner route.

## Decisions and risks requiring an explicit implementation design

- Shared aliases must lens the same owner field. A legal C -> C & V projection
  may change C: invoke it exactly once at each admitted access and store its
  returned owner. No cache of projected V or universal owner-identity assumption.
- Optional/absent families, resources, lifecycle stamps, foreign handles and
  arbitrary Type payloads retain current access/error behavior. Namespace and
  live validation cannot be cached across an operation that could change them.
- Read, write and selector capability choices travel together; public gameplay
  cannot name/recover concrete H. Undeclared family, cross-schema and write-through-
  read controls remain rejected by the checker.
- Pending commands and events are actual owned closures/Data values. Preserve
  their ordering and contents, clock advancement and deferred barrier behavior.
  Event/command counts alone are not a full payload trace.
- Existing undo closures consume World. Choose and check one concrete strategy:
  restore every extracted row owner into World before those closures can run,
  keeping leave metadata-neutral; or implement an explicitly reviewed H-aware
  inverse path. Never run old inverses against an evacuated World. A failure in
  a later row must restore earlier rows and stamps while releasing each replaced
  current owner once. Projection effects retain the existing rollback behavior.
- Backward/nonascending access, growth, partial fuel, raw invalid states and
  refused commands must return complete current/past/remaining owners. Fallback
  must restore the row first and synchronize the returned owner before resuming;
  it cannot duplicate or discard Type payloads.
- Local state persistence on error remains the accepted policy. All World fields
  and journal ownership must survive enter/leave; no fabricated replacement World.
- H layout must be inspected in actual JS and Native output. Large heterogeneous
  tuple flattening can recreate the rejected wide Native union. Do not assume
  erased Type sharing is free or that fewer literals imply faster execution.

## Bounded finite acceptance gates

1. Five-second checker prototype for the closed generic seams and arbitrary
   heterogeneous Type owners; compare actual source quantities of preserved APIs.
2. Original versus new complete Workshop observations on both JS and Native,
   retaining every existing checkpoint, row output and normative reference join.
3. Full cell/stamp observations after same-row aliases, mutating projection,
   repeated writes, skip, late failure, reverse access, growth, refusal and deep
   Wrapped recovery. Retain partial producer/view fuel and boundary controls.
4. Actual deferred command/event payload and order observations, foreign same-ID
   MissingEntity with unchanged queue, and resources/clock/Local policy controls.
5. Archived selected producer and recovery equivalence on finite arbitrary-Type
   owners; actual reached recovery omission mutant detected on both backends.
6. Current public confinement negatives, plus a negative attempt to recover or
   specialize concrete row H from the universal callback.
7. Source-hashed actual route counters and emitted Native layout/JS dispatch;
   distinguish transport diagnosis from physical allocation and timing.
8. Both ordinary and selected prepared-provider unchanged paired regression
   gates with source-bound full outputs. No confirmed slowdown remains the gate;
   full-core JS/bevy-ts and Native qualification remain separate.

Finite comparisons are not universal refinement or proofs. Do not claim #30
complete from a prototype report; record any remaining capability explicitly.

## Checked prototype checkpoint (not general adapter delivery)

owned-composee6ee80f5 checks the additive closed plan and full traversal; selector
precedes enter, abstract body returns through leave before finish, each_since
threads its explicit cursor. ID1 heterogeneous-owner fixture2967b853 passes
JS/Native with actual selected prepared extraction and full owner restoration.
Shared aliases invoke a mutating projection3→4→5; success outputs3,4 and final
owner5,7; failure discards row outputs but restores actual projection-returned
owner5,7 and the second Bool-array ownerTrue,False. This no-write prototype does
not validate journal inverses, general IDs, refusal or complete-world bridges.
Native fixture width32/register31 is not Workshop representation acceptance.
Source-bound receipt and frozen prototype source: evidence/owned-seam-prototype.

## Checked detached-cell checkpoint

Additive row-column Cell contains captured actualid, actual owner, currentstamp,
dirtybit and a recursive cold Column carrier. detach uses original lifecycle
then original swap(None); refusal preserves original Column plus actual rejected
incoming. attach takes the whole token, no external ID/column, and returns the
complete original Col.SwapOutcome including previous/incoming owners. Untaken
projection is explicitly Deferred, not component absence; provider must bridge
to the original operation. Replacement returns every immediate previous owner
and stamp, or refused incoming. Adapter entity/clock/journal remains separate.

Seventeen JS/Native source-bound controls in evidence/row-cell-checkpoint cover
ordinary/prepared owners and absence, invalid bounds,32Wrapped cold, mutating
projections/shared aliases, both immediate predecessors/stamps, actual backward
recovery, fuel0 seek refusal, refused replacement, and malformed attachment:
refusal preserves incoming41,43; accepted replacement exposes previous3,7.
This is finite cell evidence, not full World/transaction/performance acceptance.
The provider must explicitly preserve/release attach's returned previous owner
and cannot silently discard a refused incoming before World exposure.

## Profiling evidence requirement

The user requested actual JS call-stack and memory profiles before/after. Use the source-bound Node inspector runner under `experiments/public-optimized-compose/node-profiles/`, retaining CPU samples, sampled allocation stacks including collected objects, GC events and every complete observed application. The exact shared-live generated before artifact is frozen; compare it with the correctness-verified owned provider using identical profiling settings. Sampling does not replace physical allocation accounting or the unchanged paired performance gate.

### Captured restoration checkpoint (finite, not an opaque token API)

`captured-column.bend` specializes the selected original swap/seek route with
incoming `None`. Checked accepted extraction returns the actual owner and an
affine restoration closure capturing the actual ordinary index or prepared
current slot; release reinstalls the actual projection-returned owner and stamp.
The exported constructors and `capture_seek` remain raw and forgeable. This is
**not** universal safety for arbitrary raw tokens: the guarantee is scoped to
capture-produced tokens preserved by trusted provisioning. Rank-2 gameplay
cannot inspect its concrete `H` or mutate the captured cold representation.
The original fallible `row-column` API and malformed-owner controls remain.

The initial captured checkpoint observes 23 records on JS/Native, including six
old/new fuel/seek pairs, actual complete cell payloads, 32 nested wrappers,
backward recovery, refusal, absence and legal mutating projection. Native fixture
result width is 7 words; this does not qualify the full Workshop representation.
The additive `restored-row` and `owned-family` helpers and four Workshop context
shapes checker-pass. A copied owned Workshop first JS run matches all 23 original
checkpoints. Full provider-specific failure/clock/refusal controls, Native,
confinement/mutation, matched profiles and both binding regression gates remain.
