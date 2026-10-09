# #46 typed construction/resource candidate — source-qualified only

Governing issue #46 and independent Spec review `9e3d5f2e`: validating an already-created P did not supply generic raw construction; the existing resource write grant did not validate its resource declaration. This candidate fills those code seams without changing the adopted 33 modules.

## API and established ownership contract

- `constructor`: retained nominal Constructed declaration + affine input projector + explicit reversible author constructor. Complete Decode admission runs **before** the constructor. Output is existing `bundle-construction.Construction<I,P,Error>`: Invalid returns exact I; Constructed returns arbitrary Type P and one `P -> I` undo. No automatic Raw-to-Type inverse or constructor truthfulness proof is claimed.
- `FallibleFactory` supports arbitrary Data constructor errors, preserving `Validation<D.Error>` versus `Constructor<Custom>` instead of flattening business errors into decoder errors. Actual opaque-H custom fixture demonstrates validation precedence and exact owner return.
- `request`: composes the constructor with the actual owned core spawn/insert request. Immediate validation/entity refusal returns the original I via the explicit undo; accepted output retains that undo for application-selected later recovery. Prepared P owners and deferred visibility use unchanged core Batch. There is no new global activation/recovery/finalizer policy.
- `resource`: retained nominal resource Constructed declaration validates arbitrary Type R before existing same-frame `F.resource_set`. Rejection returns exact R and the unchanged frame; successful replacement uses existing resource undo. Codec refusal is an operation result, not an invented automatic system failure.

Actual providers alone see the trusted frame. Gameplay bodies universally quantify H and invoke owned grants. Plain/transient declarations keep their existing save behavior; no descriptor or save policy changes.

## Concrete consuming source and full observations

`fixture` uses two nominal schemas and affine Array<U32>/Array<Bool> payloads. It covers actual construction/undo; malformed nested struct/array/nullable/literal paths; namespace-bound handle codec; validated resource success/refusal and transaction failure. Resource reports include complete World metadata/liveness/store/resource/queue count, physical owner sentinels and actual resource undo count.

`custom-fixture` exercises two schemas and arbitrary typed constructor errors versus Decode refusal, with every incoming sentinel retained.

`request-fixture` reaches the constructed spawn/insert grant, aborts the accepted batch and consumes the returned P through its single retained undo. The foreign insert uses a real handle reserved/activated in a second independently created same-schema world from the same Factory. Invalid raw input never reserves/enqueues. All request World fields supported by this Unit-store fixture are observed in Snapshot. This fixture intentionally aborts before delivery: its unused delivery callbacks are not a successful materialization implementation. The previously qualified complete15+8 core delivery consumers remain unchanged; the additive `materialization-v1/fixture` now supplies that successful source route (qualification pending).

Four intended negatives cover actual opaque-H undeclared/read-only operations, nominal schema misuse and raw affine owner duplication. Compiling skip-validator and refused-operation partial-write mutants reach the same consuming callsites; no backend kill is claimed yet. Partial-write mutates the real World clock on validation refusal, exposed by the complete Snapshot.

## Authority and archived host work

Reference pins: Rust Bevy `ad678262ce53b5d142fe49ee5e08caff6f00ab60`, Bend `a950fd683c0d76f09794078e6174fe98a1492876`, bevy-ts `3040a3b2a3f28fa8554d856f9ccb6bf5433fa334`.

| Source-backed boundary | Current candidate / explicit obligation |
| --- | --- |
| Rust `bevy_ecs/src/world/mod.rs:2038–2057`: typed `FromWorld`/resource insertion | Author-provided typed construction/provider; no unchecked host value enters World |
| Bend Type payload ownership; existing `bundle-construction.bend` reversible result | Arbitrary I/P/R Type; explicit original-owner undo/sink; no duplicating payload/project alias |
| TS `Descriptor.ts:275,403`: constructed component/resource; `293,420`: transient | Generic declaration-bound construction and resource validation; transient save semantics stay existing core |
| TS `Descriptor.ts:538–545`: decode preferred over result for untrusted save input | Retained complete Codec is the typed untrusted-input decoder; explicit constructor follows successful admission. This does not automatically implement arbitrary JS constructor-object dispatch |

The additive source implements successful raw-construction materialization. TS Standard Schema adapters and host-wire experiments were removed from active ECS work and preserved in the [classified tooling archive](../../../../docs/archive/ts-extension-index.md). Remaining acceptance includes independent complete new models, actual TS/JS/Native observations and feature-specific timing/scaling; syntax/type success alone is not acceptance. The adopted complete23 evidence is reused only for its unchanged scope. No new law/policy/dependency, broad replay or performance claim.

`source-checks.json` and `source-closure.json` retain source-current source5/CPU5/shared-lock checks and exact diagnostics. One outer-harness lock-wait timeout is preserved separately; the harness now acquires the lock before starting the unchanged five-second checker.

## Additive completion source (not backend-qualified)

- `materialization-v1/fixture`: ordinary declaration access, real Local registration and opaque-H owned grant; success uses existing deferred completion and actual `World.barrier`. Seven scenarios per schema observe full metadata, physical slots/lifecycle, every Mail owner/error, full Local recovery packets and operation output before/after delivery. Late missing delivery remains an explicit returned packet; skip retains state; abort retains accepted undo plus every returned P in Local. The app-selected Mail installer/sink is the already qualified route, not a new global recovery policy.
- `constructed-resource`: constructor→resource grant composition. Invalid construction returns I. Resource validation refusal consumes the existing explicit R→I undo. Accepted writes retain undo in the result; transaction failure uses existing `Resource.restore`, which drops the displaced replacement. No automatic abort recovery of its I is promised. `raw-resource-fixture` observes complete snapshots for success/refusal/abort in both schemas.

`source-checks-extension.json` and `source-closure-extension.json` freeze additive full entry/type authority checks without changing historical source receipts. No emitted execution, performance or mathematical law claim is made by this extension.

The additive custom-error and actual refusal consumers are frozen separately in `fallible-composition-v1`; downstream resource admission and actual custom-constructor delivery are in `completion-addon-v1`. Their full independent models remain separate from original44. No host conversion or source-only fixture is reported as generated ECS interoperability or full #46 acceptance.
