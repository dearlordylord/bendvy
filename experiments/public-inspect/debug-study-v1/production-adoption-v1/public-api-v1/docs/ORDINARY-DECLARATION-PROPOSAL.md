# #56 ordinary declaration facade — source proposal

Draft for review. No proposed API below is adopted, compiled or runtime-qualified. This updates the existing #56 direction: the qualified eight experimental leaves are a foundation, not fulfillment of ordinary automatic debug.

## Normal application shape

Proposed Bend-shaped API, with schema factories composed from ordinary constructors. Gameplay does not repeat kind, ID, label or storage lenses for debug.

The ordinary schema input must also be single-source. Proposed schema construction is explicit below; `Slot.First`/`Slot.Second` are library structural paths, not caller lens callbacks. The library assigns kind-local numeric IDs from declaration order, derives kind from the constructor, uses the single declared key as default display name, and derives storage extraction/restoration from product paths.

```bend
# Arbitrary affine payload types; no debug structural adapter.
def game_schema():
  Schema.pair(
    Schema.component(~Position, "position"),
    Schema.pair(Schema.component(~Velocity, "velocity"),
                Schema.resource(~Clock, "clock")))

# Normal paths select the same schema declarations, not separately named tokens.
def position(): Schema.at(~game_schema, Slot.First{})
def velocity(): Schema.at(~game_schema, Slot.Then{Slot.First{}})
def clock(): Schema.at(~game_schema, Slot.Then{Slot.Second{}})
# Ordinary typed access declaration, used for execution and debug alike.
def movement_params():
  Params.pair(
    Query.named("moving", Query.pair(
      Query.write(position()), Query.read(velocity()))),
    Resource.read(clock()))

# move receives only the capabilities generated from movement_params.
# Its parameter type is the facade's type family for this closed declaration.
def movement():
  System.define(~movement_params, ~move, "Movement")

# Normal scheduling retains real registrations and steps; no debug graph copy.
def update():
  Schedule.define("Update", Schedule.system(movement()))

# The sole debug-specific structural instruction.
def application():
  App.define(game_schema(), update(), Debug.Enabled)
```

This is a public surface sketch, not a claim that these exact signatures exist. Actual definitions will have explicit Bend template/type arguments where inference does not supply them. The application author supplies ordinary parameter choices and the system name once. They do not supply `~metadata`, `~access`, `~name`, a parallel description record, or a debug projection of system/schedule structure. Optional owner-returning presentation `P -> P & V` is allowed only for opaque payload values; structural description never calls such a presenter to infer access.

## One declaration, three library-derived views

A canonical parameter factory retains nominal schema/category/token identity and a detached structured access spec, with closed provider/type indices. Library composition derives: (1) the exact narrow capability record supplied to the body, (2) the existing runtime provisioning requirements, (3) debug structure. Users cannot independently choose these three projections. Wrong schema/category and write-through-read are type errors at canonical constructors/body boundaries. A heterogeneous parameter product remains typed; it is not a runtime list of arbitrary affine payloads.

The same retained system declaration supplies actual `Sys.register` name/access, provider preparation and description. Registration returns the real namespace/system ID; description binds to that identity. Schedule description traverses the actual `Sch.Step` sequence and registration owners, retaining phase/barrier positions and duplicate-label identities. A retained ordinary query constructor AST records required/optional, present/absent and lifecycle clauses; it also constructs the matcher. Required row selection is not converted into missing-resource preflight. Optional access keeps its existing provisioning semantics.

For this product-schema facade, `Schema.component(~P,key)` internally determines `Column<S,P>` storage, nominal schema/path token, kind, key/default name and kind-local ID. `Schema.resource(~R,key)` determines the affine resource slot. `Schema.pair` derives left/right take/put by tuple destructuring/reconstruction; nested paths compose those library lenses. No schema author supplies a debug `cn`/`rn` projection, repeats a descriptor, or implements a parallel lens. A custom preexisting storage layout remains a trusted low-level adapter, not the canonical automatic facade. Product schema construction is a necessary new ordinary authoring seam, not a capability already delivered by current Family.define. Typed payload indices and lenses are closed/erased; only operational schema entries/access syntax are retained Data. The prototype must verify that the schema/path type family and provider specialization can actually elaborate in Bend; this is not inferred from the schematic snippet alone.

The schema inventory uses ordinary `schema-fragments` descriptors/entries for kind/key/name. Machine names and finite value declarations must be retained by the ordinary machine factory; actual current/pending/previous observations still read the real typed Slot. Names are presentation labels, not authority. No runtime reflection or cloning of arbitrary `Type` components/resources is needed.

