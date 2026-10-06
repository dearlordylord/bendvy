# Blind consumer notes

This consumer started from public declarations and pinned Bevy, bevy-ts and
Bend sources. It did not read project optimization reports, benchmarks,
existing gameplay example bodies, earlier API audits or Git history.

The intended application is a small arena simulation. Position, Velocity and
Health are distinct `Type` component owners, each containing an actual
`Array<U32>`. Armor is optional. Movement requires Position and Velocity;
damage requires Health and optionally reads Armor. Two closed gameplay
callbacks should receive abstract provider types and explicitly thread their
affine context through each operation. Repeated ticks should demonstrate
registration reuse. A failed damage tick should restore previous Health and
discard staged events if public failure is available.

First impressions before query/provider publication:

- The ownership model is understandable: a projection restores its component
  owner beside a duplicable view, avoiding copying the owned component.
- Schema provisioning requires explicit closed take/put/project lenses and
  distinct family token types. This is considerably more boilerplate than a
  Bevy derive or a bevy-ts descriptor. It may be appropriate for the bounded
  experiment but would be a real application authoring cost.
- The visible system registry threads an affine owner and an erased runner
  index. Its access list is descriptive metadata; restricted gameplay access
  must come from the forthcoming rank-2 provider boundary.
- The visible world/component constructors are public. This assessment tests
  ordinary callback confinement, not confinement of malicious provisioning.

Expected type constraints: read handles cannot write; absent optional Armor
must be narrowed; movement cannot read Health; a handle of another schema
must not satisfy this schema's family operations; callback code must not know
the concrete world, storage, journal, provider context or entity constructors.

No application checker attempt has occurred yet. Query/provider is pending;
implementation will target the frozen public API supplied by the integrator.
No new laws or dependencies are proposed.
