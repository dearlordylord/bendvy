# Remaining core parity — draft ticket breakdown

Approved for ticket publication by the user on 2026-10-06: “делайте таски я пре-аппрувлю всё”.
This is the evolving development guideline, not approval of every future law,
dependency, numerical allowance or renewed optimization budget.
Parent: GitHub #1. Tracker: GitHub, triage label `ready-for-agent`.
The current implementation frontier is published below. Later scope remains
explicit in the [parity table](../reference/core-map.md); detailed later tickets
are refined when their capability prerequisites exist. Parent #1 is unchanged.

## Shared delivery contract

Each implementation slice delivers actual public application behavior, complete
observations on JS/Native against observed pinned TS behavior where applicable,
intended access/schema/ownership negatives, and reached compiling semantic mutants.
Preserve arbitrary component families and affine Type ownership; no Data-only
component restriction. Exact laws require falsification and approval before proof.
Dependencies and numerical changes require the existing SPEC approvals.

Run the unchanged #28 frozen Workshop paired regression gate and retain all
measurements. Approved policy is **no statistically confirmed slowdown**, not
an unapproved small percentage allowance. New features have no historical Bend
baseline: freeze equivalent feature work before measuring TS/JS/Native, validate
full outputs and report cost/scaling. Existing JS<=TS and Native<=0.5TS product
qualification remains separate under #21/#23/#24. No favorable informational
process timing, silent baseline advance or reduced work closes those gates.

## Published immediate frontier

Eight tracer bullets incorporate Astra's recommended splits: query cardinality
is separate from storage integration; basic schedule execution is separate from
nested provisioning. Native GitHub blocking links match the table.

| Issue | Blocked by | Complete observable delivery |
| --- | --- | --- |
| [#29](https://github.com/dearlordylord/bendvy/issues/29) — Complete public query cardinality and exact lookup contracts | None; explicit design/policy gates still apply | An application can count matches, require exactly one match, and look up a specific entity through a composed typed query, receiving precise errors without losing its World or component owners. |
| [#30](https://github.com/dearlordylord/bendvy/issues/30) — Execute public Compose queries through optimized owned storage | None; explicit design/policy gates still apply | The existing independently authored Workshop application runs through a selected exact optimized owner/provider route while retaining its general component-family and heterogeneous-query API. |
| [#31](https://github.com/dearlordylord/bendvy/issues/31) — Integrate registered event readers with retention and lag | None; explicit design/policy gates still apply | Two independently registered public systems consume ordered events at different rates with bounded retention, explicit lag and correct successful, skipped and failed-run behavior. |
| [#32](https://github.com/dearlordylord/bendvy/issues/32) — Integrate registered removal and despawn readers | None; explicit design/policy gates still apply | Independent public systems observe removal and despawn records after explicit structural barriers, including slow readers and retries after entity data is no longer queryable. |
| [#33](https://github.com/dearlordylord/bendvy/issues/33) — Execute deterministic public phases and conditional schedules | None; explicit design/policy gates still apply | An application declares a static typed sequence of registered systems, phases, conditions and explicit barriers, and executes it repeatedly in authored order. |
| [#34](https://github.com/dearlordylord/bendvy/issues/34) — Validate nested schedule requirements before public execution | #33 | An application nests typed schedules and phases with declared component/resource/service requirements; all requirements and duplicate rules are checked before any schedule work executes. |
| [#35](https://github.com/dearlordylord/bendvy/issues/35) — Preserve transactional reader visibility across composed schedules | #31, #32, #33 | Repeated conditional public schedules combine event, added/changed and removal readers without conflating their skip, successful-run or failed-retry cursor rules. |
| [#36](https://github.com/dearlordylord/bendvy/issues/36) — Define and execute per-system affine Local ownership | None; explicit design/policy gates still apply | Two independently registered system instances retain isolated affine Local owners across repeated runs, conditional skips, defined failure/retry and disposal. |

Optimized integration #30 may reveal an interface expansion too large for one context. In that case
split additive compatibility expansion, independently green consumer migrations,
and contraction after all migrations; retain executable integration acceptance.
Do not close it with only a feasibility report.

## Retained later implementation frontier

Draft detailed tracer bullets when the stated prerequisite exists. These are
coverage reservations, not agent-ready implementation tickets.

| Capability | Return condition / likely slices |
| --- | --- |
| Schema fragments/features and bundles | Nested provisioning #34 constrains provisioning; compose two independent features, validate dependencies/duplicates, then general typed bundles |
| Relations/inverse consistency | Existing handles/transactions/barriers plus #32; link/unlink and inverse cleanup, then hierarchy/cycle/failure-stream scenarios |
| Lifetime scopes | Defined relation/removal cleanup; group cleanup preserves persistent entities |
| Component states and machines | Schedules #33/#35 and explicit transition contract; queued transitions and next-marker publication, then exit/transition/enter failure slices |
| Validation | Concrete component/resource/state boundaries; malformed input rejects without partial mutation |
| Snapshots/restore | Validation plus supported relations/machines and allocator policy; save fields/omissions first, then restore identity and queues/streams/cursor boundaries |
| Inspector/debug | Concrete event/removal/scheduled readers #31/#32/#35; noninterference and no retention participation, then opt-in diagnostics with overhead |
| Allocator/root authority/capacity | Independent policy/design work can start now; independent/fabricated roots, exhaustion/growth, then restore identity. No unchecked global-uniqueness claim |
| General payload recovery and runtime captures | Local #36 and explicit recoverable interface; broader Type/IO payloads, capture registration/disposal, extensible heterogeneous schedules |
| Query contract completeness | Audit exact pinned count/cardinality/lookup errors against current API; publish a separate bounded behavior ticket if #29 cannot include it without scope growth |
| Proof/refinement | Retain delivered seven exact #18 subjects; draft/falsify and request exact remaining-law approval before proof; current public runtime/backend correspondence remains separate |
| Full performance qualification | Existing #21/#23/#24, not a duplicate umbrella; complete source-current connected gates and five-workload/three-size equivalent qualification |
| Fixed-step simulation | Integrated public spawn/move/damage/removal/hit/death path and its explicit proof/performance gates |
| Copied Tower Defense | Only required application capabilities and integration prerequisites; separate copy, preserve authoritative reducer and canonical jev |

Browser/render adapters, schema generation and parallel/GPU orchestration retain
separate revisit conditions. They are not silently added as core parity blockers.
