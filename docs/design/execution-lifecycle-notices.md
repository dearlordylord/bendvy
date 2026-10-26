# Lifecycle notices in World administration

The coordinator selected candidate B after comparing
`execution-lifecycle-notice-candidate.md` and the independent separate-owner
candidate. The cross-judgment is retained at
`/tmp/bendvy-gh85-notice-design-judge.md`. This document records the selected
implementation contract. It does not assert that the implementation or evidence
is complete.

World owns a separate affine `Notice.Journal<S>`. Its user `events:List<E>` field
and event APIs keep their meaning. The journal contains per-channel sequence
numbers, previous/current maintenance generations, dropped-through floors and
active reader registrations. Scope carries only a reusable detached view;
Administration retains the actual journal. Reassembly ignores the returned view
and takes the authoritative journal exclusively from Administration.

The World constructor appends `lifecycle` after `clock`. Administration appends
the journal; Scope appends its view after `prior`. Root splits and query adapters
preserve the immutable view while moving actual component/resource owners.
A newly separated group captures a new snapshot after any preceding publication
barrier. Readers share snapshots; they never share one affine reader token.

Closed removed/despawned builder primitives derive capability, canonical stream
identity and SharedView/ReadOnly LifecycleAccess metadata together. Removal
capabilities and tokens carry the full nominal selected Layout origin and schema.
LifecycleAccess is a built-in snapshot access, not a physical component/resource
requirement or a caller-authored catalog entry. It remains in planner access uses
while physical schema requirements omit it. Reader registration and retirement
remain administrative operations on the actual World, outside running scopes.

Publication occurs inside the existing automatic command interpreter. A remove
of an actually present owner emits one family notice; a missing remove, refused
operation or insert/replacement emits none. Successful despawn emits one removal
notice for each actually present family and one despawn notice for the old full
entity identity. The actual arbitrary Type owners remain in their existing
structural receipts. Presence extraction never invokes a refresher or discards
an owner to inspect it. Full namespace and allocator generation admission remain
before mutation. Stale repeated despawn therefore emits no duplicate notice.
The identity DTO carries nominal S, actual namespace and complete entity-key;
it imports entity-key rather than World and provides no live-handle constructor.

Each channel starts at next sequence 1 and dropped-through floor 0. Reader
Retained starts at the floor; Future starts at next-1. Dropping a nonempty previous
generation advances the floor to its final sequence. A valid read reports
max(floor-cursor,0), clamps the cursor once, then yields the next retained row if
present. Both Item and Empty return the clamped token; refusal returns the actual
unchanged token. Unrelated families cannot increase a reader's missed count.
Every yield updates the returned token immediately, so a subsequent body or
condition error retains consumed progress in that owner's actual Local.
Registration IDs never reuse retired values and refuse exhaustion before mutation.
Namespace, active ID and selector are checked before retirement mutates the journal.

Maintenance runs exactly once after a Finished ordinary public App update, after
its selected final-deferred policy, including errors handled with Continue.
Invalid, Stopped and genuine exceptional exits do not pretend to complete an
update and do not rotate. An empty Finished update still rotates. A Finished
update with final application suppressed can rotate retained notices but never
publishes or flushes its pending commands. Bare system, group and Scope helpers
never perform maintenance themselves.

This placement follows pinned Bevy ad678262 `bevy_app/src/sub_app.rs` update then
clear_trackers, `bevy_ecs/src/world/mod.rs` clear_trackers updating removed
components, and `bevy_ecs/src/lifecycle.rs` per-component message maintenance.
Previous/current generations bound retention in completed updates, not item
count, memory bytes, channel count or active-reader count. No hard item limit is
introduced or claimed.

The journal change must migrate every actual World constructor, Administration,
command Remainder, Scope adapter and root split/join. Runtime journal/readers are
not silently added to detached serialization; GH91 owns that contract. Existing
user events and raw trusted provisioning remain explicit boundaries. Required
ordinary evidence includes unlike schemas/families, actual owner receipts,
fast/slow readers and lag, per-yield errors, conditions, refusal, retirement,
foreign/stale handles, generation reuse, deferred visibility/suppression,
invalid preservation, both parallel paths and JS/native execution. No new law or
universal runtime preservation theorem is asserted by this design.

