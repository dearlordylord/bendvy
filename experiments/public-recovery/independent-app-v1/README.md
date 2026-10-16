# Independent ordinary recovery application

Authored by agent `/root/recovery52_independent_app` on branch
`parity52/independent-application`, base `d38025142`. Owned scope is only
`experiments/public-recovery/independent-app-v1/`. Application operations and
observers were authored independently of library implementation and prior
application operation bodies, scenarios, observers, and expected oracles.
No oracle is supplied here. A separate author must derive it after this source
freeze. No backend was launched by this author.

The allowed reusable material was `mixed-v1/fixture.bend` imports/declarations
before `type Args` and `Instance`/`define`/`Run`/`run` definitions, and the trusted
`heterogeneous-v1/schema.bend`. The declaration prefix and System wrappers in
`application.bend` reuse that material. The second-component declaration remains
available but the new body never invokes it. All gameplay uses canonical public
`component_replace`, resource `replace`, capture `capture_replace`, composed
ordinary declarations (`D.both`), and `System.define`/`System.run`. No Frame,
journal, inverse action, or Lens is built by gameplay.

`scenario.bend` makes exactly two calls against one schema/world:

1. Remove the present nested affine component on entity `(7,1)` with `None`,
   replace the resource, replace the capture, then return `PolicyDeclined`.
2. Reuse the returned world/owner to remove that present component again,
   replace resource/capture with distinct owners, then return success.

The trusted bootstrap directly provisions public World/Column owners to isolate
recovery from world creation/foreign provenance (covered by existing capability
evidence). Entities 1 and 2 are live; all four physical slots in both columns
are observed. The target and sibling carry different complete nested arrays and
nonzero lifecycle stamps. The second component column is an untouched sibling
owner. World clock starts at 11. The ordinary public `define` supplies registry
provisioning and the initial cursor. All literal owners are visible in source;
there are no checksums or hidden selected-element expectations.

`observe.bend` is separate from the body. Each observer returns the original
affine owner with its text. It scans every slot 0–3 in both seeded columns with
public preserving views and lifecycle access. It preserves resource, capture,
live array, complete world metadata, registrations, registry fields, output and
all typed recovery records during observation. Pending commands are empty in
this fixture and remain so; their complete empty state is represented by count
0. Published events are observed element by element. Explicit `release` calls
occur only after the corresponding full observation, and world/registry/capture
are retained between the rollback and commit calls.

## Complete observation format

`main.bend` prints `scenario.scenario()` once using `IO.print`. The string has
three lines, ordered `initial:`, `rollback:`, `commit:`. Each completed call has
`outcome`, full `output`, `world`, `owner`, and full typed `recovery` fields.
The initial line has the full defined world and owner.

Arrays preserve their entire tree shape: `L(value)` for a leaf and
`N(left,right)` for a node. Nested arrays recurse using the same grammar.
Option owners are `None` or `Some(value)`. Component rows are
`row<ID>=<option>@(<added>,<changed>);`. A component recovery record is
`record((namespace,id),(added,changed),payload);`; array records are
`Replaced(array)` or `Swapped(index,value)`, with every list ending in `[]`.
Recovery product order is first component, second component, capture, resource.
Metadata lists preserve list order. Access entries are `[name]` and terminate
with `[]`; registrations are `(id,name,access)` and terminate with `[]`.

World fields are namespace, next entity id, high water, full live array,
capacity, depth, both complete columns, full resource, all events, pending count,
all registrations, next system id, clock. Owner fields are registry namespace,
id, name, complete access list, cursor, and full capture. Output includes the
applied-removal flag and every refused incoming owner (None on this path).
Exceptional public definition/run constructors have explicit full-observation
branches and visibly different labels; none is asserted unreachable by a hole.

This records the old payload/stamp after rollback, released None records and
attempted replacement owners, monotonic world clock, registry cursor and sibling
preservation, then the genuinely committed absence and returned original owner.
These are observations to compare against an independently authored oracle,
not acceptance claims from source checking.

## Calling convention and references

A gameplay body declares `~H` and `~caps` as template arguments. The System
contract's erased `@-H`/`@-caps` indexes do not mean the body should declare
ordinary erased runtime arguments. With `-H`/`-caps`, a standalone uninstantiated
application check can pass but concrete scenario specialization rejects the
canonical template operations. The retained failure diagnostics show that
obstacle; switching the body/helpers to templates repaired only this application.

Reference priority: pinned Rust Bevy `world/entity_access/world_mut.rs` documents
`take` returning the removed component bundle and `remove` removing membership;
Bend guide governs affine ownership and template/runtime separation; pinned TS
`packages/core/src/internal/world.ts` `removeComponent` removes membership and
logs the removal. Recovery ownership and rollback are this repository's explicit
ordinary recovery opt-in, not a claim that Rust/TS automatically roll back user
systems. Reference commits were verified against `.references/sources.json`:
Bevy `ad678262ce53b5d142fe49ee5e08caff6f00ab60`, Bend
`a950fd683c0d76f09794078e6174fe98a1492876`, TS
`3040a3b2a3f28fa8554d856f9ccb6bf5433fa334`.
