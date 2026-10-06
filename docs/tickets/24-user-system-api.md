# S-USER-API — independently authored ECS systems and typed component families

GitHub #26; first step is interface design and independent review.

Follow-up to blind consumer audit #25; full-core #1 and callback integration
#24 remain binding. Optimization is paused while the application boundary is
made usable. This ticket approves investigation and interface design, not a
production representation, new law/proof or weakened performance requirement.

## Confirmed missing seams

The audited source supports generic payload-reading queries and affine command
operations. Its schedule registrar takes an engine-authored BodyKind enum; it
does not register a caller-authored gameplay function. Its generic world exposes
two affine payload slots plus one Data flag, not a caller-defined component family
with independently selectable/mutable membership and declared capabilities.
Packing components into a payload may be a physical representation, but it is
not a complete public component-family interface. These are missing capability
gates; the audit does not establish that previous changes caused regressions.

## First bounded design gate

Design and independently review the smallest explicit typed schema and system
registration seam that supports the original simulation contract. Reuse closed
template/rank2 abstract providers; preserve proper Bend affine ownership and
repeatability without duplicating Type closures or exposing storage. Explain
which owner moves where and which declarations grant each capability. No schema
DSL, runtime reflection, plugin system or new dependency is required. Keep API
contract distinct from physical representation and existing concrete fast paths.

## Implementation return conditions after design review

1. A fresh external consumer authors and registers movement and damage callbacks
   without modifying library modules, adding engine BodyKind variants, manually
   building journals/caches or copying built-in gameplay bodies.
2. One caller-defined world has independent Position, Velocity, Health and optional
   Armor/tag membership. Demonstrate at least three independently accessible
   affine Type component families; retain an actual owned Array payload. Data
   components remain allowed; there is no Data-only restriction.
3. Run finite fixed ticks through create/spawn, read/write/filter/optional query,
   resource access, insert/remove/despawn and explicit deferred barrier, hit/death
   publication and read-only observation. Freeze expected external checkpoints
   before implementation and compare with actual pinned bevy-ts.
4. Preserve transaction read-your-writes, own-system rollback, earlier commits,
   queue/publication boundaries and same-instance retry. Re-test undeclared
   access, actual public writes-through-read, cross-schema use, foreign handle
   MissingEntity with unchanged queue, duplicate owners and reconstruction.
   Negatives need compiling positive controls and intended rejection/detection.
5. Integrate fresh connected gates on exact source, including confinement and
   registration/capture repeatability. Then run a reviewed bounded performance
   regression check; mandatory JS/TS<=1 and Native/TS<=0.5/full5×3 remain open
   until complete qualification. Do not infer speed or authority from API traces.
6. Return to a fresh blind consumer on the reviewed public package, then plan the
   isolated Tower Defense copy only when its actual prerequisites pass. Never
   edit `/workspace/typescript/jev`.

New ECS laws and dependencies require their existing approval gates. Default
checker5s and unchanged kernel remain. No production adoption or universal
runtime refinement follows from this design ticket or its finite application.
