# #48 machines — verified initial runtime milestone

#48 remains open. The experimental implementation now executes the selected
24-frame application for two nominal schemas through actual registered bodies,
enter hooks, schedules, transactions and retained affine transition readers.
This is finite executable evidence, not production adoption, universal runtime
refinement, an approved law/proof, or full issue completion.

The [pinned contract](../../experiments/public-machines/contract.md),
[actual TS observations](../../experiments/public-machines/expected.json), and
[primary Node receipt](../../experiments/public-machines/evidence/reference-v1/receipt.json)
were frozen before Bend implementation. Node 24.20.0 directly imports the pinned
TS core; no dependency was installed. Both applications retain complete
observations, including failed publishing/reader retries, same-state set and
skip behavior, pending aliases, conditions, deferred spawns and definition order.

The [terminal runtime receipt](../../experiments/public-machines/evidence/full-semantic-v2/receipt.json)
has SHA256 `0c439f18af799980c0462245d38939a071052ca6a033a3aed09dd7c371ec25c1`
and status `FULL24_TWO_SCHEMA_JS_NATIVE_AND_EIGHT_REACHED_MUTATIONS_PASS`.
Its 67 bounded commands bind 38 core Bend modules, 142 source pins and 1750 artifact
hashes. Normal JS and Native each match all 48 complete records. All 12 actual
negative consumers reject at the intended type/affine seam. Eight compiling
operation mutations change the named checkpoint in both roots on both backends:
early current mutation, missing pending inverse, resource prefix restoration,
failed-reader cursor advancement, running a skipped reader, ordinary identity
suppression, reversed definition order, and preservation of a later captured
write. The last is explicitly a pinned-reference deviation, not an approved
project defect or retention policy.

The [independent review](../reviews/machines-full-semantic-admission.md) admits
and reconciles this exact finite cohort. The root additionally verified every
declared source/artifact hash and both-schema/backend records. Checkers and
runtimes have five-second limits, emits 30 seconds and Clang 120 seconds; every
child uses owned-descendant supervision. Normal-exit orphans are inconclusive,
deadline output remains lossless, and ldd/tool/config/reference/source/stage/log
inventories are guarded. Native uses one thread with GPU off. Supplemental
process-supervision canaries are infrastructure evidence only.

The [portable evidence inventory](../../experiments/public-machines/evidence/full-semantic-v2/files.json)
binds complete raw captures, all staged subjects, emissions, binaries, original
source bytes and expected/observed records. The [failed prior attempt](../../experiments/public-machines/evidence/full-semantic-v1/receipt.json)
remains nonpassing. Its model incorrectly gave the component column a leading
empty slot. Source inspection established one initial leaf, writes only to ID1,
and `Column.swap(id-1)`; only that physical-cell model field was corrected for
all 48 records. Complete component/resource payloads and stamps remain checked.

Common gameplay values come from actual TS observations. Physical padding,
closed registrations/catalogs, publication clocks and affine cursor ownership
are source-derived supplements. Opaque callbacks are preserved and exercised
at barriers; their queue length is observed, without claiming raw callback
serialization. Hooks are provisioned before this fixture's first frame whereas
TS lazily registers them. Dispatch performs condition checks, without claiming
the schedule's own dispatch trace equals a TS skipped-system trace. Equivalent
registration/schedule timing is therefore still pending.

The public marker contract remains unresolved: Runtime.ts1534 deletes a newly
queued request for a later already-snapshotted machine, while a self-requeue can
survive. The ticket's blanket next-marker retention statement conflicts with
that observed behavior. This milestone selects neither TS loss nor stronger
retention as project policy.

Remaining gates include actual never-activated skip, 65,537-publication overflow,
independently allocated same-schema foreign-reader instances, supplementary
owned disposal, missing/raw provisioning runtime controls and public adoption.
Pinned Runtime exposes no public unregister/dispose operation; its stream
reader maps/sets retain registrations. Bend `Sys.dispose`/`St.dispose` cleanup
must be labeled a supplemental extension, without mutating TS private maps to
manufacture parity. Complete transition-handler failure positions and marker
atomicity remain #49. Full product performance qualification remains
#21/#23/#24. No core source, policy, dependency, threshold or ECS proof changed.