## Existing seams and necessary changes

| Seam | Existing information | Required ordinary-facade change |
| --- | --- | --- |
| `component.bend` Family; schema-fragments Descriptor/Entry | closed storage/provider lenses, nominal schema/token, kind/key/name | canonical schema factories reuse these definitions for parameters and inventory; no debug-only storage adapter |
| `capabilities.bend`, compose/query-contract | narrow typed grants, opaque frame, selector behavior | retain the normal parameter/query syntax before erasure; construct grants and AST together |
| `system.bend` Registry | actual namespace/ID/name/access strings; erased runner | additive declaration-bound registration, with a canonical factory deriving requirements/access/description from the same parameter declaration |
| schedule-provision Plan/Provisioned | actual steps plus required component/resource/service IDs | facade constructs this plan from declaration requirements; retain returned owners/needs; do not invent Machine requirements |
| schedule Step/Schedule | actual system IDs, condition IDs, phases, barriers, affine owners | observe actual retained structure, no parallel user schedule DTO |
| inspector-declaration Declaration.bind | one resource declaration produces metadata plus actual read capability | concrete existing feasibility witness; generalize this library pattern to ordinary typed parameter composition |
| debug eight experimental leaves | pure rendering/index/lint structure and trusted generic registration adapters | reuse internally; arbitrary caller projections remain trusted low-level adapters, never the safe ordinary facade |
| App/runtime debug switch | experimental request gate only | ordinary application construction retains operational declarations; disabled requests skip descriptor expansion/index/lint/render/presentation work |

Disabled debug does not promise zero registration work, zero metadata bytes or zero allocation. Operational declarations and grants remain necessary. Enabled overhead is measured separately under the existing qualification gates; this proposal adds no approval gate. Creation-time enablement does not imply a live toggle contract.

Legacy raw `Sys.register(name, accessStrings, ~runner)` stays available. It cannot retrospectively supply complete automatic structure: two different resource/component/query declarations can share the same name/access strings, while the runner index and payload type are erased. The retained runtime record therefore is not injective with respect to structural specifications. The technical barrier is reconstruction after information loss, not implementing automatic debug for new ordinary declarations. Do not claim full legacy reflection or skip #56 as impossible.

## Source basis

All references are the pinned local checkouts from `.references/sources.json`.

- bevy-ts `packages/core/src/System.ts:712–727, 1048–1084`: normalize the ordinary access spec once and retain both `spec` and collected requirements. `internal/debug.ts:118–155, 245–274`: derive descriptions/access/placements from retained system specs and actual schedule steps. This is declaration retention, not body introspection.
- Rust Bevy `crates/bevy_ecs/src/system/system_param.rs:258–295`; `function_system.rs:575–590`: typed SystemParam initialization registers the same accesses used by actual parameter retrieval. Bend should preserve that coupling through canonical factories.
- Bend `guide/GUIDE.md:205,259–277,342–347`: erased indices disappear, closed templates specialize at compile time, and definitions can return Type. These support typed parameter composition; they do not prove this proposed facade compiles.
- Adopted `src/ecs/inspector-declaration.bend:9–22` is an actual one-declaration-to-metadata-and-grant source witness. Current `system.bend:9–32`, `schedule-provision.bend:5–18`, `schedule.bend:7–19`, and `schema-fragments.bend` delimit the information already retained.

## Qualification and remaining full #56 obligations

Root owns every production source change. First implement a minimal canonical schema + component/resource/query parameter product and ordinary system/schedule/application facade, then affected five-second source checks. Fresh matched positives and refusals must cover undeclared access, cross-schema, wrong category, labels used as tokens, writes through read, affine duplication and opaque frame escape. Independently author a complete multi-system oracle before outputs: same declaration requirements versus grants/description, duplicate labels with real IDs, schedule placement/barriers, owner/marker/cursor preservation, enabled repeated descriptions and disabled no-description work. Fresh IO/JS/Native and reached divergence controls qualify the actual ordinary path; old experimental receipts cannot transfer acceptance. Executable delivery also retains #28; full overhead qualification remains separate under contention.

Full #56 still includes all published info/list/get/dump/description formats and population/naming, graph/machine/transient/plain observations and its dependency boundaries. Nonempty condition declarations need the same retained ordinary spec and actual Check preflight/grants; no general adopted When facade currently exists. Service/captured-owner invocation and #50/#53 policies are not chosen here. Machine provisioning must use an approved existing contract, not a fabricated SP token. These limits do not prevent implementing the independent component/resource/query/system/schedule ordinary slice, but do prevent calling it full #56.
