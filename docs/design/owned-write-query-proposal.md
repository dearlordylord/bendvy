# Direct owned write query — proposal, not an approved implementation

## Finding

A Bend-native write query can give a closed, universally quantified callback one
affine selected-row transaction owner containing the actual Main owner. Read/write
operations then transform that retained Main directly, rather than repeatedly
resolving a Handle through World. Return the owner once and restore the slot before
proceeding to the next entity. This fits ECS component iteration and Bend ownership;
it is a new trusted provider/transaction representation, not a storage-only patch.

Current Dense first collects handles (`candidate/measurement-bend.bend51–56`), then
calls abstract Main read/write and Ledger read/write for every handle. Main reads
and writes enter `storage.with_main`; Native Base.Array.get/swap/set each compute
array size and descend the tree. This establishes repeated source-level access
paths, not their measured cost. Generated JS uses direct flat indexing; Native
walk counts must not be presented as JS complexity or performance evidence.

## Source basis

Pinned Bevy `query/fetch.rs2505–2578` implements `QueryData for &mut T` with an item
`Mut<T>` pointing directly at the matched table/sparse-set component and its change
ticks. Its access registration requires unique mutable component access
(`fetch.rs2473`); `system/query.rs586–613` restricts reborrow lifetimes. Bevy does
not resolve an entity handle back through World for every field read inside the
query item. It uses Rust lifetimes and trusted unsafe fetches; those mechanisms
must not be copied as authority into safe Bend. Nor does ordinary Bevy mutable
iteration supply Bendvy's authored transactional rollback contract automatically.

Bend's quantities keep Main/Ledger as Type; Base.Array.get requires Data, whereas
swap threads Type owners. R-A proves finite executable provider behavior through
`@-P: Type` callbacks; R-C1 supplies a bounded owned write-query precursor. Neither
is a universal confinement proof or approval of a production API. Original sources
are read-only at `.references/bevy` and `.references/bend2`; use the tracked pins,
not branch tips. Installed compiler and pinned source remain distinct tool records.

## Proposed trusted representation

A private selected-row owner holds selected schema handle, actual affine Main,
optional declared Aux, optional affine Ledger, remaining World, inverse journal,
staged commands/events/marks, and unchanged row metadata. Public constructors
remain available: authority rests on the closed rank-2 callback quantified over
opaque Owner/Aux, not module privacy. A callback receives declared token-specific
read/write operations and must return the same abstract owner plus Data observation.

Keep the current token/opaque Owner operation signatures where possible. Trusted
operations open this private owner, read or swap retained Main/Ledger, then rebuild
it. Every successful scalar write prepends the exact existing inverse and mark at
the original operation position. Do not coalesce repeated writes or replace the
journal with one initial snapshot. A returned owner closes the selected slot once;
MainNone/membership filtering and stable ascending entity order remain unchanged.
Ledger can remain owned by the traversal for all rows, with each callback receiving
it only inside its owner; preserve the original None result when absent. This
requires a separately checked capability fixture before implementation.

## Required seams and obstacles

- **Cross-entity access:** retaining selected Main leaves a temporary empty slot.
  Same-entity lookup must resolve to the retained owner, never report a spurious
  Mismatch. Other-entity lookup/write requires an explicitly granted operation
  that threads the complete owner; it cannot receive a second World alias.
  Arbitrary existing `W -> H -> ...` callbacks cannot transparently operate on a
  World with a detached Main. Restore before invoking them, or implement a reviewed
  selected-owner-aware adapter. Both choices preserve behavior but alter cost.
- **Failure and inverse order:** restore all held Main/Ledger owners into World
  before calling existing global unwind. The inverse list still includes every
  successful Main/Ledger scalar write in reverse operation order, including prior
  rows. Failure must return owners, discard only failed staged publication and
  preserve previous successful system commits. A failure result that drops the
  opaque Owner is inadmissible. Non-scalar/destructive restoration remains a
  separate unresolved capability, not covered by current scalar inverses.
- **Deferred structure:** enqueue commands during callbacks without applying them.
  Flush only after selected owners return, at the existing authored barrier.
  Reserved IDs/high-water/liveness semantics remain distinct. Do not mutate
  membership while a traversal owns detached components.
- **Snapshots and readers:** a full World snapshot/read inside the callback must
  include current retained values and staged visibility rules. Restore before the
  existing observer or provide a checked owner-aware observer. Publish added/
  changed/removal/event positions and reader stamps only at original commit points;
  read-after-write within the callback must see the retained latest value.
- **Opaque world callbacks:** the existing transaction API abstracts W, not a
  selected-row state. A new trusted adapter must satisfy actual callback operation
  types, not replace application callbacks with an action DSL or benchmark-only
  shortcut. Operations outside selected capabilities force reintegration or a
  broader provider design. No automatic compatibility is assumed.
- **Schema/access:** keep Main/Aux/Ledger Type and schema tokens distinct. Re-run
  undeclared-access, cross-schema, write-through-read, reconstruction, duplicate
  return and escaping-owner controls against the actual provider call sites.

## Bounded implementation decision to revisit

Start with declared selected Main read/write plus Ledger read/write and deferred
staging; retain existing callbacks and authored field/effect observations. Explicitly
exclude new cross-entity capabilities initially, with a tracked follow-up, while
preserving existing general World paths for systems that require them. Establish
finite repeated write/read, repeated writes then failure, mixed Main/Ledger inverse
ordering, deferred spawn/despawn, same-entity lookup, snapshots and independent
reader traces on both schemas before calling the integrated capability complete.
If existing selected callbacks use excluded operations, they cannot be routed to
this provider until those seams are implemented.

The experiment must run equivalent authored work against bevy-ts. Do not benchmark
only the direct query while retaining extra work in the reference. Compile/runtime
limits remain5/30/120 seconds; no performance outcome, numerical threshold, law,
proof, dependency or implementation scope is approved by this proposal.