Earlier 16/19-command development and 24-command checker receipts retain their
own exact source bytes and limits. They remain checker/primary-TS evidence;
they do not inherit this newer runtime result.

## Source-current provisioning readiness (2026-10-09)

This is read-only source research, not a new execution or an approved contract
change. The manifest `.references/sources.json` pins Bevy to
`ad678262ce53b5d142fe49ee5e08caff6f00ab60`, bevy-ts to
`3040a3b2a3f28fa8554d856f9ccb6bf5433fa334`, and Bend to
`a950fd683c0d76f09794078e6174fe98a1492876`. Absolute-reference repository HEADs
were read and match all three pins. Sources below are local read-only reference
paths from the repository root; isolated worktrees must use absolute reference
paths. No compiler, runtime, timing population or historical verifier was run.

### Existing seams and actual gaps

`src/ecs/machine.bend` already supplies schema/token/value-indexed `Slot` with
`Missing`/`Present`, `CurrentView.Unavailable`, finite typed queue inputs, and
complete-old-slot transaction inverses in `write_taken`/`reset_taken`.
`src/ecs/machine-world.bend` supplies closed resource `take`/`put` lenses which
return the arbitrary affine world and retain every unrelated field. It has no
public initial-provision constructor, requirement list or reusable schedule
preflight. Low-level `queue(Missing, value)` silently retains `Missing`; it is
not an application requirement-refusal boundary.

`experiments/public-machines/provider.bend` has actual independent Flow/Level
slots, but `initial_resources` always constructs both as present. Its
`condition_needs`, `condition_provisioned`, `condition_check` and
`condition_world` already inspect every declared condition leaf independently
of Boolean short circuiting and distinguish missing provisioning from a normal
false condition. `condition-controls.bend` includes missing-under-true-or and
missing-under-negation controls, but those metadata controls do not exercise an
actual missing-slot application world.

The existing application is more complete than a new preflight proposal would
suggest: `experiments/public-machines/application.bend` already implements
`action_ready`, `ready`, `provision_checked`, `checked` and `frame`. Refusal returns
both actual `Owners` and actual world before `named` calls `P.frame` or builds/runs
the schedule. This is the concrete owner-preserving seam to reuse. Its operation
requirements are fixture-specific and sometimes conservatively require both
slots. A reusable boundary must derive the exact declared machine requirement
union, rather than imposing both Flow and Level on every application operation.
Existing body dispatch also advertises a fixed broad access list. Changing that
list or deriving exact capabilities requires corresponding source negatives;
preflight cannot silently redefine existing registration access contracts.

### Reference contract and differences

Pinned Rust `.references/bevy/crates/bevy_state/src/app.rs`,
`AppExtStates::init_state` and `insert_state` (lines 96–152), establish committed
state, next-state storage, transition-message support and state registration.
`init_state` leaves existing state intact; `insert_state` overwrites it. The
initial/replacement message has `exited: None`, `entered: Some(state)`; replacement
clears prior transition messages. The tests `insert_state_can_overwrite_init_state`
and `insert_state_can_overwrite_insert_state` confirm replacement. Rust
`condition.rs::state_exists`, `in_state` and `state_changed` use optional state
resources: absent state returns false. `state_changed` additionally observes
newly inserted resources. These are material differences from the existing
selected TS/Bend initialization, which starts with changed=false and no ordinary
from/to transition event. Do not add Rust initial messages or change initial
changed flags as an incidental provisioning patch: the existing
`Transition<V>{from,to}` cannot represent initial None-to-Some messages, and the
observable adaptation requires separate agreement.

