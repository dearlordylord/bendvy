# Lifecycle maintenance and actual-owner law subjects

The production successor separates internal pair execution from public App
maintenance. Single App maintains after Sys.Executed, including returned body
errors. Refusal retains its actual World/system. A direct public pair maintains
after Finished, including valid both-disabled execution; AdmissionRefused retains
the actual returned owners/completions and any invoked sibling's effects. Internal
scheduled groups use kernel_when and never maintain. A scheduled outer Finished
can maintain after continuing past a refused leaf. Outer Stopped/Invalid do not.
RootApp maintains after its selected final-deferred policy.

Pinned Bevy runs the default schedule before clearing trackers in
[sub_app.rs145–159](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_app/src/sub_app.rs#L145-L159).
Its executor passes returned failure to the handler without a rollback operation
in [single_threaded.rs137–163](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/schedule/executor/single_threaded.rs#L137-L163).
Bend's explicit refusal/Stopped outcomes and exact returned affine owners are
adaptations, not assertions that Rust exposes the same result API.

## Removed test work

At the user's instruction, the nine newly authored post-c911 maintenance test
files were removed: two Python models, two expected-output gold files, the four
solely test Bend core/driver files and the synthetic parallel-systems maintenance
fixture. No more work or launch on those paths is authorized. Historical artifacts
are not active gates, fallbacks or substitutes for Bend laws. Production Bend and
the five previously approved execution laws remain unchanged by this removal.
Integration owns cleanup of earlier authored public Python models and wiring.

## Unapproved actual-owner drafts

New statements are in `test-fixtures/execution-lifecycle-laws/LAWS.bend`. They are
drafts only, without proofs or approval. They quantify actual World, Scope, Local,
Reader and App.State Type owners using erased symbolic equation binders. Erasure
is not permission to duplicate runtime owners. No Data mirror replaces these
subjects. The existing five approved Data laws retain their original scope.

| Draft | Actual subject | Precise limit |
| --- | --- | --- |
| single_run_forwards_executed_result_with_maintenance | Single.run wrapper forwarding an assumed Sys.Executed | Not an admission or kernel owner-preservation theorem. |
| single_run_forwards_refused_result | Single.run wrapper forwarding an assumed exact Sys.Refused | The premise already supplies owner preservation; the conclusion pins wrapper forwarding only. |
| body_error_reassembles_actual_type_owners | Sys.returned with actual Scope and Local | Reassembles those returned owners and captured tick; no claim about arbitrary body writes. |
| finished_maintains_actual_app_state | Maintenance.completed on actual Finished state | Preserves actual owners/guards/handler; caller placement and journal rotation need separate coverage. |
| stopped_preserves_actual_app_state | Maintenance.completed on actual Stopped state | Exact incomplete state/error/history; no claim about host panic cleanup. |
| invalid_preserves_actual_app_state | Maintenance.completed on actual Invalid state | Exact state/reason, without rotation. |
| foreign_reader_preserves_actual_scope_and_reader | Access.read over actual Scope/Reader | Assumes unequal namespaces; exact returned Scope/Reader, not host namespace uniqueness. |
| pair_run_forwards_finished_result_with_maintenance | Pair.run_when wrapper forwarding an assumed kernel Finished | Kernel classification is a premise, not a conclusion. |
| pair_run_forwards_refused_result | Pair.run_when wrapper forwarding an assumed kernel refusal | Preserves effects already supplied by the premise; no kernel refusal or admission theorem. |
| reassembly_preserves_actual_owners_and_authoritative_journal | Actual State.reassemble with Type payload owners | No result premise; admin journal wins over arbitrary worker snapshot. |
| single_foreign_admission_returns_exact_type_owners | Actual Sys.run with foreign owner namespace | Premise is only namespace inequality; exact original World and system are the conclusion. |
| reader_lag_clamp_and_yield_preserve_actual_scope | Actual Access.read over arbitrary Type Scope payloads | Quantified cursor/lag and a retained one-item channel; broader search/retention needs separate laws. |
| foreign_family_entry_retains_world_and_incoming_owner | Actual Publication.entry with foreign family handle | Valid route and namespace inequality; exact World, incoming affine owner and no notice are conclusions. |

These drafts do not yet cover pair kernel gate/admission classification, general
multi-item reader search/retention, accepted command publication, or exactly-once
placement through every scheduled caller. Those need further exact production-
subject laws; convenient Data helper equations would not satisfy the requirement.
No new proof is written until the exact statements and limits are approved.

On the coherent82 candidate, normal Bend statement checking reports exactly
13 unfilled law TODOs, without type/import errors. That establishes statement
wellformedness only: there are no proofs, no kernel-verdict claim and no approval.

## Separate future kernel laws

These subjects are not supplied by the four wrapper-forwarding drafts. They need
their own exact statements and approval; none may assume the kernel result it is
meant to establish.

- The single foreign-admission subject is now drafted as
  `single_foreign_admission_returns_exact_type_owners` above. Its only premise
  is namespace inequality, not an assumed Sys.run outcome. The corresponding
  pair subjects below remain future work.
- `pair_admitted_both_disabled_is_finished`: actual `Pair.kernel_when` with both
  gates False, equal actual owner/World namespaces and matching actual
  registration-list metadata. Conclude `Run.Finished{world,left,right,None,None}`
  with exact original Type owners, prior cursors and clock, rather than refusal.
  Do not assume Task.verify or kernel_when returned those values.
- `pair_foreign_admission_returns_exact_refusal`: actual `Pair.kernel_when` with
  both actual owner namespaces foreign to the supplied World. Conclude exact
  `Run.AdmissionRefused{world,left,right,None,None}` without invocation/cursor
  advance or maintenance. This must follow the closed ordinary executor path;
  an arbitrary trusted execute callback cannot be assumed to respect disabled
  gates and cannot justify the statement.
- `pair_partial_refusal_keeps_invoked_sibling_result`: actual closed pair path
  with one refused owner and one admitted enabled owner. Describe the invoked
  body's actual returned Scope/Local/completion and captured tick directly;
  conclude the partial refusal retains that result and the untouched refused
  owner. A premise that already states the final preserved kernel result would
  merely repeat wrapper forwarding and is explicitly insufficient.

None of these would prove host namespace allocation uniqueness, arbitrary raw
constructor confinement, or exception cleanup. Scheduled Finished-with-refused-leaf
rotation remains distinct from direct pair AdmissionRefused forwarding.
