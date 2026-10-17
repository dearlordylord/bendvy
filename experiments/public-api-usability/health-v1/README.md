# Registered ECS and App usability check

A bounded implementation/API investigation, not a blind audit or a replacement
App API. No `src/ecs` files are changed. The shared example infrastructure is
already checked by CI; this separate prototype campaign is explicitly invoked.

```sh
BENDVY_EXAMPLE_NATIVE=1 bash experiments/public-api-usability/health-v1/check.sh
```

Select installed binaries with `BEND`, `NODE`, `CLANG`. The private workspace
Clang wrapper additionally needs `BENDVY_CLANG19_ROOT`. The script uses the same
shared backend lock, five-second source/runtime, 30-second emission and
120-second Native build bounds. Generated artifacts stay in ignored `build/`.

## Compared paths

| Path | What actually executes |
| --- | --- |
| `examples/scheduled-health` | Ordinary declaration, registered query and direct Schedule |
| `main.bend`, `app-core.bend`, `app-run.bend` | Actual `ordinary-app-component.register`, SchemaApp attachment, ordinary App schedule/provisioning, automatically derived Inspector observations |
| `single-main.bend`, `single-query.bend` | Generic prototype owning one ordinary registration and its generated Schedule/dispatch adapter |
| `other-single-main.bend` | Same helper with another nominal Schema/Store/token/declaration family; shared component payloads, separate schema source |

Every path uses the same actual deferred spawns and decay callback. Two entities
start at Health10/20 with factors0.5/0.25; an entity lacking HealthDecay retains
Health30. The first query runs before the barrier; six ticks follow it.
`verify.py` derives all numerical observations independently. Complete outputs,
including the skipped entity, must agree across paths and backends. App debug
observations are read-only; they do not replace the real update system.

## Findings

- The registered ECS and full ordinary App paths support this scenario without
  adding core functionality. A success here does not prove the whole API.
- `ordinary-app-schedule.run` still takes an explicit typed dispatcher and
  provisioning callback. Merely using SchemaApp does not remove that assembly.
- The generic one-system prototype moves schedule assembly, cursor threading,
  dispatch and result adaptation out of the user simulation. This demonstrates
  that this boilerplate is not inherently required in every Bend application.
  It moves required machinery into a reusable helper; it does not remove that
  machinery or prove that a general heterogeneous helper is ready.
- Explicit affine ownership and erased indices remain language constraints.
  In particular, a wrapper function and an expression returning the exact
  indexed function are not interchangeable at every erased index. The prototype
  needed exact observer/fold function indices and a module split to stay within
  the unchanged development-check limit. This is API/checker usability evidence,
  not proof of a semantic runtime defect or an excuse to raise the limit.
- Typed column projections are needed by the selected custom Store layout.
  Their handwritten form in this example is not proof that declaration-based
  storage generation is impossible. That separate generalization is not built
  or claimed here.

## Boundary checks

`controls.bend` checks ordinary App missing-provisioning refusal before an
explicit barrier: all three commands remain pending and cursor remains0.
The same held App is repaired by attaching its ordinary plan and executes the
complete normal scenario. A failing callback performs the real component write
before returning failure; the returned App still observes Health10/20,
Health30 and cursor0. This is the approved Bend transaction behavior; Rust Bevy
does not promise to undo direct system writes on every returned error.

`foreign.bend` creates two actual same-schema worlds through IO in one process.
A registration from the first is rejected on the second and returned with
cursor0. This executes ordinary registration rejection, not a full foreign-world
SchemaApp campaign. The attempted combined App/IO source check hit the unchanged
five-second bound; the narrower ordinary boundary is reported honestly.

Four source controls must fail with the intended type diagnostic: write through
read, treat opaque H as World, duplicate affine H, and cross-schema handles.
They are finite type witnesses, not universal confinement proofs.

## Limits and next action

The helper supports exactly one registered query system, with Data arguments and
row outputs as required by the existing `ordinary-system` entry. This scenario
uses Data components; arbitrary affine component runtime qualification,
heterogeneous schedules, Local/capture composition, disposal and additional
provisioning are not established for the prototype. No new ownership, cleanup,
exception, numerical or law contract is adopted.

No performance measurement or production-core adoption is claimed. Generalize
only through an explicit owning usability task with normal correctness,
authority, independent review and combined regression requirements. Keep the
existing closed semantic audit #61 distinct from this usability finding.
The separate blind audit remains recorded in the example README.

## Result and owner

All five subjects pass stock JS and Native `-O3`, with identical complete output
per pair; all four intended type refusals are detected. Five output corruptions
are rejected by the independent finite verifier. `RESULTS.json` records the
93-file Bend source closure, unchanged governing core/example bodies at
`795cbd5f5`, tools, limits and output hashes; `evidence/` retains complete output
and source/type-check diagnostics. Generated C/JS/binaries are reproducible local
build artifacts, not a portable accepted production evidence package.

Generalization and adoption are tracked by
[#73](https://github.com/dearlordylord/bendvy/issues/73). This is a usability
follow-up, not a newly proved functional parity failure and not a replacement
for existing performance work. The new primary API must retain the independent
review and combined regression requirements before core adoption.
