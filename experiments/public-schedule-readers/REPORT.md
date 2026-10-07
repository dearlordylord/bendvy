# #35 P-SCHEDULE-READERS: finite semantics report

Source-current semantics pass. This report does not close the issue: independent
Spec/Standards review, the unchanged #28 paired regression gate, feature-specific
performance evidence and coordinated delivery remain separate acceptance work.
No ECS laws, proofs, dependencies or numerical thresholds were introduced.

The retained [receipt](evidence/source-current/receipt.json) has SHA256
`69820a6eb73015ade86ee924456a82f13d9758be84ea13795ede6936b567b6df`.
It records 28 backend result rows and four intended negative controls. The
original complete build directory is
`/workspace/formal-proofs/bendvy/.artifacts/public-schedule-readers-1791352114029283816`.
The retained evidence copies complete observations, compressed large
traces, negative diagnostics and the unchanged receipt; generated C/JS/binaries
remain in that build directory and are bound by receipt hashes.

## Observations

| Subject | Evidence | JS / Native |
|---|---|---|
| Actual pinned TS composed schedule | 25 complete checkpoints; full arrays; event capacity 65,536 with a 65,535-publication batch | Exact / exact |
| Actual pinned TS Added+Changed schedule | Four checkpoints: seed, skipped spawn, own-write resume, consumed next run | Exact / exact |
| Domain/resource ownership | Ordinary/removal partition; actual Event.run and recovery; all four words of an affine Array resource | Pass / pass |
| Scheduled disposal and late registration | Event, changed and removal owners disposed/re-registered through actual schedules; fast peers remain consumed | Pass / pass |
| Mixed registered publisher | Immediate Ping10, deferred Ping11 and actual Aux removal; failed transaction and successful retry/barrier; full owners | Pass / pass |
| Mixed event-reader recovery | Failure/retry both observe 42; successful publication/removal; capacity 2 retention; slow-peer lag, event skip, removal backlog and consumed own publication | Pass / pass |
| Foreign schedule namespace | All 25 runs reject before dispatch while recovering schedule/world owners | Pass / pass |

Disposal and both mixed controls are source-backed Bend controls, not claims of
paired upstream disposal/custom-barrier API parity. Main and Added references
execute the pinned upstream Runtime/Schedule APIs directly with existing Node.
The main reader-failure fixture selects one row and captures that actual
transaction error observation; it does not claim arbitrary aggregate failed
row observations. The observer names its known fast/slow roles and reports
additional retained reader identities as `reader#N`.

## Reached mutations

Every row below compiles under the unchanged five-second checker bound and is
detected by complete actual scheduled observations on both backends.

| Mutation | First relevant difference |
|---|---|
| Event skip keeps backlog | Skipped reader metadata; subsequent resumed backlog |
| Lifecycle success consumes pre-run clock | `change-own-write-consumed`: rows replay and owners change again |
| Failed event reader advances cursor | Failed reader metadata; retry loses event values |
| Failed removal reader advances cursor | Removal retry loses retained notices |
| Failed publisher commits | Failed-publisher status, values and downstream dispatch differ |
| Removal transport drops notices | Resume-fast removal values disappear |
| Event recovery retains notices in ordinary domain | Retention loses ordinary values; removal peer loses Aux1 notice |

Two earlier proposed mutations survived: the first trace skipped an event
reader with no unread work, and changing activation metadata did not advance an
already active reader. Their full repeated outputs and partial receipts are
retained in `evidence/intermediate25`; they are not passing mutation evidence.
The trace now publishes 5 immediately before skipping the fast reader, and the
failure mutant explicitly updates the real position. An earlier pre-clock
mutation failed to compile because Bend cannot match a computed scrutinee; the
final mutation uses an explicit parameter helper and is reached. A prior C emit
hit the 30-second bound under contention; its bound was not increased.

## Source and ownership

Schedule's original default runner is byte-preserved; the additive
`run_with_skip` consumes/returns its arbitrary affine owner and World, invokes
skip only after a false condition, and retains existing failure/namespace rules.

`reader-domains.drive` is the reusable pre-dispatch seam. It moves event metadata
and arbitrary `H`/World owners through the actual publication synchronization.
The application invokes synchronization before dispatch/skip/frame and after
schedule return, including output from a final deferred barrier. Component and
resource payloads remain arbitrary Type owners; the schema uses actual Arrays.
Temporary moved-out fields use explicit Empty/Occupied affine slots and restore
actual returned registrations, including rejection paths.

Recovery follows the actual source semantics: Event positions are publication
ticks (`since` compares cursor<ticked batch), not offsets into filtered lists.
Event.run synchronizes but does not trim; Event.frame applies retention.
`recover` filters notice-only batches without advancing the dropped boundary,
keeps every actual tick/position, restores ordinary values into held metadata,
and appends fresh removal records to the independent removal log. Mixed-reader
failure, retry, own publication, peer skip and capacity retention test this
interaction rather than relying only on an ordering-specific publisher fixture.

This remains a closed setup/consumer transport seam. It does not establish
universal registration authority, runtime refinement, physical allocation
behavior or production API approval.

## Reproduction and bounds

Run `python3 experiments/public-schedule-readers/run.py`. The final run used
`taskset -c11` after a 0.5-second `/proc/stat` sample observed that CPU idle.
CPU pinning was infrastructure recovery; no performance cohort or profiling was
run. Limits are checker 5 / emit 30 / approved private Clang19 compilation 120 /
runtime 5 seconds, with owned process-group timeout cleanup.

The receipt binds 40 imported/local executable inputs, the actual 33-file TS
source inventory, 70 installed Base files, relevant package/config inputs,
compiler/Node/Python/Clang bytes, complete staged inventories, explicit foreign
input and intended before/after mutation hashes. Guards run before and after
each command; runtime-generated input artifacts are also hashed. All inputs
remained unchanged. Read-only reference HEADs match the tracked manifest:
bevy-ts 3040a3b2a3f28fa8554d856f9ccb6bf5433fa334,
Bevy ad678262ce53b5d142fe49ee5e08caff6f00ab60 and
Bend2 a950fd683c0d76f09794078e6174fe98a1492876.

Performance/scaling qualification, full connected public-core coverage and
universal runtime refinement remain open. This task supplies finite executable
observations and source-current type/ownership controls only.