## Constructor migration boundary

Migrate active core modules, ordinary examples and current public fixtures.
Preserve historical source cohorts under `test-fixtures/connected-performance`,
`test-fixtures/public-inspect/graph-stream-public-bridge-v1/feature-timing-v1` and
`test-fixtures/public-scopes/ordinary-v1` byte-for-byte. Their raw World hits
include pre-Clock.State representations and are not selected dependencies of the
current lifecycle consumers. Their old qualifications do not apply to this
migration. A future selected dependency requires an explicit successor rather
than changing its frozen historical source.

## Implementation checkpoint: journal and closed primitive

The current implementation appends `World.lifecycle: Notice.Journal<S>` after
`clock`; genuine creation initializes its actual namespace. World helpers and
active constructor consumers retain that owner. `State.Administration` retains
the actual journal while `State.Scope` carries detached `Notice.View<S>`. Scope
separation snapshots the journal once after prior publication; reassembly ignores
the returned view. Root splits and query adapters carry the same immutable view.

The new `Build.Lifecycle` CPS primitive supplies canonical removed-family and
despawn `Next` capabilities while preserving abstract H and Book. Its removed
capability fixes the selected full leaf origin and selector before storing a
monomorphic cap. `D.LifecycleAccess` stays in planner uses as SharedView/ReadOnly;
physical `requirement_keys` omit this framework-owned snapshot. Administrative
registration/retirement operate on the actual journal; their refusals retain the
actual reader and journal, and exhausted IDs refuse before mutation.

Command publication carries an internal remove tag and actual displaced-owner
presence fact. Only Accepted remove plus Some owner appends a removal notice.
Despawn traverses actual heterogeneous Type receipts, returns those same owners,
and appends each present family's notice followed by one old-identity despawn.
These operations use the existing publication boundary's tick. No refresher runs
while extracting presence. RootApp's post-final-policy result adapter rotates
only Finished, so Invalid/Stopped retain their state and suppressed-final Finished
does not publish its pending queues.

Qualified bounded source checks pass for the journal, World, State, access,
query, builder, command publication and RootApp modules; current filters,
history, scheduled, composition, command-capacity, ordinary execution and public
save-pending consumers also pass. The pure `notice-positive-core.bend` checks
concrete ordinary Execute.define/run specialization for two nominal schemas.
Reader schema, full-origin, stream and duplication controls reach their intended
type refusals. The genuine WorldIO driver is deliberately separate: proof-only
checking refuses its foreign-dependent effects, so this is not a driver proof
or backend success. Raw development diagnostics are retained under
`/tmp/gh85-source-window`.

This checkpoint has no new backend capture, notice behavior acceptance, native
worker evidence or full GH85 qualification. Complete independent notice models,
actual ordinary publication/read/maintenance observations, reader conditions and
errors, retention/lag/retirement/foreign-world cases, normal checks and integrated
Spec/Standards review remain required. Existing tick/filter receipts describe
their earlier source bytes; they do not qualify this later journal migration.

## Cross-partition qualification: corrected authority premise

The initial same-C primitive is source-checked but insufficient for a Unit-column
metadata reader beside the actual component writer. Its equality must not simply
be removed. `FragmentSchema<S,C,R>` carries kind/key/name entries and loses the
full selected origin; World currently carries no full-layout inventory. Neither
those entries nor a key-only journal catalog can reject a same-key/different-origin
witness. `Task.define` quantifies local C and actual WC independently.

A narrow single-family definition adapter was considered and rejected: it would
exclude ordinary mixed-capability Programs and multi-family readers. The full
target needs a general authority shape, rather than another key-only adapter or
a smaller API. No inadequate primitive has been committed or backend-qualified.

### Approved general full-World authority migration

The erasure premise above is false: S and local C do not determine actual WC.
The general repair retains WC in the closed Program and Owner authority:

