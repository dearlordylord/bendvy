# Typed machine provisioning — source candidate

This is an isolated #48 implementation candidate, not core adoption or an approved public initial-provision policy. No generated/runtime output was used, and no backend has run.

`initial.bend` consumes the actual canonical `Machine.Family` and its closed lenses. Its private `install_empty` initializes only an empty typed slot. An occupied slot is put back unchanged and the incoming value is returned explicitly. This is a checked empty-slot primitive, not a decision to reject, overwrite or merge duplicate public provisions. The existing selected initialization (`NoPending`, no previous value, changed=false, no initial transition message) is named `selected_initial`; adapting Rust initial messages/change flags remains pending.

`requirements.bend` provides schema/token-indexed requirements, a stable first-occurrence union, complete missing-token discovery, and preflight that returns the actual arbitrary `Type` world and owner pack on both paths. It captures no reusable affine context and changes no registry, identity, cleanup or disposal policy. Schema-authored inspection/lenses remain trusted declarations; public ADT constructors are not an unforgeability proof.

`declared.bend` derives explicit body/reader requirements and optional condition references separately from the ordinary action list. Conditions are not required merely because they mention a machine. The new scene's optional condition path follows pinned Rust: absent `in_state` and `state_exists` are false; negation and short-circuit OR retain Boolean semantics. The former TS-inspired always-required condition preflight is preserved only in earlier source-check history, not selected as parity authority.

The actual application route preserves its owner-returning refusal seam before `App.named` calls `Provider.frame` or builds/runs a schedule. Required readers/body operations retain the selected fixture's existing broad machine requirements; registration access lists are unchanged. This is not a claim that Rust rejects an entire schedule before frame advancement for missing required system parameters. The generic public adaptation of required-system refusal/skip boundaries remains to be reconciled; the optional-state condition semantics do not require that adaptation.

## Complete consuming subject

`main.bend` creates actual worlds for two nominal schemas with owned component/resource Arrays. It registers hooks and a reader before attempting missing provisioning. Seventeen complete checkpoints per schema retain physical component cells/stamps, resource Arrays, all machine-slot fields, streams and positions, frame/tick/clock, queues, world registrations, actual registry owners/cursors, reader capabilities and application traces:

1. Missing initial slots and a required reader refusal before work.
2. Absent state_exists, true OR missing in_state, and negated missing in_state through actual schedules.
3. Flow-only provision, present state_exists, required Level refusal and a false optional Flow condition with Level still absent.
4. Level provision and successful retry of the same already-registered, previously lazy reader.
5. Actual seed/deferred application, prior queued state, failed publisher rollback, failed reader and successful retry.
6. A private occupied-slot control returns and observes the incoming value while preserving the complete current/pending/previous/changed slot.

`Delivered` returns the actual factory, owners/world and incoming value through the source continuation. Setup alternatives retain the actual returned factory/resource/world and any hook/owner/incoming value still held by this fixture. Final rendering is fixture teardown, not a public disposal/finalizer contract. Existing opaque command values are preserved in the actual world and observed by queue count, as in the original complete observer.

`main-mutant.bend` changes only the reached explicit-required missing branch: it calls `App.named` instead of refusing. It does not change optional condition semantics. Its complete countermodel must be independently authored before execution; source success is not evidence the mutant was reached.

## Source evidence and remaining gates

`final-source-v1` uses pinned Bend 2.0.35 with CPU5, the shared child lock and five-second checks. Initial/requirements/declaration, the full normal and mutant, and a generic arbitrary `Type` C/R consumer pass. Five negatives fail at their intended boundaries: nominal schema, undeclared token, World duplication, registered owner-pack duplication and attempting initialization through a read-only capability. Exact argv, input pins and raw captures are retained. These are source/type checks, not approved proofs or executable qualification.

The twelve reused scene modules and complete owner observer are source-joined. Canonical core imports point to the root integrator's actual modules. Provider changes are limited to optional condition evaluation and state_exists leaves; application changes add those leaves' display names. No old factory source was edited.

Next gates are independent whole normal/countermodels, source/authority review, and an admitted existing JS/Native recipe. Public duplicate initialization, Rust initial messages/change flags, raw invalid values, later-key behavior, identity/capture/finalizer policies and full #48 acceptance remain pending. No numerical policy, dependency or law was added.

## Exact single-machine consumer

`flow-only.bend` registers an actual Sys.Registry from one typed Flow Family declaration. Its requirement union contains Flow only; Level stays absent through all five checkpoints for each nominal schema. The false gate returns the actual world and registry before preflight; the enabled missing case preserves both, and the installed case calls actual run_tracked and observes Boot. `flow-only-source-v1` passed the same source5/CPU5 guard. This is source evidence; execution remains unqualified.

The older main scene intentionally retains its broad registered dispatcher: application.run_body advertises Flow.read/Flow.next/Level.next plus component/resource/commands access regardless of opcode. Its preflight and action_ready remain broad, including Noop. It does not prove minimal opcode-specific access inference. Read/GatedRead retain the older two-reader adapter; a false optional gate is not a new public required-reader scheduling policy. Exact single-machine declaration scope is demonstrated separately by flow-only, not attributed to the broad historical dispatcher.