Pinned TS `.references/bevy-ts/packages/core/src/Runtime.ts` lines 759–771 installs
provisions into `currentMachines` in input order, so the last duplicate initial
provision wins. Public `machine`/`machines` at lines 2113–2153 constrain values to
the declared finite machine type. `hasRequirement` and `tryRunSchedule` at
1661–1689 inspect the full schedule requirements before `advanceFrame` or any
work, returning `MissingRuntimeRequirements` with missing kind/name entries.
`Machine.ts` constructors `not`, `and`, `or` preserve/union requirements;
`Schedule.ts::gate` unions condition and body requirements. Therefore a missing
machine hidden behind a true disjunction still refuses at the selected TS
application boundary. That stronger schedule requirement is not the same as
Rust's optional `in_state` false result; keep pure condition evaluation and
required application preflight separate and record the adaptation explicitly.

`experiments/public-machines/reference.mjs::rawBoundaries` and frozen
`expected.json.raw.missing` provide actual TS evidence: RawFlow refusal has
frame=0, tick=0, no entities/resources/machines/commands. The same oracle records
last duplicate initial value, duplicate definition rejection, and untyped JS
invalid initial/queued values. Raw JS accepts INVALID/UNKNOWN; neither Rust finite
enums nor the existing Bend finite types provide that value domain. Implement
finite typed provisions and missing requirements without introducing a string
state escape hatch, runtime invalid-value policy or claiming raw-JS parity.

### Restoration boundaries

Transaction restoration is independently implementable with existing approved
operations: preserve the complete old slot, including presence, current,
pending, previous and changed, and return the same arbitrary world and owners on
failure. Existing `machine.bend::write_taken`/`reset_taken` plus
`transaction.bend` already implement those inverses; TS
`Runtime.ts::journalMachine`/`rollbackSystem` restores the original pending entry
or absence (lines 1017–1061). Source-current missing-world cases should exercise
that seam instead of replacing it with a second restoration mechanism. Missing
preflight refusal must occur before entering the transaction or consuming any
registered reader owner; later provision and retry use the retained actual
owners, without re-registration or eager reader activation.

Public saved-world restoration is a different capability, owned by #59/#60.
TS `Runtime.ts::restore` validates saved machine names and finite values before
mutation (1808–1815), then clears pending machines and transition events with
other runtime streams before applying saved committed values (1818–1834).
That crosses snapshot ownership/stale-handle and stream-clearing boundaries.
No rawBindings restore observation exists in the #48 oracle. It is not justified
to claim saved-world restoration from the #48 transaction inverse or to import
#59/#60 identity policies into a provisioning implementation.

### Implementation-ready bounded slice

Reuse the existing `Slot`/closed lenses to supply finite typed initial machine
values and explicit missing slots through an ordinary schema-bound provisioning
API; preserve the selected no-pending/no-previous/changed=false initialization.
Duplicate initial provisions remain a contract decision: TS last-write-wins
does not select the Bend API policy. A checked empty-slot provision candidate
may return its supplied owner when occupied without claiming replacement parity. Preserve definition order separately
from provision order; do not mint new globally unique IDs or foreign handles.
Reuse actual `application.frame` refusal/result ownership and extract a generic
closed declared-requirement preflight seam, with no world mutation or callback
invocation on failure. Test full worlds with one/both slots missing, no-machine
operations, hidden condition requirements, and retry after typed provisioning in
two nominal schemas. Retain exact original owners and all unrelated Type payloads,
commands, clocks, registration metadata and stream state in complete observations.

Pure conditions are optional reads, not required-body accesses. Pinned Rust
`condition.rs::state_exists` and `in_state` return false for absent state; negation
and Boolean composition act on that result. Therefore missing state under
`not(in_state(...))` may yield true, and a true disjunct may permit execution.
Do not import the TS blanket condition requirement union into native preflight.
Explicit required body/reader accesses remain separate; refusing the whole frame
for those accesses is a candidate adaptation, not proved Bevy scheduling parity.

Generalizing declarations must keep undeclared/cross-schema/write-through-read
negatives at the actual consumer boundary.

This slice needs fresh source-current JS/Native observations and reached controls,
then unchanged paired regression before executable core delivery. Existing full48
runtime and condition-control receipts qualify their original sources only. It
requires no new identity, capture finalizer, affine-event, raw invalid-value or
later-key deletion decision. Initial Bevy messages/changed semantics, exact public
error-shape adaptation, and public saved-world restoration remain explicit
separate contract/delivery questions; the slice does not close all of #48.
