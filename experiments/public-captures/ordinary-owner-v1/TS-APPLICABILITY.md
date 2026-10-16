# Existing TS capture reference applicability

This crosswalk relates the actual TS reference to the first ordinary consumer
`d4afab4d0` and scheduled successor `9c8e6112b`. The [scheduled stock JS/Native
evidence](scheduled-v1/runtime-v1/README.md) separately matches all 6,169
independent oracle bytes. Neither historical Bend research nor this crosswalk
alone qualifies the new ordinary API.

The actual reference is [reference.mjs](../reference.mjs), retained by
[reference-001/receipt.json](../evidence/reference-001/receipt.json):
`PREFLIGHT_PASS`, Node 24.20.0, CPU 6, cap 5, exit 0 and empty stderr. Its complete
2,622-byte [stdout](../evidence/reference-001/ts-capture-observations.stdout)
equals the preauthored [expected.stdout](../expected.stdout).

| Input/evidence | SHA-256 |
| --- | --- |
| Reference source | `f6fc7a92bdabb8144602e7cb69d35a7c7912227f204af164a46fb91dcdf9ff13` |
| Receipt | `f61f0ad5ed6cceeb2a2e897755c494c548a5bf686058a617e87c9d8381b584af` |
| Complete stdout/oracle | `17752376a322e5283a17a99add4d606b613d0f54c1f397cd5d8b7f3c85400c1e` |
| Reference manifest | `5d4d89ca984a2eb21e21715344219bb9caa022b6bebca0c9f8959584cceb8b8f` |

The prior read-only audit verified every receipt file pin and exact 33-file TS
core membership at bevy-ts `3040a3b2a3f28fa8554d856f9ccb6bf5433fa334`.
That audit is reused here, not repeated. [run-reference.py](../run-reference.py)
is the existing runner; no new execution or runner is introduced.

## Shared operations and boundaries

The TS reference retains sixteen full observations: eight in each of two nominal
schemas, two separate closures with two host Arrays each, and two actual runtimes.

| TS operation | Ordinary Bend source correspondence |
| --- | --- |
| `initial`, `a-success` | First fixture `registered`/`first`; successor `registered`/`scheduled-success`: two complete array owners and committed resource update. |
| `a-repeat` | Same instance retains both arrays across calls; successor repeats the first owner through failure/retry and the second through `second-repeat`. TS does not have a second-instance repeat checkpoint. |
| `a-skipped` through actual `Schedule.when` | First fixture directly calls `Capture.skip`; successor `scheduled-skip` reaches actual `Sch.run_with_skip` → `Skipped` → `Capture.skip`, with no gameplay or capture/resource change. |
| `a-failed`, `a-retry` | Both arrays retain entered-call mutations on failure while the ECS resource write rolls back; the same returned owner runs again. Successor reaches actual schedule failure/retry. |
| `b-independent` | Separately authored second owner has independent arrays; Bend executes it before first-owner failure, unlike TS. |

These are behavioral correspondences, not complete output equality. TS seeds are
A `[11,12]`/`[21,22]`, B `[101,102]`/`[201,202]`, with fixed increments 1/10 and
Ledger increment 1. Bend seeds are 1/2/3/4 and 100/101/102/103; arguments select
deltas 1/10/2-failure/3-retry, plus 20 for scheduled second repeat. Bend updates
its second array by 10×delta. Both full outputs must remain intact; no common
wire, normalized World identity or missing TS observations are invented.

## Nonshared authority and unregister

TS `same-definition-other-runtime` enters the same JS closure in another runtime,
sharing its host arrays while keeping that runtime's Ledger independent. This is
not Bend's registered-instance authority: foreign run/unregister must refuse.
Successor `9c8e6112b` supplies a real foreign registration with colliding ID, name
and access, then observes refusal, original owners and final recovered packs.
Both stock backends now match the complete independent scheduled oracle; the
retained evidence includes these refusal and owner-recovery observations.

Pinned TS has no public unregister/removeSystem API. The custom `dispose` in
[public-local-owner/reference.mjs](../../public-local-owner/reference.mjs) deletes
an adapter-owned Map entry; it is not upstream TS unregister evidence. Bevy
`ad678262ce53b5d142fe49ee5e08caff6f00ab60`,
`crates/bevy_ecs/src/system/system_registry.rs:531–555`, governs removal returning
the actual system, invalidating its old ID and obtaining a new ID on registration.
The first Bend fixture recovers/re-registers its pack; the successor recovers both
local packs and the foreign twin. Those require their independent Bend oracles,
not a fabricated TS policy wrapper.

Reuse the actual TS reference for the shared mechanisms above. Exact numeric or
full-trace pairing is not established. The older `s-capture` 39-line reference has
a scalar lexical capture and component Array, not two captured Arrays; its Bend
prototype does not qualify these new API paths. Authority controls and the
reached unregister-removal omission are established by their separate Bend
evidence, not by this TS crosswalk. Full #50 still requires the ordinary
component-query capture entry and its qualification.
