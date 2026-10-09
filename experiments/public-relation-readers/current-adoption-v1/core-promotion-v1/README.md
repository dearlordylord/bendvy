# #43 core integration handoff

The eight proposed modules are now implemented in the root-owned integration checkout at `35e60a4c` and consumed by the complete ordinary application. Source-current finite positive/reached-mutant JS+Native evidence is `d0654a54`; fullcapacity Native/copied-printer JS evidence is `e8c92478`. Root integrated the evidence through `a09c0bfd`. These are development semantics, not public delivery.

`DELIVERY-READINESS.json` records the concrete next promotion: the same eight files from `promotion.patch`, with exact hashes. All 18 existing core dependencies still match current master `d729ffe2`; read-only `git apply --check` passes there and all eight targets remain absent. Root is the sole `src/ecs` integrator. No ninth core module or contract change is required by the demonstrated behavior.

| Qualified implementation | Core placement |
| --- | --- |
| queue, domains, readings, routing | `src/ecs/internal/relation-failures/` |
| barrier | same internal directory; actual World clock advances once per barrier |
| canonical v14 runtime | `src/ecs/relation-failure-runtime.bend` |
| ordinary reader declaration | `src/ecs/relation-failure-reader.bend` |
| owned disposal | `src/ecs/relation-failure-disposal.bend` |

The ordinary declaration retains the same `G.Descriptor<S>` used by mutation; key/name derive registration domains and diagnostic access strings. `register`, `run`, `skip`, `with_world`, `barrier`, `frame` and `dispose` preserve Registry, world and arbitrary Type component/resource/argument/output owners. Logs contain Data notices; this does not promote #53 arbitrary-Type event storage. Disposal removes memberships only after successful canonical `Sy.dispose`; refusal returns runtime and reader. No activation, capacity, validation, cleanup or error policy changes.

## Actual public observation route

An ordinary reader receives `K.Input{readings,args}` after `K.run_identified` calls `Read.all` on its registered descriptor keys and position. Each exposed `Read.KeyReading<S,E>` has exactly `key`, `values:List<E>` and `lagged`; ordinary gameplay can pattern-match these returned Data fields. Reading them requires neither reflection, a second registry, a JSON adapter nor the compiler's automatic display printer.

The consuming provider in `consumer-v1/provider.bend` demonstrates the existing core `Cap.ValueRead` route: it retains World plus arbitrary Type arguments in a private context; universally abstract gameplay receives only that closed read capability. Retry, lifecycle and mixed readers actually call it. Source controls reject a missing second capability slot, cross-schema output, write-through-read and duplicate abstract owner. Descriptor filtering belongs to the actual runtime. Diagnostic access strings do not enforce authority, and an arbitrary trusted provider is not proved pure by opaque `H`.

Keep this trusted application adapter, fixture schemas/classifiers, gameplay bodies, DTOs, observers, collectors and oracles in experiments. The obsolete phantom `ReadGrant` and pre-v14 runtime are excluded. Existing canonical capabilities suffice; promoting the fixture-specific provider would unnecessarily expose its context representation.

Automatic display of the entire large returned Data term is a separate unresolved **installed JS output path**: the original recursive printer fails after application completion; the exact copied iterative printer succeeds. The fullcapacity application still emits and checks every field—244,722,906 bytes with the new nominal paths—rather than using a checksum or truncated report. Programmatic `KeyReading` access is demonstrated, but it does not waive that full-output acceptance gate or turn copied-printer evidence into installed-printer evidence. Keep the limitation owned by #43; no dependency, new serializer contract or compiler replacement is selected here.

## Current acceptance and exact next action

| Requirement | Source-current evidence | Remaining gate |
| --- | --- | --- |
| Ordered failures/retry/skip/lag/disposal/barrier, actual schedule, mixed event/removal cursors and full affine owners | Six promoted JS/Native cohorts `d0654a54`; whole positive `1cf4…`, countermodels `6b97…`/`4fd1…` and complete positive rejection; 102 lossless members/51 guards | Public delivery binding after master promotion; historical source namespaces remain immutable |
| Foreign MissingEntity/unchanged queue; two nominal schemas; actual capability controls | Complete migrated consumer, source5 intended refusals and closed provider | Preserve source-current authority binding; no independent-factory-root universality claim (#38) |
| 65,537 missing-target + self command / 65,536 retention per schema | Promoted unpatched Native and copied-printer JS `e8c92478`; entire nested `bda9…`, 244,722,906-byte output `aab843…`, byte-identical independent synthetic; 35 lossless members/17 guards | Installed JS full-output path remains unqualified |
| Pinned TS shared scenarios | `f358a5f1`: all 52 observations, complete 46,244,319-byte independent `5217231a…` oracle | Retain explicit comparison mapping; TS does not supply Bend physical front/back queues, affine proof or invented foreign/disposal APIs |
| Default regression | No new measurement claimed | Root runs unchanged #28 paired Workshop gate on the complete integrated root; baseline `327bec49`, workload, balanced pairs/statistics and zero-allowance policy unchanged |
| Feature performance | Semantic/fullcount receipts contain no comparative timing claim | Equivalent complete TS/JS/Native timing/scaling under #21/#23/#24; defer comparisons under contention |
| Completion | Eight modules staged and reviewed; master targets still absent at the recorded pin | Final independent Spec/Standards delivery review, verified master push and English #43 report before closure; update #61 actual public inventory |

Root's next code action is to apply the existing eight-file patch, preserving the 18 matching dependencies and unrelated work. Rebase the consuming imports and source-derived nominal inventory consistently to master; retain original qualified cohorts and record the path-only join, without rebinding historical raw to new module identities. Prepare only the source-current delivery checks demanded by that join and the unchanged #28 gate for independent admission. Do not repeat already qualified integration-checkout cohorts or introduce a new runner family.

Reference priority remains Rust Bevy architecture, Bend types/runtime, then pinned bevy-ts feature inventory. Exact source commits are in `DELIVERY-READINESS.json` and `.references/sources.json`. Finite controls are not universal proofs; #43 remains open and no laws, dependencies or numerical tolerances are changed.