```text
Build.Program(S, WC, C, R, Ops)
  = forall H B. Builder(S,WC,C,R,H,B) -> B -> B & Ops(H)
Build.Builder(S,WC,C,R,H,B)
  = forall Ops. Selection(S,WC,C,R,H,B,Ops) -> B -> B & Ops(H)
Build.Selection passes the existing local component/resource/query primitives
  plus Lifecycle(S,WC,C,R,H,B).
Family<S,WC,fullOrigin,Removed{canonicalKey}>
  derives from fullLayout/route + WC==Layout.columns(S,fullLayout)
  + Layout.grant_valid(fullLayout,route).
Lifecycle takes that canonical family witness, independently of local C.
Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,program,body>
```

The single-system `Sys.define/run` boundary fixes WC=C, matching its whole-World
scope. `Task.define` already receives actual WC/WR independently of C/R; its
retained Owner and Program must use that same WC. The full-WC proof therefore
cannot be instantiated for an unrelated World shape at definition. Root Tree.Leaf
already carries WC and will require its Owner/Program to match it. Conditions,
rebind/lifecycle helpers, metadata extraction/restoration and registry selections
must preserve WC; no generic adapter may erase it and subsequently reconstruct
an owner for a fresh WC.

The witness constructor must retain the full-layout equality and grant-valid
evidence, with origin/selector derived from that layout/route; a zero-field phantom
witness must not provide an unchecked ordinary relabeling path.
A canonical family witness proves full leaf membership through actual WC's
branded ColumnSlot representation, including P/V/refresher/key/classification.
It needs no physical extraction and no runtime type comparison. Unknown or
undeclared routes fail grant_valid or the full-WC equality; same-key different
origins fail the equality/witness type. Existing raw constructors remain trusted
setup. Fragment inventories still supply their existing descriptor validation;
no fake lifecycle Fragment is inserted, and the witness must not be derived from
their erased key/name entries alone.

Composition stays general: one Program can request any number of full-WC family
witnesses through Lifecycle and combine their Next capabilities with local
component/resource/query grants in its own Ops(H). Local can own multiple affine
readers and unrelated Type owners. Component/query primitives continue to qualify
local C; only Lifecycle uses full WC. Read-only metadata readers can thus have
C=Unit beside the actual writer's C, with no dummy lens or column ownership.
Part.uses retains SharedView/ReadOnly LifecycleAccess; physical requirements omit
it. Scope continues to own local columns and copied journal view, while the
retained Owner/Program binds the view's interpretation to the actual full World.

A bounded static scan of the active source tree (excluding the documented frozen
cohorts) finds 118 qualified Build.Program occurrences in 14 core modules;
Build.Builder occurs twice in one core module, 39 times across 30 ordinary
example files, and six times across four current fixture files. Qualified
Sys.Owner occurs 194 times in 14 core modules, 17 times in 10 example files and
42 times in eight fixture files. Task.restored has 12 uses in five core modules;
Task.detached has seven uses in four. These are textual upper bounds, not a
claim that every matched fixture is selected or every occurrence is an API.
Local unqualified builder definitions and aliases require inspection too.

The existing command owner already carries full layout/route, so its inner
Sys.Owner's WC can be `Layout.columns(S,layout)` without adding another public
Cmd.Owner parameter. Bare Execute.Application similarly fixes WC=C and need not
add a new application parameter. Root/pair registry contexts already know the
product full C. The main extra propagation is generic Sys.Owner/Program and
Task/Scope restore helpers. Where Task's WC currently occurs after its declaration
parameter, move that binder before Program rather than relying on an unbound
forward reference; update positional static arguments with the same migration.
The coordinator approved this general shape after the independent architecture
critique in `/tmp/bendvy-gh85-authority-design.md`; the broad signature migration
has not yet been implemented at this private checkpoint.

The current unindexed Meta/Local detached pair and unindexed Permit list also
erase authority. Meta should retain the complete Owner identity (including WC,
Program/body and Local type); ordinary detached/restored/rebind paths must not
retarget it. Permits are heterogeneous across owners, so the implementation must
either retain the required World/program index in an appropriate typed structure
or expose an explicitly trusted internal erasure boundary with no ordinary
unchecked reconstruction. An unindexed Data record is not sufficient evidence.

