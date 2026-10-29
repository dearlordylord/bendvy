# Replacement execution API

Start with the [current source map](../../docs/reference/execution-api.md) and
[Scheduled health](../../examples/scheduled-health/README.md). The
[SPEC replacement amendment](../../docs/SPEC.md#ordinary-execution-replacement-user-amendment-2026-10-26-utc)
defines ordinary execution.

Compiled declarations supply both the operational capabilities and planning
metadata. The ordinary entry retains actual affine system, condition, handler,
resource, component, and command owners. Returned body errors preserve performed
writes and authored commands under the selected error-handler policy. They do
not imply rollback or cancellation of independent work.

Raw World constructors, storage lenses, and arbitrary owner-transforming callbacks
are trusted setup. System bodies receive the abstract capabilities produced by
their declarations. Affine typing prevents duplication but does not itself prove
that a returned owner is the original owner or that cleanup ran exactly once.

The five [approved executable helper laws](../../docs/design/execution-law-candidates.md)
cover reusable Data and named pure executor helpers. They do not prove arbitrary
affine World preservation, complete schedule execution, or native concurrency.
Other draft laws retain their separate approval status.

The old API guide and transactional executor are preserved at
[`1037bab017fcc8037c518fa5d89dfa0c28e9ee30`](https://github.com/dearlordylord/bendvy/blob/1037bab017fcc8037c518fa5d89dfa0c28e9ee30/src/ecs/README.md).
Historical observations retain that source's original contract. The explicit
application-owned recovery used by the migrated AppA is separate from ordinary
execution and remains available through `execution-recoverable-component.bend`.
`Feature` (`feature.bend`) assembles retained replacement execution nodes with
`from_facts` and `pair`. Their accepted compilations supply schema requirements,
registration facts and nested scope members. `lower` validates selected names,
dependencies, fragment collisions and nested edges before execution. `run`
returns the original root and provisions on refusal; otherwise it invokes the
actual Taskful root and returns its report. Thread that returned owner into the
next run. The ordinary consumer is `examples/parallel-composition`.
`FeatureProvision.bind_feature` (`feature-provision.bend`) checks declared needs
against the feature's own fragment and dependency closure; identical descriptor
entries collapse for grants, while conflicts remain errors. Raw metadata,
assemblies and closed declarations are trusted authoring operations. The former
Feature schedule builder and its failure-prefix Schedule/System executor are
removed from package source. Historical builders replay with their original
library in the [historical source checkout](../../test-fixtures/HISTORICAL.md).
