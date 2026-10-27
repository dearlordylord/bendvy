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
