# Remaining marker and initialization gates

This private candidate represents global marker sequencing only. SPEC.md establishes Bevy first, Bend second and historical TypeScript third. Pinned Bevy commit `ad678262ce53b5d142fe49ee5e08caff6f00ab60` supplies the phase ordering: `crates/bevy_state/src/state/transitions.rs:217` chains dependent transitions, exit, transition and enter; `state/freely_mutable_state.rs:20` schedules state application in the dependent-transition phase. `phases.bend` composes those four groups after one supplied structural flush, preserving arbitrary affine world and callback owners.

The ordinary registered consumer reaches actual public machine operations for two machines. It freezes and consumes both initial queues before applying either; all applications precede all hook groups. Hook-created queues survive into the next marker. Its three complete observations retain physical arrays, registry ownership/cursor, complete events, snapshots, pending command count and both machine slots. Initial current/previous/changed values are explicit fixture history, not a provisioning policy.

| Gate | Governing source or decision | Next action |
| --- | --- | --- |
| Global phase composition | Pinned Bevy transitions.rs:217 and existing machines parity acceptance | Qualify this private additive primitive; root decides public integration after review. |
| Queues created during a marker survive until its next execution | docs/parity/machines.md acceptance; captured initial cohort | Consumer covers queues created by hook groups. Nonempty pending restoration during the application group remains an unqualified branch. |
| Existing handler failure behavior | docs/parity/handlers.md requires exit/transition failure to keep old state and retry; enter failure follows commit | Preserve existing prepare/commit. Global composition alone does not reconcile this failure contract with apply-before-hooks; no lifecycle migration is proposed. |
| Conditional-equal transition messages and changed bookkeeping | Pinned Bevy transitions.rs:152 and freely_mutable_state.rs:49; current Bend apply_present has differences | Separate concrete implementation audit is required; this consumer applies unequal values only and approves no divergence. |
| Initial entry message and initial changed/previous adaptation | Pinned Bevy app.rs:96; existing selected-initial provisioning qualification is narrower | Specify the existing approved Bend adaptation before modifying initialization; do not choose duplicate provisioning or initial-message policies here. |
| Ordinary schedule installation | Current public operations supplies authority, not a complete automatic scheduler | Integrate reviewed composition through an actual ordinary schedule while preserving the existing declaration boundary. |

Historical snapshot/application behavior is evidence about code, not a separate approved observable contract. The private cohort adapter delegates current-state, previous-state, changed and publication decisions to existing machine application; it introduces no equality law or initialization rule. Full #48 acceptance remains open.
