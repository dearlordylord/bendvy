# Execution replacement law candidates

These five approved subjects describe existing pure functions in the replacement
executor. All five exact equations pass the pinned compiler and matching BendTT
kernel through `PROOF.bend --verdict`. All five compiling planted defects also
fail the corresponding isolated proofs, with passing actual-source controls.
The source basis is integration commit `552f90a23283ae879d3908e9f473ba82ad368eee`.
[Issue #77](https://github.com/dearlordylord/bendvy/issues/77) supplies the
nontransactional execution decisions. [Issue #79](https://github.com/dearlordylord/bendvy/issues/79)
owns the scheduler behavior covered here.

The [exact statements](../../test-fixtures/execution-laws/LAWS.bend) quantify
reusable `Data` state. They do not quantify an arbitrary affine `Type` World.
The functions return the supplied state or the state returned by the handler;
a handler remains free to transform that state deliberately.

## Exact approved subjects

| Candidate | Exact behavior and domain | Excluded claim |
| --- | --- | --- |
| `rejected_plan_state` | For every `Data` state, requirement, error and output type, callback set, state and rejection reason, actual `Exec.run` on `Plan.Rejected` returns exactly `Exec.Invalid{state,reason}`. | This does not establish valid plan construction, actual affine owner identity, or IO effects. |
| `body_error_continuation` | For the same types, every handler, continuation, returned state, error, output, node ID and existing observation list, actual `Exec.invoked` on `BodyError` calls the handler on that returned state. It appends the exact `BodyFailed` observation, preserving all previous observations, error and output. `Continue` passes the handler's returned state to the continuation; `Escalate` returns `Stopped` with that state and exact history. | It does not forbid deliberate handler mutation, characterize fatal runtime exits, or prove the complete scheduler's dispatch wiring. |
| `disabled_condition_state` | For every callback set, continuation, returned state, node ID and history, actual `Exec.conditioned` on `Disabled` continues with that state and appends one exact `Skipped` observation. Neither dispatch nor the handler contributes to this result. | It does not decide what effects the condition performed before returning that state. |
| `condition_error_continuation` | For every callback set, continuation, returned state, error, node ID and history, actual `Exec.conditioned` on `ConditionError` applies the same handler policy and appends the exact `ConditionFailed` observation. It does not dispatch that body. | It does not equate a condition error with disabled execution or admission refusal. |
| `ready_exact` | For every requirement type, raw pending-node list and edge list, actual `Plan.ready` returns exactly the pending nodes, in their supplied order and multiplicity, for which every incoming edge's predecessor ID is absent from pending. Node requirements are retained exactly. | This does not validate IDs or edges, impose a worker order, detect access conflicts, or establish runtime concurrency. Unknown predecessors count as absent in this raw helper; valid-plan checks remain separate. |

These equations have no Boolean premise. The ready-set specification scans every
incoming edge for absence from pending. It never calls production `has`,
`predecessor_pending`, `ready_scan`, `ready_member`, or `ready`.
The handler specification matches only the actual `Handling` result constructors;
it never calls production `handled`, `invoked`, or `conditioned`.

Completion is represented by removal from pending. A failed, skipped or refused
predecessor therefore cannot remain an implicit success gate after completion.
The candidate does not establish that the runtime records each completion
correctly. That wiring needs its own public observations and any later exact
whole-run subject.

## Falsification and proof sketches

The [fixture results](../../test-fixtures/execution-laws/CHECKS.md) record 324
literal transition instances and 374 literal ready-set instances. All 698
instances pass the existing pinned source checker. Five source-compiling
planted defects fail at their named equality instance, while the same five
instances pass against the actual implementation. Literal equality checks are
finite falsification evidence, even when the checker prints `ALL PROOFS CHECK`.
No universal proof follows from that literal-check message. The separate
`PROOF.bend --verdict` gate proves exactly the five approved equations, relative
to their imported definitions and recorded compiler/kernel closures.

The transition instances cover empty and nonempty prior history, zero and
nonzero states and errors, unchanged and changed output, and handlers that
change state before either continuing or escalating. The ready-set instances
cover every subset of three node IDs against zero, one or two distinct directed
edges, including self-edges. Additional cases cover reordered nodes, duplicate
node IDs, duplicate edges and unknown predecessor IDs.

The first four proofs unfold the selected result constructor. The two handler
laws use a directly proved constructor-split lemma. The ready-set proof uses
structural list and edge induction, explicit membership equalities, and an
eight-case Boolean identity. Every internal helper is proved rather than assumed.
Their role is to discharge the exact approved equations; they add no behavioral
premise or separate public contract. Each isolated approved proof passes against
the actual source and fails against its compiling defect. Four failures name
the law's own proof definition. The ready-set failure names `keep_actual`, a
helper inside that proof section. The complete source, expected locations and
diagnostic hashes are in `PROOF-CONTROLS.json`.

The coordinator obtained a blind back-translation at
`/home/node/.claude/orchestrate/bendvy-gh78-94/reviews/laws-blind/translation.md`.
It identifies the Data-only scope, raw-list domain, handler and continuation
freedom, and missing whole-run and affine refinement guarantees.

## Historical obligations

The [existing law reconciliation](../parity/laws.md) remains authoritative about
approval. No historical approval transfers to these new subjects.

| Earlier subject | Replacement disposition |
| --- | --- |
| Approved `lookup_full_exact`, `query_any_complete_ordered`, `query_present_complete_ordered`, `query_absent_complete_ordered` | Preserve their frozen Nat model proofs. They do not prove the new chunk representation, generic payloads, or parallel query call path. |
| Approved `explicit_flush_independent` | Preserve the explicit-flush model theorem. It does not establish new dependency synchronization or ordinary final deferred application. |
| Approved `schedule_execution_exact` and `owned_runtime_schedule_correspondence` | Preserve exact historical subjects. Their primitive schedule has no implicit final flush and their owned observation covers element zero. They cannot be used as replacement-executor acceptance. |
| Approved `u32_increment_no_wrap` and `u32_comparison_agrees_nat` | Reuse only unchanged arithmetic statements within their exact original bounds. They do not prove allocator or executor ownership behavior. |
| Unapproved `full_key_equality` | Retain as an unchanged independently stated helper candidate if its exact source binding still matches. It remains unapproved and is unrelated to the new executor proof. |
| Unapproved selected-reader completion and stream completion subjects | Preserve historical candidate bytes and evidence. Do not promote failure-preserved cursors into new Bevy-style reader behavior without the source-backed #84 decision and exact replacement subject. |
| Unapproved change-clock `logical_progress`, `bounded_age`, `equal_not_new`, `absent_not_added` | The intended arithmetic and explicit-absence decisions remain relevant. Reconcile exact source hashes before reuse; neither #77 nor this proposal approves them. |
| Historical rollback, failure-prefix, and no-final-flush expectations | Retire their use as ordinary execution requirements under #77. Keep historical proof and execution evidence under its original source and contract. |

Partition and reassembly, actual affine owner return, declaration confinement,
serial and parallel observation agreement, reader completion, deferred
visibility, and pending-work save behavior remain separate requirements of
#78 through #94. This candidate set does not replace those requirements with a
Data-state model. Their exact executable subjects depend on the completed public
APIs and representations.

## Exact approval and Bevy source comments

The user answered the coordinator's async request with the exact text
"Approve the five exact candidates for proof". The approval refers to commit
`c055aef5064d32c4aff351a9e583da1ebb320407` and its `SUBJECTS.json` bindings.
The subsequent request for a Russian explanation did not revoke that approval.
The request presented these limits:

> Approve the five exact subjects in `test-fixtures/execution-laws/LAWS.bend`
> together with its `spec.bend` at the hashes in `SUBJECTS.json`, for later proof.
> They require rejected plans to retain state and reason, returned body and
> condition errors to use the returned state and handler policy, false conditions
> to skip dispatch without rewinding state, and ready nodes to depend on pending
> predecessors rather than predecessor success. A handler may halt later serial
> work through escalation, while retaining its returned state and prior history.
> These subjects cover reusable Data and the named executable helper functions.
> They do not approve a generic affine World proof, shared-access purity, native
> concurrency, every exceptional exit, or the remaining #78–94 law subjects.

The user then asked for comments referencing Bevy code and behavior. Each law
now links to actual source at Bevy commit
`ad678262ce53b5d142fe49ee5e08caff6f00ab60`, verified in the read-only reference.
The comments separate source-backed execution behavior from Bend-specific
state return, observation lists and pending-list representation. They do not
claim that Bevy proves these exact helper equations.

Only comments changed in `LAWS.bend`; its equations and imports match the approved
revision after comment and blank-line removal. `spec.bend` is byte-identical.
`SUBJECTS.json` retains the original approval hash and records the comment-only
successor hash. Approval does not extend to the remaining full executor laws.

## Proof tool binding

The complete proof passes `--verdict` with the originally recorded compiler and
installed resource closure, including Base SHA-256
`3cd0b0944b11e15c4da5c9af2560e3c04f27d3d37027f1617899aeec17b499ce`.
It also passes the preserved matching 2.0.35 resource bundle, whose 70 files were
verified against its existing `BUNDLE-PROOF.json`. Both use the same compiler
bytes, SHA-256 `f77417474ded314ad5d1a68fa3ebbe214c2124bf04d56a59b05bc17be6b0327a`.
Each closure's kernel executable and source hash is recorded in `SUBJECTS.json`.
Setting `BENDTT=/usr/bin/false` makes each verdict fail, confirming the kernel
participates.

The first attempt with the original resource closure exceeded the 15-second
limit while building its uncached kernel. It was not counted as a proof result.
The existing kernel source was then built using the already-installed Lean
toolchain, and the subsequent proof verdict passed within the unchanged limit.
No compiler patch, new dependency, native runtime concurrency test, or performance
claim is part of this proof delivery.
