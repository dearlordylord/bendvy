# Ordinary App entry qualification

This fixture checks the derived ordinary App entry for [#73](https://github.com/dearlordylord/bendvy/issues/73). The public [ordinary App guide](../../../docs/reference/ordinary-app.md) describes the API. This directory contains the source-informed consumers and their retained evidence.

`Component.add`, `Service.add`, and `LocalFields.add` derive execution recipes beside the existing registered App. `Entry.attach` validates actual identities and constructs the owned schedule. `Entry.run` delegates to the existing ordinary execution and debug path. The consumer supplies no dispatcher, numeric-ID plan, cursor adapter, or availability metadata.

## Reproduce a consumer

Use the existing example tools and shared backend lock:

```sh
BENDVY_EXAMPLE_CPU=11 BENDVY_EXAMPLE_NATIVE=1 bash experiments/public-api-usability/health-v2/check.sh normal
```

The same script accepts `other`, `missing`, `local`, `foreign`, `failure`, `repair`, and `type`. It uses unchanged 30-second emission, 120-second Native `-O3` build, and 5-second consumer limits. Set `BEND`, `NODE`, and `CLANG` as documented by the examples. The private Clang wrapper also needs its existing `BENDVY_CLANG19_ROOT` environment value.

`verify.py` compares the complete output to independently authored arithmetic and control expectations. Root-authored expected files are unchanged by subject execution.

## Qualified behavior

| Consumer | Complete expected bytes | Observation |
| --- | --- | --- |
| `normal` | 262 | Health query followed by a separately observed affine service counter, including the empty pre-barrier query |
| `other` | 262 | Same ordinary heterogeneous route with a distinct nominal schema |
| `missing` | 63 | Missing canonical service rejects before the queued barrier, preserving pending count 3 and query cursor 0 |
| `local` | 59 | Actual Array capture persists through failure and same-App retry while the resource rolls back then commits |
| `foreign` | 101 | Two actual World creations produce namespaces 1 and 2; new attachment rejects the foreign World and retains both cursors and counter |
| `failure` | 58 | Query writes then fails; Health and cursor roll back, the next service does not run, and the excluded entity remains 30 |
| `repair` | 101 | Repair only the missing service slot, then retry the same returned App with the same registration and an advanced cursor |
| `type` | 34 | Arbitrary Type Array component, first committed replacement and second failed write rollback; complete JS and Native comparisons |

All eight consumers have complete JS and Native comparisons under the stated limits. Their `results-*-pair` directories retain outputs, logs, generated artifacts, exact source bindings, and the root's independent comparisons. The second schema is in `results-second-pair`. These are finite checks, not universal refinements or performance measurements.

Two first formatting attempts were rejected by their independent oracles. Repair initially printed `True` instead of `true`; the Type witness initially printed an extra final LF. `results-repair-attempt01` and `results-type-attempt01` preserve those attempts, including the unexecuted Native status. Their successor freezes preserve the original wire.

## Authority and reached execution

`AUTHORITY-RESULTS.json` binds five intended source refusals to their actual diagnostics: nominal App mismatch, affine App duplication, abstract-owner escape, write through read, and undeclared component access. They fail at the intended type boundaries, not at missing imports or parsing.

The separate dispatch mutant skips the new component execution adapter while retaining the actual invocation and context. Its JS child completes with empty stderr, all Health values stay 10 and 20, and the service still counts 1 through 7. The unchanged complete normal oracle rejects that 219-byte output. `results-dispatch-mutant` retains this reached-callsite evidence. The ordinary core does not contain the mutation.

Historical source freezes remain exact. `SOURCE-APPLICABILITY.json` records removal of three unused example imports, with all remaining source bytes unchanged. Current consumers therefore no longer import the example that is being migrated.

Scheduled Local arguments are repeatable Data. Local capture and output remain Type; output dropping follows the existing scheduled Local policy. Component row outputs retain only the latest Data list. No general host IO, cleanup policy, timing improvement, or bounded-memory claim is added.

## Delivery evidence

The migrated scheduled-health example passes both backends against its unchanged 192-byte oracle. Independent final Spec/Standards review passed candidate `2a1ce30ba`, including all eight scenario pairs, 137 retained artifact joins and five intended authority refusals.

The [fresh blind audit](../../../audits/blind-user-73/FINDINGS.md) independently authored a two-system consumer from public APIs, Bevy and Bend sources, without reading these fixtures or optimization history. Its complete 48-byte arithmetic oracle passes JS and Native. The guide now addresses its setup, callback syntax and World/handle findings. Explicit Bend type aliases remain visible; this does not claim TypeScript-style type inference.

[Combined regression evidence](results-regression28/receipt.json) records 123 successful commands and 110 complete protected Workshop outputs. Twenty adjacent pairs per backend yielded `NO_CONFIRMED_REGRESSION` (JS p=0.5881, Native p=0.8684). The archive retains 908 source/output/artifact members. External CPU contention was present; this bounded whole-process gate does not qualify full-parity performance.

Core and example integration `2a1ce30ba` passed both [CI jobs](https://github.com/dearlordylord/bendvy/actions/runs/39079114169). Subsequent audit, documentation and evidence commits leave core bytes unchanged. Wider parity/performance and pending law approval remain under their existing issues.