The approved first implementation uses existing erased fullLayout/route/WC
equality/grant_valid proofs directly, with sameOrigin transport when an
independently authored feature fixes its leaf origin. Do not add a relabelable
zero-field Family wrapper. Feature factories remain generic in full layout,
routes and proofs until global recipe composition. Meta retains the exact Owner
type, and heterogeneous Permit<S,WC> retains full-World authority alongside actual
unique registration-id/namespace/program validation. Ordinary prepare/invoke
callers must migrate together; standalone raw Scope/Permit invocation needs an
explicit qualified prepared carrier or a narrowly documented trusted internal
boundary, rather than declaring all existing public helpers trusted.

### Qualified invocation carrier

The ordinary prepare/invoke boundary retains an affine
`Prepared<ExactWorld,ExactOwner>`. It carries the actual owner, the permits
produced by preparation and the namespace read from that preparing World.
`ExactWorld` includes the full WC; `ExactOwner` includes WC, the closed Program,
body and Local. A metadata-only observer therefore retains full schema authority
while its physical C stays Unit.

Tree Runtime already quantifies its exact World and Owners. Preparation returns
`World & Prepared<World,Owners>`; invocation consumes that prepared carrier.
Joining two leaves combines their carriers into
`Prepared<World,Product.Owner<L,R>>`, retaining the same global World index.
The invoke boundary compares the captured preparing namespace with the immutable
Scope view before admission. A refused comparison preserves owners and emits
admission refusals without running bodies or advancing their cursors.

Permits remain heterogeneous over owners but carry S and WC. They are internal
preparation records, not standalone ordinary invocation authority. Ordinary
callers cannot reconstruct a qualified carrier from an unindexed detached Local
and copied metadata; Task.Meta is indexed by the exact Owner. Raw constructors
remain the documented trusted construction boundary. Bare Scope helpers that
assume preparation must be internal adapters, with ordinary callers migrated to
the qualified carrier in the same change.

Implementation status: the indexed Builder, Owner, Task metadata, lifecycle and
Tree compilation source entries have passed bounded source checks. The prepared
carrier migration and all ordinary consumers are still pending; this section
records the selected target, not evidence of completion.

The carrier also retains a Data provenance tree. Each leaf records its actual
preparing namespace and exact permit list; each pair preserves left/right
association. A successful join keeps this tree and the exact product owner.
A failed generic preparation returns a distinct unqualified Inventory containing
the exact product owners and their provenance tree. Inventory has no promotion
function to Prepared. Only the closed composition interpreter constructs these
inventories, preserving the owner/tree association.

Invocation success retains a carrier with the actually returned owner, its
original namespace, permits and provenance, plus completion statuses. Refusal
retains the unchanged carrier and supplied Scope. Thus a false condition, an
admission refusal and an invoked body error remain distinct: only actual body
invocation updates its owner cursor; a body error keeps the returned owner and
its writes.

### Private full-WC checkpoint evidence

This checkpoint is private, unqualified work. It is not an integration handoff
or completion of GH85. Current bounded source checks pass for Root application,
Tree composition, command/system lifecycle, lifecycle filters, the scheduled
query/command consumer, the original notice-positive core and the concrete
Prepared foreign-Scope core. The WorldIO foreign driver stops check-only solely
at its five reached foreign definitions. No backend has run for the new driver.

The independent Prepared foreign oracle was generated before any capture:
5911 bytes, SHA256
`f25af260c1ff23770d83c20ec21da32149ca339fc7b07145c161193b74d3cb17`.
It models refusal without invocation, retained affine Local/queue/cursor, then
one invocation against the correct Scope, retained body-error writes and exact
queue payload identities, both complete physical Worlds and their journals.
Positive correct-World definition and exact-owner detached restoration pass;
wrong-World definition and detached WC laundering fail at their intended WC and
Meta-owner mismatches. Source logs remain under `/tmp/gh85-source-window`.

Current caller migration remains incomplete. Historical connected-performance,
feature-timing and public-scopes/ordinary-v1 archives remain frozen. Qualified
ordinary Scope/command wrappers are wired through Tree and Root; the remaining
lower-level standalone adapter audit, all current caller migrations, full notice
reader scenarios, intended controls, backend capture and independent review gates
remain open. Existing filter/history/scheduled and event-case oracles are intact.
